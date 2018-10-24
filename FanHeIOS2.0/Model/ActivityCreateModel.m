//
//  ActivityCreateModel.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ActivityCreateModel.h"

@implementation ActivityCreateModel

- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
    self.begintime = [CommonMethod paramStringIsNull:self.begintime];
    self.endtime = [CommonMethod paramStringIsNull:self.endtime];
    if(self.begintime.length && self.begintime.length>16){
        self.begintime = [self.begintime substringToIndex:16];
    }
    if(self.endtime.length && self.endtime.length>16){
        self.endtime = [self.endtime substringToIndex:16];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}


- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.userid = [coder decodeObjectForKey:@"userid"];
        self.activityid = [coder decodeObjectForKey:@"activityid"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.image = [coder decodeObjectForKey:@"image"];
        self.imagePhoto = [coder decodeObjectForKey:@"imagePhoto"];
        self.begintime = [coder decodeObjectForKey:@"begintime"];
        self.endtime = [coder decodeObjectForKey:@"endtime"];
        self.tags = [coder decodeObjectForKey:@"tags"];
        self.intro = [coder decodeObjectForKey:@"intro"];
        self.provincename = [coder decodeObjectForKey:@"provincename"];
        self.cityname = [coder decodeObjectForKey:@"cityname"];
        self.districtname = [coder decodeObjectForKey:@"districtname"];
        self.address = [coder decodeObjectForKey:@"address"];
        self.lat = [coder decodeObjectForKey:@"lat"];
        self.lng = [coder decodeObjectForKey:@"lng"];
        self.phone = [coder decodeObjectForKey:@"phone"];
        self.tickets = [coder decodeObjectForKey:@"tickets"];
        self.guests = [coder decodeObjectForKey:@"guests"];
        self.applyendtime = [coder decodeObjectForKey:@"applyendtime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userid forKey:@"userid"];
    [coder encodeObject:self.activityid forKey:@"activityid"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.image forKey:@"image"];
    [coder encodeObject:self.imagePhoto forKey:@"imagePhoto"];
    [coder encodeObject:self.begintime forKey:@"begintime"];
    [coder encodeObject:self.endtime forKey:@"endtime"];
    [coder encodeObject:self.tags forKey:@"tags"];
    [coder encodeObject:self.intro forKey:@"intro"];
    [coder encodeObject:self.provincename forKey:@"provincename"];
    [coder encodeObject:self.cityname forKey:@"cityname"];
    [coder encodeObject:self.districtname forKey:@"districtname"];
    [coder encodeObject:self.address forKey:@"address"];
    [coder encodeObject:self.lat forKey:@"lat"];
    [coder encodeObject:self.lng forKey:@"lng"];
    [coder encodeObject:self.phone forKey:@"phone"];
    [coder encodeObject:self.tickets forKey:@"tickets"];
    [coder encodeObject:self.guests forKey:@"guests"];
    [coder encodeObject:self.applyendtime forKey:@"applyendtime"];
}
     

@end
