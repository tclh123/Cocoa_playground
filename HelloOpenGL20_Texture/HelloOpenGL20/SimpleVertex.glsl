attribute vec4 Position; // 1
attribute vec4 SourceColor; // 2
 
varying vec4 DestinationColor; // 3

uniform mat4 Projection;    // add a Projection
uniform mat4 Modelview;     // add Model-view Matrix

attribute vec2 TexCoordIn; // New
varying vec2 TexCoordOut; // New

void main(void) { // 4
    DestinationColor = SourceColor; // 5
    gl_Position = Projection * Modelview * Position; // 6
    TexCoordOut = TexCoordIn; // New
}
