module Scenes.AllScenes exposing (allScenes)

{-|


# AllScenes

Record all the scenes here

@docs allScenes

-}

import Dict
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Scene.Scene exposing (AllScenes)
import Scenes.Audio.Model as Audio
import Scenes.Camera.Model as Camera
import Scenes.Components.Model as Components
import Scenes.Home.Model as Home
import Scenes.Interaction.Model as Interaction
import Scenes.Rain.Model as Rain
import Scenes.SSLevel1.Model as SSLevel1
import Scenes.SSLevel2.Model as SSLevel2
import Scenes.Stress.Model as Stress
import Scenes.Tetris.Model as Tetris
import Scenes.Transition.Model as Transition


{-| All Scenes

Store all the scenes with their name here.

-}
allScenes : AllScenes UserData SceneMsg
allScenes =
    Dict.fromList
        [ ( "Home", Home.scene )
        , ( "Stress", Stress.scene )
        , ( "Audio", Audio.scene )
        , ( "Transition", Transition.scene )
        , ( "Camera", Camera.scene )
        , ( "Interaction", Interaction.scene )
        , ( "Components", Components.scene )
        , ( "Tetris", Tetris.scene )
        , ( "Rain", Rain.scene )
        , ( "SSLevel1", SSLevel1.scene )
        , ( "SSLevel2", SSLevel2.scene )
        ]
