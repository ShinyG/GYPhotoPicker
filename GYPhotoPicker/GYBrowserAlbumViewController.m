//
//  GYBrowserAlbumViewController.m
//  GYPhotoPicker
//
//  Created by 高言 on 16/3/25.
//  Copyright © 2016年 高言. All rights reserved.
//

#import "GYBrowserAlbumViewController.h"
#import "GYAlbumViewController.h"
#import "GYAlbumConst.h"
#import "GYBrowserCell.h"
#import "GYAlbumConst.h"
#import "GYAlbumManager.h"

@interface GYBrowserAlbumViewController () <UICollectionViewDataSource,UICollectionViewDelegate>

/** collectionView */
@property (nonatomic , weak) UICollectionView *collectionView;
/** collectionFlowLayout */
@property (nonatomic , weak) UICollectionViewFlowLayout *flowLayout;
/** rightItem */
@property (nonatomic , weak) UIButton *rightItemBtn;
/** tableView顶部间距 */
@property (nonatomic , assign) CGFloat topMargin;

@end

@implementation GYBrowserAlbumViewController

static NSString * const cellIdForBrowser = @"browserCell";

- (void)viewDidLoad {
    [super viewDidLoad];

    if (ScreenW > ScreenH) {
        self.topMargin = navBarH;
    } else {
        self.topMargin = navBarH + 20;
    }
    
    [self setupStyle];
    [self setupCollectionView];
    [self selectedImage:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedImage:) name:selectImageNotification object:nil];
}

- (void)setupStyle
{
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
}

- (void)setupCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(ScreenW, ScreenH - self.topMargin);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.flowLayout = flowLayout;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenW, ScreenH) collectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.pagingEnabled = YES;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[GYBrowserCell class] forCellWithReuseIdentifier:cellIdForBrowser];
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    [collectionView scrollToItemAtIndexPath:self.indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    [self scrollViewDidEndDecelerating:self.collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.albums.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GYBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdForBrowser forIndexPath:indexPath];
    cell.image = self.albums[indexPath.row];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger index = offsetX / ScreenW + 0.5 + 1;
    self.indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    self.navigationItem.title = [NSString stringWithFormat:@"%ld / %ld",index,self.albums.count];
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if (navBarH > 0) {
        if (size.width > size.height) {
            self.topMargin = navBarH;
        } else {
            self.topMargin = navBarH + 20;
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.indexPath.row - 1 inSection:0];
        [UIView animateWithDuration:0.5 animations:^{
            self.flowLayout.itemSize = CGSizeMake(size.width, size.height - self.topMargin);
            self.collectionView.frame = CGRectMake(0, 0, size.width, size.height);
        } completion:^(BOOL finished) {
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
        }];
        
        
    }
    
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
    UIViewController *rootVc = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
    [self.navigationController popToViewController:rootVc animated:NO];
    [rootVc performSelector:@selector(finishSelectImages) withObject:nil];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:selectImageNotification object:nil];
}

@end
