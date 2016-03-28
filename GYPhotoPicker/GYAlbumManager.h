//
//  GYAlbumManager.h
//  GYPhotoPicker
//
//  Created by 高言 on 16/3/24.
//  Copyright © 2016年 高言. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 相册元数据
 */
static NSString * const ALBUMDATASOURCE = @"ALBUMDATASOURCE";
/**
 * 每个相册的第一张图片
 */
static NSString * const ALBUMFIRSTPHOTO = @"ALBUMFIRSTPHOTO";
/**
 * 相册名称
 */
static NSString * const ALBUMNAME = @"ALBUMSNAME";
/**
 * 相册中照片的数量
 */
static NSString * const ALBUMPHOTOSCOUNT = @"ALBUMPHOTOSCOUNT";


@interface GYAlbumManager : NSObject

+ (instancetype)shareAlbumManager;

- (void)removeFromMemory;

/** 选中的image*/
@property (nonatomic , strong) NSMutableArray *selectedImages;
/** 最大可选数 */
@property (nonatomic , assign) NSInteger maxSelectedNum;

/**
 * 懒加载相册中的图片，只返回第一个相册的图片和所有相册的基本信息
 */
- (void)loadAlbumslazily:(void(^)(NSArray *photosInFirstAlbum,NSArray *albumsInfo))block;

/**
 * 加载指定索引的相册中的照片
 */
- (void)loadAlbumWithIndex:(NSInteger)albumIndex results:(void(^)(NSArray *photos))block;

/** 
 * 获取所有相册 一口气加载所有图片
 */
- (void)loadAllAlbumsDirectly:(void(^)(NSArray *albums))block;

@end
