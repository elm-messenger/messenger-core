module Scenes.Interaction.Components.Button.Model exposing (component)

{-| Component model

@docs component

-}

import Color
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.Coordinate.Coordinates exposing (judgeMouseRect)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group)
import Scenes.Interaction.Components.Button.Init exposing (InitData)
import Scenes.Interaction.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget)
import Scenes.Interaction.SceneBase exposing (SceneCommonData)


type ButtonState
    = Normal
    | Hovered
    | Pressed


type alias Data =
    { initdata : InitData
    , pos : ( Float, Float )
    , curState : ButtonState
    }


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        ButtonInitMsg msg ->
            let
                ( x, y ) =
                    msg.center

                ( w, h ) =
                    msg.size
            in
            ( Data msg ( x - w / 2, y - h / 2 ) Normal, () )

        _ ->
            ( Data (InitData ( 0, 0 ) ( 0, 0 ) Color.black "") ( 0, 0 ) Normal, () )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    let
        isHovered =
            judgeMouseRect env.globalData.mousePos data.pos data.initdata.size

        nextState =
            if isHovered && data.curState == Normal then
                Hovered

            else if not isHovered && data.curState == Hovered then
                Normal

            else
                data.curState
    in
    case evnt of
        MouseUp _ _ ->
            ( ( { data | curState = Normal }, basedata ), [], ( env, True ) )

        MouseDown _ _ ->
            if judgeMouseRect env.globalData.mousePos data.pos data.initdata.size then
                ( ( { data | curState = Pressed }, basedata ), [], ( env, True ) )

            else
                ( ( data, basedata ), [], ( env, False ) )

        _ ->
            ( ( { data | curState = nextState }, basedata ), [], ( env, True ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    let
        rsize =
            case data.curState of
                Normal ->
                    data.initdata.size

                Hovered ->
                    data.initdata.size |> Tuple.mapBoth ((+) 10) ((+) 10)

                Pressed ->
                    data.initdata.size |> Tuple.mapBoth ((-) 10) ((-) 10)
    in
    ( group []
        [ P.rectCentered data.initdata.center rsize 0 data.initdata.color
        , P.textboxCentered
            data.initdata.center
            30
            data.initdata.content
            "firacode"
            Color.black
        ]
    , 0
    )


matcher : ComponentMatcher Data BaseData ComponentTarget
matcher data basedata tar =
    tar == "Button"


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
