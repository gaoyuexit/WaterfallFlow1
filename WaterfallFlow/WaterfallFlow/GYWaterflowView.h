//
//  GYWaterflowView.h
//  WaterfallFlow
//
//  Created by 郜宇 on 15/11/24.
//  Copyright © 2015年 郜宇. All rights reserved.
//  使用瀑布流形式展示内容的控件

#import <UIKit/UIKit.h>
@class GYWaterflowView, GYWaterflowViewCell;

typedef enum{
    GYWaterflowViewMarginTypeTop,
    GYWaterflowViewMarginTypeButtom,
    GYWaterflowViewMarginTypeLeft,
    GYWaterflowViewMarginTypeRight,
    GYWaterflowViewMarginTypeColumn, // 每一列间距
    GYWaterflowViewMarginTypeRow     // 每一行间距
}GYWaterflowViewMarginType;





#pragma mark -- 数据源方法
@protocol  GYWaterflowViewDataSource <NSObject>

@required

/**
 *  一共有多少个数据
 */
- (NSUInteger)numberOfCellsInWaterflowView:(GYWaterflowView *)waterflowView;

/**
 *  返回index位置对应的cell
 */
- (GYWaterflowViewCell *)waterflowView:(GYWaterflowView *)waterflowView cellAtIndex:(NSUInteger)index;


@optional
/**
 *  一共有多少列
 */
- (NSUInteger)numberOfColumnsInWaterflowView:(GYWaterflowView *)waterflowView;

@end

#pragma mark -- 代理方法
@protocol GYWaterflowViewDelegate <UIScrollViewDelegate>

@optional
/**
 *  第index位置cell对应的高度
 */
- (CGFloat)waterflowView:(GYWaterflowView *)waterflowView heightAtIndex:(NSUInteger)index;

/**
 *  点击第index位置cell对应的事件
 */
- (void)waterflowView:(GYWaterflowView *)waterflowView didSelectAtIndex:(NSUInteger)index;
/**
 *  返回间距
 */
- (CGFloat)waterflowView:(GYWaterflowView *)waterflowView marginForType:(GYWaterflowViewMarginType)type;



@end








/**
 *  瀑布流控件
 */
@interface GYWaterflowView : UIScrollView
/**
 *  数据源
 */
@property (nonatomic, weak) id<GYWaterflowViewDataSource> dataSource;
/**
 *  代理
 */
@property (nonatomic, weak) id<GYWaterflowViewDelegate> delegate;
/**
 *  刷新数据 (只要调用这个方法,会重新向数据源和代理发送请求,请求数据)
 */
- (void)reloadData;

// 根据 标示 去缓存池查找可循环利用的cell
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;







@end
