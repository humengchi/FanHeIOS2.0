//
//  DBInstance.m
//  Promotion
//
//  Created by Rookie Wang on 15/7/6.
//  Copyright (c) 2015年 hmc. All rights reserved.
//

#import "DBInstance.h"
#import "FMDB.h"

@interface DBInstance()

@property (nonatomic, copy) NSString *dbFilePath;
@property (nonatomic, strong) FMDatabase *db;

@end

@implementation DBInstance

+ (DBInstance *)shareInstance {
    static DBInstance *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DBInstance alloc] init];
    });
    
    return instance;
}

+ (NSString *)getDBVersion {
    return @"4";//2->3
}

- (BOOL)openDB:(NSString *)dbFilePath {
    self.db = [FMDatabase databaseWithPath:dbFilePath];
    NSLog(@"dbPath:%@", dbFilePath);
    if (![self.db open]) {
        NSLog(@"Could not open db.");
        return NO;
    }
    
    //初始化表
    if (![self initTable]) {
        NSLog(@"Could not init table.");
        return NO;
    }
    
    //设置数据库版本
    [self.db setUserVersion:[DBInstance getDBVersion].intValue];
    
    return YES;
}

- (BOOL)initTable {
    BOOL isSuccess = YES;
    if([self.db userVersion] == [DBInstance getDBVersion].intValue){
        return isSuccess;
    }
    
    if([self.db userVersion] > [DBInstance getDBVersion].intValue){
        @throw [[NSException alloc] initWithName:DBInitFailedException reason:@"数据库初始化失败：降级！" userInfo:nil];
    }
    
    [self.db beginTransaction];
    for (int i=[self.db userVersion]; i<=[DBInstance getDBVersion].intValue; i++) {
        switch (i) {
            case 1:{
                //ChartModel
                isSuccess = [self executeUpdate:@"CREATE TABLE IF NOT EXISTS chart ( userid INTEGER PRIMARY KEY AUTOINCREMENT, realname TEXT, letter TEXT, image TEXT, company TEXT, position TEXT,phone TEXT, usertype INTEGER, canviewphone INTEGER);"];
                if (!isSuccess) {
                    break;
                }
                
            }
                break;
                
            case 3:{
                //ChartModel
                isSuccess = [self executeUpdate:@"ALTER TABLE chart ADD canviewphone INTEGER"];
                if (!isSuccess) {
                    break;
                }
            }
                break;
            case 4:{
                //ChartModel->Group
                isSuccess = [self executeUpdate:@"CREATE TABLE IF NOT EXISTS groupChart ( userid INTEGER PRIMARY KEY AUTOINCREMENT, realname TEXT, image TEXT, company TEXT, position TEXT);"];
                if (!isSuccess) {
                    break;
                }
                
            }
                break;
                
            default:
                break;
        }
    }
    
    if (isSuccess) {
        [self.db commit];
    }else {
        [self.db rollback];
    }
    
    return isSuccess;
}

- (BOOL)executeUpdate:(NSString*)sql {
    BOOL result = NO;
    @try {
        result = [self.db executeUpdate:sql];
    }
    @catch (NSException *exception) {
        result = NO;
        NSLog(@"error:%@", exception);
    }
    @finally {
        return result;
    }
}

- (BOOL)upinsertModel:(BaseModel *)model{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[model properties_aps]];
    for (NSString *fieldStr in [model properties_virtual_aps]) {
        [dict removeObjectForKey:fieldStr];
    }
    
    NSArray *keyArray = [dict allKeys];
    NSString *keyString = [keyArray componentsJoinedByString:@","];
    
    NSMutableString *valueString = [[NSMutableString alloc] init];
    for (NSString *key in keyArray) {
        [valueString appendString:@":"];
        [valueString appendString:key];
        [valueString appendString:@","];
    }
    
    if (valueString.length) {
        valueString = [NSMutableString stringWithString:[valueString substringToIndex:valueString.length - 1]];
    }
    
    NSString *sql = [NSString stringWithFormat:@"insert or replace into %@ (%@) values (%@) ",[model properties_tableName],keyString,valueString];
    
    return [self.db executeUpdate:sql withParameterDictionary:dict];
}

- (NSMutableArray *)getModelsBySqlParams:(NSString *)sql modelClass:(Class )modelClass argsArray:(NSArray *)argsArray {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    FMResultSet *rs=[self.db executeQuery:sql withArgumentsInArray:argsArray];
    while ([rs next]){
        BaseModel * model = [[modelClass  alloc] initWithFMResultSet:rs];
        [array addObject:model];
    }
    [rs close];
    
    return array;
}

/**
 * 获取所有的citysModel
 * level-1,2,3
 * @return
 */
- (NSMutableArray*)getAllCitysModel:(NSString*)LevelType ParentId:(NSString*)ParentId{
    if(ParentId == nil || ParentId.length == 0){
        ParentId = @"100000";
    }
    NSString *sql = [NSString stringWithFormat:@"select *from citys where LevelType = ? and ParentId = ? order by ifnull(sort,100) desc,Letter"];
    return [self getModelsBySqlParams:sql modelClass:[CitysModel class] argsArray:@[LevelType, ParentId]];
}
/**
 * 获取citysModel
 *
 * @return
 */
- (CitysModel*)getCitysModelById:(NSString*)cityId{
    if(cityId == nil || cityId.length == 0){
        return nil;
    }
    NSString *sql = [NSString stringWithFormat:@"select *from citys where id = ?"];
    NSMutableArray *array = [self getModelsBySqlParams:sql modelClass:[CitysModel class] argsArray:@[cityId]];
    if(array.count){
        return [array firstObject];
    }else{
        return nil;
    }
}

/*
 * 保存人脉联系人
 */
- (BOOL)saveChartModelArray:(NSMutableArray *)chartArray{
    BOOL isSuccess = YES;
    @try {
        [self.db beginTransaction];
        [self.db executeUpdate:@"delete from chart"];
        for(ChartModel *model in chartArray){
            isSuccess = [self upinsertModel:model];
            if (!isSuccess) {
                break;
            }
        }
    }
    @catch (NSException *exception) {
        isSuccess = NO;
    }
    @finally {
        if (isSuccess) {
            [self.db commit];
        }else {
            [self.db rollback];
        }
        return isSuccess;
    }
}

/*
 * 获取某个人的人脉联系人
 */
- (NSMutableArray *)selectCharttingID:(NSString *)itemID {
    if(![itemID isKindOfClass:[NSString class]]){
        return [NSMutableArray array];
    }
    if([CommonMethod paramStringIsNull:itemID].length==0){
        return [NSMutableArray array];
    }
    NSString *sql = [NSString stringWithFormat:@"select * from chart where userid = %@", itemID];
    return [self getModelsBySqlParams:sql modelClass:[ChartModel class] argsArray:@[]];
}

/*
 * 获取所有的人脉联系人
 */
- (NSMutableArray*)getAllChartsModel{
    NSString *sql = @"select * from chart;";
    return [self getModelsBySqlParams:sql modelClass:[ChartModel class] argsArray:@[]];
}

/*
 * 搜索符合条件的所有的人脉联系人
 */
- (NSMutableArray*)getAllChartsModelBySearch:(NSString*)text{
    NSString *sql = @"SELECT * FROM chart where realname LIKE ? or company LIKE ? or position LIKE ?;";
    return [self getModelsBySqlParams:sql modelClass:[ChartModel class] argsArray:@[[NSString getLikeStr:text],[NSString getLikeStr:text],[NSString getLikeStr:text]]];
}

/*
 * 保存群组成员的信息
 */
- (BOOL)savGroupChartModelArray:(NSMutableArray *)groupChartArray{
    BOOL isSuccess = YES;
    @try {
        [self.db beginTransaction];
        for(GroupChartModel *model in groupChartArray){
            isSuccess = [self upinsertModel:model];
            if (!isSuccess) {
                break;
            }
        }
    }
    @catch (NSException *exception) {
        isSuccess = NO;
    }
    @finally {
        if (isSuccess) {
            [self.db commit];
        }else {
            [self.db rollback];
        }
        return isSuccess;
    }
}

/*
 * 获取群组成员的信息
 */
- (NSMutableArray *)selectGroupChartModelByUserId:(NSString *)userId {
    if(![userId isKindOfClass:[NSString class]]){
        return [NSMutableArray array];
    }
    if([CommonMethod paramStringIsNull:userId].length==0){
        return [NSMutableArray array];
    }
    NSString *sql = [NSString stringWithFormat:@"select * from groupChart where userid = %@", userId];
    return [self getModelsBySqlParams:sql modelClass:[GroupChartModel class] argsArray:@[]];
}

@end
