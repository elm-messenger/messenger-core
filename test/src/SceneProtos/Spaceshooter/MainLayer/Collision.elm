module SceneProtos.Spaceshooter.MainLayer.Collision exposing (..)

import Lib.Base exposing (SceneMsg)
import Lib.UserData exposing (UserData)
import Messenger.Component.Component exposing (AbstractComponent)
import Messenger.GeneralModel exposing (unroll)
import SceneProtos.Spaceshooter.Components.ComponentBase exposing (BaseData, ComponentMsg(..), ComponentTarget(..))
import SceneProtos.Spaceshooter.SceneBase exposing (SceneCommonData)


type alias GameComponent =
    AbstractComponent SceneCommonData UserData ComponentTarget ComponentMsg BaseData SceneMsg


{-| Judge Collision, return the list of messages to be sent to the game components
-}
judgeCollision : List GameComponent -> List ( ComponentTarget, ComponentMsg )
judgeCollision xs =
    judgeCollisionHelper xs xs []


{-| xs is all the objects

ys are the remaining ones

-}
judgeCollisionHelper : List GameComponent -> List GameComponent -> List ( ComponentTarget, ComponentMsg ) -> List ( ComponentTarget, ComponentMsg )
judgeCollisionHelper xs ys acc =
    case ys of
        [] ->
            acc

        z :: zs ->
            let
                newMsgs =
                    List.foldl
                        (\x lastMsgs ->
                            if (unroll x).baseData.id == (unroll z).baseData.id then
                                lastMsgs

                            else
                                lastMsgs ++ judgeOne z x
                        )
                        acc
                        xs
            in
            judgeCollisionHelper xs zs newMsgs


judgeOne : GameComponent -> GameComponent -> List ( ComponentTarget, ComponentMsg )
judgeOne praw qraw =
    let
        p =
            unroll praw

        q =
            unroll qraw

        p1 =
            p.baseData.position

        ( p1x, p1y ) =
            p.baseData.position

        ( p1w, p1h ) =
            p.baseData.collisionBox

        p2 =
            ( p1x + p1w, p1y + p1h )

        q1 =
            q.baseData.position

        ( q1x, q1y ) =
            q.baseData.position

        ( q1w, q1h ) =
            q.baseData.collisionBox

        q2 =
            ( q1x + q1w, q1y + q1h )
    in
    if judgeSimpleCollision ( p1, p2 ) ( q1, q2 ) then
        [ ( Id p.baseData.id, CollisionMsg q.baseData.ty ), ( Id q.baseData.id, CollisionMsg p.baseData.ty ) ]

    else
        []


{-| judgeSimpleCollision
Simply judge if two rectangle collides.

Here inputs are all the vertices, not width/height

-}
judgeSimpleCollision : ( ( Float, Float ), ( Float, Float ) ) -> ( ( Float, Float ), ( Float, Float ) ) -> Bool
judgeSimpleCollision ( p1, p2 ) ( p3, p4 ) =
    let
        p1x =
            Tuple.first p1

        p1y =
            Tuple.second p1

        p2x =
            Tuple.first p2

        p2y =
            Tuple.second p2

        p3x =
            Tuple.first p3

        p3y =
            Tuple.second p3

        p4x =
            Tuple.first p4

        p4y =
            Tuple.second p4
    in
    p2y >= p3y && p1y <= p4y && p2x >= p3x && p1x <= p4x
