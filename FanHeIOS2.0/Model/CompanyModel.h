//
//  CompanyModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/25.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface BusinessModel : BaseModel

@property (nonatomic, copy)     NSString *name;
@property (nonatomic, copy)     NSString *intro;

@end

@interface CompanyModel : BaseModel

@property (nonatomic, strong)   NSNumber *companyid;
@property (nonatomic, copy)     NSString *company;
@property (nonatomic, copy)     NSString *city;
@property (nonatomic, strong)   NSNumber *scale;
@property (nonatomic, copy)     NSString *logo;
@property (nonatomic, copy)     NSString *introduction;
@property (nonatomic, copy)     NSString *website;
@property (nonatomic, copy)     NSString *ic_name;
@property (nonatomic, copy)     NSString *ic_num;
@property (nonatomic, copy)     NSString *ic_type;
@property (nonatomic, copy)     NSString *ic_created_at;
@property (nonatomic, copy)     NSString *ic_legal_person;
@property (nonatomic, copy)     NSString *ic_fund;
@property (nonatomic, copy)     NSString *scale_cn;
@property (nonatomic, copy)     NSString *industry;
@property (nonatomic, copy)     NSString *financing;
@property (nonatomic, strong)   NSMutableArray *businessArray;
@property (nonatomic, strong)   NSMutableArray *dynamicArray;
@property (nonatomic, copy)     NSString *address;
@property (nonatomic, copy)     NSString *lat;
@property (nonatomic, copy)     NSString *lng;
@property (nonatomic, copy)     NSString *telephone;
@property (nonatomic, strong)   NSMutableArray *managerArray;
@property (nonatomic, strong)   NSNumber *manager_cnt;
@property (nonatomic, strong)   NSMutableArray *employeeArray;

@property (nonatomic, copy)     NSString *bgimage;

@end
