module Scenes.SSLevel1.Model exposing (scene)

{-|


# Level configuration module

-}

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (Env)
import Messenger.Scene.RawScene exposing (RawSceneProtoLevelInit)
import Messenger.Scene.Scene exposing (SceneStorage)
import SceneProtos.Spaceshooter.Components.ComponentBase exposing (ComponentMsg(..))
import SceneProtos.Spaceshooter.Components.Enemy.Init as EnemyInit
import SceneProtos.Spaceshooter.Components.Enemy.Model as Enemy
import SceneProtos.Spaceshooter.Components.Ship.Init as ShipInit
import SceneProtos.Spaceshooter.Components.Ship.Model as Ship
import SceneProtos.Spaceshooter.Init exposing (InitData)
import SceneProtos.Spaceshooter.Model exposing (genScene)


initData : Env () UserData -> Maybe SceneMsg -> InitData SceneMsg
initData _ _ =
    { objects =
        [ Ship.component (ShipInitMsg <| ShipInit.InitData 0 ( 100, 500 ) 200)
        , Enemy.component (EnemyInitMsg <| EnemyInit.InitData 1 (-1 / 10) ( 1920, 800 ) 120 30 200)
        ]
    , level = "Level1"
    }


init : RawSceneProtoLevelInit UserData SceneMsg (InitData SceneMsg)
init env msg =
    Just (initData env msg)


{-| Scene storage
-}
scene : SceneStorage UserData SceneMsg
scene =
    genScene init
