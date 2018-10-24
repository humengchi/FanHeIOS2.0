//
//  DymanicHeaderView.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/2.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "DymanicHeaderView.h"

@implementation DymanicHeaderView

- (void)drawRect:(CGRect)rect {
    [CALayer updateControlLayer:self.headerImageView.layer radius:22 borderWidth:0 borderColor:nil];
}

- (void)updateDisplay:(DynamicUserModel *)model{
    self.model = model;
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[CommonMethod paramStringIsNull:model.user_image]] placeholderImage:KHeadImageDefaultName([CommonMethod paramStringIsNull:model.user_realname])];
    self.nameLabel.text = [CommonMethod paramStringIsNull:model.user_realname];
    
    self.companyLabel.text = [NSString stringWithFormat:@"%@%@",[CommonMethod paramStringIsNull:model.user_company], [CommonMethod paramStringIsNull:model.user_position]];
    
    self.vipImageView.hidden = model.user_usertype.integerValue != 9;
    [self.attionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.attionBtn setTitleColor:[UIColor colorWithHexString:@"AFB6C1"] forState:UIControlStateNormal];
    if (model.isattention.integerValue == 1) {
        self.attionBtn.selected = NO;
    }else{
        self.attionBtn.selected = YES;
    }
    if(model.user_id.integerValue == [DataModelInstance shareInstance].userModel.userId.integerValue){
        self.attionBtn.hidden = YES;
        self.atConstraint.constant = 0;
    }else{
        self.attionBtn.hidden = NO;
        self.atConstraint.constant = 64;
    }
    
    for(UIView *view in self.tagsView.subviews){
        [view removeFromSuperview];
    }
    CGFloat start_X = 0;
    if([CommonMethod paramStringIsNull:model.relationship].length){
        CGFloat strWidth = [NSHelper widthOfString:model.relationship font:FONT_SYSTEM_SIZE(8) height:11]+15;
        UILabel *realtionLabel = [UILabel createrLabelframe:CGRectMake(start_X, 0, strWidth, 11) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e") test:model.relationship font:8 number:1 nstextLocat:NSTextAlignmentCenter];
        [CALayer updateControlLayer:realtionLabel.layer radius:5.5 borderWidth:0.3 borderColor:HEX_COLOR(@"818c9e").CGColor];
        [self.tagsView addSubview:realtionLabel];
        start_X += strWidth+6;
    }
    if([CommonMethod paramNumberIsNull:model.samefriend].integerValue){
        NSString *str = [NSString stringWithFormat:@"%@个共同好友", model.samefriend];
        CGFloat strWidth = [NSHelper widthOfString:str font:FONT_SYSTEM_SIZE(8) height:11]+15;
        UILabel *samefriendLabel = [UILabel createrLabelframe:CGRectMake(start_X, 0, strWidth, 11) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e") test:str font:8 number:1 nstextLocat:NSTextAlignmentCenter];
        [CALayer updateControlLayer:samefriendLabel.layer radius:5.5 borderWidth:0.3 borderColor:HEX_COLOR(@"818c9e").CGColor];
        [self.tagsView addSubview:samefriendLabel];
        start_X += strWidth+6;
    }
    if([CommonMethod paramNumberIsNull:model.user_othericon].integerValue == 1){
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(start_X, 0, 31, 11)];
        iconImageView.image = kImageWithName(@"icon_zy_zf");
        [self.tagsView addSubview:iconImageView];
    }
}

#pragma  关注
- (IBAction)attionHisSaide:(UIButton *)sender {
    [[self viewController] newThreadForAvoidButtonRepeatClick:sender];
    [[NSNotificationCenter defaultCenter] postNotificationName:ATTIONHISACTIVEORTALK object:nil];
}

- (IBAction)gotoHiaMainPage:(UITapGestureRecognizer *)sender {
    NewMyHomePageController *myHome = [[NewMyHomePageController alloc]init];
    myHome.userId = self.model.user_id;
    [[self viewController].navigationController pushViewController:myHome animated:YES];
}


@end
