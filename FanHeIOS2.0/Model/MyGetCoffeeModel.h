//
//  MyGetCoffeeModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/26.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface MyGetCoffeeModel : BaseModel

@property (nonatomic, copy) NSString    *image;
@property (nonatomic, copy) NSString    *company;
@property (nonatomic, copy) NSString    *position;
@property (nonatomic, copy) NSString    *realname;
@property (nonatomic, copy) NSString    *revert;
@property (nonatomic, copy) NSString    *reverttime;
@property (nonatomic, copy) NSString    *taketime;
@property (nonatomic, copy) NSString    *takemessage;
@property (nonatomic, copy) NSString    *code;
@property (nonatomic, copy) NSString    *admintime;
@property (nonatomic, copy) NSString    *city;
@property (nonatomic, copy) NSString    *workyearstr;

@property (nonatomic, strong) NSNumber  *coffeegetid;
@property (nonatomic, strong) NSNumber  *coffeeid;
@property (nonatomic, strong) NSNumber  *type;
@property (nonatomic, strong) NSNumber  *isfriend;
@property (nonatomic, strong) NSNumber  *msgid;
@property (nonatomic, strong) NSNumber  *userid;
@property (nonatomic, strong) NSNumber  *othericon;// 1专访
@property (nonatomic, strong) NSNumber  *usertype;// 9嘉宾用户
@property (nonatomic, strong) NSNumber  *exchange;

@property (nonatomic, assign) CGFloat   cellHeight;

@end
