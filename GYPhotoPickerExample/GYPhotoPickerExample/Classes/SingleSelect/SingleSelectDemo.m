//
//  SingleSelectDemo.m
//  GYPhotoPickerExample
//
//  Created by 高言 on 16/3/28.
//  Copyright © 2016年 高言. All rights reserved.
//

#import "SingleSelectDemo.h"
#import "GYAlbumViewController.h"

@interface SingleSelectDemo () <GYAlbumViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation SingleSelectDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)select {
    GYAlbumViewController *vc = [[GYAlbumViewController alloc] init];
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)albumViewControllerDidSelectedImages:(NSArray *)images
{
    self.imageView.image = images.firstObject;
}

@end
