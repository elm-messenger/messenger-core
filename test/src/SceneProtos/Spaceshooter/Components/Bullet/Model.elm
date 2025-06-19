module SceneProtos.Spaceshooter.Components.Bullet.Model exposing (component)

{-| Component model

@docs component

-}

import Color exposing (Color)
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import REGL.BuiltinPrograms as P
import SceneProtos.Spaceshooter.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget(..), emptyBaseData)
import SceneProtos.Spaceshooter.SceneBase exposing (SceneCommonData)


type alias Data =
    { color : Color
    }


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init _ initMsg =
    case initMsg of
        BulletInitMsg msg ->
            ( { color = msg.color }
            , { id = msg.id
              , position = msg.position
              , velocity = msg.velocity
              , alive = True
              , collisionBox = ( 20, 10 )
              , ty = "Bullet"
              }
            )

        _ ->
            ( { color = Color.black }, emptyBaseData )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    case evnt of
        Tick dt ->
            let
                newBullet =
                    { basedata | position = ( Tuple.first basedata.position + basedata.velocity * dt, Tuple.second basedata.position ) }
            in
            ( ( data, newBullet ), [], ( env, False ) )

        _ ->
            ( ( data, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    case msg of
        CollisionMsg "Bullet" ->
            ( ( data, { basedata | alive = False } ), [], env )

        _ ->
            ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view _ data basedata =
    ( P.roundedRect basedata.position ( 20, 10 ) 5 data.color
    , 0
    )


matcher : ComponentMatcher Data BaseData ComponentTarget
matcher _ basedata tar =
    tar == Type basedata.ty || tar == Id basedata.id


componentcon : ConcreteUserComponent Data SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
componentcon =
    { init = init
    , update = update
    , updaterec = updaterec
    , view = view
    , matcher = matcher
    }


{-| Component generator
-}
component : ComponentStorage SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg
component =
    genComponent componentcon
