//
//  GYPhotoCell.m
//  GYPhotoPicker
//
//  Created by 高言 on 16/3/24.
//  Copyright © 2016年 高言. All rights reserved.
//

#import "GYPhotoCell.h"
#import "GYSelectButton.h"
#import "GYAlbumManager.h"
#import "GYAlbumConst.h"

@interface GYPhotoCell()

@property (nonatomic , weak) UIImageView *imageView;
@property (nonatomic , weak) GYSelectButton *selectButton;

@end

@implementation GYPhotoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupImageView];
        [self setupButton];
    }
    return self;
}

- (void)setupImageView
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.cornerRadius = 3;
    imageView.clipsToBounds = YES;
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
}

- (void)setupButton
{
    GYSelectButton *selectButton = [GYSelectButton selectButtonWithAction:^(GYSelectButton *btn) {
        if ([GYAlbumManager shareAlbumManager].selectedImages.count == [GYAlbumManager shareAlbumManager].maxSelectedNum) {
            btn.selected = NO;
            [[GYAlbumManager shareAlbumManager].selectedImages removeObject:self.image];
            [[NSNotificationCenter defaultCenter] postNotificationName:selectImageNotification object:nil];
            return ;
        }
        
        btn.selected = !btn.selected;
        if (btn.selected) {
            [[GYAlbumManager shareAlbumManager].selectedImages addObject:self.image];
        } else {
            [[GYAlbumManager shareAlbumManager].selectedImages removeObject:self.image];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:selectImageNotification object:nil];
    }];
    [self.contentView addSubview:selectButton];
    self.selectButton = selectButton;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    self.imageView.image = image;
    
    self.selectButton.selected = NO;

    if ([[GYAlbumManager shareAlbumManager].selectedImages containsObject:image]) {
        self.selectButton.selected = YES;
    }
}

- (void)setIsFirst:(BOOL)isFirst
{
    _isFirst = isFirst;
    self.selectButton.hidden = isFirst;
    if (isFirst) {
        self.imageView.contentMode = UIViewContentModeCenter;
    } else {
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.contentView.bounds.size.width;
    CGFloat height = self.contentView.bounds.size.height;
    self.selectButton.frame = CGRectMake(0, 0, width, 0.25 * height);
    self.imageView.frame = self.bounds;
}

@end
