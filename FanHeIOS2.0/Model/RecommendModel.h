//
//  RecommendModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/10/25.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface RecommendModel : BaseModel

@property (nonatomic, copy)     NSString *name;
@property (nonatomic, assign)   BOOL canChoiceAll;
@property (nonatomic, assign)   BOOL hasSelectedAll;
@property (nonatomic, strong)   NSMutableArray *userArray;

- (id)initWithArray:(NSArray*)array keyName:(NSString*)keyName;

@end
