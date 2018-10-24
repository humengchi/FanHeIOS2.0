//
//  ReportViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/19.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, ReportType) {
    ReportType_Topic = 1,
    ReportType_Viewpoint = 2,
    ReportType_Activity = 3,
    ReportType_Review = 4,
    ReportType_Dynamic = 6,
};

@interface ReportViewController : BaseViewController

@property (nonatomic, assign) ReportType reportType;
@property (nonatomic, strong) NSNumber  *reportId;

@end
