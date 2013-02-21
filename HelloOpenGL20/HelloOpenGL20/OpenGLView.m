//
//  OpenGLView.m
//  HelloOpenGL20
//
//  Created by tclh123 on 13-2-21.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import "OpenGLView.h"
//#import <QuartzCore/QuartzCore.h>

@interface OpenGLView()

- (void)setupLayer;
- (void)setupContext;
- (void)setupRenderBuffer;
- (void)setupFrameBuffer;
- (void)render;

- (void)compileShaders;
- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType;

@end

@implementation OpenGLView

// override initWithFrame 构造函数
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        
        [self compileShaders];
        
        [self render];
    }
    return self;
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

// 创建render buffer（渲染缓冲区）
- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer); //返回一个唯一的integer来标记render buffer（这里把这个唯一值赋值到_colorRenderBuffer）
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);    //其实就是告诉OpenGL，我们定义的buffer对象是属于哪一种OpenGL对象
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer]; //为render buffer分配空间
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

}

// 清理屏幕
- (void)render {
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);  // 把屏幕清理一下，显示另一个颜色吧。（RGB 0, 104, 55，绿色吧）
    glClear(GL_COLOR_BUFFER_BIT);   // 清理 COLOR_BUFFER_BIT
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
