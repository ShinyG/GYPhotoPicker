//
//  GYMaskView.h
//  GYPhotoPicker
//
//  Created by 高言 on 16/3/24.
//  Copyright © 2016年 高言. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GYMaskView : UIView

+(instancetype)shareMaskView;

/** 先调用hideBlock，之后maskView消失 */
@property (nonatomic , copy) void(^hideBlock)();
/** maskView先展示到窗口上，之后调用showBlock */
@property (nonatomic , copy) void(^showBlock)();

- (void)showMask;
- (void)hideMask;

@end
