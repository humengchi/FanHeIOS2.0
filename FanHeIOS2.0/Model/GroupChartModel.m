//
//  GroupChartModel.m
//  JinMai
//
//  Created by renhao on 16/5/18.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "GroupChartModel.h"

@implementation GroupChartModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
}

- (void)parseFMResultSet:(FMResultSet *)set{
    self.userid = @([set intForColumn:@"userid"]);
    self.realname = [set stringForColumn:@"realname"];
    self.image = [set stringForColumn:@"image"];
    self.company = [set stringForColumn:@"company"];
    self.position = [set stringForColumn:@"position"];
}

- (NSString*)properties_tableName{
    return @"groupChart";
}

- (NSArray *)properties_virtual_aps {
    return @[];
}

@end
