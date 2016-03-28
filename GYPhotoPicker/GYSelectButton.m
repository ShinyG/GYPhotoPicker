//
//  GYSelectButton.m
//  GYPhotoPicker
//
//  Created by 高言 on 16/3/24.
//  Copyright © 2016年 高言. All rights reserved.
//

#import "GYSelectButton.h"

@interface GYSelectButton()

@property (nonatomic , copy) void(^clickBlock)(GYSelectButton *btn);
@property (nonatomic , weak) UIImageView *selectImageView;

@end

@implementation GYSelectButton

+ (instancetype)selectButtonWithAction:(void(^)(GYSelectButton *btn))clickBlock
{
    GYSelectButton *selectButton = [GYSelectButton buttonWithType:UIButtonTypeCustom];
    [selectButton addTarget:selectButton action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    selectButton.clickBlock = clickBlock;
    
    UIImageView *selectImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"GYPhotoPicker.bundle/FriendsSendsPicturesSelectIcon"]];
    [selectButton addSubview:selectImageView];
    selectButton.selectImageView = selectImageView;
    
    return selectButton;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        // 切换图片
        self.selectImageView.image = [UIImage imageNamed:@"GYPhotoPicker.bundle/FriendsSendsPicturesSelectYIcon"];
        
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        anim.values = @[@(1.0),@(0.8),@(1.0),@(1.2),@(1.0)];
        anim.duration = 0.5;
        [self.selectImageView.layer addAnimation:anim forKey:nil];
    } else {
        self.selectImageView.image = [UIImage imageNamed:@"GYPhotoPicker.bundle/FriendsSendsPicturesSelectIcon"];
    }
    
}

- (void)click
{
    if (self.clickBlock) {
        self.clickBlock(self);
    }

}

- (void)setImageViewFrame:(CGRect)imageViewFrame
{
    _imageViewFrame = imageViewFrame;
    
    self.selectImageView.frame = imageViewFrame;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.selectImageView.bounds.size.width;
    CGRect imageViewRect = (CGRect){self.bounds.size.width - width - 5,5,self.selectImageView.bounds.size};
    self.selectImageView.frame = imageViewRect;
    if (self.imageViewFrame.size.width != 0) {
        self.selectImageView.frame = self.imageViewFrame;
    }
}

@end
