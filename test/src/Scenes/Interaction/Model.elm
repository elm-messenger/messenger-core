module Scenes.Interaction.Model exposing (scene)

{-| Scene configuration module

@docs scene

-}

import Color
import Duration
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (AbstractComponent, updateComponents, viewComponents)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import Messenger.GlobalComponents.Transition.Model exposing (genMixedTransitionSOM)
import Messenger.GlobalComponents.Transition.Transitions exposing (fadeMix)
import Messenger.Layer.Layer exposing (Handler, handleComponentMsgs)
import Messenger.Scene.RawScene exposing (RawSceneInit, RawSceneUpdate, RawSceneView, genRawScene)
import Messenger.Scene.Scene exposing (MConcreteScene, SceneStorage)
import REGL.BuiltinPrograms exposing (textbox)
import REGL.Common exposing (group)
import Scenes.Interaction.Components.Button.Init as ButtonInit
import Scenes.Interaction.Components.Button.Model as Button
import Scenes.Interaction.Components.Button.Msg exposing (ButtonMsg(..))
import Scenes.Interaction.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget)
import Scenes.Interaction.Components.Slider.Init as SliderInit
import Scenes.Interaction.Components.Slider.Model as Slider
import Scenes.Interaction.SceneBase exposing (SceneCommonData)


type alias Data =
    { components : List (AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
    , buttonStatus : String
    , sliderValue : Float
    }


init : RawSceneInit Data UserData SceneMsg
init env msg =
    { components =
        [ Button.component (ButtonInitMsg <| ButtonInit.InitData ( 200, 200 ) ( 100, 50 ) Color.green "NICE") env
        , Slider.component (SliderInitMsg <| SliderInit.InitData 0.5 ( 200, 300 ) 300) env
        ]
    , buttonStatus = "IDLE"
    , sliderValue = 0.5
    }


handleComponentMsg : Handler Data SceneCommonData UserData ComponentTarget ComponentMsg SceneMsg ComponentMsg
handleComponentMsg env compmsg data =
    case compmsg of
        SOMMsg som ->
            ( data, [ Parent <| SOMMsg som ], env )

        OtherMsg msg ->
            case msg of
                ButtonUpdateMsg buttonMsg ->
                    case buttonMsg of
                        Pressed ->
                            ( { data | buttonStatus = "PRESSED" }, [], env )

                        Released ->
                            ( { data | buttonStatus = "IDLE" }, [], env )

                SliderUpdateMsg sliderMsg ->
                    ( { data | sliderValue = sliderMsg }, [], env )

                _ ->
                    ( data, [], env )


update : RawSceneUpdate Data UserData SceneMsg
update env msg data =
    let
        ( comps1, msgs1, ( env1, _ ) ) =
            updateComponents env msg data.components

        ( data1, msgs2, env2 ) =
            handleComponentMsgs env1 msgs1 { data | components = comps1 } [] handleComponentMsg

        sommsgs =
            List.filterMap
                (\m ->
                    case m of
                        Parent som ->
                            case som of
                                SOMMsg sommsg ->
                                    Just sommsg

                                _ ->
                                    Nothing

                        _ ->
                            Nothing
                )
                msgs2
    in
    case msg of
        KeyDown 8 ->
            ( data1
            , [ genMixedTransitionSOM ( fadeMix, Duration.seconds 1 ) ( "Home", Nothing )
              ]
            , env2
            )

        _ ->
            ( data1, sommsgs, env2 )


view : RawSceneView UserData Data
view env data =
    group []
        [ viewComponents env data.components
        , textbox ( 0, 50 ) 20 ("Button Status: " ++ data.buttonStatus) "firacode" Color.black
        , textbox ( 0, 80 ) 20 ("Slider Value: " ++ String.fromFloat data.sliderValue) "firacode" Color.black
        ]


scenecon : MConcreteScene Data UserData SceneMsg
scenecon =
    { init = init
    , update = update
    , view = view
    }


{-| Scene generator
-}
scene : SceneStorage UserData SceneMsg
scene =
    genRawScene scenecon
