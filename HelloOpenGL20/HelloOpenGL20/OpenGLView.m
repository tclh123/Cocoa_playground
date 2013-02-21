//
//  OpenGLView.m
//  HelloOpenGL20
//
//  Created by tclh123 on 13-2-21.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import "OpenGLView.h"
//#import <QuartzCore/QuartzCore.h>

@implementation OpenGLView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupLayer];
        [self setupContext];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self render];        
    }
    return self;
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
