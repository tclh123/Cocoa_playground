//
//  OpenGLView.h
//  HelloOpenGL20
//
//  Created by tclh123 on 13-2-21.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>   //     CAEAGLLayer, EAGLContext ，应该属于所谓的EGL部分吧？

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

@interface OpenGLView : UIView {
    CAEAGLLayer *_eaglLayer;    // CA EAGL Layer
    EAGLContext *_context;      // EAGL context
    GLuint _colorRenderBuffer;  // unsigned int, 唯一值标记一个 buffer
    
    // vertex_shader 传入变量 的指针
    GLuint _positionSlot;
    GLuint _colorSlot;
    
    // vertex_shader 的 matrix (Uniform类型的传入变量)
    // uniform 关键字表示，这会是一个应用于所有顶点的常量，而不是会因为顶点不同而不同的值。
    GLuint _projectionUniform;
    GLuint _modelViewUniform;
    
    float _currentRotation;
}

+ (Class)layerClass;


@end
