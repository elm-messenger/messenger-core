module Messenger.Base exposing
    ( WorldEvent(..)
    , UserEvent(..)
    , GlobalData
    , Env
    , Flags
    , removeCommonData, addCommonData
    , UserViewGlobalData
    , userGlobalDataToGlobalData, globalDataToUserGlobalData
    , getVirtualSize, getRealSize, getViewPort, getCanvasOffset
    , getLoadingProgress, getFonts, getPrograms, getSprite, getAllSprites
    )

{-|


# Base Module

Some Basic Data Types for the game

@docs WorldEvent
@docs UserEvent
@docs GlobalData
@docs Env
@docs Flags
@docs removeCommonData, addCommonData
@docs UserViewGlobalData
@docs userGlobalDataToGlobalData, globalDataToUserGlobalData


## Internal Data Getters

Safe access to internal engine state

@docs getVirtualSize, getRealSize, getViewPort, getCanvasOffset
@docs getLoadingProgress, getFonts, getPrograms, getSprite, getAllSprites

-}

import Audio
import Browser.Events exposing (Visibility(..))
import Dict exposing (Dict)
import Html exposing (Html)
import Json.Encode as Encode
import Messenger.Internal as Internal exposing (InternalData)
import REGL
import REGL.Common exposing (Camera)
import Set exposing (Set)


{-| World Event

This is the World Event for the game.

The events that messenger will receive from outside

Basically users don't need to deal with the world events, they work with user events instead.

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
    | NullEvent


{-| User Event

This is the User Event for the game.

Users can get outside information through these events.

`Tick` is triggered every timeInterval. The int attacked to it is

`KeyDown`, `KeyUp` records the keyboard events.
"KeyDown" event is sent when the key is pressed, "KeyUp" is sent when the key is released.

  - Note: if you just want to check if a key is pressed or not, use globalData.pressedKeys instead.
    check all the keycodes [here](https://www.toptal.com/developers/keycode).

`MouseDown`, `MouseUp` records the button code and position when mouse up and down.
Mouse code 0 represents the left mouse button, 1 represents middle mouse button and 2 represents
right mouse button.

We have provide some key and mouse codes in messenger-extra.

`MouseWheel` records the wheel event for mouse, positive value means scrolling down while
negative value means scrolling up. It can be also used for touchpad.

`Prompt name result` gives the result user entered in the prompt window.

-}
type UserEvent
    = Tick Float
    | KeyDown Int
    | KeyUp Int
    | MouseDown Int ( Float, Float )
    | MouseUp Int ( Float, Float )
    | MouseWheel Int
    | Prompt String String


{-| GlobalData

GlobalData is the data that doesn't change during the game.

It won't be reset if you change the scene.

It is mainly used for display and reading/writing some localstorage data.

  - `globalStartFrame` records the past frames number since the game started
  - `globalStartTime` records the past time since the game started, in milliseconds
  - `sceneStartFrame` records the past frames number since this scene started
  - `sceneStartTime` records the past time since this scene started, in milliseconds
  - `userdata` records the data that users set to save
  - `extraHTML` is used to render extra HTML tags. Be careful to use this
  - `windowVisibility` records whether users stay in this tab/window
  - `pressedKeys` records the keycodes that are be pressed now
  - `pressedMouseButtons` records the mouse buttons that are pressed now
  - `volume` records the volume of the game
  - `currentScene` records the current scene name
  - `mousePos` records the mouse position, in virtual coordinate
  - `camera` records the camera position and zoom level

-}
type alias GlobalData userdata =
    { internalData : InternalData
    , sceneStartTime : Float
    , globalStartTime : Float
    , globalStartFrame : Int
    , sceneStartFrame : Int
    , currentTimeStamp : Float
    , windowVisibility : Visibility
    , mousePos : ( Float, Float )
    , pressedMouseButtons : Set Int
    , pressedKeys : Set Int
    , extraHTML : Maybe (Html WorldEvent)
    , canvasAttributes : List (Html.Attribute WorldEvent)
    , volume : Float
    , userData : userdata
    , currentScene : String
    , camera : Camera
    }


{-| This type is for user to use when initializing the messenger.
It is very useful when dealing with local storage.
-}
type alias UserViewGlobalData userdata =
    { sceneStartTime : Float
    , globalStartTime : Float
    , sceneStartFrame : Int
    , globalStartFrame : Int
    , camera : Camera
    , volume : Float
    , extraHTML : Maybe (Html WorldEvent)
    , canvasAttributes : List (Html.Attribute WorldEvent)
    , userData : userdata
    }




{-| Turn UserViewGlobalData into GlobalData
-}
userGlobalDataToGlobalData : UserViewGlobalData userdata -> GlobalData userdata
userGlobalDataToGlobalData user =
    { internalData = Internal.emptyInternalData
    , currentTimeStamp = 0
    , sceneStartTime = user.sceneStartTime
    , globalStartTime = user.globalStartTime
    , sceneStartFrame = user.sceneStartFrame
    , globalStartFrame = user.globalStartFrame
    , volume = user.volume
    , windowVisibility = Visible
    , pressedKeys = Set.empty
    , pressedMouseButtons = Set.empty
    , canvasAttributes = user.canvasAttributes
    , mousePos = ( 0, 0 )
    , extraHTML = user.extraHTML
    , userData = user.userData
    , currentScene = ""
    , camera = user.camera
    }


{-| Turn GlobalData into UserViewGlobalData
-}
globalDataToUserGlobalData : GlobalData userdata -> UserViewGlobalData userdata
globalDataToUserGlobalData globalData =
    { sceneStartTime = globalData.sceneStartTime
    , globalStartTime = globalData.globalStartTime
    , sceneStartFrame = globalData.sceneStartFrame
    , globalStartFrame = globalData.globalStartFrame
    , volume = globalData.volume
    , extraHTML = globalData.extraHTML
    , canvasAttributes = globalData.canvasAttributes
    , userData = globalData.userData
    , camera = globalData.camera
    }


{-| Environment

Environment is provided to users almost all the time.

It stores GlobalData and CommonData (Similar to GlobalData but just for one scene),
so you can get and modify them through the Env.

-}
type alias Env common userdata =
    { globalData : GlobalData userdata
    , commonData : common
    }


{-| Remove common data from environment.

Useful when dealing with portable components by yourself.

Most of the time it will not be used since it has been built into prepared update functions.

-}
removeCommonData : Env cdata userdata -> Env () userdata
removeCommonData env =
    { globalData = env.globalData
    , commonData = ()
    }


{-| Add the common data to a Environment without common data.
-}
addCommonData : cdata -> Env () userdata -> Env cdata userdata
addCommonData commonData env =
    { globalData = env.globalData
    , commonData = commonData
    }


{-| The main flags.

Get info from js script.

**Learn more about flags [here](https://guide.elm-lang.org/interop/flags)**

-}
type alias Flags =
    { timeStamp : Float
    , info : String
    }



-- INTERNAL DATA GETTERS


{-| Get virtual coordinate dimensions
-}
getVirtualSize : GlobalData userdata -> ( Float, Float )
getVirtualSize globalData =
    ( globalData.internalData.virtualWidth, globalData.internalData.virtualHeight )


{-| Get real canvas dimensions
-}
getRealSize : GlobalData userdata -> ( Float, Float )
getRealSize globalData =
    ( globalData.internalData.realWidth, globalData.internalData.realHeight )


{-| Get browser viewport dimensions
-}
getViewPort : GlobalData userdata -> ( Float, Float )
getViewPort globalData =
    globalData.internalData.browserViewPort


{-| Get canvas positioning offset
-}
getCanvasOffset : GlobalData userdata -> ( Float, Float )
getCanvasOffset globalData =
    ( globalData.internalData.startLeft, globalData.internalData.startTop )


{-| Get resource loading progress (loaded, total)
-}
getLoadingProgress : GlobalData userdata -> ( Int, Int )
getLoadingProgress globalData =
    ( globalData.internalData.loadedResNum, globalData.internalData.totResNum )


{-| Get set of loaded font names
-}
getFonts : GlobalData userdata -> Set String
getFonts globalData =
    globalData.internalData.fonts


{-| Get set of loaded shader program names
-}
getPrograms : GlobalData userdata -> Set String
getPrograms globalData =
    globalData.internalData.programs


{-| Get a specific sprite texture by name
-}
getSprite : String -> GlobalData userdata -> Maybe REGL.Texture
getSprite name globalData =
    Dict.get name globalData.internalData.sprites


{-| Get all loaded sprite textures
-}
getAllSprites : GlobalData userdata -> Dict String REGL.Texture
getAllSprites globalData =
    globalData.internalData.sprites
