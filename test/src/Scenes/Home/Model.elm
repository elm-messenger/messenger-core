module Scenes.Home.Model exposing (scene)

{-| Scene configuration module

@docs scene

-}

import Color
import Duration
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (UserEvent(..))
import Messenger.Coordinate.Camera exposing (defaultCamera, setCameraPos, setCameraScale)
import Messenger.GlobalComponents.AssetLoading.Model as InitScene
import Messenger.GlobalComponents.Transition.Model exposing (genSequentialTransitionSOM)
import Messenger.GlobalComponents.Transition.Transitions exposing (fadeIn, fadeOut)
import Messenger.Render.Texture exposing (renderSprite)
import Messenger.Resources.Base exposing (ResourceDef(..))
import Messenger.Scene.RawScene exposing (RawSceneInit, RawSceneUpdate, RawSceneView, genRawScene)
import Messenger.Scene.Scene exposing (MConcreteScene, SceneOutputMsg(..), SceneStorage)
import REGL
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group)


type alias Data =
    {}


init : RawSceneInit Data UserData SceneMsg
init env msg =
    {}


update : RawSceneUpdate Data UserData SceneMsg
update env msg data =
    case msg of
        KeyDown 49 ->
            ( data
            , [ genSequentialTransitionSOM ( fadeOut, Duration.seconds 1 ) ( fadeIn, Duration.seconds 1 ) ( "Transition", Nothing )
              ]
            , env
            )

        KeyDown 50 ->
            ( data
            , [ SOMChangeScene Nothing "Stress"
              ]
            , env
            )

        KeyDown 51 ->
            ( data
            , [ SOMChangeScene Nothing "Audio"
              ]
            , env
            )

        KeyDown 52 ->
            ( data
            , [ SOMChangeFPS (REGL.Millisecond 30)
              ]
            , env
            )

        KeyDown 53 ->
            ( data
            , [ SOMChangeFPS REGL.AnimationFrame
              ]
            , env
            )

        KeyDown 54 ->
            ( data
            , [ SOMLoadResource "sq" (TextureRes "assets/img/sq.jpg" Nothing)
              , SOMLoadGC (InitScene.genGC Nothing)
              ]
            , env
            )

        KeyDown 55 ->
            ( data
            , [ SOMChangeScene Nothing "Camera"
              ]
            , env
            )

        KeyDown 56 ->
            ( data
            , [ SOMChangeScene Nothing "Components"
              ]
            , env
            )

        KeyDown 57 ->
            let
                gd =
                    env.globalData
            in
            ( data
            , [ SOMChangeScene Nothing "Tetris"
              ]
            , { env | globalData = gd |> setCameraPos ( 220, 400 ) |> setCameraScale 1.5 }
            )

        KeyDown 81 ->
            ( data
            , [ SOMChangeScene Nothing "Interaction"
              ]
            , env
            )

        _ ->
            ( data, [], env )


prompt : String
prompt =
    """Instructions:
Press the following key to trigger actions.
Press Backspace to return to the menu.
-= Menu =-
1. Transition Test
2. Rendering Stress Test
3. Audio Test
4. Change FPS to 30ms per frame
5. Change FPS to Animation Frame
6. Load a new image (along with the asset loading GC)
7. Camera Test
8. Component Test
9. Tetris
q. Interaction
"""


view : RawSceneView UserData Data
view env data =
    group []
        [ P.clear Color.lightYellow
        , P.textbox ( 0, 30 ) 50 prompt "firacode" Color.black
        , renderSprite env.globalData.internalData ( 1200, 0 ) ( 0, 200 ) "ship"
        , renderSprite env.globalData.internalData ( 1500, 300 ) ( 0, 200 ) "sq"
        ]


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
