module Messenger.UserConfig exposing
    ( UserConfig, PortDefs
    , EnabledBuiltinProgram(..)
    )

{-|


# User Configuration

Configuration and port definitions used to start a Messenger program. Generated
projects usually fill this record from `MainConfig.elm` and `Lib.Ports`.

@docs UserConfig, PortDefs
@docs EnabledBuiltinProgram

-}

import Audio
import Json.Decode as Decode
import Json.Encode as Encode
import Messenger.Base exposing (GlobalData, GlobalDataInit)
import Messenger.Internal exposing (WorldEvent)
import REGL


{-| Built-in REGL programs enabled at startup.

  - `NoBuiltinProgram` represents enabling no builtin program
  - `CustomBuiltinProgramList` represents enabling a list of custom builtin programs
  - `TextOnlyBuiltinProgram` represents enabling the builtin program for text only
  - `BasicShapesBuiltinProgram` represents enabling the builtin programs for basic shapes
  - `CommonBuiltinProgram` represents enabling the builtin programs for common shapes
  - `AllBuiltinProgram` represents enabling all builtin programs (Recommended)

-}
type EnabledBuiltinProgram
    = NoBuiltinProgram
    | CustomBuiltinProgramList (List String)
    | TextOnlyBuiltinProgram
    | BasicShapesBuiltinProgram
    | AllBuiltinProgram


{-| User configuration for Messenger.

`userdata` is a custom type which can store any data in the game.
users can **save their own global data** and **implement local storage** here.

`scenemsg` is another custom type which represents the message type users wants
to send to a scene when switching scenes.

  - `initScene` represents the scene users get start
  - `initSceneMsg` represents the message to initialize the start scene
  - `globalDataCodec` is for local storage. Users decode saved data into
    `GlobalDataInit`, and encode the current `GlobalData` when saving.
  - `virtualSize` represents how users want their game be virtual sized. In other words,
    users make their game in the virtual size, and the game will be resized due to the browser window size
    but keeping the aspect ratio
  - `debug` option determines whether enable some simple debugging tools or not
    remember to disable it when releasing game
  - `timeInterval` See `TimeInterval`
  - `ports` stores the ports that users must provide.

-}
type alias UserConfig userdata scenemsg =
    { initScene : String
    , initSceneMsg : Maybe scenemsg
    , globalDataCodec :
        { encode : GlobalData userdata -> String
        , decode : String -> GlobalDataInit userdata
        }
    , virtualSize :
        { width : Float
        , height : Float
        }
    , debug : Bool
    , timeInterval : REGL.TimeInterval
    , ports : PortDefs
    , enabledProgram : EnabledBuiltinProgram
    , fboNum : Int
    }


{-| Ports required by Messenger.

Generated projects define these ports in `Lib.Ports`. Messenger uses them for
local storage, prompts, alerts, REGL commands, data-file loading, and audio
interop.

**Learn more about ports [here](https://guide.elm-lang.org/interop/ports)**

-}
type alias PortDefs =
    { sendInfo : String -> Cmd WorldEvent
    , audioPortToJS : Encode.Value -> Cmd (Audio.Msg WorldEvent)
    , audioPortFromJS : (Decode.Value -> Audio.Msg WorldEvent) -> Sub (Audio.Msg WorldEvent)
    , alert : String -> Cmd WorldEvent
    , prompt : { name : String, title : String } -> Cmd WorldEvent
    , promptReceiver : ({ name : String, result : String } -> WorldEvent) -> Sub WorldEvent
    , reglupdate : (Float -> WorldEvent) -> Sub WorldEvent
    , setView : Encode.Value -> Cmd WorldEvent
    , execREGLCmd : Encode.Value -> Cmd WorldEvent
    , recvREGLCmd : (Encode.Value -> WorldEvent) -> Sub WorldEvent
    , loadDataFile : { name : String, path : String } -> Cmd WorldEvent
    , dataFileLoaded : ({ name : String, data : String } -> WorldEvent) -> Sub WorldEvent
    }
