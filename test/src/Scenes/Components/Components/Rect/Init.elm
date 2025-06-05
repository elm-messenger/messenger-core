module Scenes.Components.Components.Rect.Init exposing (InitData)

{-|


# Init module

@docs InitData

-}

import Color exposing (Color)


{-| The data used to initialize the scene
-}
type alias InitData =
    { left : Float
    , top : Float
    , width : Float
    , height : Float
    , id : Int
    , color : Color
    }
