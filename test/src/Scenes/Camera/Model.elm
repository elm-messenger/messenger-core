module Scenes.Camera.Model exposing (scene)

{-| Scene configuration module

@docs scene

-}

import Color
import Duration
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (UserEvent(..))
import Messenger.Coordinate.Camera exposing (defaultCamera, setCameraAngle, setCameraPos, setCameraScale)
import Messenger.GlobalComponents.Transition.Model exposing (genMixedTransitionSOM)
import Messenger.GlobalComponents.Transition.Transitions exposing (fadeMix)
import Messenger.Scene.RawScene exposing (RawSceneInit, RawSceneUpdate, RawSceneView, genRawScene)
import Messenger.Scene.Scene exposing (MConcreteScene, SceneStorage)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group, groupWithCamera)


type alias Data =
    {}


init : RawSceneInit Data UserData SceneMsg
init env msg =
    {}


update : RawSceneUpdate Data UserData SceneMsg
update env msg data =
    let
        gd =
            env.globalData

        oldcam =
            gd.camera
    in
    case msg of
        KeyDown 8 ->
            ( data
            , [ genMixedTransitionSOM ( fadeMix, Duration.seconds 1 ) ( "Home", Nothing )
              ]
            , env
            )

        KeyDown 49 ->
            let
                ng =
                    setCameraScale 0.5 gd
            in
            ( data
            , []
            , { env | globalData = ng }
            )

        KeyDown 50 ->
            let
                ng =
                    setCameraPos ( oldcam.x + 100, oldcam.y ) gd
            in
            ( data
            , []
            , { env | globalData = ng }
            )

        KeyDown 51 ->
            let
                ng =
                    setCameraPos ( oldcam.x - 100, oldcam.y ) gd
            in
            ( data
            , []
            , { env | globalData = ng }
            )

        KeyDown 52 ->
            let
                ng =
                    setCameraAngle (oldcam.rotation + pi / 4) gd
            in
            ( data
            , []
            , { env | globalData = ng }
            )

        KeyDown 53 ->
            let
                ng =
                    gd
                        |> setCameraPos ( gd.internalData.virtualWidth / 2, gd.internalData.virtualHeight / 2 )
                        |> setCameraScale 1
                        |> setCameraAngle 0
            in
            ( data
            , []
            , { env | globalData = ng }
            )

        _ ->
            ( data, [], env )


comment : String
comment =
    """Mode:
1: 0.5x
2. Move Camera right 100
3. Move Camera left 100
4. Rotate Camera PI/4
5. Reset Camera
"""


view : RawSceneView UserData Data
view env data =
    group []
        [ P.clear Color.lightBlue
        , P.textbox ( 0, 30 ) 40 comment "firacode" Color.black
        , groupWithCamera (defaultCamera env.globalData)
            []
            [ P.textbox ( 100, 0 ) 30 "Some fixed text on the screen" "firacode" Color.black
            ]
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
