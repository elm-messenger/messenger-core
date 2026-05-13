module Messenger.UI.Input exposing (Input)

{-|


# Input to the Messenger UI

The generated `Main.elm` collects user configuration, resources, scenes, and
startup global components into this record before calling `Messenger.UI.genMain`.

@docs Input

-}

import Messenger.Resources.Base exposing (ResourceDefs)
import Messenger.Scene.Scene exposing (AllScenes, GlobalComponentStorage)
import Messenger.UserConfig exposing (UserConfig)


{-| The input required to start a Messenger program.

  - `config` contains ports and runtime settings.
  - `resources` are loaded before normal updates begin.
  - `scenes` maps scene names to scene storage.
  - `globalComponents` are loaded at startup.

-}
type alias Input userdata scenemsg =
    { config : UserConfig userdata scenemsg
    , resources : ResourceDefs
    , scenes : AllScenes userdata scenemsg
    , globalComponents : List (GlobalComponentStorage userdata scenemsg)
    }
