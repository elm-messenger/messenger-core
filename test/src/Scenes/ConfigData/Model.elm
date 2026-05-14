module Scenes.ConfigData.Model exposing (scene)

{-| Scene configuration module

@docs scene

-}

import Color
import Duration
import Json.Decode as Decode
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (Env, Runtime, UserEvent(..), getConfigData)
import Messenger.GlobalComponents.Transition.Model exposing (genMixedTransitionSOM)
import Messenger.GlobalComponents.Transition.Transitions exposing (fadeMix)
import Messenger.Scene.RawScene exposing (RawSceneInit, RawSceneUpdate, RawSceneView, genRawScene)
import Messenger.Scene.Scene exposing (MConcreteScene, SceneStorage)
import REGL.BuiltinPrograms as P
import REGL.Common exposing (group)


type alias Data =
    { texts : List String
    , index : Int
    }


parseTexts : Runtime -> Env () UserData -> List String
parseTexts runtime env =
    case getConfigData "texts" runtime of
        Just raw ->
            case Decode.decodeString (Decode.list Decode.string) raw of
                Ok texts ->
                    texts

                Err _ ->
                    []

        Nothing ->
            []


init : RawSceneInit Data UserData SceneMsg
init runtime env _ =
    { texts = parseTexts runtime env
    , index = 0
    }


update : RawSceneUpdate Data UserData SceneMsg
update _ env msg data =
    case msg of
        KeyDown 8 ->
            ( data
            , [ genMixedTransitionSOM ( fadeMix, Duration.seconds 1 ) ( "Home", Nothing )
              ]
            , env
            )

        KeyDown 13 ->
            ( { data | index = modBy (List.length data.texts) (data.index + 1) }
            , []
            , env
            )

        _ ->
            ( data, [], env )


view : RawSceneView UserData Data
view _ env data =
    let
        currentText =
            Maybe.withDefault "" <|
                List.head <|
                    List.drop data.index data.texts
    in
    group []
        [ P.clear Color.lightYellow
        , P.textbox ( 0, 30 ) 40 "Press Enter to show next" "firacode" Color.black
        , P.textbox ( 0, 100 ) 40 currentText "firacode" Color.black
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
