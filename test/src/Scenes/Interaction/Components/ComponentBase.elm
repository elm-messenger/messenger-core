module Scenes.Interaction.Components.ComponentBase exposing (ComponentMsg(..), ComponentTarget, BaseData)

{-|


# Component base

@docs ComponentMsg, ComponentTarget, BaseData

-}

import Scenes.Interaction.Components.Button.Init as ButtonInit
import Scenes.Interaction.Components.Button.Msg as ButtonMsg
import Scenes.Interaction.Components.Slider.Init as SliderInit
import Scenes.Interaction.Components.Slider.Msg as SliderMsg


{-| Component message
-}
type ComponentMsg
    = ButtonInitMsg ButtonInit.InitData
    | ButtonUpdateMsg ButtonMsg.ButtonMsg
    | SliderInitMsg SliderInit.InitData
    | SliderUpdateMsg SliderMsg.SliderMsg
    | NullComponentMsg


{-| Component target
-}
type alias ComponentTarget =
    String


{-| Component base data
-}
type alias BaseData =
    ()
