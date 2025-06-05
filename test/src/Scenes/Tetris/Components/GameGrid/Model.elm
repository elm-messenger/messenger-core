module Scenes.Tetris.Components.GameGrid.Model exposing (component)

{-| Component model

@docs component

-}

import Browser.Events exposing (Visibility(..))
import Color
import Lib.Base exposing (SceneMsg)
import Lib.Tetris.Base exposing (AnimationState, Direction(..), TetrisEvent(..))
import Lib.Tetris.Grid as G
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import REGL.BuiltinPrograms exposing (rect)
import REGL.Common exposing (group)
import Scenes.Tetris.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget)
import Scenes.Tetris.Components.GameGrid.Animate exposing (animate, cancelState, changeDir, spawnTetrimino, startAccelerate, startMove, startRotate)
import Scenes.Tetris.Components.GameGrid.Base exposing (Data)
import Scenes.Tetris.Components.GameGrid.Render exposing (renderWell)
import Scenes.Tetris.SceneBase exposing (SceneCommonData, State(..))


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init _ _ =
    ( { grid = G.empty
      , active = G.empty
      , scale = { width = 10, height = 20 }
      , position = ( 0, 0 )
      , direction = { left = False, right = False }
      , animation = { move = AnimationState False False 0, rotate = AnimationState False False 0, accelerate = False }
      }
    , ()
    )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update ({ globalData } as env) evnt data basedata =
    if globalData.windowVisibility == Visible then
        case evnt of
            KeyDown 37 ->
                --Left
                ( ( startMove <| changeDir Left data, basedata ), [], ( env, False ) )

            KeyDown 39 ->
                --Right
                ( ( startMove <| changeDir Right data, basedata ), [], ( env, False ) )

            KeyDown 38 ->
                --Up
                ( ( startRotate True data, basedata ), [], ( env, False ) )

            KeyDown 40 ->
                --Down
                ( ( startAccelerate True data, basedata ), [], ( env, False ) )

            KeyUp _ ->
                ( ( cancelState data, basedata ), [], ( env, False ) )

            Tick dt ->
                let
                    newMaxScore =
                        max env.commonData.score globalData.userData.tetrisData.currentMaxScore

                    newEnv =
                        { env | globalData = { globalData | userData = UserData { lastMaxScore = globalData.userData.tetrisData.lastMaxScore, currentMaxScore = newMaxScore } } }
                in
                if env.commonData.state == Playing && dt <= 100 then
                    animate dt newEnv data
                        |> (\( d, m, e ) -> ( ( d, () ), m ++ [ Parent <| SOMMsg SOMSaveGlobalData ], ( e, False ) ))

                else
                    ( ( data, basedata ), [ Parent <| SOMMsg SOMSaveGlobalData ], ( newEnv, False ) )

            _ ->
                ( ( data, basedata ), [], ( env, False ) )

    else
        ( ( cancelState data, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec ({ commonData } as env) msg data basedata =
    case msg of
        TetrisMsg tevent ->
            case tevent of
                Start ->
                    let
                        ( newData, newEnv ) =
                            spawnTetrimino { env | commonData = { commonData | score = 0, lines = 0 } } { data | grid = G.empty }
                    in
                    ( ( newData, basedata ), [], newEnv )

                CancelAll ->
                    ( ( cancelState data, basedata ), [], env )

                Move dir ->
                    ( ( startMove <| changeDir dir data, basedata ), [], env )

                Rotate on ->
                    ( ( startRotate on data, basedata ), [], env )

                Accelerate on ->
                    ( ( startAccelerate on data, basedata ), [], env )

                _ ->
                    ( ( data, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view _ data _ =
    ( group []
        [ renderWell data
        , rect ( 0, 0 ) ( 600, 30 ) Color.white
        ]
    , 0
    )


matcher : ComponentMatcher Data BaseData ComponentTarget
matcher _ _ tar =
    tar == "GameGrid"


componentcon : ConcreteUserComponent Data SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
componentcon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Component generator
-}
component : ComponentStorage SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
component =
    genComponent componentcon
