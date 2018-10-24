//
//  MyWallCoffeeModel.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/26.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "MyWallCoffeeModel.h"

@implementation MyWallCoffeeModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{

}

- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
    NSLog(@"%@",dict);
    if(self.coffeestatus.integerValue==5 && self.remainingcnt.integerValue<=0){
        self.coffeestatus = @(6);
    }
}

- (BOOL)compareModel:(MyWallCoffeeModel*)model{
    if(self.coffeestatus.integerValue != model.coffeestatus.integerValue){
        return NO;
    }
    if(self.getmycoffeecnt.integerValue != model.getmycoffeecnt.integerValue){
        return NO;
    }
    if(self.mygetcnt.integerValue != model.mygetcnt.integerValue){
        return NO;
    }
    if(self.remainingcnt.integerValue != model.remainingcnt.integerValue){
        return NO;
    }
    if(self.mygetmsgcnt.integerValue != model.mygetmsgcnt.integerValue){
        return NO;
    }
    if(self.getmycoffeemsgcnt.integerValue != model.getmycoffeemsgcnt.integerValue){
        return NO;
    }
    if(self.praisenum.integerValue != model.praisenum.integerValue){
        return NO;
    }
    
    if(![self.remark isEqualToString:model.remark]){
        return NO;
    }
    if(![self.lastperson isEqualToString:model.lastperson]){
        return NO;
    }
    
    if(self.getmycoffeephoto.count != model.getmycoffeephoto.count){
        return NO;
    }
    if(self.mygetphoto.count != model.mygetphoto.count){
        return NO;
    }
    if(self.image.count != model.image.count){
        return NO;
    }
    return YES;
}

@end
