//
//  DetailController.h
//  SingleView2
//
//  Created by tclh123 on 12-12-28.
//  Copyright (c) 2012年 tclh123. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailController : UIViewController


@property (weak, nonatomic) IBOutlet UITextField *Name;

@property (weak, nonatomic) IBOutlet UITextField *Age;

@property (weak, nonatomic) IBOutlet UITextField *Gender;

@property (weak, nonatomic) IBOutlet UITextField *Blog;     //其实就是靠 这种 IBOutlet ，实现CodeBehind吧

@property (weak) NSString *greetingText;

- (IBAction)SaveClick:(id)sender;//单击事件

- (IBAction)textFiledReturnEditing:(id)sender;//return释放键盘

@end