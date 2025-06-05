module Scenes.Components.SceneBase exposing
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


{-| Layer target type
-}
type alias LayerTarget =
    String


{-| Common data
-}
type alias SceneCommonData =
    {}


{-| General message for layers
-}
type LayerMsg
    = NullLayerMsg
