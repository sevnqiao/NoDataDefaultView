//
//  UIView+NoDataDefaultView.m
//  NoDataDefaultViewDemo
//
//  Created by xiong on 2017/6/5.
//  Copyright © 2017年 xiong. All rights reserved.
//

#import "UIView+NoDataDefaultView.h"
#import <objc/runtime.h>

static char NoDataDefaultViewKey ;

@implementation UIView (NoDataDefaultView)

- (void)setNoDataDefaultView:(NoDataDefaultView *)noDataDefaultView
{
    [self willChangeValueForKey:@"NoDataDefaultViewKey"];
    
    objc_setAssociatedObject(self, &NoDataDefaultViewKey, noDataDefaultView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self didChangeValueForKey:@"NoDataDefaultViewKey"];
}

- (NoDataDefaultView *)noDataDefaultView
{
    return objc_getAssociatedObject(self, &NoDataDefaultViewKey);
}

- (void)configNoDataDefaultViewWithViewType:(NoDataDefaultViewType)viewType isHasData:(BOOL)isHasData handle:(HandleBlock)handle
{
    
    if (viewType == NoDataDefaultViewTypeNoData)
    {
        [self configNoDataDefaultViewWithViewType:NoDataDefaultViewTypeNoData imageName:@"nodata_icon" title:nil detail:@"矮油，没有更多数据呀" isHasData:isHasData handle:nil];
    }
    else
    {
        [self configNoDataDefaultViewWithViewType:NoDataDefaultViewTypeNoData imageName:@"network_error_icon" title:@"矮油，网络竟然崩溃了" detail:@"别紧张，试试看刷新页面~" isHasData:isHasData handle:handle];
    }
}

- (void)configNoDataDefaultViewWithImageName:(NSString *)imageName title:(NSString *)title detail:(NSString *)detail isHasData:(BOOL)isHasData handle:(HandleBlock)handle
{
    [self configNoDataDefaultViewWithViewType:NoDataDefaultViewTypeNone imageName:imageName title:title detail:detail isHasData:isHasData handle:handle];
}

- (void)configNoDataDefaultViewWithViewType:(NoDataDefaultViewType)viewType imageName:(NSString *)imageName title:(NSString *)title detail:(NSString *)detail isHasData:(BOOL)isHasData handle:(HandleBlock)handle
{
    if (isHasData)
    {
        if (self.noDataDefaultView)
        {
            [self.noDataDefaultView removeFromSuperview];
        }
    }
    else
    {
        if (!self.noDataDefaultView)
        {
            self.noDataDefaultView = [[NoDataDefaultView alloc]initWithFrame:self.bounds];
        }
        
        self.noDataDefaultView.imageName = imageName;
        self.noDataDefaultView.titleText = title;
        self.noDataDefaultView.detailText = detail;
        self.noDataDefaultView.handleBlock = handle;
    
        [self addSubview:self.noDataDefaultView];
    }
}

@end


@interface NoDataDefaultView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *handleButton;

@end

@implementation NoDataDefaultView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    self.imageView = ({
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.hidden = YES;
        [self addSubview:imageView];
        imageView;
    });
    
    self.titleLabel = ({
        UILabel *label = [[UILabel alloc]init];
        label.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15];
        label.hidden = YES;
        [self addSubview:label];
        label;
    });
    
    self.detailLabel = ({
        UILabel *label = [[UILabel alloc]init];
        label.textColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12];
        label.numberOfLines = 2;
        label.hidden = YES;
        [self addSubview:label];
        label;
    });
    
    self.handleButton = ({
        UIButton *button = [[UIButton alloc]init];
        [button addTarget:self action:@selector(didClickHandleButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1] forState:UIControlStateNormal];
        [button setTitle:@"重新加载" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.layer.borderColor = [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1].CGColor;
        button.layer.borderWidth = 1;
        button.layer.cornerRadius = 15;
        button.layer.masksToBounds = YES;
        button.hidden = YES;
        [self addSubview:button];
        button;
    });
}

- (void)didClickHandleButton:(UIButton *)button
{
    if (self.handleBlock) {
        [self removeFromSuperview];
        self.handleBlock();
    }
}

#pragma mark - setter / getter
- (void)setImageName:(NSString *)imageName
{
    _imageName = imageName;
    self.imageView.image = [UIImage imageNamed:imageName];
    self.imageView.hidden = !(imageName.length>0);
    [self setNeedsDisplay];
}

- (void)setTitleText:(NSString *)titleText
{
    _titleText = titleText;
    self.titleLabel.text = titleText;
    self.titleLabel.hidden = !(titleText.length>0);
    [self setNeedsDisplay];
}

- (void)setDetailText:(NSString *)detailText
{
    _detailText = detailText;
    self.detailLabel.text = detailText;
    self.detailLabel.hidden = !(detailText.length>0);
    [self setNeedsDisplay];
}

- (void)setHandleBlock:(HandleBlock)handleBlock
{
    _handleBlock = handleBlock;
    self.handleButton.hidden = !(handleBlock);
    [self setNeedsDisplay];
}

#pragma mark - layout
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = ({
        CGRect frame = CGRectZero;
        frame.size = self.imageView.image.size;
        frame.origin = CGPointMake((self.frame.size.width - self.imageView.image.size.width ) / 2, self.frame.size.height / 2 - self.imageView.image.size.height - 30);
        frame;
    });
    
    self.titleLabel.frame = ({
        CGRect frame = CGRectZero;
        frame.size = CGSizeMake(self.frame.size.width, self.titleText.length > 0 ? 15 : 0);
        frame.origin = CGPointMake(0, self.frame.size.height / 2 + 10);
        frame;
    });
    
    self.detailLabel.frame = ({
        CGRect frame = CGRectZero;
        CGFloat height = [self.detailText boundingRectWithSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesFontLeading
                                                    attributes:nil
                                                       context:nil].size.height;
        frame.size = CGSizeMake(self.frame.size.width, height);
        frame.origin = CGPointMake(0, CGRectGetMaxY(self.titleLabel.frame) + 15);
        frame;
    });
    
    self.handleButton.frame = ({
        CGRect frame = CGRectZero;
        frame.size = CGSizeMake(100, 30);
        frame.origin = CGPointMake((self.frame.size.width - 100) / 2, CGRectGetMaxY(self.detailLabel.frame) + 20);
        frame;
    });
}




@end
