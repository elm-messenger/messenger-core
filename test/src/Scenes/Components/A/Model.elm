module Scenes.Components.A.Model exposing (layer)

{-| Layer configuration module

Set the Data Type, Init logic, Update logic, View logic and Matcher logic here.

@docs layer

-}

import Color
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Component.Component exposing (AbstractComponent, updateComponents, viewComponents)
import Messenger.GeneralModel exposing (Matcher, Msg(..), MsgBase(..))
import Messenger.Layer.Layer exposing (ConcreteLayer, Handler, LayerInit, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer, handleComponentMsgs)
import Scenes.Components.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget)
import Scenes.Components.Components.Rect.Init as RectInit
import Scenes.Components.Components.Rect.Model as Rect
import Scenes.Components.SceneBase exposing (..)


type alias Data =
    { components : List (AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
    }


init : LayerInit SceneCommonData UserData LayerMsg Data
init runtime env initMsg =
    Data
        [ Rect.component (RectInit <| RectInit.InitData 150 150 200 200 0 Color.blue) runtime env
        , Rect.component (RectInit <| RectInit.InitData 200 200 200 200 1 Color.red) runtime env
        ]


handleComponentMsg : Handler Data SceneCommonData UserData LayerTarget LayerMsg SceneMsg ComponentMsg
handleComponentMsg _ env compmsg data =
    case compmsg of
        SOMMsg som ->
            ( data, [ Parent <| SOMMsg som ], env )

        OtherMsg msg ->
            case msg of
                RectReportMsg rm ->
                    -- let
                    --     _ =
                    --         Debug.log "RectReportMsg" rm
                    -- in
                    ( data, [], env )

                _ ->
                    ( data, [], env )


update : LayerUpdate SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
update runtime env evt data =
    let
        ( comps1, msgs1, ( env1, block1 ) ) =
            updateComponents runtime env evt data.components

        ( data1, msgs2, env2 ) =
            handleComponentMsgs runtime env1 msgs1 { data | components = comps1 } [] handleComponentMsg
    in
    ( data1, msgs2, ( env2, block1 ) )


updaterec : LayerUpdateRec SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
updaterec _ env msg data =
    ( data, [], env )


view : LayerView SceneCommonData UserData Data
view runtime env data =
    viewComponents runtime env data.components


matcher : Matcher Data LayerTarget
matcher data tar =
    tar == "A"


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
