//
//  BannerModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/11/8.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface BannerModel : BaseModel
@property (nonatomic, strong)   NSNumber *type;
@property (nonatomic, strong)   NSNumber *sort;

@property (nonatomic, copy)     NSString *url;
@property (nonatomic, copy)     NSString *image;
@property (nonatomic, copy)     NSString *title;
@property (nonatomic, copy)     NSString *nickname;

@property (nonatomic, copy)     NSString *begintime;
@property (nonatomic, copy)     NSString *endtime;

@end
