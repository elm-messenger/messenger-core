module Scenes.Transition.Model exposing (scene)

{-| Scene configuration module

@docs scene

-}

import Color
import Duration
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (UserEvent(..))
import Messenger.GlobalComponents.Transition.Base exposing (nullTransition)
import Messenger.GlobalComponents.Transition.Model exposing (genMixedTransitionSOM, genSequentialTransitionSOM)
import Messenger.GlobalComponents.Transition.Transitions exposing (fadeImgMix, fadeIn, fadeInImg, fadeInWithRenderable, fadeMix, fadeOut, fadeOutImg)
import Messenger.Scene.RawScene exposing (RawSceneInit, RawSceneUpdate, RawSceneView, genRawScene)
import Messenger.Scene.Scene exposing (MConcreteScene, SceneOutputMsg(..), SceneStorage)
import Quantity
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group)
import String exposing (fromInt)


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

        KeyDown 49 ->
            ( data
            , [ genMixedTransitionSOM ( fadeMix, Duration.seconds 1 ) ( "Home", Nothing )
              ]
            , env
            )

        KeyDown 50 ->
            ( data
            , [ genSequentialTransitionSOM ( fadeOut, Duration.seconds 1 ) ( fadeIn, Duration.seconds 1 ) ( "Home", Nothing )
              ]
            , env
            )

        KeyDown 51 ->
            ( data
            , [ genSequentialTransitionSOM ( nullTransition, Quantity.zero ) ( fadeInWithRenderable <| view env data, Duration.seconds 1 ) ( "Home", Nothing )
              ]
            , env
            )

        KeyDown 52 ->
            ( data
            , [ genMixedTransitionSOM ( fadeImgMix "mask" False, Duration.seconds 1 ) ( "Home", Nothing )
              ]
            , env
            )

        KeyDown 53 ->
            ( data
            , [ genSequentialTransitionSOM ( fadeOutImg "mask" False, Duration.seconds 1 ) ( fadeInImg "mask" True, Duration.seconds 1 ) ( "Home", Nothing )
              ]
            , env
            )

        _ ->
            ( data, [], env )


comment : String
comment =
    """Mode:
1: Fading, mixed
2: Fade out black + Fade in black, sequential
3: null + Fade in with Renderable, sequential
4: Clock, mixed
5: Clock x 2, sequential
"""


view : RawSceneView UserData Data
view env data =
    group []
        [ P.clear Color.lightGreen
        , P.textbox ( 0, 30 ) 40 comment "firacode" Color.black
        , P.textbox ( 0, 900 ) 30 (fromInt env.globalData.sceneStartFrame) "firacode" Color.black
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
