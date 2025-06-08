module Scenes.Tetris.SceneBase exposing
    ( LayerTarget
    , SceneCommonData
    , LayerMsg(..)
    , State(..)
    )

{-|


# SceneBase

Basic data for the scene.

@docs LayerTarget
@docs SceneCommonData
@docs LayerMsg

-}

import Color exposing (Color)
import Lib.Tetris.Grid exposing (Grid)


type State
    = Paused
    | Playing
    | Stopped


{-| Layer target type
-}
type alias LayerTarget =
    String


{-| Common data
-}
type alias SceneCommonData =
    { state : State
    , score : Int
    , lines : Int
    , next : Grid Color
    }


{-| General message for layers
-}
type LayerMsg
    = NullLayerMsg
