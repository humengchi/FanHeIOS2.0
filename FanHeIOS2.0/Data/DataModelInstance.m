//
//  DataModelInstance.m
//  JinMai
//
//  Created by 胡梦驰 on 16/3/22.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "DataModelInstance.h"

@implementation DataModelInstance

+ (DataModelInstance *)shareInstance{
    static DataModelInstance *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DataModelInstance alloc] init];
    });
    
    return instance;
}

- (void)setUserModel:(UserModel *)userModel{
    if(userModel){
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userModel];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:SAVE_LOGIN_USER_MODEL];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if(userModel.phone.length){
            [[NSUserDefaults standardUserDefaults] setObject:userModel.phone forKey:@"login_phone"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:SAVE_LOGIN_USER_MODEL];
    }
}

- (UserModel*)userModel{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SAVE_LOGIN_USER_MODEL];
    if(data){
        UserModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return model;
    }else{
        return nil;
    }
}

- (void)setAdminUserModel:(UserModel *)adminUserModel{
    if(adminUserModel){
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:adminUserModel];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:SAVE_ADMIN_LOGIN_USER_MODEL];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:SAVE_ADMIN_LOGIN_USER_MODEL];
    }
}

- (UserModel*)adminUserModel{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SAVE_ADMIN_LOGIN_USER_MODEL];
    if(data){
        UserModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        return model;
    }else{
        return nil;
    }
}

@end
