module Scenes.Interaction.Components.Button.Init exposing (..)

import Color


type alias InitData =
    { center : ( Float, Float )
    , size : ( Float, Float )
    , color : Color.Color
    , content : String -- It's also possible to pass a Renderable object here
    }
