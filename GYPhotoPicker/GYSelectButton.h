//
//  GYSelectButton.h
//  GYPhotoPicker
//
//  Created by 高言 on 16/3/24.
//  Copyright © 2016年 高言. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GYSelectButton : UIButton

+ (instancetype)selectButtonWithAction:(void(^)(GYSelectButton *btn))clickBlock;

@property (nonatomic , assign) CGRect imageViewFrame;

@end
