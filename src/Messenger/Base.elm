module Messenger.Base exposing
    ( UserEvent(..)
    , GlobalData
    , Runtime
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
@docs Runtime
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
type alias Runtime =
    Internal.InternalData


{-| User Event

This is the User Event for the game.

Users can get outside information through these events.

`Tick` is triggered every timeInterval. The int attacked to it is

`KeyDown`, `KeyUp` records the keyboard events.
"KeyDown" event is sent when the key is pressed, "KeyUp" is sent when the key is released.

  - Note: if you just want to check if a key is pressed or not, use `getPressedKeys runtime` instead.
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
Runtime values like time, input state, scene name, and volume live in the
separate read-only `Runtime`; use the getter functions below to read them.

  - `userdata` records the data that users set to save
  - `extraHTML` is used to render extra HTML tags. Be careful to use this
  - `canvasAttributes` is used to attach attributes to the game canvas
  - `camera` records the camera position and zoom level
-}
type alias GlobalData userdata =
    { extraHTML : Maybe (Html WorldEvent)
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
getSceneStartTime : Runtime -> Float
getSceneStartTime runtime =
    (Internal.getInternalData runtime).sceneStartTime


{-| Get elapsed time since the game started.
-}
getGlobalStartTime : Runtime -> Float
getGlobalStartTime runtime =
    (Internal.getInternalData runtime).globalStartTime


{-| Get the frame count since the game started.
-}
getGlobalStartFrame : Runtime -> Int
getGlobalStartFrame runtime =
    (Internal.getInternalData runtime).globalStartFrame


{-| Get the frame count since the current scene started.
-}
getSceneStartFrame : Runtime -> Int
getSceneStartFrame runtime =
    (Internal.getInternalData runtime).sceneStartFrame


{-| Get the current timestamp.
-}
getCurrentTimeStamp : Runtime -> Float
getCurrentTimeStamp runtime =
    (Internal.getInternalData runtime).currentTimeStamp


{-| Get the current browser visibility.
-}
getWindowVisibility : Runtime -> Visibility
getWindowVisibility runtime =
    (Internal.getInternalData runtime).windowVisibility


{-| Get the mouse position in virtual coordinates.
-}
getMousePos : Runtime -> ( Float, Float )
getMousePos runtime =
    (Internal.getInternalData runtime).mousePos


{-| Get the pressed mouse buttons.
-}
getPressedMouseButtons : Runtime -> Set Int
getPressedMouseButtons runtime =
    (Internal.getInternalData runtime).pressedMouseButtons


{-| Get the pressed keys.
-}
getPressedKeys : Runtime -> Set Int
getPressedKeys runtime =
    (Internal.getInternalData runtime).pressedKeys


{-| Get the current volume.
-}
getVolume : Runtime -> Float
getVolume runtime =
    (Internal.getInternalData runtime).volume


{-| Get the current scene name.
-}
getCurrentScene : Runtime -> String
getCurrentScene runtime =
    (Internal.getInternalData runtime).currentScene


{-| Get virtual coordinate dimensions
-}
getVirtualSize : Runtime -> ( Float, Float )
getVirtualSize runtime =
    let
        internalData =
            Internal.getInternalData runtime
    in
    ( internalData.virtualWidth, internalData.virtualHeight )


{-| Get real canvas dimensions
-}
getRealSize : Runtime -> ( Float, Float )
getRealSize runtime =
    let
        internalData =
            Internal.getInternalData runtime
    in
    ( internalData.realWidth, internalData.realHeight )


{-| Get browser viewport dimensions
-}
getViewPort : Runtime -> ( Float, Float )
getViewPort runtime =
    (Internal.getInternalData runtime).browserViewPort


{-| Get canvas positioning offset
-}
getCanvasOffset : Runtime -> ( Float, Float )
getCanvasOffset runtime =
    let
        internalData =
            Internal.getInternalData runtime
    in
    ( internalData.startLeft, internalData.startTop )


{-| Get resource loading progress (loaded, total)
-}
getLoadingProgress : Runtime -> ( Int, Int )
getLoadingProgress runtime =
    let
        internalData =
            Internal.getInternalData runtime
    in
    ( internalData.loadedResNum, internalData.totResNum )


{-| Get set of loaded font names
-}
getFonts : Runtime -> Set String
getFonts runtime =
    (Internal.getInternalData runtime).fonts


{-| Get set of loaded shader program names
-}
getPrograms : Runtime -> Set String
getPrograms runtime =
    (Internal.getInternalData runtime).programs


{-| Get a specific sprite texture by name
-}
getSprite : String -> Runtime -> Maybe REGL.Texture
getSprite name runtime =
    Dict.get name (Internal.getInternalData runtime).sprites


{-| Get all loaded sprite textures
-}
getAllSprites : Runtime -> Dict String REGL.Texture
getAllSprites runtime =
    (Internal.getInternalData runtime).sprites


{-| Get loaded config data by key.
-}
getConfigData : String -> Runtime -> Maybe String
getConfigData key runtime =
    Dict.get key (Internal.getInternalData runtime).configData
