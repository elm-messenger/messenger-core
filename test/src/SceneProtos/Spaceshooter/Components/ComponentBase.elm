module SceneProtos.Spaceshooter.Components.ComponentBase exposing
    ( ComponentMsg(..), ComponentTarget(..), BaseData
    , emptyBaseData
    )

{-|


# Component base

@docs ComponentMsg, ComponentTarget, BaseData

-}

import SceneProtos.Spaceshooter.Components.Bullet.Init as Bullet
import SceneProtos.Spaceshooter.Components.Enemy.Init as Enemy
import SceneProtos.Spaceshooter.Components.Ship.Init as Ship


{-| Component message
-}
type ComponentMsg
    = NewBulletMsg Bullet.CreateInitData
    | CollisionMsg String
    | GameOverMsg
    | BulletInitMsg Bullet.InitData
    | EnemyInitMsg Enemy.InitData
    | ShipInitMsg Ship.InitData
    | NullComponentMsg


{-| Component target
-}
type ComponentTarget
    = Type String
    | Id Int


{-| Component base data
-}
type alias BaseData =
    { id : Int
    , ty : String
    , position : ( Float, Float )
    , velocity : Float
    , collisionBox : ( Float, Float )
    , alive : Bool
    }


emptyBaseData : BaseData
emptyBaseData =
    { id = 0
    , position = ( 0, 0 )
    , velocity = 0
    , collisionBox = ( 0, 0 )
    , alive = True
    , ty = ""
    }
