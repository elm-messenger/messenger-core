module Lib.Tetris.Tetriminos exposing (random)

import Color exposing (Color)
import Lib.Tetris.Grid as G exposing (Grid)
import Random


random : Int -> Grid Color
random t =
    let
        number =
            Random.int 0 (List.length tetriminos - 1)

        tetrimino n =
            Maybe.withDefault G.empty (List.head (List.drop n tetriminos))
    in
    Tuple.first <| Random.step (Random.map tetrimino number) (Random.initialSeed t)


tetriminos : List (Grid Color)
tetriminos =
    List.map
        (\( a, b ) -> G.fromList a b)
        [ ( Color.rgb255 60 199 214, [ ( 0, 0 ), ( 1, 0 ), ( 2, 0 ), ( 3, 0 ) ] )
        , ( Color.rgb255 251 180 20, [ ( 0, 0 ), ( 1, 0 ), ( 0, 1 ), ( 1, 1 ) ] )
        , ( Color.rgb255 176 68 151, [ ( 1, 0 ), ( 0, 1 ), ( 1, 1 ), ( 2, 1 ) ] )
        , ( Color.rgb255 57 147 208, [ ( 0, 0 ), ( 0, 1 ), ( 1, 1 ), ( 2, 1 ) ] )
        , ( Color.rgb255 237 101 47, [ ( 2, 0 ), ( 0, 1 ), ( 1, 1 ), ( 2, 1 ) ] )
        , ( Color.rgb255 149 196 61, [ ( 1, 0 ), ( 2, 0 ), ( 0, 1 ), ( 1, 1 ) ] )
        , ( Color.rgb255 232 65 56, [ ( 0, 0 ), ( 1, 0 ), ( 1, 1 ), ( 2, 1 ) ] )
        ]
