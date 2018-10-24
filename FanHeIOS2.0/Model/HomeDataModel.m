//
//  HomeDataModel.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/10/31.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "HomeDataModel.h"

@implementation ActivityModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (void)parseDict:(NSDictionary *)dict{
    if(dict){
        [self setValuesForKeysWithDictionary:dict];
    }
}

@end

@implementation DJTalkModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (void)parseDict:(NSDictionary *)dict{
    if(dict){
        [self setValuesForKeysWithDictionary:dict];
        CGFloat imageHeight=(WIDTH-32)*167/343.0;
        CGFloat height = [NSHelper heightOfString:self.title font:FONT_SYSTEM_SIZE(17) width:WIDTH-32];
        if(height > 25){
            self.cellHeight = 125+imageHeight;
        }else{
            self.cellHeight = 108+imageHeight;
        }
    }
}

@end

@implementation HomeTableDataModel

@end

@implementation HomeDataModel

- (void)parseDict:(NSDictionary *)dict{
    self.tt = [NSMutableArray array];
    for(NSDictionary *dataDict in [CommonMethod paramArrayIsNull:dict[@"tt"]]){
        TalkFianaceModel *model = [[TalkFianaceModel alloc] initWithDict:dataDict];
        [self.tt addObject:model];
    }
    
    self.activity = [NSMutableArray array];
    for(NSDictionary *dataDict in [CommonMethod paramArrayIsNull:dict[@"activity"]]){
        ActivityModel *model = [[ActivityModel alloc] initWithDict:dataDict];
        [self.activity addObject:model];
    }
    self.djtalk = [NSMutableArray array];
    for(NSDictionary *dataDict in [CommonMethod paramArrayIsNull:dict[@"djtalk"]]){
        DJTalkModel *model = [[DJTalkModel alloc] initWithDict:dataDict];
        [self.djtalk addObject:model];
    }
    self.hopeme = [NSMutableArray array];
    for(NSDictionary *dataDict in [CommonMethod paramArrayIsNull:dict[@"hopeme"]]){
        UserModel *model = [[UserModel alloc] initWithDict:dataDict];
        [self.hopeme addObject:model];
    }
    self.hotpeople = [NSMutableArray array];
    for(NSDictionary *dataDict in [CommonMethod paramArrayIsNull:dict[@"hotpeople"]]){
        UserModel *model = [[UserModel alloc] initWithDict:dataDict];
        [self.hotpeople addObject:model];
    }
    self.mayknowpeople = [NSMutableArray array];
    for(NSDictionary *dataDict in [CommonMethod paramArrayIsNull:dict[@"mayknowpeople"]]){
        UserModel *model = [[UserModel alloc] initWithDict:dataDict];
        [self.mayknowpeople addObject:model];
    }
    self.seeme = [NSMutableArray array];
    for(NSDictionary *dataDict in [CommonMethod paramArrayIsNull:dict[@"seeme"]]){
        UserModel *model = [[UserModel alloc] initWithDict:dataDict];
        [self.seeme addObject:model];
    }
    self.tableDataArray = [NSMutableArray array];
    if(self.mayknowpeople.count){
        HomeTableDataModel *model = [[HomeTableDataModel alloc] init];
        model.type = @(1);
        model.title = @"你可能想认识他们";
        model.array = self.mayknowpeople;
        [self.tableDataArray addObject:model];
    }
    if(self.djtalk.count){
        HomeTableDataModel *model = [[HomeTableDataModel alloc] init];
        model.type = @(2);
        model.title = @"大家聊金融";
        model.array = self.djtalk;
        [self.tableDataArray addObject:model];
    }
    if(self.hotpeople.count){
        HomeTableDataModel *model = [[HomeTableDataModel alloc] init];
        model.type = @(3);
        model.title = @"人气推荐";
        model.array = self.hotpeople;
        [self.tableDataArray addObject:model];
    }
}


@end
