//
//  MultiSelectDemo.m
//  GYPhotoPickerExample
//
//  Created by 高言 on 16/3/28.
//  Copyright © 2016年 高言. All rights reserved.
//

#import "MultiSelectDemo.h"
#import "GYAlbumViewController.h"

@interface MultiSelectDemo ()<UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *textFiled;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic , strong) NSMutableArray *images;

@end

@implementation MultiSelectDemo

static NSString * const ID = @"cell";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:ID];
}

- (IBAction)select {
    NSLog(@"%@",self.textFiled.text);
    [self.textFiled resignFirstResponder];
    
    GYAlbumViewController *vc = [GYAlbumViewController albumViewControllerWithMaxSelectedNum:self.textFiled.text.intValue finishSelectedBlock:^(NSArray *images) {
        self.images = images.mutableCopy;
        [self.collectionView reloadData];
    }];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
    imageView.frame = cell.bounds;
    imageView.image = self.images[indexPath.row];
    [cell addSubview:imageView];
    
    return cell;
}

@end
