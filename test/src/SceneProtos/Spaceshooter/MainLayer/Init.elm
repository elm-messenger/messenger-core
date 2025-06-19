module SceneProtos.Spaceshooter.MainLayer.Init exposing (InitData)

{-|


# Init module

@docs InitData

-}

import Lib.UserData exposing (UserData)
import Messenger.Component.Component exposing (AbstractComponent)
import SceneProtos.Spaceshooter.Components.ComponentBase exposing (BaseData, ComponentMsg, ComponentTarget)


{-| The data used to initialize the scene
-}
type alias InitData cdata scenemsg =
    { components : List (AbstractComponent cdata UserData ComponentTarget ComponentMsg BaseData scenemsg)
    }
