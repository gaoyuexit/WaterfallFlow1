//
//  GYWaterflowView.m
//  WaterfallFlow
//
//  Created by 郜宇 on 15/11/24.
//  Copyright © 2015年 郜宇. All rights reserved.
//

#import "GYWaterflowView.h"
#import "UIView+Extension.h"
#import "GYWaterflowViewCell.h"
// cell默认高度
#define GYWaterflowViewDefaultCellH 70
// 默认的列数
#define GYWaterflowViewDefaultNumberOfColumns 3
// 默认的间距(上,下,左,右,行,列)
#define GYWaterflowViewDefaultMargin 8



@interface GYWaterflowView ()
// 存放reloadData方法中,每个cell的frame
@property (nonatomic, strong)NSMutableArray *cellFrames;
// 字典,用位置(下标)做为key,判断这个位置是否有cell,如果key对应的Value有值,直接取,不创建了
// 字典存放正在展示的cell
@property (nonatomic, strong)NSMutableDictionary *displayingCells;

// 缓存池 (用set,存放离开屏幕的cell)
@property (nonatomic, strong)NSMutableSet *reusableCells;


@end



@implementation GYWaterflowView

#pragma mark - 初始化
- (NSMutableArray *)cellFrames
{
    if (!_cellFrames) {
        _cellFrames = [NSMutableArray array];
    }
    return _cellFrames;
}

- (NSMutableDictionary *)displayingCells
{
    if (!_displayingCells) {
        _displayingCells = [NSMutableDictionary dictionary];
    }
    return _displayingCells;
}

- (NSMutableSet *)reusableCells
{
    if (!_reusableCells) {
        _reusableCells = [NSMutableSet set];
    }
    return _reusableCells;
}



#pragma mark - 公共接口
/**
 * 刷新数据 (只要调用这个方法,会重新向数据源和代理发送请求,请求数据)
 * 1.重新计算每一个cell的frame , 存到数组中
 */
- (void)reloadData
{
    // cell的总数 (numberOfCellsInWaterflowView 必须实现的方法)
    NSUInteger numberOfCells = [self.dataSource numberOfCellsInWaterflowView:self];
    // 总列数 (numberOfColumnsInWaterflowView 可选的方法)
    NSUInteger numberOfColumns = [self numberOfColumns];
    // 瀑布流每个cell的宽度是相等的,所以写到for循环外面
    // cell的间距
    CGFloat topM = [self marginForType:GYWaterflowViewMarginTypeTop];
    CGFloat bottomM = [self marginForType:GYWaterflowViewMarginTypeButtom];
    CGFloat leftM = [self marginForType:GYWaterflowViewMarginTypeLeft];
    CGFloat rightM = [self marginForType:GYWaterflowViewMarginTypeRight];
    CGFloat columnM = [self marginForType:GYWaterflowViewMarginTypeColumn];
    CGFloat rowM = [self marginForType:GYWaterflowViewMarginTypeRow];
    // cell的宽度
    CGFloat cellW = (self.width - leftM - rightM - (numberOfColumns - 1) * columnM) / numberOfColumns;
    // 用一个C语言的数组存放所有列的最大Y值 (数组需要初始化) (就是该列的总高度,该列的最大的Y值)排完后这一列的总高度
    CGFloat maxYOfColumns[numberOfColumns];
    for (int i = 0; i < numberOfColumns; i ++) {
        // 数组初始化
        maxYOfColumns[i] = 0.0;
    }
    
    //求cellY 需要知道最短的那一列最大的的Y值(总高度)+margin
    //求cellX 需要知道最短的那一列是哪一列,才能求出X坐标
    
    for (int i = 0; i < numberOfCells; i ++) { // 看每个cell放到哪个位置
        //
        NSUInteger cellColumn = 0;
        // 取出第0列的高度
        CGFloat maxOfCellColumn = maxYOfColumns[cellColumn];
        
        // 求出最短的一列 (数组中求最小值的方法,然后取出这个最小值对应的下标)
        for (int j = 1; j < numberOfColumns; j ++) {
            if (maxYOfColumns[j] < maxOfCellColumn) {
                maxOfCellColumn = maxYOfColumns[j];
                cellColumn = j; // 则cell处于第J列
            }
        }
        CGFloat cellX = leftM + cellColumn * (cellW + columnM);
        CGFloat cellY = 0;
        if (maxOfCellColumn == 0.0) { // 第一行
            cellY = topM;
        }else{
            cellY = maxOfCellColumn + rowM;
        }

        // 询问代理i位置的高度
        CGFloat cellH = [self heightAtIndex:i];
        CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
        // 添加每个cellFrame放到数组中
        [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
        
        // 更新最短那一列的高度
        maxYOfColumns[cellColumn] = CGRectGetMaxY(cellFrame);
        
        // 显示cell(直接创建的,不好,我们用可以重用的)
//        GYWaterflowViewCell *cell = [self.dataSource waterflowView:self cellAtIndex:i];
//        cell.frame = cellFrame;
//        [self addSubview:cell];
    }
    // 设置contentSize(求C语言数组中,最大的值)(最大的高度)
    CGFloat contentH = maxYOfColumns[0];
    for (int i = 1; i < numberOfColumns; i ++) {
        if (maxYOfColumns[i] > contentH) {
            contentH = maxYOfColumns[i];
        }
    }
    contentH += bottomM;
    self.contentSize = CGSizeMake(0, contentH);
}


#pragma mark - 私有方法
// 返回每个cell对应的高度
- (CGFloat)heightAtIndex:(NSUInteger)index
{
    if ([self.delegate respondsToSelector:@selector(waterflowView:heightAtIndex:)]) {
        return [self.delegate waterflowView:self heightAtIndex:index];
    }else{
        return GYWaterflowViewDefaultCellH;
    }
}

// 返回列数
- (NSUInteger)numberOfColumns
{
    // 如果数据源有这个方法 (这个是可选的)
    if ([self.dataSource respondsToSelector:@selector(numberOfColumnsInWaterflowView:)]) {
        return [self.dataSource numberOfColumnsInWaterflowView:self];
    }else{
        return GYWaterflowViewDefaultNumberOfColumns;
    }
}

// 返回间距
- (CGFloat)marginForType:(GYWaterflowViewMarginType)type
{
    if ([self.delegate respondsToSelector:@selector(waterflowView:marginForType:)]) {
        return [self.delegate waterflowView:self marginForType:type];
    }else{
        return GYWaterflowViewDefaultMargin;
    }
}

// 判断一个frame是否显示在屏幕上
- (BOOL)isInScreen:(CGRect)frame
{
    // 画图看 向上滑动,上面的cell的最大的Y值大于偏移量才显示,下方的cell,cell的最小的Y值要小于偏移量+屏幕的高度才显示
//    if (CGRectGetMaxY(frame) > self.contentOffset.y && CGRectGetMinY(frame) < self.contentOffset.y + self.height) {
//        return YES;
//    }
//    return NO;
    return (CGRectGetMaxY(frame) > self.contentOffset.y) && (CGRectGetMinY(frame) < self.contentOffset.y + self.height);
}


#pragma mark - 注意
// 这里不能使用ScrollView:DidScroll 方法,因为这个方法要设置代理,self.delegate = self. 但是这个类.h中存在其他的代理了,否则自己给自己设置代理,别的地方没法用了
// 控件发生尺寸变化时候会调用这个方法,但是ScrollView滚动的时候,也会调用这个方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    // 向数据源索要对应位置的cell
    NSUInteger numberOfCells = self.cellFrames.count;
    for (int i = 0; i < numberOfCells; i ++) {
        // 取出i位置的frame
        CGRect cellFrame = [self.cellFrames[i] CGRectValue];
        
        // 优先从字典中取出i位置的cell
        GYWaterflowViewCell *cell = self.displayingCells[@(i)];
        
        // 判断i位置对应的frame在不在屏幕上(能否看见)
        if ([self isInScreen:cellFrame]) { // 在屏幕上
            // 优先从字典中取出i位置的cell , 因为不在屏幕上,还要判断,所以,拿到外面
//            GYWaterflowViewCell *cell = self.displayingCells[@(i)];
            if (cell == nil) {
                // 直接创建i位置的cell
                cell = [self.dataSource waterflowView:self cellAtIndex:i];
                cell.frame = cellFrame;
                [self addSubview:cell];
                // 存放到字典中
                self.displayingCells[@(i)] = cell;
            }
        }else{// 不在屏幕上
            // 放到缓存池 set
            // 向上滑,上面的i位置的已经创建了,如果i位置的cell存在,并且不在屏幕上
            if (cell) {
                // 从scrollView和字典中移除
                [cell removeFromSuperview];
                [self.displayingCells removeObjectForKey:@(i)];
                
                // 存放到缓存池 (不是自己用的,是给控制器用的)
                [self.reusableCells addObject:cell];
                
            }
        }
    }
}

// 根据 标示 去缓存池查找可循环利用的cell
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    // 这一种不太好,如果找不到 我们不让他返回空,让他继续查找
    // 随便取一个
//    GYWaterflowViewCell *cell = [self.reusableCells anyObject];
//    if ([cell.identifier isEqualToString:identifier]) {
//        return cell;
//    }
//    return nil;
    __block GYWaterflowViewCell *reusableCell = nil;
    [self.reusableCells enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        GYWaterflowViewCell *cell = (GYWaterflowViewCell *)obj;
        if ([cell.identifier isEqualToString:identifier]) {
            reusableCell = cell;
            *stop = YES;
        }
    }];
    
    if (reusableCell) { // 如果存在,从缓存池中移除,被用掉了
        [self.reusableCells removeObject:reusableCell];
    }
    return reusableCell;
}



#pragma mark - 事件处理
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (![self.delegate respondsToSelector:@selector(waterflowView:didSelectAtIndex:)]) return;
    
    // 获得触摸点
    UITouch *touch = [touches anyObject];
//    CGPoint point = [touch locationInView:touch.view];
    CGPoint point = [touch locationInView:self]; // 应该以屏幕左上角为原点
    __block NSNumber *selectIndex = nil;
    // 遍历显示在屏幕上的cell就可以,遍历数组太慢了,没必要
    [self.displayingCells enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        GYWaterflowViewCell *cell = (GYWaterflowViewCell *)obj;
        if (CGRectContainsPoint(cell.frame, point)) {
            selectIndex = key;
            *stop = YES;
        }
        
    }];
    if (selectIndex) {
        [self.delegate waterflowView:self didSelectAtIndex:selectIndex.unsignedIntegerValue];
    }
}

// 即将显示的是时候(第一次加到视图上的时候,就显示数据) addsubView方法之后会调用
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self reloadData];
}













@end
