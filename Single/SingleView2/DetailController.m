//
//  DetailController.m
//  SingleView2
//
//  Created by tclh123 on 12-12-28.
//  Copyright (c) 2012年 tclh123. All rights reserved.
//

#import "DetailController.h"

@interface DetailController ()

@end

@implementation DetailController


@synthesize Blog;
@synthesize Gender;
@synthesize Name;
@synthesize Age;

@synthesize greetingText;   //自动实现的 getter是 greetingText


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    Blog.text=self.greetingText;
}
//View Unload 释放
- (void)viewDidUnload {
    self.Name = nil;
    //[self setName:nil];
    [self setAge:nil];
    [self setGender:nil];
    [self setBlog:nil];
    [super viewDidUnload];
}

//单击事件
- (IBAction)SaveClick:(id)sender {
    NSLog(@"%s","alter click");
    
    //弹出alter
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"是否保存！"
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:@"取消",nil];
    [alert show];
    
}

//单击return
-(IBAction)textFiledReturnEditing:(id)sender {
    [sender resignFirstResponder];  //resign: 辞职
    NSLog(@"触发Did End On Exit");
}

//什么用的？？
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}
@end
