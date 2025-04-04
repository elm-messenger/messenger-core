module Lib.Resources exposing (resources)

{-|


# Textures

@docs resources

-}

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
    [ ( "ship", TextureRes "assets/enemy.png" Nothing )
    , ( "mask", TextureRes "assets/mask.jpg" Nothing )
    ]


{-| All audio assets.

The format is similar to `allTexture`.

Example:

        [ ( "test", AudioRes "assets/test.ogg" )
        ]

-}
allAudio : ResourceDefs
allAudio =
    [ ( "test", AudioRes "assets/test.ogg" )
    ]


{-| All fonts.

Example:

        [ ( "firacode", FontRes "assets/FiraCode-Regular.png" "assets/FiraCode-Regular.json" )
        ]

-}
allFont : ResourceDefs
allFont =
    [ ( "firacode", FontRes "assets/FiraCode-Regular.png" "assets/FiraCode-Regular.json" )
    ]


{-| All programs.

Example:

        [ ( "test", ProgramRes myprogram )
        ]

-}
allProgram : ResourceDefs
allProgram =
    []
