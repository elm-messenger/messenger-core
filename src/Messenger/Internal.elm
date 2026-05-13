module Messenger.Internal exposing
    ( InternalData(..), InternalDataObj
    , emptyInternalData, getInternalData
    )

{-|


# Internal Data

Internal engine state that should not be directly accessible to user code.

@docs InternalData, InternalDataObj
@docs emptyInternalData, getInternalData

-}

import Dict exposing (Dict)
import Messenger.Audio.Internal exposing (AudioRepo, emptyRepo)
import REGL
import Set exposing (Set)


{-| Opaque internal engine data.
-}
type InternalData
    = InternalData InternalDataObj


{-| Internal engine data object that tracks rendering and resource state.
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
        }


{-| Get the internal data object.
-}
getInternalData : InternalData -> InternalDataObj
getInternalData (InternalData internalData) =
    internalData
