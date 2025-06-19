module SceneProtos.Spaceshooter.Model exposing (genScene)

{-| Scene configuration module

@docs genScene

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (Env, addCommonData)
import Messenger.Scene.LayeredScene exposing (LayeredSceneEffectFunc, LayeredSceneLevelInit, LayeredSceneProtoInit, genLayeredScene, initCompose)
import Messenger.Scene.Scene exposing (SceneStorage)
import SceneProtos.Spaceshooter.FrontLayer.Model as FrontLayer
import SceneProtos.Spaceshooter.Init exposing (InitData)
import SceneProtos.Spaceshooter.MainLayer.Model as MainLayer
import SceneProtos.Spaceshooter.SceneBase exposing (..)


commonDataInit : Env () UserData -> Maybe (InitData SceneMsg) -> SceneCommonData
commonDataInit _ _ =
    { score = 0
    , gameOver = False
    }


init : LayeredSceneProtoInit SceneCommonData UserData LayerTarget (LayerMsg SceneMsg) SceneMsg (InitData SceneMsg)
init env data =
    let
        cd =
            commonDataInit env data

        envcd =
            addCommonData cd env

        comps =
            List.map (\x -> x envcd)
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
        [ MainLayer.layer (MainInitData { components = comps }) envcd
        , FrontLayer.layer (FrontInitData levelName) envcd
        ]
    }


settings : LayeredSceneEffectFunc SceneCommonData UserData LayerTarget (LayerMsg SceneMsg) SceneMsg
settings _ _ _ =
    []


{-| Scene generator
-}
genScene : LayeredSceneLevelInit UserData SceneMsg (InitData SceneMsg) -> SceneStorage UserData SceneMsg
genScene initd =
    genLayeredScene (initCompose init initd) settings
