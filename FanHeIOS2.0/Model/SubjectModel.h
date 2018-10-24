//
//  SubjectModel.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/10/28.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface SubjectModel : BaseModel
@property (nonatomic, strong) NSNumber  *businessID;

@property (nonatomic, copy) NSString    *business;
@property (nonatomic, copy) NSString    *image;
@property (nonatomic, copy) NSString    *title;
@property (nonatomic, copy) NSString    *url;

//个人主页中专访id
@property (nonatomic, strong) NSNumber  *subjectId;
@end
