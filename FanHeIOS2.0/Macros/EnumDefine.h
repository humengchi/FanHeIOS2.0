//
//  EnumDefine.h
//  JinMai
//
//  Created by 胡梦驰 on 16/3/31.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#ifndef EnumDefine_h
#define EnumDefine_h


//验证码发送类型
typedef NS_ENUM(NSInteger, Code_Type) {
    Code_Type_Register,
    Code_Type_Forget_Login,
    Code_Type_Code_Login,
};

//全局搜索类型
typedef NS_ENUM(NSUInteger, RSearchResult) {
    SearchResult_Topic,
    SearchResult_Post,
    SearchResult_Activity
};

#endif /* EnumDefine_h */
