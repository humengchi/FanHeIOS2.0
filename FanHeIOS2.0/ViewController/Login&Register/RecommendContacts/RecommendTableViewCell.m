//
//  RecommendTableViewCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/10/25.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "RecommendTableViewCell.h"

@interface RecommendTableViewCell ()

@property (nonatomic, assign) BOOL canChoiceAll;
@property (nonatomic, strong) RecommendModel *model;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *allSelectedBtn;

@property (weak, nonatomic) IBOutlet UIView *firstView;
@property (weak, nonatomic) IBOutlet UIImageView *firstHeaderImageView;
@property (weak, nonatomic) IBOutlet UIButton *firstSelectedBtn;
@property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstCompanyLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstPositionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *firstVipImageView;
@property (weak, nonatomic) IBOutlet UIImageView *firstBgImageView;

@property (weak, nonatomic) IBOutlet UIView *secondView;
@property (weak, nonatomic) IBOutlet UIImageView *secondHeaderImageView;
@property (weak, nonatomic) IBOutlet UIButton *secondSelectedBtn;
@property (weak, nonatomic) IBOutlet UILabel *secondNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondCompanyLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondPositionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *secondVipImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secondBgImageView;

@property (weak, nonatomic) IBOutlet UIView *thirdView;
@property (weak, nonatomic) IBOutlet UIImageView *thirdHeaderImageView;
@property (weak, nonatomic) IBOutlet UIButton *thirdSelectedBtn;
@property (weak, nonatomic) IBOutlet UILabel *thirdNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdCompanyLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdPositionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thirdVipImageView;
@property (weak, nonatomic) IBOutlet UIImageView *thirdBgImageView;

@end

@implementation RecommendTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [CALayer updateControlLayer:self.firstHeaderImageView.layer radius:30 borderWidth:0 borderColor:nil];
        [CALayer updateControlLayer:self.secondHeaderImageView.layer radius:30 borderWidth:0 borderColor:nil];
        [CALayer updateControlLayer:self.thirdHeaderImageView.layer radius:30 borderWidth:0 borderColor:nil];
    });
    [CommonMethod viewAddGuestureRecognizer:self.firstView tapsNumber:1 withTarget:self withSEL:@selector(selectUserButtonClicked:)];
    [CommonMethod viewAddGuestureRecognizer:self.secondView tapsNumber:1 withTarget:self withSEL:@selector(selectUserButtonClicked:)];
    [CommonMethod viewAddGuestureRecognizer:self.thirdView tapsNumber:1 withTarget:self withSEL:@selector(selectUserButtonClicked:)];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateDisplay:(RecommendModel*)model{
    self.model = model;
    self.canChoiceAll = model.canChoiceAll;
    if(model.canChoiceAll){
        self.titleLabel.text = [NSString stringWithFormat:@"#%@#圈",model.name];
        self.titleLabel.textColor = HEX_COLOR(@"1ABC9C");
    }else{
        self.titleLabel.text = model.name;
        self.titleLabel.textColor = HEX_COLOR(@"41464E");
    }
    self.allSelectedBtn.hidden = !model.canChoiceAll;
    self.allSelectedBtn.selected = model.hasSelectedAll;
    self.bgImageView.hidden = !model.canChoiceAll;
    if(model.userArray.count == 3){
        [self setFirstUserInfo:model.userArray[0]];
        [self setSecondUserInfo:model.userArray[1]];
        [self setThirdUserInfo:model.userArray[2]];
    }
}

- (void)setFirstUserInfo:(UserModel*)model{
    [self.firstHeaderImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    self.firstNameLabel.text = model.realname;
    self.firstCompanyLabel.text = model.company;
    self.firstPositionLabel.text = model.position;
    self.firstSelectedBtn.hidden = self.canChoiceAll;
    self.firstSelectedBtn.selected = model.isSelected;
    self.firstBgImageView.hidden = self.canChoiceAll;
    self.firstVipImageView.hidden = model.usertype.integerValue != 9;
}

- (void)setSecondUserInfo:(UserModel*)model{
    [self.secondHeaderImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    self.secondNameLabel.text = model.realname;
    self.secondCompanyLabel.text = model.company;
    self.secondPositionLabel.text = model.position;
    self.secondSelectedBtn.hidden = self.canChoiceAll;
    self.secondSelectedBtn.selected = model.isSelected;
    self.secondBgImageView.hidden = self.canChoiceAll;
    self.secondVipImageView.hidden = model.usertype.integerValue != 9;
}

- (void)setThirdUserInfo:(UserModel*)model{
    [self.thirdHeaderImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    self.thirdNameLabel.text = model.realname;
    self.thirdCompanyLabel.text = model.company;
    self.thirdPositionLabel.text = model.position;
    self.thirdSelectedBtn.hidden = self.canChoiceAll;
    self.thirdSelectedBtn.selected = model.isSelected;
    self.thirdBgImageView.hidden = self.canChoiceAll;
    self.thirdVipImageView.hidden = model.usertype.integerValue != 9;
}

#pragma mark - method
- (IBAction)selectAllButtonClicked:(UIButton*)sender{
    sender.selected = !sender.isSelected;
    self.model.hasSelectedAll = sender.isSelected;
    [self updateDisplay:self.model];
    if(sender.isSelected){
        if(self.selectedUser){
            self.selectedUser(self.model.userArray);
        }
    }else{
        if(self.removeUser){
            self.removeUser(self.model.userArray);
        }
    }
}

- (void)selectUserButtonClicked:(UITapGestureRecognizer*)tap{
    UIView *view = tap.view;
    UserModel *model = self.model.userArray[view.tag-201];
    UIButton *btn;
    if(view.tag==201){
        btn = self.firstSelectedBtn;
    }else if(view.tag==202){
        btn = self.secondSelectedBtn;
    }else{
        btn = self.thirdSelectedBtn;
    }
    btn.selected = !btn.isSelected;
    model.isSelected = btn.isSelected;
    [self updateDisplay:self.model];
    if(btn.isSelected){
        if(self.selectedUser){
            self.selectedUser(@[model]);
        }
    }else{
        if(self.removeUser){
            self.removeUser(@[model]);
        }
    }
}

@end
