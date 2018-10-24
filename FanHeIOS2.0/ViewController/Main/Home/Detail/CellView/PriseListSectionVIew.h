//
//  PriseListSectionVIew.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PriseListSectionVIew : UIView
@property (weak, nonatomic) IBOutlet UIView *imageView;
@property (weak, nonatomic) IBOutlet UIView *secoundLine;
@property (weak, nonatomic) IBOutlet UIView *fristLine;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *removeBtn;
@property (nonatomic ,strong) DynamicModel * model;
- (void)updateDisplay:(DynamicModel*)model;
@end
