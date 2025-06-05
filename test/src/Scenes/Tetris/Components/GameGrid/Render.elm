module Scenes.Tetris.Components.GameGrid.Render exposing (renderWell)

import Color exposing (Color)
import Lib.Tetris.Grid as G
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable, group)
import Scenes.Tetris.Components.GameGrid.Base exposing (Data)


renderBox : (Color -> Color) -> Color -> ( Int, Int ) -> Renderable
renderBox fun c ( x, y ) =
    P.rect ( toFloat x * 30, toFloat y * 30 + 30 ) ( 30, 30 ) <| fun c


renderWell : Data -> Renderable
renderWell data =
    let
        ( x, y ) =
            data.position
    in
    group []
        (data.grid
            |> G.stamp x (floor y) data.active
            |> G.mapToList (renderBox identity)
            |> (::)
                (P.rect
                    ( 0, 30 )
                    ( toFloat data.scale.width * 30, toFloat data.scale.height * 30 )
                    (Color.rgb255 236 240 241)
                )
        )
