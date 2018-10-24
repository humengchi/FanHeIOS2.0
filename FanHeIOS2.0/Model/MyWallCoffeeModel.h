//
//  MyWallCoffeeModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/26.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface MyWallCoffeeModel : BaseModel

@property (nonatomic, strong)   NSNumber    *coffeestatus;
@property (nonatomic, strong)   NSNumber    *getmycoffeecnt;
@property (nonatomic, strong)   NSNumber    *mygetcnt;
@property (nonatomic, strong)   NSNumber    *remainingcnt;
@property (nonatomic, strong)   NSNumber    *mygetmsgcnt;
@property (nonatomic, strong)   NSNumber    *getmycoffeemsgcnt;
@property (nonatomic, strong)   NSNumber    *praisenum;

@property (nonatomic, strong)   NSArray     *getmycoffeephoto;
@property (nonatomic, strong)   NSArray     *mygetphoto;

@property (nonatomic, strong)   NSArray     *image;
@property (nonatomic, copy)     NSString    *remark;
@property (nonatomic, copy)     NSString    *lastperson;

- (BOOL)compareModel:(MyWallCoffeeModel*)model;

@end
