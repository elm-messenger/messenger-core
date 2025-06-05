module Lib.UserData exposing (UserData, decodeUserData, encodeUserData)

{-|


# User data

@docs UserData, decodeUserData, encodeUserData

-}

import Json.Decode as Decode exposing (at, decodeString)
import Json.Encode as Encode


{-| User defined data
-}
type alias TetrisUserData =
    { lastMaxScore : Int
    , currentMaxScore : Int
    }


type alias UserData =
    { tetrisData : TetrisUserData
    }


{-| Encoder for the UserData.
-}
encodeUserData : UserData -> String
encodeUserData storage =
    Encode.encode 0
        (Encode.object
            [ ( "maxScore", Encode.int storage.tetrisData.currentMaxScore )
            ]
        )


{-| Decoder for the UserData.
-}
decodeUserData : String -> UserData
decodeUserData ls =
    let
        lastMaxScore =
            Result.withDefault 0 (decodeString (at [ "maxScore" ] Decode.int) ls)
    in
    UserData <| TetrisUserData lastMaxScore lastMaxScore
