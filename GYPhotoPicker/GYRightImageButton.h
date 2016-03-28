//
//  GYRightImageButton.h
//  GYPhotoPicker
//
//  Created by 高言 on 16/3/24.
//  Copyright © 2016年 高言. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GYRightImageButton : UIButton

+ (instancetype)rightImageButton:(void(^)(GYRightImageButton *btn))clickBlock;

@end
