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

##GLSL文件

我发现glsl文件里如果有中文注释，会出错。但是下面还是给出注释方便阅读。

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

##为这个简单的长方形创建 Vertex Data！

![长方形](http://pic002.cnblogs.com/images/2011/283130/2011080816061947.jpg)

　　在你用OpenGL渲染图形的时候，时刻要记住一点，你只能直接渲染三角形，而不是其它诸如矩形的图形。所以，一个正方形需要分开成两个三角形来渲染。
　　图中分别是顶点（0,1,2）和顶点（0,2,3）构成的三角形。
　　OpenGL ES2.0的一个好处是，你可以按你的风格来管理顶点。


##增加一个投影

　　为了在2D屏幕上显示3D画面，我们需要在图形上做一些投影变换，所谓投影就是下图这个意思：

![投影](http://pic002.cnblogs.com/images/2011/283130/2011080816120726.jpg)

　　基本上，为了模仿人类的眼球原理。我们设置一个远平面和一个近平面，在两个平面之前，离近平面近的图像，会因为被缩小了而显得变小；而离远平面近的图像，也会因此而变大。


