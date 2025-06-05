module Lib.Tetris.Base exposing (AnimationState, Direction(..), TetrisEvent(..))


type TetrisEvent
    = Start
    | Pause
    | Resume
    | Move Direction
    | Rotate Bool
    | Accelerate Bool
    | CancelAll
    | GameOver


type Direction
    = Left
    | Right


type alias AnimationState =
    { key : Bool
    , active : Bool
    , elapsed : Float
    }
