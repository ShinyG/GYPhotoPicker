//
//  GYAlbumManager.m
//  GYPhotoPicker
//
//  Created by 高言 on 16/3/24.
//  Copyright © 2016年 高言. All rights reserved.
//

#import "GYAlbumManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define iOS8 [UIDevice currentDevice].systemVersion.doubleValue >= 8.0

@interface GYAlbumManager()

/** 相册的一级缓存,只缓存相册的名称、照片数量和一些元数据 */
@property (nonatomic , strong) NSMutableArray *albumsInfo;
/** 相册的二级缓存,加载过某个相册就缓存起来 */
@property (nonatomic , strong) NSMutableDictionary *albumCaches;

@end

@implementation GYAlbumManager

- (NSMutableArray *)albumsInfo {
    if (!_albumsInfo) {
        _albumsInfo = @[].mutableCopy;
    }
    
    return _albumsInfo;
}

- (NSMutableDictionary *)albumCaches {
    if (!_albumCaches) {
        _albumCaches = @{}.mutableCopy;
    }
    
    return _albumCaches;
}

+ (instancetype)shareAlbumManager
{
    static GYAlbumManager *manager;
    if (!manager) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            manager = [[self alloc] init];
            manager.selectedImages = @[].mutableCopy;
            manager.maxSelectedNum = 1;
        });
    }
    
    return manager;
}

/**
 * 清空缓存
 */
- (void)clearCache
{
    [self.albumsInfo removeAllObjects];
    [self.albumCaches removeAllObjects];
    [self.selectedImages removeAllObjects];
}

/**
 * 懒加载相册中的图片，只返回第一个相册的图片和所有相册的基本信息
 */
- (void)loadAlbumslazily:(void(^)(NSArray *photosInFirstAlbum,NSArray *albumsInfo))block;
{
    [self loadAlbumslazily:block complete:nil];
}

- (void)loadAlbumslazily:(void(^)(NSArray *photosInFirstAlbum,NSArray *albumsInfo))block complete:(void(^)())complete
{
    // 每次重新打开相册都清空缓存
    [self clearCache];
    
    __weak typeof(self) weakSelf = self;
    [self loadAlbum:^(ALAssetsGroup *album, UIImage *firstPhoto, NSString *albumName, NSInteger count) {
        
        NSDictionary *albumData = @{
                                    ALBUMDATASOURCE : album,
                                    ALBUMFIRSTPHOTO : firstPhoto,
                                    ALBUMNAME : albumName,
                                    ALBUMPHOTOSCOUNT : @(count)
                                    };
        [weakSelf.albumsInfo addObject:albumData];
        
        
    } complete:^{
        [weakSelf loadPhotosSourceWithAlbum:weakSelf.albumsInfo[0][ALBUMDATASOURCE] results:^(NSArray *photosSource) {
            [weakSelf loadPhotosWithPhotosSource:photosSource onMainQueue:NO results:^(NSArray *photos) {
                
                // 缓存第一个相册的数据
                self.albumCaches[@(0)] = photos;
                
                if (block) {
                    block(photos,weakSelf.albumsInfo);
                }
                
                
                if (complete) {
                    complete();
                }
            }];
        }];
        

    }];
}

/**
 * 加载指定索引的相册中的照片
 */
- (void)loadAlbumWithIndex:(NSInteger)albumIndex results:(void(^)(NSArray *photos))block
{
    // 1. 先从缓存中取
    if (self.albumCaches.count > 0) {
        NSArray *caches = self.albumCaches[@(albumIndex)];
        if (caches.count > 0) {
            block(caches);
            return;
        }
    }

    
    // 2. 如果没有再去解析
    __weak typeof(self) weakSelf = self;
    [weakSelf loadPhotosSourceWithAlbum:weakSelf.albumsInfo[albumIndex][ALBUMDATASOURCE] results:^(NSArray *photosSource) {
        [weakSelf loadPhotosWithPhotosSource:photosSource onMainQueue:NO results:^(NSArray *photos) {
            
            // 缓存相册的数据
            self.albumCaches[@(albumIndex)] = photos;
            
            if (block) {
                block(photos);
            }
            
        }];
    }];
    
    
}

/**
 * 获取所有相册 一口气加载所有图片
 */
- (void)loadAllAlbumsDirectly:(void(^)(NSArray *albums))block;
{
    // 每次重新打开相册都清空缓存
    [self clearCache];
    
    [self loadGroups:^(NSArray *albums) {
        if (block) {
            block(albums);
        }
    }];
}

// 用于懒加载
// 从图片资源中加载图片
// ALAsset - > photo
- (void)loadPhotosWithPhotosSource:(NSArray *)photosSource onMainQueue:(BOOL)thread results:(void(^)(NSArray *photos))block
{
    if (![self canReadAlbums]) {
        return;
    }
    
    NSMutableArray *photos = @[].mutableCopy;
    if (!thread) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            for (ALAsset *result in photosSource) {
//                ALAssetRepresentation *representation = [result defaultRepresentation];
//                // 获取资源图片的类型
//                UIImage *image = [UIImage imageWithCGImage:[representation fullScreenImage]];
                UIImage *image = [UIImage imageWithCGImage:result.aspectRatioThumbnail];
                [photos addObject:image];
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                block(photos.copy);
            });
        });
    } else {
        for (ALAsset *result in photosSource) {
            ALAssetRepresentation *representation = [result defaultRepresentation];
            // 获取资源图片的类型
            UIImage *image = [UIImage imageWithCGImage:[representation fullScreenImage]];
            [photos addObject:image];
        }
        block(photos.copy);
    }

    
}

// 用于懒加载
// 从相册中加载图片资源
// ALAssetsGroup - > ALAsset
- (void)loadPhotosSourceWithAlbum:(ALAssetsGroup *)album results:(void(^)(NSArray *photosSource))block
{
    if (![self canReadAlbums]) {
        return;
    }
    
    // 设置获取类型
    [album setAssetsFilter:[ALAssetsFilter allPhotos]];
    if (album.numberOfAssets > 0) {
        // 用于存储相片的数组
        NSMutableArray *photosSource = [[NSMutableArray alloc] init];
        // 3. 遍历相册，获取照片数据
        [album enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            
            if (result) {
                [photosSource addObject:result];
            } else {
                block(photosSource);
            }
            
        }];
    }
    
}

// 用于懒加载
// 从数据库中加载相册
// ALAssetsLibrary - > ALAssetsGroup
- (void)loadAlbum:(void(^)(ALAssetsGroup *album,UIImage *firstPhoto,NSString *albumName,NSInteger count))block complete:(void(^)())completeBlock
{
    if (![self canReadAlbums]) {
        return;
    }
    
    // 1. 创建相簿库
    static ALAssetsLibrary *assetsLib;
    if (!assetsLib) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            assetsLib = [[ALAssetsLibrary alloc] init];
        });
    }
    
    __weak typeof(self) weakSelf = self;
    // 用于存储每个相册的数组
    // 2. 遍历相簿库取出每个相册
    // 异步的方法：获取相册数据
    [assetsLib enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *album, BOOL *stop) {
        if (album) {
            // 设置获取类型
            [album setAssetsFilter:[ALAssetsFilter allPhotos]];
            NSString *albumName = [NSString stringWithFormat:@"%@",[album valueForProperty:ALAssetsGroupPropertyName]];
            NSInteger count = [album numberOfAssets];

            [weakSelf loadPhotosSourceWithAlbum:album results:^(NSArray *photosSource) {
                if (photosSource.count > 0) {
                    [weakSelf loadPhotosWithPhotosSource:@[photosSource.firstObject] onMainQueue:YES results:^(NSArray *photos) {
                        UIImage *firstPhoto = photos.firstObject;
                        if (block) {
                            block(album,firstPhoto,albumName,count);
                        }
                    }];
                }
                
            }];
        } else { // group为空，相册已经便利完,返回提取好的相册数组
            if (completeBlock) {
                completeBlock();
            }
        }
    } failureBlock:^(NSError *error) {
        
    }];
}

// 一口气加载所有图片
- (void)loadGroups:(void(^)(NSArray *albums))block
{
    if (![self canReadAlbums]) {
        return;
    }
    
    // 1. 创建相簿库
    static ALAssetsLibrary *assetsLib;
    if (!assetsLib) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            assetsLib = [[ALAssetsLibrary alloc] init];
        });
    }
    
    // 用于存储每个相册的数组
    NSMutableArray *albums = @[].mutableCopy;
    // 2. 遍历相簿库取出每个相册
    // 异步的方法：获取相册数据
    [assetsLib enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            // 设置获取类型
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            if (group.numberOfAssets > 0) {
                // 用于存储相片的数组
                NSMutableArray *photos = [[NSMutableArray alloc] init];
                // 3. 遍历相册，获取照片数据
                [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        // 获取资源图片的详细资源信息
                        ALAssetRepresentation *representation = [result defaultRepresentation];
                        // 获取资源图片的类型
                        UIImage *image = [UIImage imageWithCGImage:[representation fullScreenImage]];
                        [photos addObject:image];
                    } else {
                        [albums addObject:photos];
                    }
                }];
            }
        } else { // 4. group为空，相册已经便利完,返回提取好的相册数组
            block(albums);
        }
    } failureBlock:^(NSError *error) {
        
    }];
    
}

// 判断权限
- (BOOL)canReadAlbums
{
    // 获取当前应用对照片的访问授权状态
    ALAuthorizationStatus authorizationStatus = [ALAssetsLibrary authorizationStatus];
    // 如果没有获取访问授权，或者访问授权状态已经被明确禁止，则显示提示语，引导用户开启授权
    if (authorizationStatus == ALAuthorizationStatusRestricted || authorizationStatus == ALAuthorizationStatusDenied) {
        NSDictionary *mainInfoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appName = [mainInfoDictionary objectForKey:@"CFBundleName"];
        NSString *tipTextWhenNoPhotosAuthorization = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", appName];
        // 展示提示语
        NSLog(@"%@",tipTextWhenNoPhotosAuthorization);
        return NO;
    }
    return YES;
}

- (void)removeFromMemory
{
    [self clearCache];
}

@end
