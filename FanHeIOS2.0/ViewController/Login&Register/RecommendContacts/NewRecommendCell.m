//
//  NewRecommendCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/24.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "NewRecommendCell.h"

@interface NewRecommendCell ()

@property (weak, nonatomic) IBOutlet UIView *firstView;
@property (weak, nonatomic) IBOutlet UIImageView *firstHeaderImageView;
@property (weak, nonatomic) IBOutlet UIButton *firstSelectedBtn;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstCompanyLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstPositionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *firstVipImageView;
@property (weak, nonatomic) IBOutlet UIImageView *firstBgImageView;

@property (nonatomic, strong) UserModel *model;

@end

@implementation NewRecommendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [CALayer updateControlLayer:self.firstHeaderImageView.layer radius:30 borderWidth:0 borderColor:nil];
    });
}

- (void)updateDisplay:(UserModel*)model{
    [self.firstHeaderImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    self.firstNameLabel.text = model.realname;
    self.firstCompanyLabel.text = model.company;
    self.firstPositionLabel.text = model.position;
    self.firstSelectedBtn.selected = model.isSelected;
    self.firstVipImageView.hidden = model.usertype.integerValue != 9;
    self.firstBgImageView.image = model.isSelected?kImageWithName(@"bg_tj_checked02"):kImageWithName(@"bg_tj_checked01");
}


@end
