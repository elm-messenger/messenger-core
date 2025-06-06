module Messenger.Coordinate.Camera exposing
    ( setCameraPos, setCameraScale, setCameraAngle
    , transformPos, transformPosInverse
    , defaultCamera
    )

{-|


# Camera Tools

@docs setCameraPos, setCameraScale, setCameraAngle
@docs transformPos, transformPosInverse
@docs defaultCamera

-}

import Messenger.Base exposing (GlobalData)
import REGL.Common exposing (Camera)


{-| Set the camera position.
-}
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


{-| Set the camera scale.
-}
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


{-| Set the camera angle.
-}
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


{-| Tranform a position from the virtual canvas to the camera coordinate system.
-}
transformPos : Camera -> ( Float, Float ) -> ( Float, Float )
transformPos camera ( x, y ) =
    let
        scale =
            camera.zoom

        angle =
            camera.rotation

        cosAngle =
            cos angle

        sinAngle =
            sin angle
    in
    if angle == 0 then
        ( (x - camera.x) * scale, (y - camera.y) * scale )

    else
        ( (x - camera.x) * scale * cosAngle - (y - camera.y) * scale * sinAngle
        , (y - camera.y) * scale * cosAngle + (x - camera.x) * scale * sinAngle
        )


{-| Transform a position from the camera coordinate system to the virtual canvas.

This is the inverse of `transformPos`.

-}
transformPosInverse : Camera -> ( Float, Float ) -> ( Float, Float )
transformPosInverse camera ( x, y ) =
    let
        scale =
            camera.zoom

        angle =
            camera.rotation

        cosAngle =
            cos angle

        sinAngle =
            sin angle
    in
    if angle == 0 then
        ( x / scale + camera.x, y / scale + camera.y )

    else
        ( x / scale * cosAngle + y / scale * sinAngle + camera.x
        , y / scale * cosAngle - x / scale * sinAngle + camera.y
        )
