module Messenger.Coordinate.Camera exposing
    ( setCameraPos, setCameraScale, setCameraAngle
    , defaultCamera
    )

{-|


# Camera Tools

@docs setCameraPos, setCameraScale, setCameraAngle
@docs defaultCamera

-}

import Messenger.Base exposing (GlobalData)
import REGL.Common exposing (Camera)


setCameraPos : ( Float, Float ) -> GlobalData u -> GlobalData u
setCameraPos ( x, y ) user =
    let
        uc =
            user.camera
    in
    { user
        | camera =
            { uc
                | x = x
                , y = y
            }
    }


setCameraScale : Float -> GlobalData u -> GlobalData u
setCameraScale scale user =
    let
        uc =
            user.camera
    in
    { user
        | camera =
            { uc
                | zoom = scale
            }
    }


setCameraAngle : Float -> GlobalData u -> GlobalData u
setCameraAngle angle user =
    let
        uc =
            user.camera
    in
    { user
        | camera =
            { uc
                | rotation = angle
            }
    }


{-| Default camera for the game.
-}
defaultCamera : GlobalData u -> Camera
defaultCamera gd =
    { x = gd.internalData.virtualWidth / 2, y = gd.internalData.virtualHeight / 2, zoom = 1, rotation = 0 }
