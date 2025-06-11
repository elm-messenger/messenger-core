module Lib.Resources exposing (resources)

{-|


# Textures

@docs resources

-}

import Lib.Programs.PointLight as PointLight
import Messenger.Resources.Base exposing (ResourceDef(..), ResourceDefs)


{-| Resources
-}
resources : ResourceDefs
resources =
    allTexture ++ allAudio ++ allFont ++ allProgram


{-| allTexture

A list of all the textures.

Add your textures here. Don't worry if your list is too long.

Example:

        [ ( "ball", TextureRes "assets/img/ball.png" Nothing )
        , ( "car", TextureRes "assets/img/car.jpg" Nothing )
        ]

-}
allTexture : ResourceDefs
allTexture =
    [ ( "enemy", TextureRes "assets/img/enemy.png" Nothing )
    , ( "mask", TextureRes "assets/img/mask.jpg" Nothing )
    , ( "ship", TextureRes "assets/img/ship.png" Nothing )
    ]


{-| All audio assets.

The format is similar to `allTexture`.

Example:

        [ ( "test", AudioRes "assets/test.ogg" )
        ]

-}
allAudio : ResourceDefs
allAudio =
    [ ( "test", AudioRes "assets/aud/test.ogg" )
    ]


{-| All fonts.

Example:

        [ ( "firacode", FontRes "assets/FiraCode-Regular.png" "assets/FiraCode-Regular.json" )
        ]

-}
allFont : ResourceDefs
allFont =
    [ ( "firacode", FontRes "assets/fonts/font_0.png" "assets/fonts/FiraCode-Regular.json" )
    ]


{-| All programs.

Example:

        [ ( "test", ProgramRes myprogram )
        ]

-}
allProgram : ResourceDefs
allProgram =
    [ ( "plight", ProgramRes PointLight.prog )
    ]
