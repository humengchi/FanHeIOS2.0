//
//  UserModel.m
//  JinMai
//
//  Created by 胡梦驰 on 16/3/23.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "UserModel.h"
#import "SubjectModel.h"

@implementation UserModel

- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
    self.userId = [CommonMethod paramNumberIsNull:dict[@"id"]];
    if(self.userId.integerValue==0){
        self.userId = [CommonMethod paramNumberIsNull:dict[@"userid"]];
    }
    if(self.userId.integerValue&&self.userId.integerValue==[DataModelInstance shareInstance].userModel.userId.integerValue){
        self.homeData = [CommonMethod paramDictIsNull:[DataModelInstance shareInstance].userModel.homeData];
        self.coffeeInfoData = [CommonMethod paramDictIsNull:[DataModelInstance shareInstance].userModel.coffeeInfoData];
        self.topicData = [CommonMethod paramArrayIsNull:[DataModelInstance shareInstance].userModel.topicData];
        self.tagData = [CommonMethod paramArrayIsNull:[DataModelInstance shareInstance].userModel.tagData];
        self.cityData = [CommonMethod paramArrayIsNull:[DataModelInstance shareInstance].userModel.cityData];
        self.rcmListData = [CommonMethod paramArrayIsNull:[DataModelInstance shareInstance].userModel.rcmListData];
        self.activityData = [CommonMethod paramArrayIsNull:[DataModelInstance shareInstance].userModel.activityData];
        self.reportDict = [CommonMethod paramDictIsNull:[DataModelInstance shareInstance].userModel.reportDict];
        self.dynamicData = [CommonMethod paramArrayIsNull:[DataModelInstance shareInstance].userModel.dynamicData];
        self.noUploadDynamicData = [CommonMethod paramArrayIsNull:[DataModelInstance shareInstance].userModel.noUploadDynamicData];
        self.hasPublishDynamic = [CommonMethod paramNumberIsNull:[DataModelInstance shareInstance].userModel.hasPublishDynamic];
         self.cityName = [CommonMethod paramArrayIsNull:[DataModelInstance shareInstance].userModel.cityName];
        self.capacityArray = [CommonMethod paramArrayIsNull:[DataModelInstance shareInstance].userModel.capacityArray];
        self.pushActivityDic = [CommonMethod paramDictIsNull:[DataModelInstance shareInstance].userModel.pushActivityDic];
    }
    
    NSMutableArray *tmpArray = [NSMutableArray array];
    CitysModel *province = [[DBInstance shareInstance] getCitysModelById:self.provinceid.stringValue];
    if(province){
        [tmpArray addObject:province.Name];
    }
    CitysModel *city = [[DBInstance shareInstance] getCitysModelById:self.cityid.stringValue];
    if(!city && [self.city isKindOfClass:[NSNumber class]]){
        city = [[DBInstance shareInstance] getCitysModelById:((NSNumber*)self.city).stringValue];
    }
    if(city){
        [tmpArray addObject:city.Name];
    }
    BOOL hasDistrict = NO;
    CitysModel *district = [[DBInstance shareInstance] getCitysModelById:self.districtid.stringValue];
    if(!district && [self.district isKindOfClass:[NSNumber class]]){
        district = [[DBInstance shareInstance] getCitysModelById:((NSNumber*)self.district).stringValue];
    }
    if(district){
        hasDistrict = YES;
        [tmpArray addObject:district.Name];
    }
    if(tmpArray.count && hasDistrict){
        self.address = [tmpArray componentsJoinedByString:@""];
    }
    if([CommonMethod paramStringIsNull:self.qq].length && ![CommonMethod paramStringIsNull:self.weixin].length){
        self.weixin = self.qq;
    }
    //新个人主页
    self.needModel = [[NeedModel alloc] initWithDict:[CommonMethod paramDictIsNull:dict[@"need"]]];
    self.supplyModel = [[NeedModel alloc] initWithDict:[CommonMethod paramDictIsNull:dict[@"supply"]]];
    NSDictionary *coffee = [CommonMethod paramDictIsNull:dict[@"coffee"]];
    self.coffeeCnt = [CommonMethod paramNumberIsNull:coffee[@"count"]];
    self.coffeePhotosArray = [NSMutableArray array];
    for(NSDictionary *dictCoffee in [CommonMethod paramArrayIsNull:coffee[@"photo"]]){
        UserModel *model = [[UserModel alloc] initWithDict:dictCoffee];
        [self.coffeePhotosArray addObject:model];
    }
    NSDictionary *connections = [CommonMethod paramDictIsNull:dict[@"connections"]];
    self.connectionsFriendCount = [CommonMethod paramNumberIsNull:connections[@"friendcount"]];
    self.connectionsCount = [CommonMethod paramNumberIsNull:connections[@"count"]];
    self.connectionsArray = [NSMutableArray array];
    for(NSDictionary *dictConnections in [CommonMethod paramArrayIsNull:connections[@"photo"]]){
        UserModel *model = [[UserModel alloc] initWithDict:dictConnections];
        [self.connectionsArray addObject:model];
    }
    self.workHistoryArray = [NSMutableArray array];
    for(NSDictionary *careerDict in [CommonMethod paramArrayIsNull:dict[@"career"]]){
        workHistryModel *model = [[workHistryModel alloc] initWithDict:careerDict];
        [self.workHistoryArray addObject:model];
    }
    self.evaluationsArray = [NSMutableArray array];
    for(NSDictionary *evaluationsDict in [CommonMethod paramArrayIsNull:dict[@"evaluations"]]){
        UserModel *model = [[UserModel alloc] initWithDict:evaluationsDict];
        [self.evaluationsArray addObject:model];
    }
    self.attenthimlistArray = [NSMutableArray array];
    for(NSDictionary *evaluationsDict in [CommonMethod paramArrayIsNull:dict[@"attenthimlist"]]){
        UserModel *model = [[UserModel alloc] initWithDict:evaluationsDict];
        [self.attenthimlistArray addObject:model];
    }
    self.honorsArray = [NSMutableArray array];
    for(NSDictionary *honorDict in self.honor){
        HonorModel *model = [[HonorModel alloc] initWithDict:honorDict];
        [self.honorsArray addObject:model];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.userId = [coder decodeObjectForKey:@"userId"];
        self.sex = [coder decodeObjectForKey:@"sex"];
        self.status = [coder decodeObjectForKey:@"status"];
        self.usertype = [coder decodeObjectForKey:@"usertype"];
        self.province = [coder decodeObjectForKey:@"province"];
        self.city = [coder decodeObjectForKey:@"city"];
        self.district = [coder decodeObjectForKey:@"district"];
        self.province = [coder decodeObjectForKey:@"provinceid"];
        self.city = [coder decodeObjectForKey:@"cityid"];
        self.district = [coder decodeObjectForKey:@"districtid"];
        self.isinitpasswd = [coder decodeObjectForKey:@"isinitpasswd"];
        self.hasValidUser = [coder decodeObjectForKey:@"hasValidUser"];
        self.hasnews = [coder decodeObjectForKey:@"hasnews"];
        self.iseasemobuser = [coder decodeObjectForKey:@"iseasemobuser"];
        self.invitenum = [coder decodeObjectForKey:@"invitenum"];
        self.getednum = [coder decodeObjectForKey:@"getednum"];
        self.videoplaycount = [coder decodeObjectForKey:@"videoplaycount"];
        self.friendcnt = [coder decodeObjectForKey:@"friendcnt"];
        self.getcoffcnt = [coder decodeObjectForKey:@"getcoffcnt"];
        self.attentcnt = [coder decodeObjectForKey:@"attentcnt"];
        self.attentedcnt = [coder decodeObjectForKey:@"attentedcnt"];
        self.visitedcnt = [coder decodeObjectForKey:@"visitedcnt"];
        self.recomdcnt = [coder decodeObjectForKey:@"recomdcnt"];
        self.sharecnt = [coder decodeObjectForKey:@"sharecnt"];
        self.othericon = [coder decodeObjectForKey:@"othericon"];
        
        self.canviewphone = [coder decodeObjectForKey:@"canviewphone"];
        self.hasaskcheck = [coder decodeObjectForKey:@"hasaskcheck"];
        self.asksubjectid = [coder decodeObjectForKey:@"asksubjectid"];
        self.askcheck = [coder decodeObjectForKey:@"askcheck"];
        self.asksubject = [coder decodeObjectForKey:@"asksubject"];
        
        self.name = [coder decodeObjectForKey:@"name"];
        self.password = [coder decodeObjectForKey:@"password"];
        self.nickname = [coder decodeObjectForKey:@"nickname"];
        self.realname = [coder decodeObjectForKey:@"realname"];
        self.letter = [coder decodeObjectForKey:@"letter"];
        self.email = [coder decodeObjectForKey:@"email"];
        self.phone = [coder decodeObjectForKey:@"phone"];
        self.qq = [coder decodeObjectForKey:@"qq"];
        self.cardno = [coder decodeObjectForKey:@"cardno"];
        self.image = [coder decodeObjectForKey:@"image"];
        self.birthday = [coder decodeObjectForKey:@"birthday"];
        self.last_login_ip = [coder decodeObjectForKey:@"last_login_ip"];
        self.last_login_time = [coder decodeObjectForKey:@"last_login_time"];
        self.company = [coder decodeObjectForKey:@"company"];
        self.companyphone = [coder decodeObjectForKey:@"companyphone"];
        self.industry = [coder decodeObjectForKey:@"industry"];
        self.position = [coder decodeObjectForKey:@"position"];
        self.business = [coder decodeObjectForKey:@"business"];
        self.remark = [coder decodeObjectForKey:@"remark"];
        self.address = [coder decodeObjectForKey:@"address"];
        self.created_at = [coder decodeObjectForKey:@"created_at"];
        self.updated_at = [coder decodeObjectForKey:@"updated_at"];
        self.VIPFrom = [coder decodeObjectForKey:@"VIPFrom"];
        self.VIPTo = [coder decodeObjectForKey:@"VIPTo"];
        self.authenti_image = [coder decodeObjectForKey:@"authenti_image"];
        self.elastictime = [coder decodeObjectForKey:@"elastictime"];
        self.worktime = [coder decodeObjectForKey:@"worktime"];
        self.video = [coder decodeObjectForKey:@"video"];
        self.mystate = [coder decodeObjectForKey:@"mystate"];
        self.goodjobs = [coder decodeObjectForKey:@"goodjobs"];
        self.career = [coder decodeObjectForKey:@"career"];
        self.infoIsNotFinished = [coder decodeObjectForKey:@"infoIsNotFinished"];
        self.homeData = [coder decodeObjectForKey:@"homeData"];
        self.coffeeInfoData = [coder decodeObjectForKey:@"coffeeInfoData"];
        self.rcmListData = [coder decodeObjectForKey:@"rcmListData"];
        self.activityData = [coder decodeObjectForKey:@"activityData"];
        self.reportDict = [coder decodeObjectForKey:@"reportDict"];
        
        self.tagData = [coder decodeObjectForKey:@"tagData"];
        self.cityData = [coder decodeObjectForKey:@"cityData"];
        self.topicData = [coder decodeObjectForKey:@"topicData"];
        self.notecount = [coder decodeObjectForKey:@"notecount"];
        self.vpcount = [coder decodeObjectForKey:@"vpcount"];
        self.ask = [coder decodeObjectForKey:@"ask"];
        self.answer = [coder decodeObjectForKey:@"answer"];
        self.colleaguestr = [coder decodeObjectForKey:@"colleaguestr"];
        
        self.intersted_industrys = [coder decodeObjectForKey:@"intersted_industrys"];
        self.dynamicData = [coder decodeObjectForKey:@"dynamicData"];
        self.noUploadDynamicData = [coder decodeObjectForKey:@"noUploadDynamicData"];
        self.hasPublishDynamic = [coder decodeObjectForKey:@"hasPublishDynamic"];
        self.cityName = [coder decodeObjectForKey:@"cityName"];
        self.capacityArray = [coder decodeObjectForKey:@"capacityArray"];
        self.pushActivityDic = [coder decodeObjectForKey:@"pushActivityDic"];
        
        self.weixin = [coder decodeObjectForKey:@"weixin"];
        self.selftag = [coder decodeObjectForKey:@"selftag"];
        self.interesttag = [coder decodeObjectForKey:@"interesttag"];
        self.honor = [coder decodeObjectForKey:@"honor"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userId forKey:@"userId"];
    [coder encodeObject:self.sex forKey:@"sex"];
    [coder encodeObject:self.status forKey:@"status"];
    [coder encodeObject:self.usertype forKey:@"usertype"];
    [coder encodeObject:self.province forKey:@"province"];
    [coder encodeObject:self.city forKey:@"city"];
    [coder encodeObject:self.district forKey:@"district"];
    [coder encodeObject:self.province forKey:@"provinceid"];
    [coder encodeObject:self.city forKey:@"cityid"];
    [coder encodeObject:self.district forKey:@"districtid"];
    [coder encodeObject:self.isinitpasswd forKey:@"isinitpasswd"];
    [coder encodeObject:self.hasValidUser forKey:@"hasValidUser"];
    [coder encodeObject:self.hasnews forKey:@"hasnews"];
    [coder encodeObject:self.iseasemobuser forKey:@"iseasemobuser"];
    [coder encodeObject:self.invitenum forKey:@"invitenum"];
    [coder encodeObject:self.getednum forKey:@"getednum"];
    [coder encodeObject:self.videoplaycount forKey:@"videoplaycount"];
    [coder encodeObject:self.friendcnt forKey:@"friendcnt"];
    [coder encodeObject:self.getcoffcnt forKey:@"getcoffcnt"];
    [coder encodeObject:self.attentcnt forKey:@"attentcnt"];
    [coder encodeObject:self.attentedcnt forKey:@"attentedcnt"];
    [coder encodeObject:self.visitedcnt forKey:@"visitedcnt"];
    [coder encodeObject:self.colleaguestr forKey:@"colleaguestr"];
    [coder encodeObject:self.recomdcnt forKey:@"recomdcnt"];
    [coder encodeObject:self.sharecnt forKey:@"sharecnt"];
    [coder encodeObject:self.othericon forKey:@"othericon"];
    
    [coder encodeObject:self.canviewphone forKey:@"canviewphone"];
    [coder encodeObject:self.hasaskcheck forKey:@"hasaskcheck"];
    [coder encodeObject:self.asksubjectid forKey:@"asksubjectid"];
    [coder encodeObject:self.askcheck forKey:@"askcheck"];
    [coder encodeObject:self.asksubject forKey:@"asksubject"];
    
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.password forKey:@"password"];
    [coder encodeObject:self.nickname forKey:@"nickname"];
    [coder encodeObject:self.realname forKey:@"realname"];
    [coder encodeObject:self.letter forKey:@"letter"];
    [coder encodeObject:self.email forKey:@"email"];
    [coder encodeObject:self.phone forKey:@"phone"];
    [coder encodeObject:self.qq forKey:@"qq"];
    [coder encodeObject:self.cardno forKey:@"cardno"];
    [coder encodeObject:self.image forKey:@"image"];
    [coder encodeObject:self.birthday forKey:@"birthday"];
    [coder encodeObject:self.last_login_ip forKey:@"last_login_ip"];
    [coder encodeObject:self.last_login_time forKey:@"last_login_time"];
    [coder encodeObject:self.company forKey:@"company"];
    [coder encodeObject:self.companyphone forKey:@"companyphone"];
    [coder encodeObject:self.industry forKey:@"industry"];
    [coder encodeObject:self.position forKey:@"position"];
    [coder encodeObject:self.business forKey:@"business"];
    [coder encodeObject:self.remark forKey:@"remark"];
    [coder encodeObject:self.address forKey:@"address"];
    [coder encodeObject:self.created_at forKey:@"created_at"];
    [coder encodeObject:self.updated_at forKey:@"updated_at"];
    [coder encodeObject:self.VIPFrom forKey:@"VIPFrom"];
    [coder encodeObject:self.VIPTo forKey:@"VIPTo"];
    [coder encodeObject:self.authenti_image forKey:@"authenti_image"];
    [coder encodeObject:self.elastictime forKey:@"elastictime"];
    [coder encodeObject:self.worktime forKey:@"worktime"];
    [coder encodeObject:self.video forKey:@"video"];
    [coder encodeObject:self.mystate forKey:@"mystate"];
    [coder encodeObject:self.goodjobs forKey:@"goodjobs"];
    [coder encodeObject:self.career forKey:@"career"];
    [coder encodeObject:self.infoIsNotFinished forKey:@"infoIsNotFinished"];
    [coder encodeObject:self.homeData forKey:@"homeData"];
    [coder encodeObject:self.coffeeInfoData forKey:@"coffeeInfoData"];
    [coder encodeObject:self.topicData forKey:@"topicData"];
    [coder encodeObject:self.cityData forKey:@"cityData"];
    [coder encodeObject:self.tagData forKey:@"tagData"];
    [coder encodeObject:self.rcmListData forKey:@"rcmListData"];
    [coder encodeObject:self.notecount forKey:@"notecount"];
    [coder encodeObject:self.vpcount forKey:@"vpcount"];
    [coder encodeObject:self.activityData forKey:@"activityData"];
    [coder encodeObject:self.reportDict forKey:@"reportDict"];
    [coder encodeObject:self.ask forKey:@"ask"];
    [coder encodeObject:self.answer forKey:@"answer"];
    [coder encodeObject:self.intersted_industrys forKey:@"intersted_industrys"];
    [coder encodeObject:self.dynamicData forKey:@"dynamicData"];
    [coder encodeObject:self.noUploadDynamicData forKey:@"noUploadDynamicData"];
    [coder encodeObject:self.hasPublishDynamic forKey:@"hasPublishDynamic"];
    [coder encodeObject:self.cityName forKey:@"cityName"];
    [coder encodeObject:self.capacityArray forKey:@"capacityArray"];
    [coder encodeObject:self.pushActivityDic forKey:@"pushActivityDic"];
    
    [coder encodeObject:self.weixin forKey:@"weixin"];
    [coder encodeObject:self.selftag forKey:@"selftag"];
    [coder encodeObject:self.interesttag forKey:@"interesttag"];
    [coder encodeObject:self.honor forKey:@"honor"];
}


@end
