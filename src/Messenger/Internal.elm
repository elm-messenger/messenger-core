module Messenger.Internal exposing
    ( InternalData
    , emptyInternalData
    )

{-|


# Internal Data

Internal engine state that should not be directly accessible to user code.

@docs InternalData
@docs emptyInternalData

-}

import Dict exposing (Dict)
import Messenger.Audio.Internal exposing (AudioRepo, emptyRepo)
import REGL
import Set exposing (Set)


{-| Internal engine data that tracks rendering and resource state
-}
type alias InternalData =
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
    }


{-| Empty InternalData for initialization
-}
emptyInternalData : InternalData
emptyInternalData =
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
    }