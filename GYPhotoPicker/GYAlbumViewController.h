//
//  GYAlbumViewController.h
//  GYPhotoPicker
//
//  Created by 高言 on 16/3/24.
//  Copyright © 2016年 高言. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GYAlbumViewControllerDelegate <NSObject>

- (void)albumViewControllerDidSelectedImages:(NSArray *)images;

@end

@interface GYAlbumViewController : UIViewController

@property (nonatomic , weak) id<GYAlbumViewControllerDelegate> delegate;
/** 全部选取完毕的回调 */
@property (nonatomic , copy) void(^selectedImagesBlock)(NSArray *images);
/** 选择照相的回调 */
@property (nonatomic , copy) void(^clickCameraBlock)();
/** 可选最大数量 */
@property (nonatomic , assign) NSInteger maxSelectedNum;

// 初始化1
+ (instancetype)albumViewControllerWithMaxSelectedNum:(NSInteger)maxSelectedNum finishSelectedBlock:(void(^)(NSArray *images))finishSelectedBlock;
// 初始化2
+ (instancetype)albumViewControllerWithMaxSelectedNum:(NSInteger)maxSelectedNum finishSelectedBlock:(void(^)(NSArray *images))finishSelectedBlock takePhotoBlock:(void(^)())clickCameraBlock;

@end
