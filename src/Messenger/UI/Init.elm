module Messenger.UI.Init exposing (init)

{-|


# Game Init

Initialize the game

@docs init

-}

import Audio exposing (AudioCmd)
import Browser.Dom exposing (getViewport)
import Messenger.Base exposing (Env, Flags, GlobalData, GlobalDataInit, Runtime, UserEvent)
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
                updates : Runtime -> Env () userdata -> UserEvent -> ( MAbstractScene userdata scenemsg, List (SceneOutputMsg scenemsg userdata), Env () userdata )
                updates _ env _ =
                    ( abstractRec (), [], env )
            in
            Roll
                { update = updates
                , view = \_ _ -> P.empty
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
    { canvasAttributes = user.canvasAttributes
    , extraHTML = user.extraHTML
    , userData = user.userData
    , camera = user.camera
    }


{-| Initial model
-}
initModel : UserConfig userdata scenemsg -> Model userdata scenemsg
initModel config =
    { runtime = Internal.emptyInternalData
    , env = Env (emptyGlobalData config) emptyScene
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

        initGlobalDataRaw =
            config.globalDataCodec.decode flags.info

        env1 =
            im.env

        imWithRuntime =
            { im | runtime = runtime }

        newEnv1 =
            { env1 | globalData = initGlobalData }

        ms =
            loadSceneByName config.initScene scenes config.initSceneMsg { imWithRuntime | env = newEnv1 }

        runtime =
            let
                initInternalData =
                    Internal.getInternalData Internal.emptyInternalData
            in
            Internal.InternalData
                { initInternalData
                    | volume = initGlobalDataRaw.volume
                    , virtualWidth = config.virtualSize.width
                    , virtualHeight = config.virtualSize.height
                    , totResNum = resourceNum input.resources
                    , currentTimeStamp = flags.timeStamp
                    , currentScene = config.initScene
                }

        initGlobalData =
            globalDataInitToGlobalData initGlobalDataRaw

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
            List.map (\gc -> gc ms.runtime (Env initGlobalData ms.env.commonData)) input.globalComponents

        env2 =
            ms.env

        newEnv2 =
            { env2 | globalData = initGlobalData }

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
