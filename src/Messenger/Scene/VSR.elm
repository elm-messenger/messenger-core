module Messenger.Scene.VSR exposing
    ( VSR
    , updateVSR, viewVSR
    )

{-|


# Virtual Scene Runner

Run a scene as data inside another object, usually a global component. This is
used by transitions and stacked scenes where the previous scene must continue to
render or update while another scene is active.

@docs VSR
@docs updateVSR, viewVSR

-}

import Messenger.Base exposing (Env, Runtime, UserEvent(..))
import Messenger.Internal as Internal
import Messenger.Scene.Scene exposing (MAbstractScene, SceneOutputMsg, unroll)
import REGL.Common exposing (Renderable)


{-| Virtual scene runner state.

It stores the virtual scene's environment and the abstract scene value.

-}
type alias VSR userdata scenemsg =
    { env : Env () userdata
    , runtime : Runtime
    , scene : MAbstractScene userdata scenemsg
    }


{-| Update the virtual scene runner with a user event.

`Tick` also advances the virtual scene's internal time counters, mirroring how
the main Messenger model updates scene time.

-}
updateVSR : VSR userdata scenemsg -> UserEvent -> ( VSR userdata scenemsg, List (SceneOutputMsg scenemsg userdata) )
updateVSR vsr evnt =
    let
        env =
            vsr.env

        runtime1 =
            case evnt of
                Tick delta ->
                    let
                        internalData =
                            Internal.getInternalData vsr.runtime
                    in
                    Internal.InternalData
                        { internalData
                            | sceneStartFrame = internalData.sceneStartFrame + 1
                            , sceneStartTime = internalData.sceneStartTime + delta
                            , globalStartTime = internalData.globalStartTime + delta
                            , globalStartFrame = internalData.globalStartFrame + 1
                        }

                _ ->
                    vsr.runtime

        ( newScene, newMsg, newEnv ) =
            (unroll vsr.scene).update runtime1 env evnt
    in
    ( VSR newEnv runtime1 newScene, newMsg )


{-| Render the virtual scene.
-}
viewVSR : VSR userdata scenemsg -> Renderable
viewVSR vsr =
    (unroll vsr.scene).view vsr.runtime vsr.env
