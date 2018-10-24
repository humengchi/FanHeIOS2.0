//
//  GetWallCoffeeReplyTableViewCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/26.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "GetWallCoffeeReplyTableViewCell.h"

@interface GetWallCoffeeReplyTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (nonatomic, strong) MyGetCoffeeModel *model;
@property (nonatomic, assign) BOOL isMyGetCoff;
@end

@implementation GetWallCoffeeReplyTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [CALayer updateControlLayer:self.headerImageView.layer radius:20 borderWidth:0 borderColor:nil];
    [CommonMethod viewAddGuestureRecognizer:self.headerImageView tapsNumber:1 withTarget:self withSEL:@selector(gotoHomePage)];
}

- (void)gotoHomePage{
    NewMyHomePageController *vc = [[NewMyHomePageController alloc]  init];
    if(self.isMyGetCoff){
        vc.userId = self.model.userid;
    }else{
        vc.userId = [DataModelInstance shareInstance].userModel.userId;
    }
    [[self viewController].navigationController pushViewController:vc animated:YES];
}

+ (CGFloat)getCellHeight:(MyGetCoffeeModel*)model{
    NSString *contentStr = model.revert;
    CGFloat height = [NSHelper heightOfString:contentStr font:FONT_SYSTEM_SIZE(16) width:WIDTH-149 defaultHeight:16];
    return height+38+24;
}

- (void)updateDisply:(MyGetCoffeeModel*)model isMyGetCodffee:(BOOL)isMyGetCodffee{
    self.model = model;
    self.isMyGetCoff = isMyGetCodffee;
    self.timeLabel.text = model.reverttime;
    self.contentLabel.text = model.revert;
    //我领取了咖啡，别人回复
    if(isMyGetCodffee){
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    }else{
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[DataModelInstance shareInstance].userModel.image] placeholderImage:KHeadImageDefaultName([DataModelInstance shareInstance].userModel.realname)];
    }
    //背景图片，气泡
    UIImageView *bgImageView = [[UIImageView alloc] init];
    CGFloat width = [NSHelper widthOfString:model.revert font:FONT_SYSTEM_SIZE(16) height:20]+27;
    width = (width>WIDTH-149)?WIDTH-122:width;
    CGFloat top = 20; // 顶端盖高度
    CGFloat bottom = 20; // 底端盖高度
    CGFloat left = 20; // 左端盖宽度
    CGFloat right = 20; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    if(isMyGetCodffee){
        bgImageView.frame = CGRectMake(60, 38, width, [GetWallCoffeeReplyTableViewCell getCellHeight:model]-38);
        UIImage *bgImage = [UIImage imageNamed:@"bg_dialog_left"];
        bgImage = [bgImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        bgImageView.image = bgImage;
    }else{
        bgImageView.frame = CGRectMake(WIDTH-60-width, 38, width, [GetWallCoffeeReplyTableViewCell getCellHeight:model]-38);
        UIImage *bgImage = [UIImage imageNamed:@"bg_dialog_right"];
        bgImage = [bgImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
        bgImageView.image = bgImage;
    }
    [self.contentView insertSubview:bgImageView belowSubview:self.contentLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
