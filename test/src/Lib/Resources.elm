module Lib.Resources exposing (resources)

{-|


# Textures

@docs resources

-}

import Dict exposing (Dict)
import Messenger.UserConfig exposing (Resources)
import REGL
import REGL.Program exposing (REGLProgram)


{-| Resources
-}
resources : Resources
resources =
    { allTexture = allTexture
    , allAudio = allAudio
    , allFont = allFont
    , allProgram = []
    }


{-| allTexture

A list of all the textures.

Add your textures here. Don't worry if your list is too long. You can split those resources according to their usage.

Example:

    Dict.fromList
        [ ( "ball", "assets/img/ball.png" )
        , ( "car", "assets/img/car.jpg" )
        ]

-}
allTexture : Dict String ( String, Maybe REGL.TextureOptions )
allTexture =
    Dict.fromList
        [ ( "ship", ( "assets/enemy.png", Nothing ) )
        , ( "mask", ( "assets/mask.jpg", Nothing ) )
        ]


{-| All audio assets.

The format is the same with `allTexture`.

-}
allAudio : Dict.Dict String String
allAudio =
    Dict.fromList
        [ ( "test", "assets/test.ogg" )
        ]


allFont : List ( String, String, String )
allFont =
    [ ( "firacode", "assets/FiraCode-Regular.png", "assets/FiraCode-Regular.json" )
    ]


allProgram : List ( String, REGLProgram )
allProgram =
    []
