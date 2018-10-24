//
//  UserModel.h
//  JinMai
//
//  Created by 胡梦驰 on 16/3/23.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "BaseModel.h"
@class SubjectModel;

@interface UserModel : BaseModel

@property (nonatomic, strong)   NSNumber *userId;
@property (nonatomic, strong)   NSNumber *sex;
@property (nonatomic, strong)   NSNumber *status;
@property (nonatomic, strong)   NSNumber *usertype;
@property (nonatomic, strong)   NSNumber *provinceid;
@property (nonatomic, strong)   NSNumber *cityid;
@property (nonatomic, strong)   NSNumber *districtid;
@property (nonatomic, copy)     NSString *province;
@property (nonatomic, copy)     NSString *city;
@property (nonatomic, copy)     NSString *district;
@property (nonatomic, strong)   NSNumber *isinitpasswd;
@property (nonatomic, strong)   NSNumber *hasValidUser;
@property (nonatomic, strong)   NSNumber *hasnews;
@property (nonatomic, strong)   NSNumber *iseasemobuser;
@property (nonatomic, strong)   NSNumber *invitenum;
@property (nonatomic, strong)   NSNumber *getednum;
@property (nonatomic, strong)   NSNumber *videoplaycount;
@property (nonatomic, strong)   NSNumber *friendcnt;
@property (nonatomic, strong)   NSNumber *getcoffcnt;
@property (nonatomic, strong)   NSNumber *attentcnt;
@property (nonatomic, strong)   NSNumber *attentedcnt;
@property (nonatomic, strong)   NSNumber *visitedcnt;
@property (nonatomic, strong)   NSNumber *recomdcnt;
@property (nonatomic, strong)   NSNumber *sharecnt;
@property (nonatomic, copy)     NSString *colleaguestr;//共事几天
@property (nonatomic, strong)   NSNumber *othericon;//1.专访


//加好友验证
@property (nonatomic, strong)   NSNumber *canviewphone;
@property (nonatomic, strong)   NSNumber *hasaskcheck;
@property (nonatomic, strong)   NSNumber *asksubjectid;
@property (nonatomic, copy)     NSString *askcheck;
@property (nonatomic, copy)     NSString *asksubject;

@property (nonatomic, copy)     NSString *name;
@property (nonatomic, copy)     NSString *password;
@property (nonatomic, copy)     NSString *nickname;
@property (nonatomic, copy)     NSString *realname;
@property (nonatomic, copy)     NSString *letter;
@property (nonatomic, copy)     NSString *email;
@property (nonatomic, copy)     NSString *phone;
@property (nonatomic, copy)     NSString *qq;
@property (nonatomic, copy)     NSString *cardno;
@property (nonatomic, copy)     NSString *image;
@property (nonatomic, copy)     NSString *birthday;
@property (nonatomic, copy)     NSString *last_login_ip;
@property (nonatomic, copy)     NSString *last_login_time;
@property (nonatomic, copy)     NSString *company;
@property (nonatomic, copy)     NSString *companyphone;
@property (nonatomic, copy)     NSString *industry;
@property (nonatomic, copy)     NSString *position;
@property (nonatomic, copy)     NSString *business;
@property (nonatomic, copy)     NSString *remark;
@property (nonatomic, copy)     NSString *address;
@property (nonatomic, copy)     NSString *created_at;
@property (nonatomic, copy)     NSString *updated_at;
@property (nonatomic, copy)     NSString *VIPFrom;
@property (nonatomic, copy)     NSString *VIPTo;
@property (nonatomic, copy)     NSString *authenti_image;
@property (nonatomic, copy)     NSString *elastictime;
@property (nonatomic, copy)     NSString *worktime;
@property (nonatomic, copy)     NSString *video;
@property (nonatomic, copy)     NSString *mystate;

@property (nonatomic, strong)   NSArray  *goodjobs;
@property (nonatomic, strong)   NSArray  *career;
@property (nonatomic, strong)   NSArray  *intersted_industrys;

//虚拟字段
@property (nonatomic, strong)   NSNumber *infoIsNotFinished;//个人资料是否完善
@property (nonatomic, assign)   BOOL isSelected;

//首页数据缓存
@property (nonatomic, strong)   NSDictionary *homeData;
@property (nonatomic, strong)   NSDictionary *coffeeInfoData;
@property (nonatomic, strong)   NSArray *rcmListData;
@property (nonatomic, strong)   NSArray *dynamicData;//动态列表
@property (nonatomic, strong)   NSArray *noUploadDynamicData;//还未上传的动态

//话题首页缓存
@property (nonatomic, strong)   NSArray *topicData;
//活动首页缓存
@property (nonatomic ,strong)  NSDictionary *reportDict;
//搜索数据
@property (nonatomic ,strong)   NSArray *activityData;
//推荐数据
@property (nonatomic ,strong)   NSArray *recomArray;
// 通知数
@property (nonatomic, strong) NSNumber *notecount;
@property (nonatomic, strong) NSNumber *vpcount;
//活动搜索页城市
@property (nonatomic ,strong)   NSArray *cityName;
//智能筛选
@property (nonatomic ,strong)   NSArray *capacityArray;
//推荐活动
@property (nonatomic, strong)   NSDictionary *pushActivityDic;
//活动问答
@property (nonatomic, copy)     NSString *ask;
@property (nonatomic, copy)     NSString *answer;
@property (nonatomic, strong)   NSNumber *askid;
//活动标签搜索
@property (nonatomic ,strong)   NSArray *tagData;
@property (nonatomic ,strong)   NSArray *cityData;

//用户是否发送过动态
@property (nonatomic, strong)   NSNumber *hasPublishDynamic;


//新个人主页添加的字段
@property (nonatomic, copy)     NSString *bgimage;
@property (nonatomic, copy)     NSString *weixin;
@property (nonatomic, copy)     NSString *workyearstr;
@property (nonatomic, strong)   NSNumber *hisattentionnum;
@property (nonatomic, strong)   NSNumber *attentionhenum;
@property (nonatomic, strong)   NSNumber *friendnum;
@property (nonatomic, strong)   NSNumber *companyid;
@property (nonatomic, copy)     NSString *companylogo;
@property (nonatomic, strong)   NSNumber *comfriendnum;
@property (nonatomic, strong)   NSNumber *isattention;
@property (nonatomic, strong)   NSNumber *isfriend;
@property (nonatomic, strong)   NSNumber *iscoffee;
@property (nonatomic, copy)     NSString *relation;
@property (nonatomic, strong)   NSNumber *dynamicnum;
@property (nonatomic ,strong)   NSArray *album; //相册
@property (nonatomic ,strong)   NSArray *selftag;
@property (nonatomic ,strong)   NSArray *honor;
@property (nonatomic ,strong)   NSArray *interesttag;
@property (nonatomic, copy)     NSString *msg; //评论内容
//自定义解析字段
@property (nonatomic ,strong)   NSMutableArray *honorsArray;
@property (nonatomic, strong)   NeedModel *needModel;
@property (nonatomic, strong)   NeedModel *supplyModel;
@property (nonatomic, strong)   NSNumber *coffeeCnt;
@property (nonatomic, strong)   NSMutableArray *coffeePhotosArray;
@property (nonatomic, strong)   NSNumber *evid;
@property (nonatomic, strong)   NSMutableArray *evaluationsArray;
@property (nonatomic, strong)   NSMutableArray *workHistoryArray;
@property (nonatomic, strong)   SubjectModel *djtalkModel;
@property (nonatomic, strong)   NSNumber *connectionsCount;
@property (nonatomic, strong)   NSNumber *connectionsFriendCount;
@property (nonatomic, strong)   NSMutableArray *connectionsArray;
@property (nonatomic, strong)   NSMutableArray *attenthimlistArray;

@property (nonatomic, copy)     NSString *intro; //公司主页管理层user介绍

@property (nonatomic, strong)   NSNumber *invite; //是否被邀请过

@end
