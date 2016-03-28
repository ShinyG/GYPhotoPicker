//
//  GYBrowserCell.m
//  GYPhotoPicker
//
//  Created by 高言 on 16/3/25.
//  Copyright © 2016年 高言. All rights reserved.
//

#import "GYBrowserCell.h"
#import "GYAlbumConst.h"
#import "GYSelectButton.h"
#import "GYAlbumManager.h"

@interface GYBrowserCell() <UIScrollViewDelegate>

@property (nonatomic , weak) UIScrollView *scrollView;
@property (nonatomic , weak) UIImageView *imageView;
@property (nonatomic , weak) GYSelectButton *selectButton;
@end

@implementation GYBrowserCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupScrollView];
        [self setupImageView];
        [self setupButton];
    }
    return self;
}

- (void)setupScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.maximumZoomScale = 10.0;
    scrollView.minimumZoomScale = 0.8;
    scrollView.delegate = self;
    [self.contentView addSubview:scrollView];
    self.scrollView = scrollView;
}

- (void)setupImageView
{
    UIImageView *imageView = [[UIImageView alloc] init];
    [self.scrollView addSubview:imageView];
    self.imageView = imageView;
}

- (void)setupButton
{
    GYSelectButton *selectButton = [GYSelectButton selectButtonWithAction:^(GYSelectButton *btn) {
        if ([GYAlbumManager shareAlbumManager].selectedImages.count == [GYAlbumManager shareAlbumManager].maxSelectedNum) {
            btn.selected = NO;
            [[GYAlbumManager shareAlbumManager].selectedImages removeObject:self.image];
            [[NSNotificationCenter defaultCenter] postNotificationName:selectImageNotification object:nil];
            return;
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
    
    self.selectButton.selected = NO;

    if ([[GYAlbumManager shareAlbumManager].selectedImages containsObject:image]) {
        self.selectButton.selected = YES;
    }
    
    self.scrollView.frame = self.contentView.bounds;
    self.scrollView.zoomScale = 1.0;
    
    self.imageView.image = image;
    self.imageView.frame = (CGRect){image.size.width > self.bounds.size.width ? 0 : (self.bounds.size.width - image.size.width) * 0.5,
        image.size.height > self.bounds.size.height ? 0 : (self.bounds.size.height - image.size.height) * 0.5,
        image.size.width > self.bounds.size.width ? (CGSize){self.bounds.size.width , image.size.height} :image.size};
    self.scrollView.contentSize = CGSizeMake(self.contentView.bounds.size.width, self.imageView.bounds.size.height);
    
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if (scrollView.contentSize.width > ScreenW && scrollView.contentSize.height > ScreenH) {
        self.imageView.center = CGPointMake(scrollView.contentSize.width*0.5,  scrollView.contentSize.height*0.5);
    } else if (scrollView.contentSize.width > ScreenW && scrollView.contentSize.height < ScreenH) {
        self.imageView.center = CGPointMake(scrollView.contentSize.width*0.5,  scrollView.bounds.size.height*0.5);
    } else if (scrollView.contentSize.width < ScreenW && scrollView.contentSize.height > ScreenH) {
        self.imageView.center = CGPointMake(scrollView.bounds.size.width*0.5,  scrollView.contentSize.height*0.5);
    } else {
        self.imageView.center = scrollView.center;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.contentView.bounds.size.width;
    CGFloat height = 50;
    self.selectButton.frame = CGRectMake(0, 0, width, height);
    
    
    CGFloat selectBtnWidth = 40;
    CGRect imageViewRect = (CGRect){self.bounds.size.width - selectBtnWidth - 15,15,selectBtnWidth,selectBtnWidth};
    self.selectButton.imageViewFrame = imageViewRect;
    
    self.scrollView.frame = self.contentView.bounds;
    self.imageView.frame = (CGRect){self.image.size.width > self.bounds.size.width ? 0 : (self.bounds.size.width - self.image.size.width) * 0.5,
        self.image.size.height > self.bounds.size.height ? 0 : (self.bounds.size.height - self.image.size.height) * 0.5,
        self.image.size.width > self.bounds.size.width ? (CGSize){self.bounds.size.width , self.image.size.height} :self.image.size};
    self.scrollView.contentSize = CGSizeMake(self.contentView.bounds.size.width, self.imageView.bounds.size.height);
}

@end
