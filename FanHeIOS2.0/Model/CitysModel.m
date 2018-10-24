//
//  CitysModel.m
//  JinMai
//
//  Created by 胡梦驰 on 16/5/14.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "CitysModel.h"

@implementation CitysModel

- (void)parseFMResultSet:(FMResultSet *)set{
    [super parseFMResultSet:set];
    self.citysId = [set stringForColumn:@"id"];
    self.Name = [set stringForColumn:@"Name"];
    self.ParentId = [set stringForColumn:@"ParentId"];
    self.ShortName = [set stringForColumn:@"ShortName"];
    self.LevelType = [set stringForColumn:@"LevelType"];
    self.CityCode = [set stringForColumn:@"CityCode"];
    self.ZipCode = [set stringForColumn:@"ZipCode"];
    self.MergerName = [set stringForColumn:@"MergerName"];
    self.Pinyin = [set stringForColumn:@"Pinyin"];
    self.Letter = [set stringForColumn:@"Letter"];
}

- (NSString*)properties_tableName{
    return @"citys";
}


@end
