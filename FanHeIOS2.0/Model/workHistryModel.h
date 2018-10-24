//
//  workHistryModel.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/10/28.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface workHistryModel : BaseModel
@property (nonatomic, copy) NSString    *begintime;
@property (nonatomic, copy) NSString    *company;
@property (nonatomic, copy) NSString    *endtime;
@property (nonatomic, copy) NSString    *jobintro;
@property (nonatomic, copy) NSString    *position;
@property (nonatomic, copy) NSString    *logo;
@property (nonatomic, strong) NSNumber    *careerid;
@property (nonatomic, strong) NSNumber    *companyid;
@property (nonatomic, strong) NSNumber    *isfriend;
@property (nonatomic, strong) NSNumber    *isattestation;
@property (nonatomic, strong) NSNumber    *attestationtotal;
@property (nonatomic, strong) NSArray *image;
@property (nonatomic, strong) NSArray *url;
@property (nonatomic, strong) NSArray *attestationlist;

@end
