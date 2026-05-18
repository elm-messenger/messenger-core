module SceneProtos.Spaceshooter.Model exposing (genScene)

{-| Scene configuration module

@docs genScene

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (Env, Runtime, addCommonData)
import Messenger.Scene.LayeredScene exposing (LayeredSceneEffectFunc, LayeredSceneLevelInit, LayeredSceneProtoInit, genLayeredScene, initCompose)
import Messenger.Scene.Scene exposing (SceneStorage)
import SceneProtos.Spaceshooter.FrontLayer.Model as FrontLayer
import SceneProtos.Spaceshooter.Init exposing (InitData)
import SceneProtos.Spaceshooter.MainLayer.Model as MainLayer
import SceneProtos.Spaceshooter.SceneBase exposing (..)


commonDataInit : Runtime -> Env () UserData -> Maybe (InitData SceneMsg) -> SceneCommonData
commonDataInit _ _ _ =
    { score = 0
    , gameOver = False
    }


init : LayeredSceneProtoInit SceneCommonData UserData LayerTarget (LayerMsg SceneMsg) SceneMsg (InitData SceneMsg)
init runtime env data =
    let
        cd =
            commonDataInit runtime env data

        envcd =
            addCommonData cd env

        comps =
            List.map (\x -> x runtime envcd)
                (case data of
                    Just d ->
                        d.objects

                    Nothing ->
                        []
                )

        levelName =
            Maybe.withDefault "" <| Maybe.map (\x -> x.level) data
    in
    { renderSettings = []
    , commonData = cd
    , layers =
        [ MainLayer.layer (MainInitData { components = comps }) runtime envcd
        , FrontLayer.layer (FrontInitData levelName) runtime envcd
        ]
    }


settings : LayeredSceneEffectFunc SceneCommonData UserData LayerTarget (LayerMsg SceneMsg) SceneMsg
settings _ _ _ _ =
    []


{-| Scene generator
-}
genScene : LayeredSceneLevelInit UserData SceneMsg (InitData SceneMsg) -> SceneStorage UserData SceneMsg
genScene initd =
    genLayeredScene (initCompose init initd) settings
