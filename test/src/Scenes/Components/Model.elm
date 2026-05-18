module Scenes.Components.Model exposing (scene)

{-| Scene configuration module

@docs scene

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (Env, Runtime, addCommonData)
import Messenger.Scene.LayeredScene exposing (LayeredSceneEffectFunc, LayeredSceneInit, genLayeredScene)
import Messenger.Scene.Scene exposing (SceneStorage)
import Scenes.Components.A.Model as A
import Scenes.Components.B.Model as B
import Scenes.Components.SceneBase exposing (..)


commonDataInit : Runtime -> Env () UserData -> Maybe SceneMsg -> SceneCommonData
commonDataInit _ _ _ =
    {}


init : LayeredSceneInit SceneCommonData UserData LayerTarget LayerMsg SceneMsg
init runtime env msg =
    let
        cd =
            commonDataInit runtime env msg

        envcd =
            addCommonData cd env
    in
    { renderSettings = []
    , commonData = cd
    , layers =
        [ A.layer NullLayerMsg runtime envcd
        , B.layer NullLayerMsg runtime envcd
        ]
    }


settings : LayeredSceneEffectFunc SceneCommonData UserData LayerTarget LayerMsg SceneMsg
settings _ _ _ _ =
    []


{-| Scene generator
-}
scene : SceneStorage UserData SceneMsg
scene =
    genLayeredScene init settings
