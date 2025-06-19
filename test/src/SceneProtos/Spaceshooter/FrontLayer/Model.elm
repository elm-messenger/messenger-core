module SceneProtos.Spaceshooter.FrontLayer.Model exposing (layer)

{-| Layer configuration module

Set the Data Type, Init logic, Update logic, View logic and Matcher logic here.

@docs layer

-}

import Color
import Duration
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (UserEvent(..))
import Messenger.GeneralModel exposing (Matcher, Msg(..), MsgBase(..))
import Messenger.GlobalComponents.Transition.Model exposing (genMixedTransitionSOM)
import Messenger.GlobalComponents.Transition.Transitions exposing (fadeMix)
import Messenger.Layer.Layer exposing (ConcreteLayer, LayerInit, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer)
import Messenger.Scene.Scene exposing (SceneOutputMsg(..))
import REGL
import REGL.BuiltinPrograms as P exposing (defaultTextBoxOption)
import REGL.Common exposing (group)
import REGL.Effects exposing (alphamult, gblur)
import SceneProtos.Spaceshooter.SceneBase exposing (..)
import String exposing (fromInt)


type alias Data =
    { level : String }


init : LayerInit SceneCommonData UserData (LayerMsg SceneMsg) Data
init _ initMsg =
    case initMsg of
        FrontInitData lv ->
            Data lv

        _ ->
            Data ""


update : LayerUpdate SceneCommonData UserData LayerTarget (LayerMsg SceneMsg) SceneMsg Data
update env evt data =
    case evt of
        KeyDown 8 ->
            ( data
            , [ Parent <| SOMMsg <| genMixedTransitionSOM ( fadeMix, Duration.seconds 1 ) ( "Home", Nothing )
              ]
            , ( env, False )
            )

        _ ->
            if not env.commonData.gameOver then
                let
                    nextLvmsg =
                        if env.commonData.score >= 80 && data.level == "Level1" then
                            [ Parent <| SOMMsg <| SOMChangeScene Nothing "SSLevel2" ]

                        else
                            []
                in
                ( data, nextLvmsg, ( env, False ) )

            else
                case evt of
                    MouseDown 0 _ ->
                        ( data, [ Parent <| SOMMsg <| SOMChangeScene Nothing ("SS" ++ data.level) ], ( env, True ) )

                    KeyDown 32 ->
                        -- space
                        ( data, [ Parent <| SOMMsg <| SOMChangeScene Nothing ("SS" ++ data.level) ], ( env, True ) )

                    _ ->
                        ( data, [], ( env, False ) )


updaterec : LayerUpdateRec SceneCommonData UserData LayerTarget (LayerMsg SceneMsg) SceneMsg Data
updaterec env _ data =
    ( data, [], env )


view : LayerView SceneCommonData UserData Data
view env data =
    let
        gameOverVE =
            if env.commonData.gameOver then
                gblur 0.2

            else
                []

        gameOverMask =
            if env.commonData.gameOver then
                group []
                    [ group [ alphamult 0.2 ] [ P.rect ( 0, 0 ) ( 1920, 1080 ) <| Color.white ]
                    , P.textboxCentered ( 960, 540 ) 140 "Game Over" "firacode" Color.red
                    ]

            else
                P.empty
    in
    [ group gameOverVE
        [ P.textboxPro ( 1900, 80 ) { defaultTextBoxOption | size = 50, text = "Score: " ++ fromInt env.commonData.score, fonts = [ "firacode" ], color = Color.black, align = Just "right" }
        , P.textboxPro ( 1900, 30 ) { defaultTextBoxOption | size = 50, text = data.level, fonts = [ "firacode" ], color = Color.black, align = Just "right" }
        ]
    , gameOverMask
    ]
        |> group []


matcher : Matcher Data LayerTarget
matcher _ tar =
    tar == "FrontLayer"


layercon : ConcreteLayer Data SceneCommonData UserData LayerTarget (LayerMsg SceneMsg) SceneMsg
layercon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Layer generator
-}
layer : LayerStorage SceneCommonData UserData LayerTarget (LayerMsg SceneMsg) SceneMsg
layer =
    genLayer layercon
