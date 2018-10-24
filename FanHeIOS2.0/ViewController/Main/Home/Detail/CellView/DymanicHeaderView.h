//
//  DymanicHeaderView.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/2.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DymanicHeaderView : UIView
@property (weak, nonatomic) IBOutlet UIButton *attionBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UIView *tagsView;
@property (weak, nonatomic) IBOutlet UIImageView *vipImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *atConstraint;
@property (nonatomic ,strong )DynamicUserModel *model;
- (void)updateDisplay:(DynamicUserModel*)model;
@end
