//
//  GroupChartModel.h
//  JinMai
//
//  Created by renhao on 16/5/18.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupChartModel : BaseModel

@property (nonatomic, strong)   NSNumber *userid;
@property (nonatomic, copy)     NSString *realname;
@property (nonatomic, copy)     NSString *image;
@property (nonatomic, copy)     NSString *company;
@property (nonatomic, copy)     NSString *position;

@end
