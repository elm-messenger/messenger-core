module SceneProtos.Spaceshooter.Components.Ship.Init exposing (InitData)

{-|


# Init module

@docs InitData

-}


{-| The data used to initialize the scene
-}
type alias InitData =
    { id : Int
    , position : ( Float, Float )
    , bulletInterval : Float
    }
