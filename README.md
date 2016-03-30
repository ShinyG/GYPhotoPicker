# GYPhotoPicker
* 简单易用的自定义图片选择器，支持单选，多选，自定义照相。

#GYPhotoPicker的使用
* 方法一:通过cocoapods -> pod 'GYPhotoPicker'
* 方法二:Download ZIP -> 把GYPhotoPicker文件夹中的所有文件拽入项目中,主头文件为：#import "GYAlbumViewController.h"


![example](https://raw.githubusercontent.com/ShinyG/GYPhotoPicker/master/gif/GYPhotoPicker.gif)


# Example
## 1.单选
```objc    
    GYAlbumViewController *vc = [[GYAlbumViewController alloc] init];
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
    // delegate
    albumViewControllerDidSelectedImages:(NSArray *)images
```

## 2.多选
```objc
    GYAlbumViewController *vc = [GYAlbumViewController albumViewControllerWithMaxSelectedNum:self.textFiled.text.intValue finishSelectedBlock:^(NSArray *images) {
        self.images = images.mutableCopy;
        [self.collectionView reloadData];
    }];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
```

## 3.自定义相机
```objc
    GYAlbumViewController *vc = [GYAlbumViewController albumViewControllerWithMaxSelectedNum:2 finishSelectedBlock:^(NSArray *images) {
    } takePhotoBlock:^{
        NSLog(@"选择相机时调用，逻辑自定义");
        // 例如:
        [self openCamera];
    }];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
```


