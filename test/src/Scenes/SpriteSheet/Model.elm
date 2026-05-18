module Scenes.SpriteSheet.Model exposing (scene)

{-| Scene configuration module

@docs scene

-}

import Duration
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (UserEvent(..), getSceneStartTime)
import Messenger.GlobalComponents.Transition.Model exposing (genMixedTransitionSOM)
import Messenger.GlobalComponents.Transition.Transitions exposing (fadeMix)
import Messenger.Render.Texture exposing (renderSprite)
import Messenger.Scene.RawScene exposing (RawSceneInit, RawSceneUpdate, RawSceneView, genRawScene)
import Messenger.Scene.Scene exposing (MConcreteScene, SceneStorage)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group)


type alias Data =
    {}


init : RawSceneInit Data UserData SceneMsg
init _ env msg =
    {}


update : RawSceneUpdate Data UserData SceneMsg
update _ env msg data =
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
view runtime env data =
    let
        id =
            runtime

        rate =
            100

        currentAct x =
            String.fromInt (modBy x (floor (getSceneStartTime runtime / rate)))
    in
    group []
        [ renderSprite id ( 100, 300 ) ( 100, 0 ) ("char0" ++ currentAct 13)
        , renderSprite id ( 300, 300 ) ( 100, 0 ) ("char1" ++ currentAct 8)
        , renderSprite id ( 500, 300 ) ( 100, 0 ) ("char2" ++ currentAct 10)
        , renderSprite id ( 700, 300 ) ( 100, 0 ) ("char3" ++ currentAct 10)
        , renderSprite id ( 900, 300 ) ( 100, 0 ) ("char4" ++ currentAct 10)
        , renderSprite id ( 1100, 300 ) ( 100, 0 ) ("char5" ++ currentAct 6)
        , renderSprite id ( 1300, 300 ) ( 100, 0 ) ("char6" ++ currentAct 4)
        , renderSprite id ( 1500, 300 ) ( 100, 0 ) ("char7" ++ currentAct 7)
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
