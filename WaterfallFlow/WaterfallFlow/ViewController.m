//
//  ViewController.m
//  WaterfallFlow
//
//  Created by 郜宇 on 15/11/24.
//  Copyright © 2015年 郜宇. All rights reserved.
//

#import "ViewController.h"
#import "GYWaterflowView.h"
#import "GYWaterflowViewCell.h"

@interface ViewController () <GYWaterflowViewDelegate, GYWaterflowViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GYWaterflowView *waterflowView = [[GYWaterflowView alloc] init];
    waterflowView.frame = self.view.bounds;
    waterflowView.delegate = self;
    waterflowView.dataSource = self;
    [self.view addSubview:waterflowView];
    // 刷新数据
//    [waterflowView reloadData];
}

#pragma mark - 数据源方法
- (NSUInteger)numberOfCellsInWaterflowView:(GYWaterflowView *)waterflowView
{
    return 200;
}

- (NSUInteger)numberOfColumnsInWaterflowView:(GYWaterflowView *)waterflowView
{
    return 3;
}

- (GYWaterflowViewCell *)waterflowView:(GYWaterflowView *)waterflowView cellAtIndex:(NSUInteger)index
{
//    GYWaterflowViewCell *cell = [[GYWaterflowViewCell alloc] init];
//    cell.backgroundColor = [UIColor redColor];
//    return cell;
    static NSString *ID = @"cell";
    GYWaterflowViewCell *cell = [waterflowView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[GYWaterflowViewCell alloc] init];
        cell.identifier = ID;
        cell.backgroundColor = [UIColor redColor];
        
        UILabel *label = [[UILabel alloc] init];
        label.tag = 10;
        label.frame = CGRectMake(0, 0, 50, 20);
        [cell addSubview:label];
    }
    UILabel *label = (UILabel *)[cell viewWithTag:10];
    label.text = [NSString stringWithFormat:@"%lu",(unsigned long)index];
    
    
    return cell;
}

#pragma mark - 代理方法

- (CGFloat)waterflowView:(GYWaterflowView *)waterflowView heightAtIndex:(NSUInteger)index
{
    switch (index % 3) {
        case 0: return 70;
        case 1: return 100;
        case 2: return 90;
        default: return 110;
    }
}

- (CGFloat)waterflowView:(GYWaterflowView *)waterflowView marginForType:(GYWaterflowViewMarginType)type
{
    switch (type) {
        case GYWaterflowViewMarginTypeTop:
        case GYWaterflowViewMarginTypeButtom:
        case GYWaterflowViewMarginTypeLeft:
        case GYWaterflowViewMarginTypeRight:
            return 10;
        default: return 5; // 行,列间距为5
    }
}

- (void)waterflowView:(GYWaterflowView *)waterflowView didSelectAtIndex:(NSUInteger)index
{
    NSLog(@"点击了第%lu个cell",(unsigned long)index);
}
















@end
