#OpenGL ES 2.0 for iPhone Tutorial -- Part 2 Textures

[原文链接](http://www.raywenderlich.com/4404/opengl-es-2-0-for-iphone-tutorial-part-2-textures)

[译文链接](http://www.cnblogs.com/zilongshanren/archive/2011/09/02/2155061.html)

Ps. I use the ipad2 instead, because I don't own an iPhone :(

这次的sample是在[上次](https://github.com/tclh123/Cocoa_playground/tree/master/HelloOpenGL20)的基础上的。

## 大致步骤 ##

- 通过Core Graphics，读取图片像素，然后再 `glTexImage2D` 将其传入OpenGLES。并维护纹理ID。
- 修改glsl，vertex shader 加入 纹理映射坐标 的输入(属性)、输出，fragment shader 通过 `texture2D(Texture, TexCoordOut)` 函数得到纹理
- 编译shader的时候维护属性指针，render时传入 纹理映射坐标。激活OpenGLES纹理单元(GL_TEXTURE0)，并跟 纹理ID 绑定。