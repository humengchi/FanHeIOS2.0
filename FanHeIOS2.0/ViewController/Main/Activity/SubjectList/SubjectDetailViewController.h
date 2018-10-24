//
//  SubjectDetailViewController.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"
typedef NS_ENUM(NSInteger, ActionStatType)
{
    ActionStat,
     ActionReportStant,
};
@interface SubjectDetailViewController : BaseViewController
@property (nonatomic ,strong) SubjectlistModel *model;
@property (nonatomic,assign)ActionStatType  Actiontype;
@end
