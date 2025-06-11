module SceneProtos.Spaceshooter.Components.Enemy.Model exposing (component)

{-| Component model

@docs component

-}

import Color
import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Base exposing (UserEvent(..))
import Messenger.Component.Component exposing (ComponentInit, ComponentMatcher, ComponentStorage, ComponentUpdate, ComponentUpdateRec, ComponentView, ConcreteUserComponent, genComponent)
import Messenger.GeneralModel exposing (Msg(..), MsgBase(..))
import REGL.BuiltinPrograms as P
import SceneProtos.Spaceshooter.Components.Bullet.Init exposing (CreateInitData)
import SceneProtos.Spaceshooter.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget(..), emptyBaseData)
import SceneProtos.Spaceshooter.SceneBase exposing (SceneCommonData)


type alias Data =
    { interval : Float
    , timer : Float
    , sinf : Float
    , sina : Float
    }


init : ComponentInit SceneCommonData UserData ComponentMsg Data BaseData
init _ initMsg =
    case initMsg of
        EnemyInitMsg msg ->
            ( { interval = msg.bulletInterval, sinf = msg.sinF, sina = msg.sinA, timer = 15 }
            , { id = msg.id
              , position = msg.position
              , velocity = msg.velocity
              , alive = True
              , collisionBox = ( 150, 50 )
              , ty = "Enemy"
              }
            )

        _ ->
            ( { interval = 0, sinf = 0, sina = 0, timer = 15 }, emptyBaseData )


update : ComponentUpdate SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
update env evnt data basedata =
    case evnt of
        Tick dt ->
            let
                velx =
                    sin (env.globalData.sceneStartTime / data.sinf) * data.sina

                ( x, y ) =
                    basedata.position

                newEnemy =
                    { basedata | position = ( x + basedata.velocity * dt, y + velx * basedata.velocity * dt ) }

                intModify =
                    max 100 <| floor <| toFloat env.commonData.score / 2
            in
            if data.timer >= (data.interval - toFloat intModify) then
                -- Generate a new bullet
                ( ( { data | timer = 0 }, newEnemy ), [ Parent <| OtherMsg <| NewBulletMsg (CreateInitData -1 ( x - 60, y + 5 ) Color.red) ], ( env, False ) )

            else
                ( ( { data | timer = data.timer + dt }, newEnemy ), [], ( env, False ) )

        _ ->
            ( ( data, basedata ), [], ( env, False ) )


updaterec : ComponentUpdateRec SceneCommonData Data UserData SceneMsg ComponentTarget ComponentMsg BaseData
updaterec env msg data basedata =
    case msg of
        CollisionMsg "Bullet" ->
            let
                cd =
                    env.commonData
            in
            ( ( data, { basedata | alive = False } ), [], { env | commonData = { cd | score = cd.score + 1 } } )

        _ ->
            ( ( data, basedata ), [], env )


view : ComponentView SceneCommonData UserData Data BaseData
view _ _ basedata =
    ( P.rectTexture basedata.position basedata.collisionBox "enemy", 0 )


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
