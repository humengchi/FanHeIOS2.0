//
//  ChartModel.h
//  JinMai
//
//  Created by renhao on 16/5/18.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChartModel : BaseModel

@property (nonatomic, strong)   NSNumber *userid;
@property (nonatomic, strong)   NSNumber *usertype;

@property (nonatomic, copy)     NSString *realname;
@property (nonatomic, copy)     NSString *letter;
@property (nonatomic, copy)     NSString *image;
@property (nonatomic, copy)     NSString *company;
@property (nonatomic, copy)     NSString *position;
@property (nonatomic, copy)     NSString *phone;
@property (nonatomic, copy)     NSString *reason;


@property (nonatomic, strong)   NSNumber *reqid;
@property (nonatomic, strong)   NSString *audio;
@property (nonatomic, strong)   NSNumber *isattent;//关注状态
@property (nonatomic, strong)   NSNumber *status; //状态
@property (nonatomic, strong)   NSNumber *canviewphone; //状态

@end
