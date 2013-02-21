//
//  OpenGLView.m
//  HelloOpenGL20
//
//  Created by tclh123 on 13-2-21.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import "OpenGLView.h"
#import "CC3GLMatrix.h"


// 顶点 信息的结构Vertex
typedef struct {
    float Position[3];  //位置
    float Color[4];     //颜色
} Vertex;

//// 4个点
//const Vertex Vertices[] = {
//    {{1, -1, 0}, {1, 0, 0, 1}},     // r
//    {{1, 1, 0}, {0, 1, 0, 1}},      // g
//    {{-1, 1, 0}, {0, 0, 1, 1}},     // b
//    {{-1, -1, 0}, {0, 0, 0, 1}}     // black
//    
//    // OpenGL 的 z轴是垂直屏幕向外的，所以 z坐标为负数
//};
//// 三角形顶点的 数组 , 存顶点index
//const GLubyte Indices[] = {
//    0, 1, 2,    // 右上
//    2, 3, 0     // 左下
//};

// 8个点
const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {1, 0, 0, 1}},
    {{-1, 1, 0}, {0, 1, 0, 1}},
    {{-1, -1, 0}, {0, 1, 0, 1}},
    
    {{1, -1, -1}, {1, 0, 0, 1}},
    {{1, 1, -1}, {1, 0, 0, 1}},
    {{-1, 1, -1}, {0, 1, 0, 1}},
    {{-1, -1, -1}, {0, 1, 0, 1}}
};

// 6个面，每个面2个三角形
const GLubyte Indices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 6, 5,
    4, 7, 6,
    // Left
    2, 7, 3,
    7, 6, 2,
    // Right
    0, 4, 1,
    4, 1, 5,
    // Top
    6, 2, 1,
    1, 6, 5,
    // Bottom
    0, 3, 7,
    0, 7, 4    
};

@implementation OpenGLView

// override initWithFrame 构造函数
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupLayer];
        [self setupContext];
        [self setupDepthBuffer];            // depth
        [self setupRenderBuffer];           // color
        [self setupFrameBuffer];            // frame
        
        [self setupVertexBufferObjects];    // VBO
        
        [self compileShaders];
        
//        [self render];
        [self setupDisplayLink];
    }
    return self;
}

// 用 CADisplayLink，调用 render，使OpenGL的渲染频率跟屏幕的刷新频率一致
- (void)setupDisplayLink {
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

// VBO: vertex buffer object
- (void)setupVertexBufferObjects {
    
    // 顶点buffer
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    // 顶点索引buffer
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
}

// 在运行时编译shaders
- (void)compileShaders {
    
    // 1 用来调用你刚刚写的动态编译方法，分别编译了vertex shader 和 fragment shader
    GLuint vertexShader = [self compileShader:@"SimpleVertex"
                                     withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment"
                                       withType:GL_FRAGMENT_SHADER];
    
    // 2 调用了glCreateProgram。 glAttachShader，glLinkProgram 连接 vertex 和 fragment shader成一个完整的program
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    // 3 调用 glGetProgramiv  lglGetProgramInfoLog 来检查是否有error，并输出信息
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);    // GL_LINK_STATUS
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    // 4 调用 glUseProgram  让OpenGL真正执行你的program
    glUseProgram(programHandle);
    
    // 5 最后，调用 glGetAttribLocation 来获取指向 vertex shader传入变量的指针。以后就可以通过这些指针来使用了。
    // 还有调用 glEnableVertexAttribArray来启用这些数据。（因为默认是 disabled的。）
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    
    _projectionUniform = glGetUniformLocation(programHandle, "Projection");
    _modelViewUniform = glGetUniformLocation(programHandle, "Modelview");
}

// 编译 shader，并返回 handle
- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    
    // 1. 这是一个UIKit编程的标准用法，就是在NSBundle中查找某个文件。
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName
                                                           ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // 2. 调用 glCreateShader来创建一个代表shader 的OpenGL对象。这时你必须告诉OpenGL，你想创建 fragment shader还是vertex shader。所以便有了这个参数：shaderType
    GLuint shaderHandle = glCreateShader(shaderType);
    
    // 3. 调用glShaderSource ，让OpenGL获取到这个shader的源代码。这里我们还把NSString转换成C-string
    const char* shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4. 调用glCompileShader 在运行时编译shader
    glCompileShader(shaderHandle);
    
    // 5. glGetShaderiv 和 glGetShaderInfoLog  会把error信息输出到屏幕。（然后退出）
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);    // 是否成功
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);    // 什么错误
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
}

// override layerClass, 设置为特殊的layer，用以获得OpenGL的内容
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

// 设置layer为不透明
/*
 因为缺省的话，CALayer是透明的。而透明的层对性能负荷很大，特别是OpenGL的层。
 　　（如果可能，尽量都把层设置为不透明。另一个比较明显的例子是自定义tableview cell）
*/
- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
}

// 创建OpenGL Context
- (void)setupContext {
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;  //选ES2的api
    _context = [[EAGLContext alloc] initWithAPI:api];   // alloc, init
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    if (![EAGLContext setCurrentContext:_context]) {    // set EAGLContext
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

// 创建color render buffer（渲染缓冲区）
- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer); //返回一个唯一的integer来标记render buffer（这里把这个唯一值赋值到_colorRenderBuffer）
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);    //其实就是告诉OpenGL，我们定义的buffer对象是属于哪一种OpenGL对象
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer]; //为render buffer分配空间
}

// 创建depth buffer（深度测试 缓冲区）
- (void)setupDepthBuffer {
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    // glRenderbufferStorage (GLenum target, GLenum internalformat, GLsizei width, GLsizei height)
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
}


// 创建一个 frame buffer（帧缓冲区）
/*
 Frame buffer也是OpenGL的对象，它包含了前面提到的render buffer，
 以及其它后面会讲到的诸如：depth buffer、stencil buffer 和 accumulation buffer。
 */
- (void)setupFrameBuffer {
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    
    // glFramebufferRenderbuffer (GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer)
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    // 它让你把前面创建的buffer render依附在frame buffer的GL_COLOR_ATTACHMENT0位置上。

    // 把 depth buffer 附到 frame buffer上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}

// 清理屏幕，并渲染
- (void)render:(CADisplayLink*)displayLink {
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);  // 把屏幕清理一下，显示另一个颜色吧。（RGB 0, 104, 55，绿色吧）
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);   // 清理buffer
    glEnable(GL_DEPTH_TEST);    // 开启深度测试
    
    CC3GLMatrix *projection = [CC3GLMatrix matrix];
    float h =4.0f* self.frame.size.height / self.frame.size.width;
    [projection populateFromFrustumLeft:-2 andRight:2 andBottom:-h/2 andTop:h/2 andNear:4 andFar:10];   // 一个跟 frame.size对应的 平截头体 填充得projection
    glUniformMatrix4fv(_projectionUniform, 1, GL_FALSE, projection.glMatrix);   // *_projectionUniform <- projection.glMatrix
    
    CC3GLMatrix *modelView = [CC3GLMatrix matrix];
    [modelView populateFromTranslation:CC3VectorMake(sin(CACurrentMediaTime()), 0, -7)];    // 平移 (x,y,z)
    _currentRotation += displayLink.duration *90;       // _currentRotation 每秒会增加90度
    [modelView rotateBy:CC3VectorMake(_currentRotation, _currentRotation, 0)];  // 同时沿x，y轴旋转
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
    
    // 1 调用glViewport 设置UIView中用于渲染的部分。这个例子中指定了整个屏幕。但如果你希望用更小的部分，你可以更变这些参数
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    // 2 设置 输入 参数（或者说属性），根据属性的指针（Gluint型）
    // glVertexAttribPointer (GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr)
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), 0);   // _positionSlot是 属性 的整数索引，或者说handle；Position 有3个float；地址为0，因为Position定义在shader的开头。
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) *3));    // 地址为 (GLvoid*) (sizeof(float) *3)，因为前面有Position（包含3个float）。
    
    // 3 调用glDrawElements ，
    // 它最后会在每个vertex上调用我们的vertex shader，
    // 以及每个像素调用fragment shader，最终画出我们的矩形
    // glDrawElements (GLenum mode, GLsizei count, GLenum type, const GLvoid* indices);
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),
                   GL_UNSIGNED_BYTE, 0);    // GL_TRIANGLES 指用三角形画（与使用VBO有关）；sizeof(Indices)/sizeof(Indices[0])为要画的元素数；GL_UNSIGNED_BYTE指Indices中的类型
    // 最后一个0，在官方文档中说，它是一个指向index的指针。但在这里，我们用的是VBO，所以通过index的array就可以访问到了（在GL_ELEMENT_ARRAY_BUFFER传过了），所以这里不需要.
    
    
    // 在缺省状态下，OpenGL的“camera”位于（0,0,0）位置，朝z轴的正方向。
    
    
    [_context presentRenderbuffer:GL_RENDERBUFFER]; // #define GL_RENDERBUFFER 0x8D41，前面已经绑定了
    // presentRenderbuffer 把缓冲区（render buffer和color buffer）的颜色呈现到UIView上
}


// ARC mode
//// Replace dealloc method with this
//- (void)dealloc
//{
//    [_context release];
//    _context = nil;
//    [super dealloc];
//}

///// 若要重载 View的自绘函数？

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
