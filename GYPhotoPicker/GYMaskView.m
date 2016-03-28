//
//  GYMaskView.m
//  GYPhotoPicker
//
//  Created by 高言 on 16/3/24.
//  Copyright © 2016年 高言. All rights reserved.
//

#import "GYMaskView.h"

@implementation GYMaskView

+(instancetype)shareMaskView
{
    static GYMaskView *maskView;
    if (!maskView) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            maskView = [[GYMaskView alloc] init];
            maskView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
            maskView.alpha = 0.0;
            maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [[UIApplication sharedApplication].keyWindow addSubview:maskView];
        });
    }
    
    return maskView;
}

- (void)showMask
{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        if (self.showBlock) {
            self.showBlock();
        }
    }];
}

- (void)hideMask
{
//    [UIView animateWithDuration:0.25 animations:^{
//        self.alpha = 0.0;
//    } completion:^(BOOL finished) {
//        
//    }];
    if (self.hideBlock) {
        self.hideBlock();
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hideMask];
}

@end
