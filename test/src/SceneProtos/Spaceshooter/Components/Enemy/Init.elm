module SceneProtos.Spaceshooter.Components.Enemy.Init exposing (InitData)

{-|


# Init module

@docs InitData

-}


{-| The data used to initialize the scene
-}
type alias InitData =
    { id : Int
    , velocity : Float
    , position : ( Float, Float )
    , sinF : Float
    , sinA : Float
    , bulletInterval : Float
    }
