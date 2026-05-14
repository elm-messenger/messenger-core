module Messenger.Audio.Audio exposing
    ( newAudioChannel
    , audioDuration
    )

{-|


# Audio Module

You can play audio by emitting `SOMPlayAudio` message with the audio ID, a channel, and an option.

The channel is an integer that is used to identify the audio channel.

You **can** play different audio on the same channel at the same time. The previous audio will not be stopped.

However, when you stop the channel, all audio on the channel will be stopped.

If an audio is finished playing, it will be removed from the playing channel.

@docs newAudioChannel
@docs audioDuration

-}

import Dict
import Duration exposing (Duration)
import List exposing (maximum)
import Messenger.Base exposing (Runtime)
import Messenger.Internal as Internal


{-| Generate a new unique audio channel number.

    Pass the read-only Messenger runtime as the parameter. The returned value is a generated channel number.
        - Note: It is really similar to GenUID.

-}
newAudioChannel : Runtime -> Int
newAudioChannel idata =
    let
        internalData =
            Internal.getInternalData idata

        playingChannels =
            List.map (\pl -> pl.channel) internalData.audioRepo.playing
    in
    case maximum playingChannels of
        Just maxChannel ->
            maxChannel + 1

        Nothing ->
            0


{-| Get the duration of an audio by its ID.

Usage : audioDuration runtime audioId

  - runtime is the read-only Messenger runtime passed to user model functions.
  - audioID is the NAME (not ID!) of the desired audio, which should be registered in the resources.elm.

The output of the function is a Maybe Duration, with which you can extract the Float value of the length in seconds via Duration.inSeconds.

Example: audioDuration runtime "Boom" |> Duration.inSeconds == 1.274 -- the duration in seconds.

-}
audioDuration : Runtime -> String -> Maybe Duration
audioDuration internalData audioId =
    case Dict.get audioId (Internal.getInternalData internalData).audioRepo.audio of
        Just ( _, duration ) ->
            Just duration

        _ ->
            Nothing
