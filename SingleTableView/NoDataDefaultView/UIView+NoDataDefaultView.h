//
//  UIView+NoDataDefaultView.h
//  NoDataDefaultViewDemo
//
//  Created by xiong on 2017/6/5.
//  Copyright © 2017年 xiong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NoDataDefaultView;

typedef NS_ENUM(NSInteger, NoDataDefaultViewType)
{
    NoDataDefaultViewTypeNoData = 1,
    NoDataDefaultViewTypeNetworkError,
    NoDataDefaultViewTypeNone
};

typedef void(^HandleBlock)();

@interface UIView(NoDataDefaultView)

@property (nonatomic, strong) NoDataDefaultView *noDataDefaultView;


/**
 设置缺省页

 @param viewType 页面类型
 @param isHasData 是否有数据 yes 则不显示该缺省页
 @param handle 重新加载按钮的处理事件
 */
- (void)configNoDataDefaultViewWithViewType:(NoDataDefaultViewType)viewType isHasData:(BOOL)isHasData handle:(HandleBlock)handle;


/**
  设置缺省页

 @param viewType 页面类型
 @param imageName 图片名
 @param title 标题
 @param detail 详细描述
 @param isHasData 是否有数据 yes 则不显示该缺省页
 @param handle 重新加载按钮的处理事件
 */
- (void)configNoDataDefaultViewWithImageName:(NSString *)imageName title:(NSString *)title detail:(NSString *)detail isHasData:(BOOL)isHasData handle:(HandleBlock)handle;

@end



@interface NoDataDefaultView:UIView

@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, copy) NSString *detailText;
@property (nonatomic, copy) HandleBlock handleBlock;

@end

