//
//  UIView+NoDataDefaultView.m
//  SingleTableView
//
//  Created by xiong on 16/8/29.
//  Copyright © 2016年 xiong. All rights reserved.
//

#import "UIView+NoDataDefaultView.h"
#import <objc/runtime.h>

@implementation UIView(NoDataDefaultView)


static char NoDataDefaultViewKey;

#pragma mark - noDataDefaultView
- (void)setNoDataDefaultView:(NoDataDefaultView *)noDataDefaultView{
    [self willChangeValueForKey:@"NoDataDefaultViewKey"];
    objc_setAssociatedObject(self, &NoDataDefaultViewKey, noDataDefaultView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"NoDataDefaultViewKey"];
}

- (NoDataDefaultView *)noDataDefaultView{
    return objc_getAssociatedObject(self, &NoDataDefaultViewKey);
}

- (void)configDefaultView:(BOOL)isHaveData title:(NSString *)title type:(DefaultViewType)type reloadHandler:(void(^)(UIButton *sender))block{
    if (isHaveData) { // 有数据则移除当前的缺省页
        if (self.noDataDefaultView) {
            [self.noDataDefaultView removeFromSuperview];
        }
    }else{
        if (!self.noDataDefaultView) {
            self.noDataDefaultView = [[NoDataDefaultView alloc]initWithFrame:self.frame];
        }
        [self addSubview:self.noDataDefaultView];
        [self.noDataDefaultView configDefaultWithTitle:title type:type reloadHandler:block];
    }
    
    
}

@end


@implementation NoDataDefaultView
{
    void (^reloadMathodBlock)(id);
}
- (void)configDefaultWithTitle:(NSString *)title type:(DefaultViewType)type reloadHandler:(void(^)(UIButton *sender))block{
    UILabel *_textLabel;
    UIImageView *_imageView;
    UIButton *_reloadButton;

    reloadMathodBlock = block;
    
    if (type) {
        
        NSString *imageName = @"";
        
        switch (type) {
            case DefaultViewTypeDefault:
                imageName = @"estateDefaultLong_bg";
                break;
                
            default:
                break;
        }
        _imageView = [[UIImageView alloc]init];
        _imageView.frame = CGRectMake(0, (self.frame.size.height-100)*0.5, self.frame.size.width, 100);
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.image = [UIImage imageNamed:imageName];
        [self addSubview:_imageView];
    }
    
    if (title.length > 0) {
        _textLabel = [UILabel initWithTitle:title titleColor:[UIColor redColor] font:[UIFont systemFontOfSize:14.0f] textAlignment:NSTextAlignmentCenter lineNum:0];
        
        CGFloat textLabelHeight = [_textLabel.text getStringSizeWithWidth:self.frame.size.width font:_textLabel.font].height;
        _textLabel.frame = CGRectMake(0, CGRectGetMinY(_imageView.frame)-textLabelHeight, self.frame.size.width, textLabelHeight);
        
        [self addSubview:_textLabel];
    }
    
    if (block) {
        _reloadButton = [UIButton initWithTitle:@"重新加载" titleColor:[UIColor blueColor] font:[UIFont systemFontOfSize:12] radius:5];
        _reloadButton.frame = CGRectMake(self.frame.size.width/3, CGRectGetMaxY(_imageView.frame)+20, self.frame.size.width/3, 20);
        [_reloadButton addTarget:self action:@selector(reloadMathod:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_reloadButton];
        
    }
}

- (void)reloadMathod:(UIButton *)sender{
    [self removeFromSuperview];
    
    if (reloadMathodBlock) {
        reloadMathodBlock(sender);
    }
}


@end



@implementation NSString (Size)

-(CGSize)getStringSizeWithWidth:(float)width font:(UIFont*)font{
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = font;
    CGSize maxSize = CGSizeMake(width, MAXFLOAT);
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
}

- (CGSize)getStringSizeWithFont:(UIFont *)font{
    return [self getStringSizeWithWidth:MAXFLOAT font:font];
}

@end


@implementation UILabel(Init)

+ (UILabel *)initWithTitle:(NSString *)title titleColor:(UIColor *)color font:(UIFont *)font textAlignment:(NSTextAlignment)textAlignment lineNum:(NSInteger)lineNum{
    UILabel *label = [UILabel new];
    label.text = title;
    label.textColor = color;
    label.textAlignment = textAlignment;
    label.numberOfLines = lineNum;
    return label;
}

@end


@implementation UIButton(Init)
+ (UIButton *)initWithTitle:(NSString *)title titleColor:(UIColor *)color font:(UIFont *)font radius:(CGFloat)radius{
    UIButton *button = [UIButton new];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button.titleLabel setFont:font];
    button.layer.borderColor = [UIColor blackColor].CGColor;
    button.layer.borderWidth = 1;
    if (radius > 0) {
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = radius;
    }
    return button;
}

@end