module Messenger.Scene.Scene exposing
    ( AbstractScene(..)
    , MConcreteScene, MAbstractScene
    , unroll, abstract
    , SceneOutputMsg(..)
    , SceneStorage, AllScenes
    , MMsg, MMsgBase
    , MConcreteGeneralModel, MAbstractGeneralModel
    , updateResultRemap
    , GCCommonData, GCBaseData, GCMsg, GCTarget
    , AbstractGlobalComponent, ConcreteGlobalComponent
    , GlobalComponentInit, GlobalComponentUpdate, GlobalComponentUpdateRec, GlobalComponentView
    , GlobalComponentStorage
    )

{-|


# Scene Base

Core scene types and message types.

Most projects use the type aliases from `Messenger.Scene.RawScene` or
`Messenger.Scene.LayeredScene`. This module is the lower-level foundation they
build on.

@docs AbstractScene
@docs MConcreteScene, MAbstractScene
@docs unroll, abstract
@docs SceneOutputMsg
@docs SceneStorage, AllScenes
@docs MMsg, MMsgBase
@docs MConcreteGeneralModel, MAbstractGeneralModel


## Scene Result Remapper

@docs updateResultRemap


## Global Component

@docs GCCommonData, GCBaseData, GCMsg, GCTarget
@docs AbstractGlobalComponent, ConcreteGlobalComponent
@docs GlobalComponentInit, GlobalComponentUpdate, GlobalComponentUpdateRec, GlobalComponentView
@docs GlobalComponentStorage

-}

import Audio exposing (Audio)
import Dict
import Json.Decode
import Messenger.Audio.Base exposing (AudioOption, AudioTarget)
import Messenger.Base exposing (Env, UserEvent)
import Messenger.GeneralModel exposing (AbstractGeneralModel, ConcreteGeneralModel, Msg, MsgBase)
import Messenger.Resources.Base exposing (ResourceDef)
import REGL
import REGL.Common exposing (Renderable)


{-| Concrete scene model.

This is the record shape implemented by raw scenes and layered scenes before
they are abstracted into `SceneStorage`.

  - `init` creates scene data from the environment and an optional scene message.
  - `update` handles a user event and may emit `SceneOutputMsg`s.
  - `view` renders the scene from its environment and data.

-}
type alias ConcreteScene data env event ren scenemsg userdata =
    { init : env -> Maybe scenemsg -> data
    , update : env -> event -> data -> ( data, List (SceneOutputMsg scenemsg userdata), env )
    , view : env -> data -> ren
    }


{-| Unrolled abstract scene model.

An `AbstractScene` hides the concrete data type. `unroll` exposes only the
operations Messenger needs after initialization: update and view.

-}
type alias UnrolledAbstractScene env event ren scenemsg userdata =
    { update : env -> event -> ( AbstractScene env event ren scenemsg userdata, List (SceneOutputMsg scenemsg userdata), env )
    , view : env -> ren
    }


{-| Rolled abstract scene model.

This hides the concrete scene data type so scenes with different data can be
stored in the same scene map.

-}
type AbstractScene env event ren scenemsg userdata
    = Roll (UnrolledAbstractScene env event ren scenemsg userdata)


{-| Specialized concrete scene for Messenger.
-}
type alias MConcreteScene data userdata scenemsg =
    ConcreteScene data (Env () userdata) UserEvent Renderable scenemsg userdata


{-| Specialized abstract scene for Messenger.
-}
type alias MAbstractScene userdata scenemsg =
    AbstractScene (Env () userdata) UserEvent Renderable scenemsg userdata


{-| Unroll an abstract scene.

This is useful when advanced code needs to manually update or view an abstract
scene, for example in `Messenger.Scene.VSR`.

-}
unroll : AbstractScene env event ren scenemsg userdata -> UnrolledAbstractScene env event ren scenemsg userdata
unroll (Roll un) =
    un


{-| Abstract a concrete scene.

The concrete scene is initialized immediately with the given message and
environment. The resulting `AbstractScene` stores its data privately.

-}
abstract : ConcreteScene data env event ren scenemsg userdata -> Maybe scenemsg -> env -> AbstractScene env event ren scenemsg userdata
abstract conmodel initMsg initEnv =
    let
        abstractRec data =
            let
                updates : env -> event -> ( AbstractScene env event ren scenemsg userdata, List (SceneOutputMsg scenemsg userdata), env )
                updates env event =
                    let
                        ( new_d, new_m, new_e ) =
                            conmodel.update env event data
                    in
                    ( abstractRec new_d, new_m, new_e )

                views : env -> ren
                views env =
                    conmodel.view env data
            in
            Roll
                { update = updates
                , view = views
                }
    in
    abstractRec (conmodel.init initEnv initMsg)


{-| Scene output messages handled by Messenger core.

Scenes, layers, components, and global components emit these messages when they
need top-level effects such as changing scenes, playing audio, loading
resources, saving global data, or managing global components.

  - `SOMChangeScene initMsg name` changes to a scene by name.
  - `SOMAlert text` sends an alert command through user ports.
  - `SOMPrompt name title` sends a prompt command. The result comes back as a
    `Prompt name result` user event.
  - `SOMPlayAudio channel name option` plays a loaded audio resource.
  - `SOMStopAudio target` stops matching playing audio.
  - `SOMTransformAudio target transform` applies an `elm-audio` transform.
  - `SOMSetVolume volume` changes the global volume.
  - `SOMSaveGlobalData` calls `globalDataCodec.encode`.
  - `SOMLoadGC gc` loads a global component.
  - `SOMUnloadGC target` unloads matching global components.
  - `SOMCallGC ( target, msg )` sends a message to a global component.
  - `SOMChangeFPS interval` changes the REGL update interval.
  - `SOMLoadResource key resource` loads a resource at runtime. Loaded data is
    stored in opaque internal data and can be read through `Messenger.Base`
    getters.

-}
type SceneOutputMsg scenemsg userdata
    = SOMChangeScene (Maybe scenemsg) String
    | SOMAlert String
    | SOMPrompt String String
    | SOMPlayAudio Int String AudioOption
    | SOMStopAudio AudioTarget
    | SOMTransformAudio AudioTarget (Audio -> Audio)
    | SOMSetVolume Float
    | SOMSaveGlobalData
    | SOMLoadGC (GlobalComponentStorage userdata scenemsg)
    | SOMUnloadGC GCTarget
    | SOMCallGC ( GCTarget, GCMsg )
    | SOMChangeFPS REGL.TimeInterval
    | SOMLoadResource String ResourceDef


{-| Scene storage.

A `SceneStorage` is what goes into the `AllScenes` dictionary. It receives an
optional scene message and the current environment, then returns an initialized
abstract scene.

-}
type alias SceneStorage userdata scenemsg =
    Maybe scenemsg -> Env () userdata -> MAbstractScene userdata scenemsg


{-| A dictionary of scene names to scene storage.
-}
type alias AllScenes userdata scenemsg =
    Dict.Dict String (SceneStorage userdata scenemsg)


{-| Messenger message base.

This specializes `Messenger.GeneralModel.MsgBase` with `SceneOutputMsg` as the
parent/system message type.

-}
type alias MMsgBase othermsg scenemsg userdata =
    MsgBase othermsg (SceneOutputMsg scenemsg userdata)


{-| Messenger message.

This specializes `Messenger.GeneralModel.Msg` with `SceneOutputMsg` as the
parent/system message type.

-}
type alias MMsg othertar msg scenemsg userdata =
    Msg othertar msg (SceneOutputMsg scenemsg userdata)


{-| Specialized concrete general model for Messenger scenes, layers, and components.
-}
type alias MConcreteGeneralModel data common userdata tar msg bdata scenemsg =
    ConcreteGeneralModel data (Env common userdata) UserEvent tar msg Renderable bdata (SceneOutputMsg scenemsg userdata)


{-| Specialized abstract general model for Messenger scenes, layers, and components.
-}
type alias MAbstractGeneralModel common userdata tar msg bdata scenemsg =
    AbstractGeneralModel (Env common userdata) UserEvent tar msg Renderable bdata (SceneOutputMsg scenemsg userdata)


{-| Remap the result of an abstract scene update.

Use this when wrapping a scene and transforming its emitted `SceneOutputMsg`s or
environment.

-}
updateResultRemap : (( List (SceneOutputMsg scenemsg userdata), env ) -> ( List (SceneOutputMsg scenemsg userdata), env )) -> AbstractScene env event ren scenemsg userdata -> AbstractScene env event ren scenemsg userdata
updateResultRemap f model =
    let
        change : AbstractScene env event ren scenemsg userdata -> AbstractScene env event ren scenemsg userdata
        change m =
            let
                um =
                    unroll m

                newUpdate : env -> event -> ( AbstractScene env event ren scenemsg userdata, List (SceneOutputMsg scenemsg userdata), env )
                newUpdate env evnt =
                    let
                        ( oldr, oldmsg, oldres ) =
                            um.update env evnt

                        ( newmsg, newres ) =
                            f ( oldmsg, oldres )
                    in
                    ( change oldr, newmsg, newres )
            in
            Roll { um | update = newUpdate }
    in
    change model



--- Global Component


{-| Common data passed to global components.

It is the currently running scene, so global components can render or update in
relation to the active scene when needed.

-}
type alias GCCommonData userdata scenemsg =
    MAbstractScene userdata scenemsg


{-| Base data shared by all global components.

`dead` marks a component for removal. `postProcessor` transforms the scene
renderable after the scene view is produced.

-}
type alias GCBaseData =
    { dead : Bool
    , postProcessor : Renderable -> Renderable
    }


{-| Global component message type.

JSON values are used so global components can be addressed dynamically.

-}
type alias GCMsg =
    Json.Decode.Value


{-| Global component target type.
-}
type alias GCTarget =
    String


{-| Global component init type.
-}
type alias GlobalComponentInit userdata scenemsg data =
    Env (GCCommonData userdata scenemsg) userdata -> GCMsg -> ( data, GCBaseData )


{-| Global component update type.

The returned boolean is the block flag. If it is `True`, the current user event
will not be passed to later global components or the scene.

-}
type alias GlobalComponentUpdate userdata scenemsg data =
    Env (GCCommonData userdata scenemsg) userdata -> UserEvent -> data -> GCBaseData -> ( ( data, GCBaseData ), List (MMsg GCTarget GCMsg scenemsg userdata), ( Env (GCCommonData userdata scenemsg) userdata, Bool ) )


{-| Global component recursive update type.

This handles messages sent to the global component by target.

-}
type alias GlobalComponentUpdateRec userdata scenemsg data =
    Env (GCCommonData userdata scenemsg) userdata -> GCMsg -> data -> GCBaseData -> ( ( data, GCBaseData ), List (MMsg GCTarget GCMsg scenemsg userdata), Env (GCCommonData userdata scenemsg) userdata )


{-| Global component view type.
-}
type alias GlobalComponentView userdata scenemsg data =
    Env (GCCommonData userdata scenemsg) userdata -> data -> GCBaseData -> Renderable


{-| Global component storage.

This is what gets loaded by `SOMLoadGC` or startup global component lists.

-}
type alias GlobalComponentStorage userdata scenemsg =
    Env (GCCommonData userdata scenemsg) userdata -> AbstractGlobalComponent userdata scenemsg


{-| Concrete global component model.
-}
type alias ConcreteGlobalComponent data userdata scenemsg =
    { init : GlobalComponentInit userdata scenemsg data
    , update : GlobalComponentUpdate userdata scenemsg data
    , updaterec : GlobalComponentUpdateRec userdata scenemsg data
    , view : GlobalComponentView userdata scenemsg data
    , id : GCTarget
    }


{-| Abstract global component model.

The concrete data type is hidden after initialization.

-}
type alias AbstractGlobalComponent userdata scenemsg =
    MAbstractGeneralModel (GCCommonData userdata scenemsg) userdata GCTarget GCMsg GCBaseData scenemsg
