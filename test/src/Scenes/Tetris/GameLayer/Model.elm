module Scenes.Tetris.GameLayer.Model exposing (layer)

{-| Layer configuration module

Set the Data Type, Init logic, Update logic, View logic and Matcher logic here.

@docs layer

-}

import Color
import Lib.Base exposing (SceneMsg)
import Lib.Tetris.Base exposing (Direction(..))
import Lib.UserData exposing (UserData)
import Messenger.Component.Component exposing (AbstractComponent, updateComponents, viewComponents)
import Messenger.GeneralModel exposing (Matcher, Msg(..), MsgBase(..))
import Messenger.Layer.Layer exposing (ConcreteLayer, Handler, LayerInit, LayerStorage, LayerUpdate, LayerUpdateRec, LayerView, genLayer, handleComponentMsgs)
import Scenes.Tetris.Components.Button.Init as ButtonInit
import Scenes.Tetris.Components.Button.Model as Button
import Scenes.Tetris.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget)
import Scenes.Tetris.Components.GameGrid.Model as GameGrid
import Scenes.Tetris.SceneBase exposing (..)


type alias Data =
    { components : List (AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
    }


init : LayerInit SceneCommonData UserData LayerMsg Data
init env _ =
    Data
        [ GameGrid.component NullComponentMsg env
        , Button.component
            (ButtonInitMsg
                { size = ( 120, 50 )
                , position = ( 350, 550 )
                , text = { content = "New Game", color = Color.white }
                , backgroundColor = Color.darkBlue
                , buttonType = ButtonInit.State
                }
            )
            env
        , Button.component
            (ButtonInitMsg
                { size = ( 50, 50 )
                , position = ( 10, 650 )
                , text = { content = "⟳", color = Color.black }
                , backgroundColor = Color.rgb255 236 240 241
                , buttonType = ButtonInit.Rotate
                }
            )
            env
        , Button.component
            (ButtonInitMsg
                { size = ( 50, 50 )
                , position = ( 80, 650 )
                , text = { content = "←", color = Color.black }
                , backgroundColor = Color.rgb255 236 240 241
                , buttonType = ButtonInit.Move Left
                }
            )
            env
        , Button.component
            (ButtonInitMsg
                { size = ( 50, 50 )
                , position = ( 150, 650 )
                , text = { content = "→", color = Color.black }
                , backgroundColor = Color.rgb255 236 240 241
                , buttonType = ButtonInit.Move Right
                }
            )
            env
        , Button.component
            (ButtonInitMsg
                { size = ( 50, 50 )
                , position = ( 220, 650 )
                , text = { content = "↓", color = Color.black }
                , backgroundColor = Color.rgb255 236 240 241
                , buttonType = ButtonInit.Accelerate
                }
            )
            env
        ]


handleComponentMsg : Handler Data SceneCommonData UserData LayerTarget LayerMsg SceneMsg ComponentMsg
handleComponentMsg env compmsg data =
    case compmsg of
        SOMMsg som ->
            ( data, [ Parent <| SOMMsg som ], env )

        _ ->
            ( data, [], env )


update : LayerUpdate SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
update env evt data =
    let
        ( comps1, msgs1, ( env1, block1 ) ) =
            updateComponents env evt data.components

        ( data1, msgs2, env2 ) =
            handleComponentMsgs env1 msgs1 { data | components = comps1 } [] handleComponentMsg
    in
    ( data1, msgs2, ( env2, block1 ) )


updaterec : LayerUpdateRec SceneCommonData UserData LayerTarget LayerMsg SceneMsg Data
updaterec env _ data =
    ( data, [], env )


view : LayerView SceneCommonData UserData Data
view env data =
    viewComponents env data.components


matcher : Matcher Data LayerTarget
matcher _ tar =
    tar == "GameLayer"


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
