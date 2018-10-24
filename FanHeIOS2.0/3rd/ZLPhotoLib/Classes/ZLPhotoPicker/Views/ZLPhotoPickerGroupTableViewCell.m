//
//  PickerGroupTableViewCell.m
//  ZLAssetsPickerDemo
//
//  Created by 张磊 on 14-11-13.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#import "ZLPhotoPickerGroupTableViewCell.h"
#import "ZLPhotoPickerGroup.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ZLPhotoPickerGroupTableViewCell ()
@property (weak, nonatomic) UIImageView *groupImageView;
@property (weak, nonatomic) UILabel *groupNameLabel;
@property (weak, nonatomic) UILabel *groupPicCountLabel;
@property (weak, nonatomic) UIImageView *arrowImageView;
@end

@implementation ZLPhotoPickerGroupTableViewCell

- (UIImageView *)groupImageView{
    if (!_groupImageView) {
        UIImageView *groupImageView = [[UIImageView alloc] init];
        groupImageView.frame = CGRectMake(15, 5, 60, 60);
        groupImageView.contentMode = UIViewContentModeScaleAspectFill;
        [CALayer updateControlLayer:groupImageView.layer radius:0 borderWidth:0.5 borderColor:[UIColor lightGrayColor].CGColor];
        _groupImageView = groupImageView;
        [self.contentView addSubview:_groupImageView];
    }
    return _groupImageView;
}

- (UIImageView*)arrowImageView{
    if (!_arrowImageView) {
        UIImageView *arrowImageView = [[UIImageView alloc] init];
        arrowImageView.frame = CGRectMake(WIDTH-25, 26, 9, 17);
        arrowImageView.image = kImageWithName(@"next_arrow");
        _arrowImageView = arrowImageView;
        [self.contentView addSubview:_arrowImageView];
    }
    return _arrowImageView;
}

- (UILabel *)groupNameLabel{
    if (!_groupNameLabel) {
        UILabel *groupNameLabel = [[UILabel alloc] init];
        groupNameLabel.frame = CGRectMake(95, 15, WIDTH - 100, 20);
        [self.contentView addSubview:_groupNameLabel = groupNameLabel];
    }
    return _groupNameLabel;
}

- (UILabel *)groupPicCountLabel{
    if (!_groupPicCountLabel) {
        UILabel *groupPicCountLabel = [[UILabel alloc] init];
        groupPicCountLabel.font = [UIFont systemFontOfSize:13];
        groupPicCountLabel.textColor = [UIColor lightGrayColor];
        groupPicCountLabel.frame = CGRectMake(95, 40, WIDTH - 100, 20);
        [self.contentView addSubview:_groupPicCountLabel = groupPicCountLabel];
    }
    return _groupPicCountLabel;
}

- (void)setGroup:(ZLPhotoPickerGroup *)group{
    _group = group;
    
    self.groupNameLabel.text = group.groupName;
    self.groupImageView.image = group.thumbImage;
    self.groupPicCountLabel.text = [NSString stringWithFormat:@"(%lu)",(long)group.assetsCount];
    self.arrowImageView.image = kImageWithName(@"next_arrow");
}

@end
