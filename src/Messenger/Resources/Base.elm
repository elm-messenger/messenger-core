module Messenger.Resources.Base exposing
    ( saveSprite
    , igetSprite
    , ResourceDef(..), ResourceDefs, resourceNum
    )

{-|


# Resource

Resource definitions used by Messenger's loader.

Resources are declared as `( name, ResourceDef )` pairs. Messenger loads initial
resources before normal updates begin, and dynamic resources can be loaded later
with `SOMLoadResource`.

Loaded data is stored in opaque internal engine state. User code should use
getters from `Messenger.Base` such as `getLoadingProgress`, `getSprite`,
`getFonts`, `getPrograms`, and `getConfigData`.

@docs saveSprite
@docs igetSprite
@docs ResourceDef, ResourceDefs, resourceNum

-}

import Dict exposing (Dict)
import REGL exposing (Texture)
import REGL.Program exposing (REGLProgram)


{-| Save a loaded texture into the texture dictionary.

This is used internally by the loader. User code usually reads textures through
`Messenger.Base.getSprite` or renders by name with `Messenger.Render.Texture`.

-}
saveSprite : Dict String Texture -> String -> Texture -> Dict String Texture
saveSprite dst name text =
    Dict.insert name text dst


{-| Get a texture by name from a texture dictionary.

This is a low-level helper used by texture rendering internals.

-}
igetSprite : String -> Dict String Texture -> Maybe Texture
igetSprite name dst =
    Dict.get name dst


{-| Definition for a loadable resource.

  - `TextureRes url options` loads an image texture.
  - `AudioRes url` loads an audio source.
  - `FontRes textureUrl jsonUrl` loads an MSDF font.
  - `ProgramRes program` creates a custom REGL program.
  - `DataRes path` loads a plain text data file.

-}
type ResourceDef
    = TextureRes String (Maybe REGL.TextureOptions)
    | AudioRes String
    | FontRes String String
    | ProgramRes REGLProgram
    | DataRes String


{-| A list of named resource definitions.
-}
type alias ResourceDefs =
    List ( String, ResourceDef )


{-| Count resource definitions.

Messenger uses this to track loading progress.

-}
resourceNum : ResourceDefs -> Int
resourceNum =
    List.length
