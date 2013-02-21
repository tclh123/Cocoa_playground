#OpenGL ES 2.0 for iPhone Tutorial

[原文链接](http://www.raywenderlich.com/3664/opengl-es-2-0-for-iphone-tutorial)

[译文链接](http://www.cnblogs.com/zilongshanren/archive/2011/08/08/2131019.html)

Ps. I use the ipad2 instead, because I don't own an iPhone :(

##添加shaders：顶点着色器和片段着色器

　　在OpenGL ES2.0 的世界，在场景中渲染任何一种几何图形，你都需要创建两个称之为“着色器”的小程序。

　　着色器由一个类似C的语言编写- GLSL。知道就好了，我们不深究。

　　这个世界有两种着色器（Shader）：

　　*Vertex shaders* – 在你的场景中，每个顶点都需要调用的程序，称为“顶点着色器”。假如你在渲染一个简单的场景：一个长方形，每个角只有一个顶点。于是vertex shader 会被调用四次。它负责执行：诸如灯光、几何变换等等的计算。得出最终的顶点位置后，为下面的片段着色器提供必须的数据。

　　*Fragment shaders* – 在你的场景中，大概每个像素都会调用的程序，称为“片段着色器”。在一个简单的场景，也是刚刚说到的长方形。这个长方形所覆盖到的每一个像素，都会调用一次fragment shader。片段着色器的责任是计算灯光，以及更重要的是计算出每个像素的最终颜色。

###SimpleVertex.glsl

```
attribute vec4 Position; // 1. “attribute”声明了这个shader会接受一个传入变量，这个变量名为“Position”。在后面的代码中，你会用它来传入顶点的位置数据。这个变量的类型是“vec4”,表示这是一个由4部分组成的矢量。
attribute vec4 SourceColor; // 2. 传入顶点的颜色变量
 
varying vec4 DestinationColor; // 3. 没有“attribute”的关键字。表明它是一个传出变量，它就是会传入片段着色器的参数。“varying”关键字表示，依据顶点的颜色，平滑计算出顶点之间每个像素的颜色。
 
void main() { 
    DestinationColor = SourceColor; // 5. 设置目标颜色 = 传入变量：SourceColor
    gl_Position = Position; // 6. gl_Position 是一个内建的传出变量。这是一个在 vertex shader中必须设置的变量。这里我们直接把 gl_Position = Position; 没有做任何逻辑运算。
}
```
###SimpleFragment.glsl

```
varying lowp vec4 DestinationColor; // 1. 这是从vertex shader中传入的变量，这里和vertex shader定义的一致。而额外加了一个关键字：lowp。在fragment shader中，必须给出一个计算的精度。出于性能考虑，总使用最低精度是一个好习惯。这里就是设置成最低的精度。如果你需要，也可以设置成medp或者highp
 
void main() {
    gl_FragColor = DestinationColor; // 3. 在fragment shader中必须设置gl_FragColor. 这里也是直接从 vertex shader中取值，先不做任何改变
}
```