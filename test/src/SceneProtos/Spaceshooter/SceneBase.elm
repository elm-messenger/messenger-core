module SceneProtos.Spaceshooter.SceneBase exposing
    ( LayerTarget
    , SceneCommonData
    , LayerMsg(..)
    )

{-|


# SceneBase

Basic data for the scene.

@docs LayerTarget
@docs SceneCommonData
@docs LayerMsg

-}

import SceneProtos.Spaceshooter.MainLayer.Init as MainInit


{-| Layer target type
-}
type alias LayerTarget =
    String


{-| Common data
-}
type alias SceneCommonData =
    { score : Int
    , gameOver : Bool
    }


{-| General message for layers
-}
type LayerMsg scenemsg
    = MainInitData (MainInit.InitData SceneCommonData scenemsg)
    | FrontInitData String
    | NullLayerMsg
