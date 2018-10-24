//
//  ChartModel.m
//  JinMai
//
//  Created by renhao on 16/5/18.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "ChartModel.h"

@implementation ChartModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
}

- (void)parseFMResultSet:(FMResultSet *)set{
    self.userid = @([set intForColumn:@"userid"]);
    self.realname = [set stringForColumn:@"realname"];
    self.letter = [set stringForColumn:@"letter"];
    self.image = [set stringForColumn:@"image"];
    self.company = [set stringForColumn:@"company"];
    self.position = [set stringForColumn:@"position"];
    self.phone = [set stringForColumn:@"phone"];
    self.usertype = @([set intForColumn:@"usertype"]);
    self.canviewphone = @([set intForColumn:@"canviewphone"]);
}

- (NSString*)properties_tableName{
    return @"chart";
}

- (NSArray *)properties_virtual_aps {
    return @[@"reason",@"reqid",@"audio",@"isattent",@"status"];
}

@end
