module Messenger.Coordinate.Camera exposing
    ( getCameraPos, getCameraScale, getCameraAngle
    , setCameraPos, setCameraScale, setCameraAngle
    )

{-|


# Camera Tools

@docs getCameraPos, getCameraScale, getCameraAngle
@docs setCameraPos, setCameraScale, setCameraAngle

-}

import Messenger.Base exposing (GlobalData)


getCameraPos : GlobalData u -> ( Float, Float )
getCameraPos user =
    let
        uc =
            user.camera
    in
    ( uc.x, uc.y )


getCameraScale : GlobalData u -> Float
getCameraScale user =
    let
        uc =
            user.camera
    in
    uc.zoom


getCameraAngle : GlobalData u -> Float
getCameraAngle user =
    let
        uc =
            user.camera
    in
    uc.angle


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
                | angle = angle
            }
    }
