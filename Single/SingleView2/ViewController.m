//
//  ViewController.m
//  SingleView2
//
//  Created by tclh123 on 12-12-28.
//  Copyright (c) 2012年 tclh123. All rights reserved.
//

#import "ViewController.h"

//@interface ViewController ()  //自动生成的，干嘛用的？
//
//@end

@implementation ViewController

@synthesize states, datasource; // synthesize：合成。自动实现setter、getter，结合接口中的property。
@synthesize albumList;  // albumList 干嘛用的？？？

#pragma mark SetTableView
//因为 ViewController类 继承于 UIViewController<UITableViewDelegate, UITableViewDataSource> 吧，所以重载?一些函数。
//初始化 TableView

//控制Table的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section    //函数名的中缀表示
{
    return 5;
}

//每个section显示的标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"SetChildTitle";
}

//cell的工厂方法?吧   ，另外 IndexPath 是索引路径的意思，把array看做一个树结构
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cell_identifier = @"Cell";
    UITableViewCell *album_cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cell_identifier];
    if(album_cell == nil)
    {
        album_cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cell_identifier];  //实例化cell，使用 UITableViewCellStyleSubtitle样式 跟 cell_identifier 进行类型?重用
    }
    
    //设置一些 cell的属性
    [[album_cell textLabel] setBackgroundColor:[UIColor clearColor]];   //0.0 white, 0.0 alpha 
    [[album_cell detailTextLabel] setBackgroundColor:[UIColor clearColor]];
    
    //设置cell的textLabel.text，从数据源数组获取
    album_cell.textLabel.text = [datasource objectAtIndex:indexPath.row];
    
    //设置cell的arrow 样式
    album_cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return album_cell;
}

//table选择事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cell selected");
}

//手写连接（Segue）的代码，貌似对每个 segue都起作用
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //id viewController = segue.destinationViewController;
    UIViewController *viewController = segue.destinationViewController;
    //viewController.
    [viewController setValue:@"sd" forKey:@"greetingText"];
    NSLog(@"点击设置");
}

//初始化数据 datasource数组 跟 states字典
-(void)setupArray
{
    states = [[NSMutableDictionary alloc] init];
    
    [states setObject:@"Lansing" forKey:@"Michigan"];
    [states setObject:@"Sacremento" forKey:@"California"];
    [states setObject:@"Albany" forKey:@"New York"];
    [states setObject:@"Phoenix" forKey:@"Arizona"];
    [states setObject:@"Tulsa" forKey:@"Oklahoma"];
    
    datasource = [states allKeys];
}


#pragma mark - View lifecycle
//View（页面）的生命周期。

- (void)viewDidLoad
{
    [self setupArray];  //View加载时，初始化 数据array。
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setAlbumList:nil];    //View卸载时 释放。。？  states, datasource不用释放？
    [super viewDidUnload];
}
@end
