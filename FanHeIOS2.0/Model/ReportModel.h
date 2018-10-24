//
//  ReportModel.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface ReportModel : BaseModel
@property (nonatomic ,strong) NSNumber *postid;
@property (nonatomic ,strong) NSNumber *pid;
@property (nonatomic ,strong) NSNumber *readcount;
@property (nonatomic ,strong) NSString *title;
@property (nonatomic ,strong) NSString *image;
@property (nonatomic ,strong) NSNumber *reviewcount;
@property (nonatomic ,assign) CGFloat cellHeight;
@end
