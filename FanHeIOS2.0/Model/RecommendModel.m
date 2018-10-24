//
//  RecommendModel.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/10/25.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "RecommendModel.h"

@implementation RecommendModel

- (id)initWithArray:(NSArray*)array keyName:(NSString*)keyName{
    if(self = [super init]){
        if([keyName isEqualToString:@"优质人脉推荐"] || [keyName isEqualToString:@"你可能认识他们"]){
            self.canChoiceAll = NO;
        }else{
            self.canChoiceAll = YES;
        }
        self.name = keyName;
        self.userArray = [NSMutableArray array];
        for(NSDictionary *dict in array){
            UserModel *model = [[UserModel alloc] initWithDict:dict];
            model.userId = [CommonMethod paramNumberIsNull:dict[@"userid"]];
            model.isSelected = YES;
            [self.userArray addObject:model];
        }
    }
    return self;
}

@end
