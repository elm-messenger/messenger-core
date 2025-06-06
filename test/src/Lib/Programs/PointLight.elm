module Lib.Programs.PointLight exposing (..)

import Color exposing (Color)
import Json.Encode as Encode
import REGL.BuiltinPrograms as P exposing (toRgbaList)
import REGL.Common exposing (Renderable, genProg)
import REGL.Program exposing (ProgValue(..), REGLProgram)


frag =
    """
precision mediump float;
uniform vec2 view;
uniform vec4 camera;
uniform vec3 pr; // x, y, radius
uniform vec4 color;
varying vec2 v_position;
void main() {
    vec2 position = v_position * view / camera.z;
    vec2 cpos;
    if (camera.w == 0.0){
        cpos = (pr.xy - camera.xy);
    } else {
        mat2 rotation = mat2(cos(camera.w), -sin(camera.w), sin(camera.w), cos(camera.w));
        cpos = (rotation * (pr.xy - camera.xy));
    }

    float distance = distance(position, cpos);

    float intensity = 1.0 - smoothstep(0.0, pr.z, distance);

    gl_FragColor = color * intensity;
}

"""


vert =
    """
precision mediump float;
attribute vec2 pos;
varying vec2 v_position;
void main() {
    v_position = pos;
    gl_Position = vec4(pos, 0, 1);
}
"""


prog : REGLProgram
prog =
    { frag = frag
    , vert = vert
    , attributes =
        Just
            [ ( "pos"
              , StaticValue
                    (Encode.list Encode.float
                        [ -1
                        , -1
                        , 1
                        , -1
                        , 1
                        , 1
                        , -1
                        , 1
                        ]
                    )
              )
            ]
    , uniforms =
        Just
            [ ( "pr", DynamicValue "pr" )
            , ( "color", DynamicValue "color" )
            ]
    , elements = Just (StaticValue (Encode.list Encode.int [ 0, 1, 2, 0, 2, 3 ]))
    , count = Nothing
    , primitive = Nothing
    }


plight : Float -> Float -> Float -> Color -> Renderable
plight x y r color =
    genProg <|
        [ ( "_c", Encode.int 0 )
        , ( "_p", Encode.string "plight" )
        , ( "pr", Encode.list Encode.float [ x, y, r ] )
        , ( "color", Encode.list Encode.float (toRgbaList color) )
        ]
