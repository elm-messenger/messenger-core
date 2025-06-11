module SceneProtos.Spaceshooter.Components.Bullet.Init exposing
    ( InitData
    , CreateInitData
    )

{-|


# Init module

@docs InitData

-}

import Color exposing (Color)


{-| The data used to initialize the scene
-}
type alias InitData =
    { id : Int
    , velocity : Float
    , position : ( Float, Float )
    , color : Color
    }


type alias CreateInitData =
    { velocity : Float
    , position : ( Float, Float )
    , color : Color
    }
