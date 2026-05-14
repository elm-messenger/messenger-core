module Messenger.Model exposing
    ( Model
    , updateSceneTime, resetSceneStartTime
    )

{-|


# Model

This is the main model data.

Those data is **not** exposed to the scene.

We only use it in the main update.

@docs Model
@docs updateSceneTime, resetSceneStartTime

-}

import Messenger.Base exposing (Env, Runtime)
import Messenger.Internal as Internal
import Messenger.Scene.Scene exposing (AbstractGlobalComponent, MAbstractScene)


{-| The model for the game
-}
type alias Model userdata scenemsg =
    { runtime : Runtime
    , env : Env (MAbstractScene userdata scenemsg) userdata
    , globalComponents : List (AbstractGlobalComponent userdata scenemsg)
    }


{-| Update scene start time and global time
-}
updateSceneTime : Model userdata scenemsg -> Float -> Model userdata scenemsg
updateSceneTime m delta =
    let
        internalData =
            Internal.getInternalData m.runtime
    in
    { m
        | runtime =
            Internal.InternalData
                { internalData
                    | sceneStartTime = internalData.sceneStartTime + delta
                    , sceneStartFrame = internalData.sceneStartFrame + 1
                }
    }


{-| Reset the scene starttime to 0.
-}
resetSceneStartTime : Model userdata scenemsg -> Model userdata scenemsg
resetSceneStartTime m =
    let
        internalData =
            Internal.getInternalData m.runtime
    in
    { m
        | runtime =
            Internal.InternalData
                { internalData
                    | sceneStartTime = 0
                    , sceneStartFrame = 0
                }
    }
