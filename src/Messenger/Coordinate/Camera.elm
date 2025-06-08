module Messenger.Coordinate.Camera exposing
    ( setCameraPos, setCameraScale, setCameraAngle
    , defaultCamera, worldToView, viewToWorld
    )

{-|


# Camera Tools

@docs setCameraPos, setCameraScale, setCameraAngle
@docs defaultCamera, worldToView, viewToWorld

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


{-| Tranform a position from the world coordinate system to the view (camera) coordinate system.
-}
worldToView : Camera -> ( Float, Float ) -> ( Float, Float )
worldToView camera ( x, y ) =
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
        ( (x - camera.x) * scale * cosAngle + (y - camera.y) * scale * sinAngle
        , (y - camera.y) * scale * cosAngle - (x - camera.x) * scale * sinAngle
        )


{-| Transform a position from the view coordinate system to the world coordinate system.

This is the inverse of `worldToView`.

-}
viewToWorld : Camera -> ( Float, Float ) -> ( Float, Float )
viewToWorld camera ( x, y ) =
    let
        scale =
            camera.zoom

        xs =
            x / scale

        ys =
            y / scale

        angle =
            camera.rotation

        cosAngle =
            cos angle

        sinAngle =
            sin angle
    in
    if angle == 0 then
        ( xs + camera.x, ys + camera.y )

    else
        ( xs * cosAngle - ys * sinAngle + camera.x
        , ys * cosAngle + xs * sinAngle + camera.y
        )
