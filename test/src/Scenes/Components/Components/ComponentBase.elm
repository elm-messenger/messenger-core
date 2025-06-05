module Scenes.Components.Components.ComponentBase exposing (ComponentMsg(..), ComponentTarget, BaseData)

{-|


# Component base

@docs ComponentMsg, ComponentTarget, BaseData

-}

import Scenes.Components.Components.Rect.Init as RectInit
import Scenes.Components.Components.Rect.Msg as RectMsg


{-| Component message
-}
type ComponentMsg
    = RectInit RectInit.InitData
    | RectMsg RectMsg.RectMsg
    | RectReportMsg RectMsg.RectReportMsg
    | NullComponentMsg


{-| Component target
-}
type alias ComponentTarget =
    Int


{-| Component base data
-}
type alias BaseData =
    ()
