//
//  NoFriendTableViewCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/18.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "NoFriendTableViewCell.h"

@interface NoFriendTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *clickedBtn;

@end

@implementation NoFriendTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [CALayer updateControlLayer:self.clickedBtn.layer radius:3 borderWidth:0.5 borderColor:HEX_COLOR(@"818C9E").CGColor];
    // Initialization code
}

- (IBAction)gotoButtonClicked:(id)sender {
    [[self viewController].navigationController popToRootViewControllerAnimated:NO];
    [[AppDelegate shareInstance].tabBarController setSelectedIndex:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateDisplay:(BOOL)isRecentList isSearch:(BOOL)isSearch{
    self.nameLabel.text = isRecentList?@"暂无最近联系人":(isSearch?@"未搜索到好友":@"暂无任何好友");
    self.clickedBtn.hidden = NO;//isRecentList?isRecentList:isSearch;
}

@end
