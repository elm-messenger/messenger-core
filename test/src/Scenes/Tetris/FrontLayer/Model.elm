module Scenes.Tetris.FrontLayer.Model exposing (layer)

{-| Layer configuration module

Set the Data Type, Init logic, Update logic, View logic and Matcher logic here.

@docs layer

-}

import Color exposing (Color)
import Duration
import Lib.Base exposing (SceneMsg)
import Lib.Tetris.Grid as Grid exposing (Grid)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (Env, UserEvent(..))
import Messenger.Coordinate.Camera exposing (defaultCamera)
import Messenger.GeneralModel exposing (Matcher, Msg(..), MsgBase(..))
import Messenger.GlobalComponents.Transition.Model exposing (genMixedTransitionSOM)
import Messenger.GlobalComponents.Transition.Transitions exposing (fadeMix)
import Messenger.Layer.Layer exposing (ConcreteLayer, LayerInit, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer)
import REGL
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable, group)
import Scenes.Tetris.SceneBase exposing (..)


type alias EnvFrontLayer =
    Env SceneCommonData UserData


type alias Data =
    {}


init : LayerInit SceneCommonData UserData LayerMsg Data
init _ _ =
    {}


update : LayerUpdate SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
update ({ globalData } as env) msg data =
    case msg of
        KeyDown 8 ->
            ( data
            , [ Parent <| SOMMsg <| genMixedTransitionSOM ( fadeMix, Duration.seconds 1 ) ( "Home", Nothing )
              ]
            , ( { env | globalData = { globalData | camera = defaultCamera globalData } }, False )
            )

        _ ->
            ( data, [], ( env, False ) )


updaterec : LayerUpdateRec SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
updaterec env _ data =
    ( data, [], env )


view : LayerView SceneCommonData UserData Data
view env _ =
    renderPanel env


renderBlock : SceneCommonData -> Renderable
renderBlock commonData =
    case commonData.state of
        Playing ->
            P.empty

        _ ->
            P.rect ( 0, 30 ) ( 300, 600 ) <| Color.rgba 0.8 0.6 0.8 0.65


renderPanel : EnvFrontLayer -> Renderable
renderPanel { commonData, globalData } =
    group []
        [ P.textbox ( 350, 50 ) 50 "Tetris" "firacode" (Color.rgb255 52 73 95)
        , P.textbox ( 350, 120 ) 18 "Score" "firacode" (Color.rgb255 189 195 199)
        , P.textbox ( 430, 120 ) 18 "Best Score" "firacode" (Color.rgb255 189 195 199)
        , P.textbox ( 350, 140 ) 35 (String.fromInt commonData.score) "firacode" (Color.rgb255 57 147 208)
        , P.textbox ( 430, 140 ) 35 (String.fromInt globalData.userData.tetrisData.lastMaxScore) "firacode" (Color.rgb255 57 147 208)
        , P.textbox ( 350, 200 ) 18 "Lines Cleared" "firacode" (Color.rgb255 189 195 199)
        , P.textbox ( 350, 220 ) 35 (String.fromInt commonData.lines) "firacode" (Color.rgb255 57 147 208)
        , P.textbox ( 350, 280 ) 18 "Next Shape" "firacode" (Color.rgb255 189 195 199)
        , renderNext commonData.next
        , renderBlock commonData
        ]


renderNext : Grid Color -> Renderable
renderNext grid =
    grid
        |> Grid.mapToList
            (\_ ( x, y ) ->
                P.rect ( toFloat <| x * 30 + 350, toFloat <| y * 30 + 310 ) ( 30, 30 ) (Color.rgb255 200 240 241)
            )
        |> group []


matcher : Matcher Data LayerTarget
matcher _ tar =
    tar == "FrontLayer"


layercon : ConcreteLayer Data SceneCommonData UserData LayerTarget LayerMsg SceneMsg
layercon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Layer generator
-}
layer : LayerStorage SceneCommonData UserData LayerTarget LayerMsg SceneMsg
layer =
    genLayer layercon
