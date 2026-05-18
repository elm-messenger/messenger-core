module Scenes.Tetris.Model exposing (scene)

{-| Scene configuration module

@docs scene

-}

import Lib.Base exposing (SceneMsg)
import Lib.Tetris.Tetriminos as Tetriminos
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (Env, Runtime, addCommonData, getCurrentTimeStamp)
import Messenger.Scene.LayeredScene exposing (LayeredSceneEffectFunc, LayeredSceneInit, genLayeredScene)
import Messenger.Scene.Scene exposing (SceneStorage)
import Scenes.Tetris.FrontLayer.Model as FrontLayer
import Scenes.Tetris.GameLayer.Model as GameLayer
import Scenes.Tetris.SceneBase exposing (..)


commonDataInit : Runtime -> Env () UserData -> Maybe SceneMsg -> SceneCommonData
commonDataInit runtime _ _ =
    { state = Stopped
    , score = 0
    , lines = 0
    , next = Tetriminos.random <| round (getCurrentTimeStamp runtime)
    }


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
        [ GameLayer.layer NullLayerMsg runtime envcd
        , FrontLayer.layer NullLayerMsg runtime envcd
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
