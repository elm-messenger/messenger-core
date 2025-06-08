module Scenes.Interaction.Components.Slider.Model exposing (component)

{-| Component model

@docs component

-}

import Color
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.Coordinate.Coordinates exposing (judgeMouseCircle)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group)
import Scenes.Interaction.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget)
import Scenes.Interaction.Components.Slider.Init exposing (InitData)
import Scenes.Interaction.SceneBase exposing (SceneCommonData)


type alias Data =
    { initData : InitData
    , selected : Bool
    , pos : ( Float, Float )
    }


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        SliderInitMsg msg ->
            let
                ( x, y ) =
                    msg.center
            in
            ( Data msg False ( x - msg.width / 2 + msg.initValue * msg.width, y ), () )

        _ ->
            ( Data (InitData 0 ( 0, 0 ) 0) False ( 0, 0 ), () )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    case evnt of
        MouseUp _ _ ->
            ( ( { data | selected = False }, basedata ), [], ( env, False ) )

        MouseDown _ _ ->
            if judgeMouseCircle env.globalData.mousePos data.pos 15 then
                ( ( { data | selected = True }, basedata ), [], ( env, True ) )

            else
                ( ( data, basedata ), [], ( env, False ) )

        _ ->
            if data.selected then
                let
                    ( posx, _ ) =
                        env.globalData.mousePos

                    ( cx, cy ) =
                        data.initData.center

                    newposx =
                        if posx < cx - data.initData.width / 2 then
                            cx - data.initData.width / 2

                        else if posx > cx + data.initData.width / 2 then
                            cx + data.initData.width / 2

                        else
                            posx

                    progress =
                        (newposx - (cx - data.initData.width / 2)) / data.initData.width
                in
                ( ( { data | pos = ( newposx, cy ) }, basedata ), [ Parent <| OtherMsg <| SliderUpdateMsg progress ], ( env, False ) )

            else
                ( ( data, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    ( group []
        [ P.rectCentered data.initData.center ( data.initData.width, 15 ) 0 Color.grey
        , P.circle data.pos 15 Color.black
        ]
    , 0
    )


matcher : ComponentMatcher Data BaseData ComponentTarget
matcher data basedata tar =
    tar == "Slider"


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
