//
//  ACViewController.h
//  [T]AlarmClock
//
//  Created by tclh123 on 13-1-17.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACViewController : UIViewController
{
    NSTimer *timer; //NSTimer是一个怎样的调线程的?
    BOOL beat;
}

@property (weak, nonatomic) IBOutlet UILabel *lblTime;

@end
