//
//  GYBrowserAlbumViewController.h
//  GYPhotoPicker
//
//  Created by 高言 on 16/3/25.
//  Copyright © 2016年 高言. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GYAlbumViewController;
@interface GYBrowserAlbumViewController : UIViewController

/** 照片数组 */
@property (nonatomic , strong) NSArray *albums;
@property (nonatomic , strong) NSIndexPath *indexPath;

@end
