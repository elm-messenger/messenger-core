module Messenger.Recursion exposing
    ( updateObjects, updateObjectsWithTarget
    , removeObjects
    )

{-|


# Recursion List

Low-level helpers for updating lists of Messenger general models.

Most games should use the component and layer helpers generated in templates.
Use this module when building your own abstraction over
`Messenger.GeneralModel.AbstractGeneralModel`.

@docs updateObjects, updateObjectsWithTarget
@docs removeObjects

-}

import List exposing (reverse)
import Messenger.GeneralModel exposing (AbstractGeneralModel, Msg(..), MsgBase, unroll)


{-| Update every object once with an event, then deliver generated target messages.

The returned tuple contains the updated objects, parent/system messages, and the
final environment plus a block flag. If an object blocks the event, later objects
do not receive the original event, but queued target messages are still delivered
afterwards.

-}
updateObjects : envro -> env -> event -> List (AbstractGeneralModel envro env event tar msg ren bdata sommsg) -> ( List (AbstractGeneralModel envro env event tar msg ren bdata sommsg), List (MsgBase msg sommsg), ( env, Bool ) )
updateObjects envro env evt objs =
    let
        ( newObjs, ( newMsgUnfinished, newMsgFinished ), ( newEnv, newBlock ) ) =
            updateOnce envro env evt objs

        ( resObj, resMsg, resEnv ) =
            updateRemain envro newEnv ( newMsgUnfinished, newMsgFinished ) newObjs
    in
    ( resObj, resMsg, ( resEnv, newBlock ) )


{-| Deliver target messages to a list of objects.

Each `( target, msg )` pair is sent to every object whose matcher accepts the
target. Messages generated during delivery are recursively delivered until no
target messages remain.

-}
updateObjectsWithTarget : envro -> env -> List ( tar, msg ) -> List (AbstractGeneralModel envro env event tar msg ren bdata sommsg) -> ( List (AbstractGeneralModel envro env event tar msg ren bdata sommsg), List (MsgBase msg sommsg), env )
updateObjectsWithTarget envro env msgs objs =
    updateRemain envro env ( msgs, [] ) objs


{-| Remove all objects that match a target.
-}
removeObjects : tar -> List (AbstractGeneralModel envro env event tar msg ren bdata sommsg) -> List (AbstractGeneralModel envro env event tar msg ren bdata sommsg)
removeObjects t xs =
    List.filter (\x -> not <| (unroll x).matcher t) xs



-- Below are some helper functions


updateOne : envro -> env -> event -> List (AbstractGeneralModel envro env event tar msg ren bdata sommsg) -> List (AbstractGeneralModel envro env event tar msg ren bdata sommsg) -> List ( tar, msg ) -> List (MsgBase msg sommsg) -> ( List (AbstractGeneralModel envro env event tar msg ren bdata sommsg), ( List ( tar, msg ), List (MsgBase msg sommsg) ), ( env, Bool ) )
updateOne envro lastEnv evt objs lastObjs lastMsgUnfinished lastMsgFinished =
    case objs of
        ele :: restObjs ->
            let
                ( newObj, newMsg, ( newEnv, block ) ) =
                    (unroll ele).update envro lastEnv evt

                finishedMsg =
                    List.filterMap
                        (\m ->
                            case m of
                                Parent x ->
                                    Just x

                                _ ->
                                    Nothing
                        )
                        newMsg

                unfinishedMsg =
                    List.filterMap
                        (\m ->
                            case m of
                                Parent _ ->
                                    Nothing

                                Other msg ->
                                    Just msg
                        )
                        newMsg
            in
            if block then
                ( reverse restObjs ++ newObj :: lastObjs, ( lastMsgUnfinished ++ unfinishedMsg, lastMsgFinished ++ finishedMsg ), ( newEnv, block ) )

            else
                updateOne envro newEnv evt restObjs (newObj :: lastObjs) (lastMsgUnfinished ++ unfinishedMsg) (lastMsgFinished ++ finishedMsg)

        [] ->
            ( lastObjs, ( lastMsgUnfinished, lastMsgFinished ), ( lastEnv, False ) )


updateOnce : envro -> env -> event -> List (AbstractGeneralModel envro env event tar msg ren bdata sommsg) -> ( List (AbstractGeneralModel envro env event tar msg ren bdata sommsg), ( List ( tar, msg ), List (MsgBase msg sommsg) ), ( env, Bool ) )
updateOnce envro env evt objs =
    updateOne envro env evt (reverse objs) [] [] []


{-| Recursively update remaining objects
-}
updateRemain : envro -> env -> ( List ( tar, msg ), List (MsgBase msg sommsg) ) -> List (AbstractGeneralModel envro env event tar msg ren bdata sommsg) -> ( List (AbstractGeneralModel envro env event tar msg ren bdata sommsg), List (MsgBase msg sommsg), env )
updateRemain envro env ( unfinishedMsg, finishedMsg ) objs =
    if List.isEmpty unfinishedMsg then
        ( objs, finishedMsg, env )

    else
        let
            ( newObjs, ( newUnfinishedMsg, newFinishedMsg ), newEnv ) =
                List.foldl
                    (\ele ( lastObjs, ( lastMsgUnfinished, lastMsgFinished ), lastEnv ) ->
                        let
                            msgMatched =
                                List.filterMap
                                    (\( tar, msg ) ->
                                        if (unroll ele).matcher tar then
                                            Just msg

                                        else
                                            Nothing
                                    )
                                    unfinishedMsg
                        in
                        if List.isEmpty msgMatched then
                            -- No need to update
                            ( lastObjs ++ [ ele ], ( lastMsgUnfinished, lastMsgFinished ), lastEnv )

                        else
                            -- Need update
                            let
                                -- Update the object with all messages in msgMatched
                                ( newObj, ( newMsgUnfinished, newMsgFinished ), newEnv2 ) =
                                    List.foldl
                                        (\msg ( lastObj2, ( lastMsgUnfinished2, lastMsgFinished2 ), lastEnv2 ) ->
                                            let
                                                ( newEle, newMsgs, newEnv3 ) =
                                                    (unroll lastObj2).updaterec envro lastEnv2 msg

                                                finishedMsgs =
                                                    List.filterMap
                                                        (\nmsg ->
                                                            case nmsg of
                                                                Parent pmsg ->
                                                                    Just pmsg

                                                                Other _ ->
                                                                    Nothing
                                                        )
                                                        newMsgs

                                                unfinishedMsgs =
                                                    List.filterMap
                                                        (\nmsg ->
                                                            case nmsg of
                                                                Parent _ ->
                                                                    Nothing

                                                                Other omsg ->
                                                                    Just omsg
                                                        )
                                                        newMsgs
                                            in
                                            ( newEle, ( lastMsgUnfinished2 ++ unfinishedMsgs, lastMsgFinished2 ++ finishedMsgs ), newEnv3 )
                                        )
                                        ( ele, ( [], [] ), lastEnv )
                                        msgMatched
                            in
                            ( lastObjs ++ [ newObj ], ( lastMsgUnfinished ++ newMsgUnfinished, lastMsgFinished ++ newMsgFinished ), newEnv2 )
                    )
                    ( [], ( [], [] ), env )
                    objs
        in
        updateRemain envro newEnv ( newUnfinishedMsg, finishedMsg ++ newFinishedMsg ) newObjs
