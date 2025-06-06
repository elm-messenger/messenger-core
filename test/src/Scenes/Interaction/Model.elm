module Scenes.Interaction.Model exposing (scene)

{-| Scene configuration module

@docs scene

-}

import Color
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (addCommonData)
import Messenger.Component.Component exposing (AbstractComponent, updateComponents, viewComponents)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import Messenger.Layer.Layer exposing (Handler, handleComponentMsgs)
import Messenger.Scene.RawScene exposing (RawSceneInit, RawSceneUpdate, RawSceneView, genRawScene)
import Messenger.Scene.Scene exposing (MConcreteScene, SceneStorage)
import REGL
import Scenes.Interaction.Components.Button.Init as ButtonInit
import Scenes.Interaction.Components.Button.Model as Button
import Scenes.Interaction.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget)
import Scenes.Interaction.SceneBase exposing (SceneCommonData)


type alias Data =
    { components : List (AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg)
    }


init : RawSceneInit Data UserData SceneMsg
init env msg =
    { components =
        [ Button.component (ButtonInitMsg <| ButtonInit.InitData ( 200, 200 ) ( 100, 50 ) Color.green "NICE") env
        ]
    }


handleComponentMsg : Handler Data SceneCommonData UserData ComponentTarget ComponentMsg SceneMsg ComponentMsg
handleComponentMsg env compmsg data =
    case compmsg of
        SOMMsg som ->
            ( data, [ Parent <| SOMMsg som ], env )

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
    ( data1, sommsgs, env2 )


view : RawSceneView UserData Data
view env data =
    viewComponents env data.components


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
