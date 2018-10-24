//
//  CitysModel.h
//  JinMai
//
//  Created by 胡梦驰 on 16/5/14.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "BaseModel.h"

@interface CitysModel : BaseModel

@property (nonatomic, copy) NSString    *citysId;
@property (nonatomic, copy) NSString    *Name;
@property (nonatomic, copy) NSString    *ParentId;
@property (nonatomic, copy) NSString    *ShortName;
@property (nonatomic, copy) NSString    *LevelType;
@property (nonatomic, copy) NSString    *CityCode;
@property (nonatomic, copy) NSString    *ZipCode;
@property (nonatomic, copy) NSString    *MergerName;
@property (nonatomic, copy) NSString    *Pinyin;
@property (nonatomic, copy) NSString    *Letter;

@end
