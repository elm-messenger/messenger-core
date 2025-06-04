module Scenes.Stress.Model exposing (scene)

{-| Scene configuration module

@docs scene

-}

import Color
import Duration
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (UserEvent(..))
import Messenger.GlobalComponents.Transition.Model exposing (genMixedTransitionSOM)
import Messenger.GlobalComponents.Transition.Transitions exposing (fadeMix)
import Messenger.Scene.RawScene exposing (RawSceneInit, RawSceneUpdate, RawSceneView, genRawScene)
import Messenger.Scene.Scene exposing (MConcreteScene, SceneStorage)
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
        KeyDown 8 ->
            ( data
            , [ genMixedTransitionSOM ( fadeMix, Duration.seconds 1 ) ( "Home", Nothing )
              ]
            , env
            )

        _ ->
            ( data, [], env )


view : RawSceneView UserData Data
view env data =
    let
        time =
            env.globalData.sceneStartFrame
    in
    group [] <|
        P.clear Color.white
            :: P.textbox ( 0, 0 ) 50 "[Backspace] to go back to Home" "firacode" Color.black
            :: (List.concat <|
                    List.map
                        (\x ->
                            List.map
                                (\y ->
                                    P.centeredTexture ( toFloat x * 20 + toFloat time, toFloat y * 20 ) ( 20, 20 ) 0 "ship"
                                )
                                (List.range 0 50)
                        )
                        (List.range 0 100)
               )


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
