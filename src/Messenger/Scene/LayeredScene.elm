module Messenger.Scene.LayeredScene exposing
    ( LayeredSceneData
    , genLayeredScene
    , LayeredSceneInit, LayeredSceneEffectFunc
    , LayeredSceneProtoInit, LayeredSceneLevelInit, initCompose
    )

{-|


# Layered Scene

Layered scene is a pre-defined scene implementation provided by Messenger.
A layered scene stores scene common data plus a list of layers. All layers in
the list share the same common-data, target, message, user-data, and scene-message
types.

@docs LayeredSceneData
@docs genLayeredScene
@docs LayeredSceneInit, LayeredSceneEffectFunc


## Scene Prototype

@docs LayeredSceneProtoInit, LayeredSceneLevelInit, initCompose

-}

import Messenger.Base exposing (Env, UserEvent, addCommonData, removeCommonData)
import Messenger.GeneralModel exposing (MsgBase(..), filterSOM, viewModelList)
import Messenger.Layer.Layer exposing (AbstractLayer)
import Messenger.Recursion exposing (updateObjects)
import Messenger.Scene.Scene exposing (SceneOutputMsg, SceneStorage, abstract)
import REGL.Common exposing (Effect, Renderable, group)


{-| Layered scene data.

  - `renderSettings` is passed to `REGL.Common.group` when viewing all layers.
  - `commonData` is shared by all layers in the scene.
  - `layers` stores the scene's abstract layers.

Here is an example for it:

    { renderSettings = []
    , commonData = cd
    , layers =
        [ Main.layer (MainInitData { components = comps, fakeBricks = fakes, isBoss = isBoss }) envcd
        , TechTree.layer NullLayerMsg envcd
        , TextLayer.layer (TextInitData levelName) envcd
        , PauseLayer.layer NullLayerMsg envcd
        , Guide.layer NullLayerMsg envcd
        ]
    }

-}
type alias LayeredSceneData cdata userdata tar msg scenemsg =
    { renderSettings : List Effect
    , commonData : cdata
    , layers : List (AbstractLayer cdata userdata tar msg scenemsg)
    }


updateLayeredScene : (Env () userdata -> UserEvent -> LayeredSceneData cdata userdata tar msg scenemsg -> List Effect) -> Env () userdata -> UserEvent -> LayeredSceneData cdata userdata tar msg scenemsg -> ( LayeredSceneData cdata userdata tar msg scenemsg, List (SceneOutputMsg scenemsg userdata), Env () userdata )
updateLayeredScene settingsFunc env evt lsd =
    let
        ( newLayers, newMsgs, ( newEnv, _ ) ) =
            updateObjects (addCommonData lsd.commonData env) evt lsd.layers

        som =
            filterSOM newMsgs
    in
    ( { renderSettings = settingsFunc env evt lsd, commonData = newEnv.commonData, layers = newLayers }, som, removeCommonData newEnv )


viewLayeredScene : Env () userdata -> LayeredSceneData cdata userdata tar msg scenemsg -> Renderable
viewLayeredScene env { renderSettings, commonData, layers } =
    viewModelList (addCommonData commonData env) layers
        |> group renderSettings


{-| Init type for normal (not prototype) layered scenes.

It receives the environment and optional scene message, then returns the initial
`LayeredSceneData`.

       { renderSettings = []
        , commonData = cd
        , layers =
            [ Opening.layer NullLayerMsg envcd ]
        }

-}
type alias LayeredSceneInit cdata userdata tar msg scenemsg =
    Env () userdata -> Maybe scenemsg -> LayeredSceneData cdata userdata tar msg scenemsg


{-| Level init type for layered scene prototypes.

This converts a normal scene message into prototype initialization data.

-}
type alias LayeredSceneLevelInit userdata scenemsg idata =
    Env () userdata -> Maybe scenemsg -> Maybe idata


{-| Prototype init type for layered scene prototypes.

It receives the environment and prototype initialization data, then returns
`LayeredSceneData`.

-}
type alias LayeredSceneProtoInit cdata userdata tar msg scenemsg idata =
    Env () userdata -> Maybe idata -> LayeredSceneData cdata userdata tar msg scenemsg


{-| Effect function type for layered scenes.

It runs during scene update and returns render effects used when all layers are
grouped.

-}
type alias LayeredSceneEffectFunc cdata userdata tar msg scenemsg =
    Env () userdata -> UserEvent -> LayeredSceneData cdata userdata tar msg scenemsg -> List Effect


{-| Generate scene storage for a layered scene.

  - `init` creates the initial layered scene data.

  - `settingsFunc` updates `renderSettings` each time the scene updates. If you
    do not need dynamic effects, provide `\_ _ data -> data.renderSettings`.

-}
genLayeredScene : LayeredSceneInit cdata userdata tar msg scenemsg -> LayeredSceneEffectFunc cdata userdata tar msg scenemsg -> SceneStorage userdata scenemsg
genLayeredScene init settingsFunc =
    abstract
        { init = init
        , update = updateLayeredScene settingsFunc
        , view = viewLayeredScene
        }


{-| Compose prototype init with level init.
-}
initCompose : LayeredSceneProtoInit cdata userdata tar msg scenemsg idata -> LayeredSceneLevelInit userdata scenemsg idata -> LayeredSceneInit cdata userdata tar msg scenemsg
initCompose pinit linit env msg =
    pinit env <| linit env msg
