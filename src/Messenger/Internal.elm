module Messenger.Internal exposing
    ( WorldEvent(..)
    , InternalData(..), InternalDataObj
    , emptyInternalData, getInternalData
    )

{-|


# Internal Data

Internal engine state that should not be directly accessible to user code.

@docs WorldEvent
@docs InternalData, InternalDataObj
@docs emptyInternalData, getInternalData

-}

import Audio
import Browser.Events exposing (Visibility(..))
import Dict exposing (Dict)
import Json.Encode as Encode
import Messenger.Audio.Internal exposing (AudioRepo, emptyRepo)
import REGL
import Set exposing (Set)


{-| World Event

This is the internal event type Messenger receives from browser subscriptions
and ports before translating selected events into user-facing `UserEvent`s.

-}
type WorldEvent
    = WTick Float
    | WKeyDown Int
    | WKeyUp Int
    | NewWindowSize ( Float, Float )
    | WindowVisibility Visibility
    | SoundLoaded String (Result Audio.LoadError Audio.Source)
    | REGLRecv Encode.Value
    | WMouseDown Int ( Float, Float )
    | WMouseUp Int ( Float, Float )
    | MouseMove ( Float, Float )
    | WMouseWheel Int
    | WPrompt String String
    | WDataLoaded String String
    | NullEvent


{-| Opaque internal engine data.
-}
type InternalData
    = InternalData InternalDataObj


{-| Internal engine data object.

This stores all engine-owned global values: rendering dimensions, loaded
resources, audio state, runtime timing, input state, scene name, volume, and
loaded config data. It is intentionally hidden from package users; core modules
can unwrap `InternalData` when they need to update engine state.

-}
type alias InternalDataObj =
    { browserViewPort : ( Float, Float )
    , realWidth : Float
    , realHeight : Float
    , startLeft : Float
    , startTop : Float
    , sprites : Dict String REGL.Texture
    , loadedResNum : Int
    , totResNum : Int
    , fonts : Set String
    , programs : Set String
    , virtualWidth : Float
    , virtualHeight : Float
    , audioRepo : AudioRepo
    , configData : Dict.Dict String String
    , sceneStartTime : Float
    , globalStartTime : Float
    , globalStartFrame : Int
    , sceneStartFrame : Int
    , currentTimeStamp : Float
    , windowVisibility : Visibility
    , mousePos : ( Float, Float )
    , pressedMouseButtons : Set Int
    , pressedKeys : Set Int
    , volume : Float
    , currentScene : String
    }


{-| Empty InternalData for initialization
-}
emptyInternalData : InternalData
emptyInternalData =
    InternalData
        { browserViewPort = ( 0, 0 )
        , realHeight = 0
        , realWidth = 0
        , startLeft = 0
        , startTop = 0
        , sprites = Dict.empty
        , virtualWidth = 0
        , virtualHeight = 0
        , audioRepo = emptyRepo
        , loadedResNum = 0
        , totResNum = 0
        , fonts = Set.empty
        , programs = Set.empty
        , configData = Dict.empty
        , sceneStartTime = 0
        , globalStartTime = 0
        , globalStartFrame = 0
        , sceneStartFrame = 0
        , currentTimeStamp = 0
        , windowVisibility = Visible
        , mousePos = ( 0, 0 )
        , pressedMouseButtons = Set.empty
        , pressedKeys = Set.empty
        , volume = 1
        , currentScene = ""
        }


{-| Get the internal data object.
-}
getInternalData : InternalData -> InternalDataObj
getInternalData (InternalData internalData) =
    internalData
