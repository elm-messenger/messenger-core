module Scenes.Interaction.Components.ComponentBase exposing (ComponentMsg(..), ComponentTarget, BaseData)

{-|


# Component base

@docs ComponentMsg, ComponentTarget, BaseData

-}

import Scenes.Interaction.Components.Button.Init as ButtonInit
import Scenes.Interaction.Components.Button.Msg as ButtonMsg


{-| Component message
-}
type ComponentMsg
    = ButtonInitMsg ButtonInit.InitData
    | ButtonUpdateMsg ButtonMsg.ButtonMsg
    | NullComponentMsg


{-| Component target
-}
type alias ComponentTarget =
    String


{-| Component base data
-}
type alias BaseData =
    ()
