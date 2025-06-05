module Scenes.Tetris.Components.ComponentBase exposing (ComponentMsg(..), ComponentTarget, BaseData)

{-|


# Component base

@docs ComponentMsg, ComponentTarget, BaseData

-}

import Lib.Tetris.Base exposing (TetrisEvent)
import Scenes.Tetris.Components.Button.Init as Button


{-| Component message
-}
type ComponentMsg
    = TetrisMsg TetrisEvent
    | ButtonInitMsg Button.InitData
    | NullComponentMsg


{-| Component target
-}
type alias ComponentTarget =
    String


{-| Component base data
-}
type alias BaseData =
    ()
