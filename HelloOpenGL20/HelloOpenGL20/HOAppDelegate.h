//
//  HOAppDelegate.h
//  HelloOpenGL20
//
//  Created by tclh123 on 13-2-21.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenGLView.h"

@class HOViewController;

@interface HOAppDelegate : UIResponder <UIApplicationDelegate> {
    OpenGLView *_glView;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) HOViewController *viewController;

@property (nonatomic, retain) IBOutlet OpenGLView *glView;

@end
