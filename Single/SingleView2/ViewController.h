//
//  ViewController.h
//  SingleView2
//
//  Created by tclh123 on 12-12-28.
//  Copyright (c) 2012年 tclh123. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>    //两个protocol

@property (weak, nonatomic) IBOutlet UITableView *albumList;    //IB 是 Interface Builder，Outlet是插座（受）。
                                    //Interface Builder can only see methods that are prefaced with IBAction and can only see variables or properties that are prefaced with IBOutlet.
                                                        // ViewController 来控制 View

@property (nonatomic, retain) NSMutableDictionary *states;  // states，可变字典
@property (nonatomic, retain) NSArray *datasource;  //datasource，数组

-(void)setupArray;  //方法

@end
