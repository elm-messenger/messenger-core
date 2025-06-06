module Scenes.Rain.Model exposing (scene)

{-| Scene configuration module

@docs scene

-}

import Color
import Lib.Base exposing (SceneMsg)
import Lib.Programs.PointLight exposing (plight)
import Lib.UserData exposing (UserData)
import List exposing (length)
import Messenger.Base exposing (UserEvent(..))
import Messenger.Scene.RawScene exposing (RawSceneInit, RawSceneUpdate, RawSceneView, genRawScene)
import Messenger.Scene.Scene exposing (MConcreteScene, SceneStorage)
import REGL.BuiltinPrograms exposing (clear, lines)
import REGL.Common exposing (group)
import Random


type alias Data =
    { rainPos : List ( ( Float, Float ), ( Float, Float ) )
    }


genRandomPos : Int -> Int -> Float -> Float -> List ( ( Float, Float ), ( Float, Float ) )
genRandomPos nofl t ws we =
    let
        rd =
            Random.list nofl (Random.pair (Random.float 0 2000) (Random.float ws we))

        seed =
            Random.initialSeed t

        ( ng, seed2 ) =
            Random.step rd seed

        speedr =
            Random.list nofl (Random.pair (Random.float -2 -1) (Random.float 5 20))

        ( speed, _ ) =
            Random.step speedr seed2

        rpos =
            List.map2 (\( x, y ) ( sx, sy ) -> ( ( x, y ), ( x + sx, y + sy ) )) ng speed
    in
    rpos


init : RawSceneInit Data UserData SceneMsg
init env msg =
    { rainPos = genRandomPos 100 env.globalData.globalStartFrame 0 1080
    }


updateRain : Int -> Float -> Data -> Data
updateRain seed t data =
    let
        oldPos =
            List.filterMap
                (\( ( x, y ), ( sx, sy ) ) ->
                    if y > 1080 then
                        Nothing

                    else
                        let
                            vx =
                                sx - x

                            vy =
                                sy - y
                        in
                        Just ( ( x + vx * t, y + vy * t ), ( sx + vx * t, sy + vy * t ) )
                )
                data.rainPos

        idealRain =
            500

        speed =
            10

        moreRain =
            if length oldPos < idealRain then
                speed

            else
                0

        newPos =
            genRandomPos moreRain seed -30 -20
    in
    { rainPos = newPos ++ oldPos
    }


update : RawSceneUpdate Data UserData SceneMsg
update env msg data =
    case msg of
        Tick t ->
            ( updateRain env.globalData.globalStartFrame (t * 0.1) data, [], env )

        _ ->
            ( data, [], env )


view : RawSceneView UserData Data
view env data =
    group []
        [ clear Color.black
        , lines data.rainPos (Color.rgba 0.7 0.7 0.8 0.8)
        , plight 1500 200 500 (Color.rgba 1 1 1 1)
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
