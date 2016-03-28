//
//  GYRightImageButton.m
//  GYPhotoPicker
//
//  Created by 高言 on 16/3/24.
//  Copyright © 2016年 高言. All rights reserved.
//

#import "GYRightImageButton.h"

@interface GYRightImageButton()

@property (nonatomic , copy) void(^clickBlock)(GYRightImageButton *btn);

@end

@implementation GYRightImageButton

+ (instancetype)rightImageButton:(void(^)(GYRightImageButton *btn))clickBlock
{
    GYRightImageButton *button = [[GYRightImageButton alloc] init];
    [button addTarget:button action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:@"GYPhotoPicker.bundle/navigationbar_arrow_down"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"GYPhotoPicker.bundle/navigationbar_arrow_up"] forState:UIControlStateSelected];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.clickBlock = clickBlock;
    return button;
}

- (void)click
{
    if (self.clickBlock) {
        self.clickBlock(self);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
 
    self.titleLabel.frame = (CGRect){self.titleLabel.frame.origin.x - 5,self.titleLabel.frame.origin.y,self.titleLabel.bounds.size};
    CGRect imageViewRect = (CGRect){CGRectGetMaxX(self.titleLabel.frame) + 5,self.imageView.frame.origin.y,self.imageView.bounds.size};
    self.imageView.frame = imageViewRect;
}



@end
