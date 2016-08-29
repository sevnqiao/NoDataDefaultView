//
//  UIView+NoDataDefaultView.h
//  SingleTableView
//
//  Created by xiong on 16/8/29.
//  Copyright © 2016年 xiong. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, DefaultViewType) {
    
    DefaultViewTypeDefault = 1,
    
    
};

@class NoDataDefaultView;

@interface UIView(NoDataDefaultView)
@property (nonatomic, strong) NoDataDefaultView *noDataDefaultView;
- (void)configDefaultView:(BOOL)isHaveData title:(NSString *)title type:(DefaultViewType)type reloadHandler:(void(^)(UIButton *sender))block;
@end



@interface NoDataDefaultView:UIView
- (void)configDefaultWithTitle:(NSString *)title type:(DefaultViewType)type reloadHandler:(void(^)(UIButton *sender))block;
@end



@interface NSString(Size)
- (CGSize)getStringSizeWithWidth:(float)width font:(UIFont*)font;
@end



@interface UILabel(Init)
+ (UILabel *)initWithTitle:(NSString *)title titleColor:(UIColor *)color font:(UIFont *)font textAlignment:(NSTextAlignment)textAlignment lineNum:(NSInteger)lineNum;
@end



@interface UIButton(Init)
+ (UIButton *)initWithTitle:(NSString *)title titleColor:(UIColor *)color font:(UIFont *)font radius:(CGFloat)radius;
@end