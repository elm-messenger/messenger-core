module Lib.Programs.PointLight exposing (..)

import Color exposing (Color)
import Json.Encode as Encode
import REGL.BuiltinPrograms as P
import REGL.Common exposing (Renderable, genProg, toRgbaList)
import REGL.Program exposing (ProgValue(..), REGLProgram)


frag =
    """
precision highp float;
uniform vec2 view;
uniform vec4 camera;
uniform vec4 pr; // x, y, radius, radius2
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

    float dist = distance(position, cpos);
    
    if (dist > pr.w) discard;


    float alpha;

    if (dist < pr.z) {
        alpha = 1.0;
    } else {
        float t = (dist - pr.z) / (pr.w - pr.z);  // [0, 1]
        alpha = 1.0 - pow(t, 1.0 / 3.0);           // cubic root falloff
    }

    gl_FragColor = color * alpha;
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


plight : Float -> Float -> Float -> Float -> Color -> Renderable
plight x y r r2 color =
    genProg <|
        [ ( "_c", Encode.int 0 )
        , ( "_p", Encode.string "plight" )
        , ( "pr", Encode.list Encode.float [ x, y, r, r2 ] )
        , ( "color", Encode.list Encode.float (toRgbaList color) )
        ]
