module Scenes.Tetris.Components.GameGrid.Animate exposing
    ( animate
    , cancelState
    , changeDir
    , spawnTetrimino
    , startAccelerate
    , startMove
    , startRotate
    )

import Lib.Tetris.Base exposing (AnimationState, Direction(..), TetrisEvent(..))
import Lib.Tetris.Grid as G
import Lib.Tetris.Tetriminos as Tetriminos
import Lib.UserData exposing (UserData)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import Scenes.Tetris.Components.ComponentBase exposing (ComponentMsg(..))
import Scenes.Tetris.Components.GameGrid.Base exposing (Data, EnvGameGrid, OutputMsg)
import Scenes.Tetris.SceneBase exposing (State(..))


cancelState : Data -> Data
cancelState data =
    { data
        | direction = { left = False, right = False }
        , animation = { move = AnimationState False False 0, rotate = AnimationState False False 0, accelerate = False }
    }


animate : Float -> EnvGameGrid -> Data -> ( Data, List OutputMsg, EnvGameGrid )
animate dt env data =
    moveTetrimino dt data
        |> rotateTetrimino dt
        |> dropTetrimino dt env
        |> (\( resd, rese ) -> checkEndGame rese resd)


changeDir : Direction -> Data -> Data
changeDir dir data =
    case dir of
        Left ->
            { data | direction = { left = True, right = data.direction.right } }

        Right ->
            { data | direction = { left = data.direction.right, right = True } }


startMove : Data -> Data
startMove data =
    let
        ani =
            data.animation

        move =
            xor data.direction.left data.direction.right
    in
    { data | animation = { ani | move = AnimationState True move 0 } }


startRotate : Bool -> Data -> Data
startRotate rotate data =
    let
        ani =
            data.animation
    in
    { data | animation = { ani | rotate = AnimationState True rotate 0 } }


startAccelerate : Bool -> Data -> Data
startAccelerate on data =
    let
        ani =
            data.animation
    in
    { data | animation = { ani | accelerate = on } }


spawnTetrimino : EnvGameGrid -> Data -> ( Data, EnvGameGrid )
spawnTetrimino ({ commonData, globalData } as env) data =
    let
        next =
            Tetriminos.random <| round globalData.currentTimeStamp

        ( x, y ) =
            G.initPosition data.scale.width commonData.next
    in
    ( { data
        | active = commonData.next
        , position = ( x, toFloat y )
      }
    , { env | commonData = { commonData | next = next } }
    )


moveTetrimino : Float -> Data -> Data
moveTetrimino dt data =
    let
        ( x, y ) =
            data.position

        newmove =
            if data.animation.move.elapsed >= 150 then
                AnimationState data.animation.move.key True <| data.animation.move.elapsed - 150 + dt

            else
                AnimationState data.animation.move.key False <| data.animation.move.elapsed + dt

        newData =
            { data | animation = { move = newmove, rotate = data.animation.rotate, accelerate = data.animation.accelerate } }

        judgeCollision : Int -> Data
        judgeCollision dx =
            if G.collide data.scale.width data.scale.height (x + dx) (floor y) data.active data.grid then
                newData

            else
                { newData | position = ( x + dx, y ) }
    in
    if data.animation.move.key then
        case ( data.animation.move.active, data.direction.left, data.direction.right ) of
            ( True, True, False ) ->
                judgeCollision -1

            ( True, False, True ) ->
                judgeCollision 1

            _ ->
                newData

    else
        data


rotateTetrimino : Float -> Data -> Data
rotateTetrimino dt data =
    let
        ( x, y ) =
            data.position

        newrotate =
            if data.animation.rotate.elapsed >= 300 then
                AnimationState data.animation.rotate.key True <| data.animation.rotate.elapsed - 300 + dt

            else
                AnimationState data.animation.rotate.key False <| data.animation.rotate.elapsed + dt

        newData =
            { data | animation = { move = data.animation.move, rotate = newrotate, accelerate = data.animation.accelerate } }

        rotated =
            G.rotate True data.active

        shiftPosition : List Int -> Data
        shiftPosition deltas =
            case deltas of
                dx :: remainingDeltas ->
                    if G.collide data.scale.width data.scale.height (x + dx) (floor y) rotated data.grid then
                        shiftPosition remainingDeltas

                    else
                        { newData
                            | active = rotated
                            , position = ( x + dx, y )
                        }

                [] ->
                    newData
    in
    case ( data.animation.rotate.key, data.animation.rotate.active ) of
        ( True, True ) ->
            shiftPosition [ 0, 1, -1, 2, -2 ]

        ( True, False ) ->
            newData

        _ ->
            data


dropTetrimino : Float -> EnvGameGrid -> Data -> ( Data, EnvGameGrid )
dropTetrimino dt ({ commonData } as env) data =
    let
        ( x, y ) =
            data.position

        interval =
            if data.animation.accelerate then
                25

            else
                max 25 (800 - 25 * toFloat (level env - 1))
    in
    if G.collide data.scale.width data.scale.height x (floor <| y + dt / interval) data.active data.grid then
        let
            score =
                List.length data.active
                    * (if data.animation.accelerate then
                        2

                       else
                        1
                      )

            newGrid =
                G.stamp x (floor y) data.active data.grid
        in
        (\( d, e ) -> clearLines e d) <|
            spawnTetrimino { env | commonData = { commonData | score = commonData.score + score } } { data | grid = newGrid }

    else
        ( { data | position = ( x, y + dt / interval ) }, env )


clearLines : EnvGameGrid -> Data -> ( Data, EnvGameGrid )
clearLines ({ commonData } as env) data =
    let
        ( grid, lines ) =
            G.clearLines data.scale.width data.grid

        bonus =
            if lines > 0 && lines <= 3 then
                lines * 200 - 100

            else if lines == 0 then
                0

            else
                800
    in
    ( { data | grid = grid }
    , { env
        | commonData =
            { commonData
                | score = commonData.score + bonus * level env
                , lines = commonData.lines + lines
            }
      }
    )


level : EnvGameGrid -> Int
level env =
    env.commonData.lines // 10 + 1


checkEndGame : EnvGameGrid -> Data -> ( Data, List OutputMsg, EnvGameGrid )
checkEndGame ({ commonData, globalData } as env) data =
    if List.any identity (G.mapToList (\_ ( _, y ) -> y < 0) data.grid) then
        let
            currentMaxScore =
                max globalData.userData.tetrisData.currentMaxScore commonData.score
        in
        ( data
        , [ Other ( "Button", TetrisMsg GameOver ) ]
        , { commonData = { commonData | state = Stopped }, globalData = { globalData | userData = UserData { lastMaxScore = currentMaxScore, currentMaxScore = currentMaxScore } } }
        )

    else
        ( data, [], env )
