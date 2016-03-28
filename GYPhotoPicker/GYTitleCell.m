//
//  GYTitleCell.m
//  GYPhotoPicker
//
//  Created by 高言 on 16/3/25.
//  Copyright © 2016年 高言. All rights reserved.
//

#import "GYTitleCell.h"

@implementation GYTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat margin = 5;
    CGFloat cellW = self.bounds.size.width;
    CGFloat cellH = self.bounds.size.height;
    self.imageView.frame = CGRectMake(margin * 2, margin, cellH - 2 * 5, cellH - 2 * 5);
    CGFloat textLabelLeft = CGRectGetMaxX(self.imageView.frame) + 2 * margin;
    self.textLabel.frame = CGRectMake(textLabelLeft, 0, cellW - textLabelLeft - 2 * margin, cellH);
}

@end
