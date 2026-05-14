module Messenger.Base exposing
    ( UserEvent(..)
    , GlobalData
    , InternalData
    , Env
    , Flags
    , removeCommonData, addCommonData
    , GlobalDataInit
    , getSceneStartTime, getGlobalStartTime, getGlobalStartFrame, getSceneStartFrame
    , getCurrentTimeStamp, getWindowVisibility, getMousePos
    , getPressedMouseButtons, getPressedKeys, getVolume, getCurrentScene
    , getVirtualSize, getRealSize, getViewPort, getCanvasOffset
    , getLoadingProgress, getFonts, getPrograms, getSprite, getAllSprites, getConfigData
    )

{-|


# Base Module

Some Basic Data Types for the game

@docs UserEvent
@docs GlobalData
@docs InternalData
@docs Env
@docs Flags
@docs removeCommonData, addCommonData
@docs GlobalDataInit


## Internal Data Getters

Safe access to internal engine state

@docs getSceneStartTime, getGlobalStartTime, getGlobalStartFrame, getSceneStartFrame
@docs getCurrentTimeStamp, getWindowVisibility, getMousePos
@docs getPressedMouseButtons, getPressedKeys, getVolume, getCurrentScene
@docs getVirtualSize, getRealSize, getViewPort, getCanvasOffset
@docs getLoadingProgress, getFonts, getPrograms, getSprite, getAllSprites, getConfigData

-}

import Browser.Events exposing (Visibility(..))
import Dict exposing (Dict)
import Html exposing (Html)
import Messenger.Internal as Internal
import Messenger.Internal exposing (WorldEvent)
import REGL
import REGL.Common exposing (Camera)
import Set exposing (Set)


{-| Opaque internal engine data.
-}
type alias InternalData =
    Internal.InternalData


{-| User Event

This is the User Event for the game.

Users can get outside information through these events.

`Tick` is triggered every timeInterval. The int attacked to it is

`KeyDown`, `KeyUp` records the keyboard events.
"KeyDown" event is sent when the key is pressed, "KeyUp" is sent when the key is released.

  - Note: if you just want to check if a key is pressed or not, use `getPressedKeys globalData` instead.
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

GlobalData is the user-facing global state.

It won't be reset if you change the scene.

It is mainly used for display and reading/writing some localstorage data.
Runtime values like time, input state, scene name, and volume are read-only;
use the getter functions below to read them.

  - `userdata` records the data that users set to save
  - `extraHTML` is used to render extra HTML tags. Be careful to use this
  - `canvasAttributes` is used to attach attributes to the game canvas
  - `camera` records the camera position and zoom level
  - `internalData` stores opaque engine-owned data; use getters instead of editing it

-}
type alias GlobalData userdata =
    { internalData : InternalData
    , extraHTML : Maybe (Html WorldEvent)
    , canvasAttributes : List (Html.Attribute WorldEvent)
    , userData : userdata
    , camera : Camera
    }


{-| This type is for user to use when initializing the messenger.
It is very useful when dealing with local storage.
-}
type alias GlobalDataInit userdata =
    { camera : Camera
    , volume : Float
    , extraHTML : Maybe (Html WorldEvent)
    , canvasAttributes : List (Html.Attribute WorldEvent)
    , userData : userdata
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


{-| Get elapsed time since the current scene started.
-}
getSceneStartTime : GlobalData userdata -> Float
getSceneStartTime globalData =
    (Internal.getInternalData globalData.internalData).sceneStartTime


{-| Get elapsed time since the game started.
-}
getGlobalStartTime : GlobalData userdata -> Float
getGlobalStartTime globalData =
    (Internal.getInternalData globalData.internalData).globalStartTime


{-| Get the frame count since the game started.
-}
getGlobalStartFrame : GlobalData userdata -> Int
getGlobalStartFrame globalData =
    (Internal.getInternalData globalData.internalData).globalStartFrame


{-| Get the frame count since the current scene started.
-}
getSceneStartFrame : GlobalData userdata -> Int
getSceneStartFrame globalData =
    (Internal.getInternalData globalData.internalData).sceneStartFrame


{-| Get the current timestamp.
-}
getCurrentTimeStamp : GlobalData userdata -> Float
getCurrentTimeStamp globalData =
    (Internal.getInternalData globalData.internalData).currentTimeStamp


{-| Get the current browser visibility.
-}
getWindowVisibility : GlobalData userdata -> Visibility
getWindowVisibility globalData =
    (Internal.getInternalData globalData.internalData).windowVisibility


{-| Get the mouse position in virtual coordinates.
-}
getMousePos : GlobalData userdata -> ( Float, Float )
getMousePos globalData =
    (Internal.getInternalData globalData.internalData).mousePos


{-| Get the pressed mouse buttons.
-}
getPressedMouseButtons : GlobalData userdata -> Set Int
getPressedMouseButtons globalData =
    (Internal.getInternalData globalData.internalData).pressedMouseButtons


{-| Get the pressed keys.
-}
getPressedKeys : GlobalData userdata -> Set Int
getPressedKeys globalData =
    (Internal.getInternalData globalData.internalData).pressedKeys


{-| Get the current volume.
-}
getVolume : GlobalData userdata -> Float
getVolume globalData =
    (Internal.getInternalData globalData.internalData).volume


{-| Get the current scene name.
-}
getCurrentScene : GlobalData userdata -> String
getCurrentScene globalData =
    (Internal.getInternalData globalData.internalData).currentScene


{-| Get virtual coordinate dimensions
-}
getVirtualSize : GlobalData userdata -> ( Float, Float )
getVirtualSize globalData =
    let
        internalData =
            Internal.getInternalData globalData.internalData
    in
    ( internalData.virtualWidth, internalData.virtualHeight )


{-| Get real canvas dimensions
-}
getRealSize : GlobalData userdata -> ( Float, Float )
getRealSize globalData =
    let
        internalData =
            Internal.getInternalData globalData.internalData
    in
    ( internalData.realWidth, internalData.realHeight )


{-| Get browser viewport dimensions
-}
getViewPort : GlobalData userdata -> ( Float, Float )
getViewPort globalData =
    (Internal.getInternalData globalData.internalData).browserViewPort


{-| Get canvas positioning offset
-}
getCanvasOffset : GlobalData userdata -> ( Float, Float )
getCanvasOffset globalData =
    let
        internalData =
            Internal.getInternalData globalData.internalData
    in
    ( internalData.startLeft, internalData.startTop )


{-| Get resource loading progress (loaded, total)
-}
getLoadingProgress : GlobalData userdata -> ( Int, Int )
getLoadingProgress globalData =
    let
        internalData =
            Internal.getInternalData globalData.internalData
    in
    ( internalData.loadedResNum, internalData.totResNum )


{-| Get set of loaded font names
-}
getFonts : GlobalData userdata -> Set String
getFonts globalData =
    (Internal.getInternalData globalData.internalData).fonts


{-| Get set of loaded shader program names
-}
getPrograms : GlobalData userdata -> Set String
getPrograms globalData =
    (Internal.getInternalData globalData.internalData).programs


{-| Get a specific sprite texture by name
-}
getSprite : String -> GlobalData userdata -> Maybe REGL.Texture
getSprite name globalData =
    Dict.get name (Internal.getInternalData globalData.internalData).sprites


{-| Get all loaded sprite textures
-}
getAllSprites : GlobalData userdata -> Dict String REGL.Texture
getAllSprites globalData =
    (Internal.getInternalData globalData.internalData).sprites


{-| Get loaded config data by key.
-}
getConfigData : String -> GlobalData userdata -> Maybe String
getConfigData key globalData =
    Dict.get key (Internal.getInternalData globalData.internalData).configData
