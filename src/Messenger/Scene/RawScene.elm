module Messenger.Scene.RawScene exposing
    ( RawSceneInit, RawSceneUpdate, RawSceneView
    , genRawScene
    , RawSceneProtoInit, RawSceneProtoLevelInit, initCompose
    )

{-|


# Raw Scene

A raw scene owns all of its data directly. It has no built-in layers or
components, so it is useful for simple scenes or for custom scene structures that
do not fit Messenger's layered scene helper.

@docs RawSceneInit, RawSceneUpdate, RawSceneView
@docs genRawScene


## Scene Prototype

@docs RawSceneProtoInit, RawSceneProtoLevelInit, initCompose

-}

import Messenger.Base exposing (Env, Runtime, UserEvent)
import Messenger.Scene.Scene exposing (MConcreteScene, SceneOutputMsg, SceneStorage, abstract)
import REGL.Common exposing (Renderable)


{-| Raw scene init type.

Initialize scene data from the environment and optional scene message.

-}
type alias RawSceneInit data userdata scenemsg =
    Runtime -> Env () userdata -> Maybe scenemsg -> data


{-| Level init type for raw scene prototypes.

This converts a normal scene message into the prototype-specific initialization
data. It is commonly used by generated scene-prototype levels.

-}
type alias RawSceneProtoLevelInit userdata scenemsg idata =
    Runtime -> Env () userdata -> Maybe scenemsg -> Maybe idata


{-| Prototype init type for raw scene prototypes.

This creates scene data from prototype initialization data.

-}
type alias RawSceneProtoInit data userdata idata =
    Runtime -> Env () userdata -> Maybe idata -> data


{-| Raw scene update type.

It receives the environment, user event, and scene data, then returns updated
data, scene output messages, and the updated environment.

-}
type alias RawSceneUpdate data userdata scenemsg =
    Runtime -> Env () userdata -> UserEvent -> data -> ( data, List (SceneOutputMsg scenemsg userdata), Env () userdata )


{-| Raw scene view type.

It receives the environment and scene data and returns a renderable.

-}
type alias RawSceneView userdata data =
    Runtime -> Env () userdata -> data -> Renderable


{-| Generate scene storage from a concrete raw scene.
-}
genRawScene : MConcreteScene data userdata scenemsg -> SceneStorage userdata scenemsg
genRawScene =
    abstract


{-| Compose prototype init with level init.
-}
initCompose : RawSceneProtoInit data userdata idata -> RawSceneProtoLevelInit userdata scenemsg idata -> RawSceneInit data userdata scenemsg
initCompose pinit linit runtime env msg =
    pinit runtime env <| linit runtime env msg
