//
//  DBInstance.h
//  Promotion
//
//  Created by Rookie Wang on 15/7/6.
//  Copyright (c) 2015年 hmc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DBInitFailedException  @"DBInitFailedException"

@interface DBInstance : NSObject

+ (DBInstance *)shareInstance;

+ (NSString *)getDBVersion;

- (BOOL)openDB:(NSString *)dbFilePath;

/**
 * 获取所有的citysModel
 * level-1,2,3
 * @return
 */
- (NSMutableArray*)getAllCitysModel:(NSString*)LevelType ParentId:(NSString*)ParentId;

/**
 * 获取citysModel
 *
 * @return
 */
- (CitysModel*)getCitysModelById:(NSString*)cityId;

/*
 * 保存人脉联系人
 */
- (BOOL)saveChartModelArray:(NSMutableArray *)chartArray;

/*
 * 获取某个人的人脉联系人
 */
- (NSMutableArray *)selectCharttingID:(NSString *)itemID;

/*
 * 获取所有的人脉联系人
 */
- (NSMutableArray*)getAllChartsModel;

/*
 * 搜索符合条件的所有的人脉联系人
 */
- (NSMutableArray*)getAllChartsModelBySearch:(NSString*)text;

/*
 * 保存群组成员的信息
 */
- (BOOL)savGroupChartModelArray:(NSMutableArray *)groupChartArray;

/*
 * 获取群组成员的信息
 */
- (NSMutableArray *)selectGroupChartModelByUserId:(NSString *)userId;

@end
