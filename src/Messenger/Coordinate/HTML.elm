module Messenger.Coordinate.HTML exposing (genAttribute)

{-|


# HTML Coordinate Lib

Helpers for positioning `extraHTML` elements in the same virtual coordinate
system as the game canvas.

@docs genAttribute

-}

import Html exposing (Attribute)
import Html.Attributes exposing (style)
import Messenger.Base exposing (InternalData)
import Messenger.Coordinate.Coordinates exposing (fixedPosToReal, lengthToReal)


{-| Generate HTML attributes for a virtual rectangle.

The first argument is `env.globalData.internalData`. The `( x, y )` argument is
the virtual top-left position, and `( w, h )` is the virtual size. The generated
attributes use fixed browser positioning and automatically account for canvas
scale and offset.

-}
genAttribute : InternalData -> ( Float, Float ) -> ( Float, Float ) -> List (Attribute msg)
genAttribute gd ( x, y ) ( w, h ) =
    let
        ( rx, ry ) =
            fixedPosToReal gd ( x, y )

        ( rw, rh ) =
            ( lengthToReal gd w, lengthToReal gd h )
    in
    [ style "position" "fixed"
    , style "left" (String.fromFloat rx ++ "px")
    , style "top" (String.fromFloat ry ++ "px")
    , style "width" (String.fromFloat rw ++ "px")
    , style "height" (String.fromFloat rh ++ "px")
    ]
