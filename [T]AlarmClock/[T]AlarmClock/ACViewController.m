//
//  ACViewController.m
//  [T]AlarmClock
//
//  Created by tclh123 on 13-1-17.
//  Copyright (c) 2013年 tclh123. All rights reserved.
//

#import "ACViewController.h"

@interface ACViewController ()  //这个是什么用的？

@end

@implementation ACViewController

@synthesize lblTime;    //自动实现setter getter

#pragma mark - Public Methods

//...

#pragma mark - Private Methods

//timer callback
- (void) updateClock:(NSTimer *)theTimer
{
    NSDate *now = [NSDate date];
    NSDateComponents *dataConponets = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:now];
    NSString *strFormat = (beat = !beat)? @"%d:%d": @"%d %d";
    
//    UILabel *lblTime = [[UILabelalloc] initWithFrame:CGRectMake(0, 0, 75, 40)];   //声明UIlbel并指定其位置和长宽
    lblTime.backgroundColor = [UIColor clearColor];   //设置label的背景色，这里设置为透明色。
    lblTime.font = [UIFont fontWithName:@"Helvetica-Bold" size:200];   //设置label的字体和字体大小。
//    lblTime.transform = CGAffineTransformMakeRotation(0.1);     //设置label的旋转角度
    lblTime.textColor = [UIColor blackColor];    //设置文本的颜色
    lblTime.shadowColor = [UIColor colorWithWhite:0.1f alpha:0.8f];    //设置文本的阴影色彩和透明度。
    lblTime.shadowOffset = CGSizeMake(2.0f, 2.0f);     //设置阴影的倾斜角度。
    lblTime.textAlignment = UITextAlignmentCenter;     //设置文本在label中显示的位置，这里为居中。
    //换行技巧：如下换行可实现多行显示，但要求label有足够的宽度。
    lblTime.lineBreakMode = UILineBreakModeWordWrap;     //指定换行模式
    lblTime.numberOfLines = 2;    // 指定label的行数
    
    lblTime.text = [NSString stringWithFormat:strFormat, [dataConponets hour], [dataConponets minute]];
}

#pragma mark - Overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    beat = YES;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateClock:) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLblTime:nil];
    [super viewDidUnload];
}
@end
