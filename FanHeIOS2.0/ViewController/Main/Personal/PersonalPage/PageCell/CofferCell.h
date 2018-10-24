//
//  CofferCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/4.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CofferModel.h"
#import "PeopleModel.h"
@interface CofferCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *attionNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *leftRigthImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *markImageView;

@property (weak, nonatomic) IBOutlet UIImageView *firstImageView;
@property (weak, nonatomic) IBOutlet UIImageView *secendImageView;
@property (weak, nonatomic) IBOutlet UIImageView *threeImageView;
@property (strong, nonatomic) UILabel *useCountLabel;
- (void)tranferModeVale:(NSInteger)index cofferModel:(CofferModel *)coffModel peopleModel:(PeopleModel *)peopleModel isMyHomePage:(BOOL)isMyHomePage taModel:(TaMessageModel *)model;
@end
