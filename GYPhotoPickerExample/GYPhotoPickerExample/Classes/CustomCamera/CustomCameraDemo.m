//
//  CustomCameraDemo.m
//  GYPhotoPickerExample
//
//  Created by 高言 on 16/3/28.
//  Copyright © 2016年 高言. All rights reserved.
//

#import "CustomCameraDemo.h"
#import "GYAlbumViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface CustomCameraDemo ()

@end

@implementation CustomCameraDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)select {
    GYAlbumViewController *vc = [GYAlbumViewController albumViewControllerWithMaxSelectedNum:2 finishSelectedBlock:^(NSArray *images) {
        
    } takePhotoBlock:^{
        NSLog(@"选择相机时调用，逻辑自定义");
        // 例如:
        [self openCamera];
    }];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)openCamera
{
    [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted){
        NSLog(@"受限");
        return;
    }else if(authStatus == AVAuthorizationStatusDenied){
        NSLog(@"拒绝");
        return;
    }else if(authStatus == AVAuthorizationStatusAuthorized){
        NSLog(@"已经授权");
        NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        if (cameras.count == 0) {
            NSLog(@"取得设备输入对象时出错");
            return;
        } else {
        }
    }else if(authStatus == AVAuthorizationStatusNotDetermined){
        NSLog(@"不确定权限");
        return;
    }else {
        NSLog(@"未知权限");
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];
}


@end
