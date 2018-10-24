//
//  TalkFianaceModel.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface TalkFianaceModel : BaseModel
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *position;
@property (nonatomic, copy) NSString *realname;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSNumber *postid;
@property (nonatomic, strong) NSNumber *readcount;
@property (nonatomic, strong) NSNumber *reviewcount;
@property (nonatomic, strong) NSNumber *userid;
@property (nonatomic, strong) NSNumber *usertype;
@property (nonatomic, strong) NSNumber *hasValidUser;


@end
