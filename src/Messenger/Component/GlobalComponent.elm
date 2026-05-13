module Messenger.Component.GlobalComponent exposing
    ( genGlobalComponent
    , filterAliveGC
    , combinePP
    )

{-|


# Global Component

Global components are Messenger objects that live outside the current scene.
They receive user events before the scene, can emit scene output messages, and
can add post-processing effects to the rendered scene. Typical examples are FPS
overlays, transitions, loading screens, and global UI.

@docs genGlobalComponent
@docs filterAliveGC
@docs combinePP

-}

import Messenger.GeneralModel as GM
import Messenger.Scene.Scene exposing (AbstractGlobalComponent, ConcreteGlobalComponent, GCBaseData, GCCommonData, GCMsg, GCTarget, GlobalComponentStorage, MConcreteGeneralModel)
import REGL.Common exposing (Renderable)


{-| Generate an abstract global component from a concrete global component.

The second argument is the initialization message (`GCMsg`). The optional target
overrides the component's default `id`, which is useful when loading multiple
instances of the same global component type.

-}
genGlobalComponent : ConcreteGlobalComponent data userdata scenemsg -> GCMsg -> Maybe GCTarget -> GlobalComponentStorage userdata scenemsg
genGlobalComponent conpcomp gcmsg gctar =
    GM.abstract (gcTransform conpcomp gctar) <| gcmsg


{-| Turn global component into a general model.
-}
gcTransform : ConcreteGlobalComponent data userdata scenemsg -> Maybe GCTarget -> MConcreteGeneralModel data (GCCommonData userdata scenemsg) userdata GCTarget GCMsg GCBaseData scenemsg
gcTransform concomp gctar =
    let
        id =
            case gctar of
                Just t ->
                    t

                Nothing ->
                    concomp.id
    in
    { init = \env msg -> concomp.init env msg
    , update =
        \env evt data bdata ->
            let
                ( resData, resMsg, resEnv ) =
                    concomp.update env evt data bdata
            in
            ( resData, resMsg, resEnv )
    , updaterec =
        \env msg data bdata ->
            let
                ( resData, resMsg, resEnv ) =
                    concomp.updaterec env msg data bdata
            in
            ( resData, resMsg, resEnv )
    , view = \env data bdata -> concomp.view env data bdata
    , matcher = \_ _ tar -> tar == id
    }


{-| Filter out dead global components.

Global components mark themselves as dead by setting `baseData.dead` to `True`.
Messenger calls this helper each update so dead components stop receiving events
and stop rendering.

-}
filterAliveGC : List (AbstractGlobalComponent userdata scenemsg) -> List (AbstractGlobalComponent userdata scenemsg)
filterAliveGC xs =
    List.filter (\x -> not (GM.unroll x).baseData.dead) xs


{-| Collect post processors from all global components.

The returned list is applied to the scene renderable in order. Global components
that do not need post-processing should keep `postProcessor = identity`.

-}
combinePP : List (AbstractGlobalComponent userdata scenemsg) -> List (Renderable -> Renderable)
combinePP xs =
    List.map (\gc -> (GM.unroll gc).baseData.postProcessor) xs
