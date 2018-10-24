//
//  SubjectlistModel.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface SubjectlistModel : BaseModel
@property (nonatomic ,strong) NSNumber *asid;
@property (nonatomic ,strong) NSNumber *tagid;
@property (nonatomic ,strong) NSString *name;
@property (nonatomic ,strong) NSString *intro;
@property (nonatomic ,strong) NSString *ios_icon;
@property (nonatomic ,strong) NSString *ios_icon2x;

@property (nonatomic, strong) NSNumber *isAttent;

@end
