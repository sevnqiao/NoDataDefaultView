//
//  ViewController.m
//  SingleTableView
//
//  Created by xiong on 16/8/29.
//  Copyright © 2016年 xiong. All rights reserved.
//

#import "ViewController.h"
#import "UIView+NoDataDefaultView.h"
#import "MJRefresh.h"

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.dataArr = [NSMutableArray arrayWithCapacity:5];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //Call this Block When enter the refresh status automatically
        [self getData];
    }];
    
    [self.tableView configDefaultView:self.dataArr.count>0 title:@"This is a title" type:DefaultViewTypeDefault reloadHandler:^(UIButton *sender) {
         NSLog(@"123");
        [self getData];
    }];
}

- (void)getData{
    [self.dataArr addObject:@""];
    if (self.dataArr.count>5) {
        [self.dataArr removeAllObjects];
    }
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
    [self.tableView configDefaultView:self.dataArr.count>0 title:@"This is a title" type:DefaultViewTypeDefault reloadHandler:^(UIButton *sender) {
        NSLog(@"123");
        [self getData];
    }];
}

#pragma mark - UITableViewDelegate/UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identify"];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"identify"];
    }
    // cell data
    // .....
    cell.textLabel.text  = @"测试数据";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"test %ld",(long)indexPath.row];
    
    return cell;
}





- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
}



@end
