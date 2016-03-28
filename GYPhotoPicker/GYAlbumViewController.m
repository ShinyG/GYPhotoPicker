//
//  GYAlbumViewController.m
//  GYPhotoPicker
//
//  Created by 高言 on 16/3/24.
//  Copyright © 2016年 高言. All rights reserved.
//

#import "GYAlbumViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "GYBrowserAlbumViewController.h"
#import "GYAlbumManager.h"
#import "GYPhotoCell.h"
#import "GYRightImageButton.h"
#import "GYMaskView.h"
#import "GYTitleCell.h"
#import "GYAlbumConst.h"

@interface GYAlbumViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate>

/** 照片数组 */
@property (nonatomic , strong) NSMutableArray *albums;
/** 相册信息数组 */
@property (nonatomic , strong) NSArray *albumsInfo;
/** titleView的菜单 */
@property (nonatomic , weak) UITableView *tableView;
/** collectionView */
@property (nonatomic , weak) UICollectionView *collectionView;
/** collectionFlowLayout */
@property (nonatomic , weak) UICollectionViewFlowLayout *flowLayout;
/** titleBtn */
@property (nonatomic , weak) GYRightImageButton *titleBtn;
/** rightItem */
@property (nonatomic , weak) UIButton *rightItemBtn;
/** tableView顶部间距 */
@property (nonatomic , assign) CGFloat topMargin;
/** 是否需要照相机 */
@property (nonatomic , assign) BOOL isShowCamera;


@end

@implementation GYAlbumViewController

static NSString * const cellIdForCollection = @"photoCell";
static NSString *const cellIdForTable = @"photoCell";

+ (instancetype)albumViewControllerWithMaxSelectedNum:(NSInteger)maxSelectedNum finishSelectedBlock:(void(^)(NSArray *images))finishSelectedBlock
{
    GYAlbumViewController *vc = [[self alloc] init];
    vc.maxSelectedNum = maxSelectedNum;
    vc.selectedImagesBlock = finishSelectedBlock;
    return vc;
}

+ (instancetype)albumViewControllerWithMaxSelectedNum:(NSInteger)maxSelectedNum finishSelectedBlock:(void(^)(NSArray *images))finishSelectedBlock takePhotoBlock:(void(^)())clickCameraBlock
{
    GYAlbumViewController *vc = [[self alloc] init];
    vc.maxSelectedNum = maxSelectedNum;
    vc.selectedImagesBlock = finishSelectedBlock;
    vc.clickCameraBlock = clickCameraBlock;
    vc.isShowCamera = YES;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self setupTableView];
    [self setupCollectionView];
    [self setupStyle];
    [self setupAlbumData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedImage:) name:selectImageNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.collectionView reloadData];
}

- (void)setMaxSelectedNum:(NSInteger)maxSelectedNum
{
    _maxSelectedNum = maxSelectedNum;
    
    [GYAlbumManager shareAlbumManager].maxSelectedNum = maxSelectedNum;
}

- (void)setupStyle
{
    // bar
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithWhite:0.2 alpha:0.7]];
    
    // leftItem
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancle)];
    // rightItem
    UIButton *rightItemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightItemBtn.frame = CGRectMake(0, 0, 60, 25);
    rightItemBtn.backgroundColor = [UIColor orangeColor];
    rightItemBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [rightItemBtn setTitle:rightItemBtnName forState:UIControlStateNormal];
    [rightItemBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightItemBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    rightItemBtn.selected = YES;
    rightItemBtn.userInteractionEnabled = NO;
    [rightItemBtn addTarget:self action:@selector(finishSelectImages) forControlEvents:UIControlEventTouchUpInside];
    self.rightItemBtn = rightItemBtn;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightItemBtn];
    // backItem
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:nil action:nil];
    
    __weak typeof(self) weakSelf = self;
    // titleView
    GYRightImageButton *titleBtn = [GYRightImageButton rightImageButton:^(GYRightImageButton *btn) {
        [weakSelf titleBtnAction:btn];
    }];
    titleBtn.frame = CGRectMake(0, 0, 200, 44);
    [titleBtn setTitle:@"相机胶卷" forState:UIControlStateNormal];
    titleBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.navigationItem.titleView = titleBtn;
    self.titleBtn = titleBtn;
}

- (void)titleBtnAction:(GYRightImageButton *)btn
{
    __weak typeof(self) weakSelf = self;
    [GYMaskView shareMaskView].frame = weakSelf.view.bounds;
    
    // maskView 单例 不会重复创建，只是控制展示和隐藏
    [GYMaskView shareMaskView].showBlock = ^ {
        [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            CGRect rect = (CGRect){0, weakSelf.topMargin,weakSelf.tableView.bounds.size};
            weakSelf.tableView.frame = rect;
        } completion:nil];
    };
    [GYMaskView shareMaskView].hideBlock = ^ {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect rect = (CGRect){0, -4 * titleRowH - weakSelf.topMargin,weakSelf.tableView.bounds.size};
            weakSelf.tableView.frame = rect;
            btn.selected = NO;
        } completion:^(BOOL finished) {
            [GYMaskView shareMaskView].alpha = 0.0;
        }];
    };
    
    btn.selected = !btn.selected;
    if (!btn.selected) {
        [[GYMaskView shareMaskView] hideMask];
    } else {
        // 将maskView从窗口调整到当前视图上
        [weakSelf.view addSubview:[GYMaskView shareMaskView]];
        CGRect rect = (CGRect){0, -4 * titleRowH - weakSelf.topMargin,weakSelf.tableView.bounds.size};
        weakSelf.tableView.frame = rect;
        [[GYMaskView shareMaskView] showMask];
    }
}

- (void)setupAlbumData
{
    GYAlbumManager *albumManager = [GYAlbumManager shareAlbumManager];
    
    [albumManager loadAlbumslazily:^(NSArray *photosInFirstAlbum, NSArray *albumsInfo) {
        self.albums = photosInFirstAlbum.mutableCopy;
        if (self.isShowCamera) {
            [self.albums insertObject:[UIImage imageNamed:@"GYPhotoPicker.bundle/camera"] atIndex:0];
        }
        self.albumsInfo = albumsInfo;
        
        [self.tableView reloadData];
        [self.collectionView reloadData];
        
        if (navBarH > 0) {
            if (self.view.bounds.size.width > self.view.bounds.size.height) {
                self.topMargin = navBarH;
            } else {
                self.topMargin = 20 + navBarH;
            }
            
        }
        
        self.tableView.frame = CGRectMake(0, self.topMargin, ScreenW, titleRowH * albumsInfo.count);
        
        if (albumsInfo.count > 0) {
            [self.titleBtn setTitle:albumsInfo.firstObject[ALBUMNAME] forState:UIControlStateNormal];
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
        }

    }];
}

- (void)setupTableView
{
    UITableView *tableView = [[UITableView alloc] init];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.layer.anchorPoint = CGPointMake(0.5, 0);
    tableView.rowHeight = titleRowH;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [tableView registerClass:[GYTitleCell class] forCellReuseIdentifier:cellIdForTable];

    [[GYMaskView shareMaskView] addSubview:tableView];
    self.tableView = tableView;
}

- (void)setupCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(ScreenW * 0.33, ScreenW * 0.33);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.flowLayout = flowLayout;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, ScreenH) collectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[GYPhotoCell class] forCellWithReuseIdentifier:cellIdForCollection];

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.albums.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GYPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdForCollection forIndexPath:indexPath];
//    cell.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1];
    cell.image = self.albums[indexPath.row];
    if (self.isShowCamera) {
        cell.isFirst = indexPath.row == 0;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && self.isShowCamera) {
        // 打开相机
        if (self.clickCameraBlock) {
            self.clickCameraBlock();
            [self cancle];
        } else {
            [self openCamera];
        }
        
        return;
    }
    
    GYBrowserAlbumViewController *browserAlbumVc = [[GYBrowserAlbumViewController alloc] init];
    if (self.isShowCamera) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, self.albums.count-1)];
        NSArray *albums = [NSArray arrayWithArray:[self.albums objectsAtIndexes:indexSet]];
        browserAlbumVc.albums = albums;
        browserAlbumVc.indexPath = [NSIndexPath indexPathForItem:indexPath.row - 1 inSection:indexPath.section];
    } else {
        browserAlbumVc.albums = self.albums;
        browserAlbumVc.indexPath = [NSIndexPath indexPathForItem:indexPath.row inSection:indexPath.section];
    }

    [self.navigationController pushViewController:browserAlbumVc animated:YES];
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
    }else {
        NSLog(@"未知权限");
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.albumsInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GYTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdForTable];
    
    NSDictionary *albumInfo = self.albumsInfo[indexPath.row];
    NSString *title = [NSString stringWithFormat:@"%@  %@张",albumInfo[ALBUMNAME],albumInfo[ALBUMPHOTOSCOUNT]];
    UIImage *image = albumInfo[ALBUMFIRSTPHOTO];
    
    cell.textLabel.text = title;
    cell.imageView.image = image;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *albumInfo = self.albumsInfo[indexPath.row];
    [self.titleBtn setTitle:albumInfo[ALBUMNAME] forState:UIControlStateNormal];
    __weak typeof(self) weakSelf = self;
    [[GYAlbumManager shareAlbumManager] loadAlbumWithIndex:indexPath.row results:^(NSArray *photos) {
        [weakSelf titleBtnAction:weakSelf.titleBtn];
        weakSelf.albums = photos.mutableCopy;
        if (self.isShowCamera) {
            [weakSelf.albums insertObject:[UIImage imageNamed:@"GYPhotoPicker.bundle/camera"] atIndex:0];
        }
        [weakSelf.collectionView reloadData];
    }];

}

- (void)selectedImage:(NSNotification *)noti
{
    NSArray *images = [GYAlbumManager shareAlbumManager].selectedImages;
    if (images.count > 0) {
        self.rightItemBtn.userInteractionEnabled = YES;
        self.rightItemBtn.selected = NO;
        [self.rightItemBtn setTitle:[NSString stringWithFormat:@"%@(%ld)",rightItemBtnName,images.count] forState:UIControlStateNormal];
    } else {
        self.rightItemBtn.userInteractionEnabled = NO;
        self.rightItemBtn.selected = YES;
        [self.rightItemBtn setTitle:rightItemBtnName forState:UIControlStateNormal];
    }
 
}

- (void)finishSelectImages
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.selectedImagesBlock) {
            self.selectedImagesBlock([GYAlbumManager shareAlbumManager].selectedImages);
        }
        if ([self.delegate respondsToSelector:@selector(albumViewControllerDidSelectedImages:)]) {
            [self.delegate albumViewControllerDidSelectedImages:[GYAlbumManager shareAlbumManager].selectedImages];
        }
    }];
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if (navBarH > 0) {
        if (size.width > size.height) {
            self.topMargin = navBarH;
        } else {
            self.topMargin = navBarH + 20;
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            self.tableView.frame = CGRectMake(0, self.topMargin, ScreenW, titleRowH * self.albumsInfo.count);
            self.flowLayout.itemSize = CGSizeMake(size.width * 0.33, size.width * 0.33);
        }];

    }

}

- (void)cancle
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    // 释放资源
    [self.tableView removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:selectImageNotification object:nil];
    [[GYAlbumManager shareAlbumManager] removeFromMemory];
//    NSLog(@"dealloc");
}
@end
