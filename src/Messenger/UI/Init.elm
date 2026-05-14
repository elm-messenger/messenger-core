module Messenger.UI.Init exposing (init)

{-|


# Game Init

Initialize the game

@docs init

-}

import Audio exposing (AudioCmd)
import Browser.Dom exposing (getViewport)
import Messenger.Base exposing (Env, Flags, GlobalData, GlobalDataInit, UserEvent)
import Messenger.Internal as Internal
import Messenger.Internal exposing (WorldEvent(..))
import Messenger.Model exposing (Model)
import Messenger.Resources.Base exposing (ResourceDef(..), resourceNum)
import Messenger.Scene.Loader exposing (loadSceneByName)
import Messenger.Scene.Scene exposing (AbstractScene(..), MAbstractScene, SceneOutputMsg)
import Messenger.UI.Input exposing (Input)
import Messenger.UserConfig exposing (EnabledBuiltinProgram(..), UserConfig)
import REGL
import REGL.BuiltinPrograms as P
import Task


{-| Empty Scene
-}
emptyScene : MAbstractScene userdata scenemsg
emptyScene =
    let
        abstractRec _ =
            let
                updates : Env () userdata -> UserEvent -> ( MAbstractScene userdata scenemsg, List (SceneOutputMsg scenemsg userdata), Env () userdata )
                updates env _ =
                    ( abstractRec (), [], env )
            in
            Roll
                { update = updates
                , view = \_ -> P.empty
                }
    in
    abstractRec ()


{-| Empty GlobalData
-}
emptyGlobalData : UserConfig userdata scenemsg -> GlobalData userdata
emptyGlobalData config =
    globalDataInitToGlobalData (config.globalDataCodec.decode "")


globalDataInitToGlobalData : GlobalDataInit userdata -> GlobalData userdata
globalDataInitToGlobalData user =
    let
        emptyInternalData =
            Internal.getInternalData Internal.emptyInternalData
    in
    { internalData =
        Internal.InternalData
            { emptyInternalData
                | volume = user.volume
            }
    , canvasAttributes = user.canvasAttributes
    , extraHTML = user.extraHTML
    , userData = user.userData
    , camera = user.camera
    }


{-| Initial model
-}
initModel : UserConfig userdata scenemsg -> Model userdata scenemsg
initModel config =
    { env = Env (emptyGlobalData config) emptyScene
    , globalComponents = []
    }


{-| The Init function for the game.
-}
init : Input userdata scenemsg -> Flags -> ( Model userdata scenemsg, Cmd WorldEvent, AudioCmd WorldEvent )
init input flags =
    let
        config =
            input.config

        scenes =
            input.scenes

        resources =
            input.resources

        im =
            initModel config

        env1 =
            im.env

        newEnv1 =
            { env1 | globalData = newgd }

        ms =
            loadSceneByName config.initScene scenes config.initSceneMsg { im | env = newEnv1 }

        newIT =
            let
                initInternalData =
                    Internal.getInternalData initGlobalData.internalData
            in
            Internal.InternalData
                { initInternalData
                    | virtualWidth = config.virtualSize.width
                    , virtualHeight = config.virtualSize.height
                    , totResNum = resourceNum input.resources
                    , currentTimeStamp = flags.timeStamp
                    , currentScene = config.initScene
                }

        initGlobalData =
            globalDataInitToGlobalData (config.globalDataCodec.decode flags.info)

        newgd =
            { initGlobalData | internalData = newIT }

        audioLoad =
            List.filterMap
                (\( key, res ) ->
                    case res of
                        AudioRes url ->
                            Just <| Audio.loadAudio (SoundLoaded key) url

                        _ ->
                            Nothing
                )
                resources

        gcs =
            List.map (\gc -> gc (Env newgd ms.env.commonData)) input.globalComponents

        env2 =
            ms.env

        newEnv2 =
            { env2 | globalData = newgd }

        resloadcmds =
            List.filterMap
                (\( key, res ) ->
                    case res of
                        TextureRes url opts ->
                            Just <| REGL.loadTexture key url opts

                        FontRes url1 url2 ->
                            Just <| REGL.loadMSDFFont key url1 url2

                        ProgramRes program ->
                            Just <| REGL.createREGLProgram key program

                        _ ->
                            Nothing
                )
                resources

        dataloadcmds =
            List.filterMap
                (\( key, res ) ->
                    case res of
                        DataRes path ->
                            Just <| config.ports.loadDataFile { name = key, path = path }

                        _ ->
                            Nothing
                )
                resources
    in
    ( { ms | env = newEnv2, globalComponents = gcs }
    , Cmd.batch <|
        (Task.perform (\res -> NewWindowSize ( res.scene.width, res.scene.height )) getViewport
            :: (REGL.batchExec config.ports.execREGLCmd <|
                    REGL.startREGL (REGL.REGLStartConfig config.virtualSize.width config.virtualSize.height config.fboNum (bulitinPrograms config.enabledProgram))
                        :: REGL.configREGL
                            (REGL.REGLConfig config.timeInterval)
                        :: resloadcmds
               )
        )
            ++ dataloadcmds
    , Audio.cmdBatch audioLoad
    )


bulitinPrograms : EnabledBuiltinProgram -> Maybe (List String)
bulitinPrograms c =
    case c of
        CustomBuiltinProgramList xs ->
            Just xs

        NoBuiltinProgram ->
            Just []

        TextOnlyBuiltinProgram ->
            Just [ "textbox" ]

        BasicShapesBuiltinProgram ->
            Just [ "textbox", "triangle", "circle", "quad", "poly" ]

        AllBuiltinProgram ->
            Nothing
