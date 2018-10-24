//
//  BaseModel.h
//  JinMai
//
//  Created by 胡梦驰 on 16/3/21.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMResultSet.h"

@interface BaseModel : NSObject

- (NSString *)properties_tableName;
- (NSDictionary *)properties_aps;
- (NSArray *)properties_virtual_aps;

- (id)initWithDict:(NSDictionary *)dict;
- (void)parseDict:(NSDictionary *)dict;


- (id)initWithFMResultSet:(FMResultSet *)set;
- (void)parseFMResultSet:(FMResultSet *)set;

@end
