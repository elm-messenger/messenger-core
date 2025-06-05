module Scenes.Components.Components.Rect.Model exposing (component)

{-| Component model

@docs component

-}

import Color
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.Coordinate.Coordinates exposing (judgeMouseRect)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import REGL.BuiltinPrograms as P
import Scenes.Components.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget)
import Scenes.Components.Components.Rect.Init exposing (InitData)
import Scenes.Components.SceneBase exposing (SceneCommonData)


type alias Data =
    InitData


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init env initMsg =
    case initMsg of
        RectInit initData ->
            ( initData, () )

        _ ->
            ( InitData 0 0 0 0 0 Color.black, () )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    case evnt of
        MouseDown 0 pos ->
            if judgeMouseRect pos ( data.left, data.top ) ( data.width, data.height ) then
                ( ( { data | color = Color.black }, basedata ), [ Other ( data.id + 1, RectMsg Color.green ), Parent <| OtherMsg <| RectReportMsg data.id ], ( env, True ) )

            else
                ( ( data, basedata ), [], ( env, False ) )

        _ ->
            ( ( data, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    case msg of
        RectMsg c ->
            ( ( { data | color = c }, basedata ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view env data basedata =
    ( P.rect ( data.left, data.top ) ( data.width, data.height ) data.color, 0 )


matcher : ComponentMatcher Data BaseData ComponentTarget
matcher data basedata tar =
    tar == data.id


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
