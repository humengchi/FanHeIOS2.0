//
//  MyActivityModel.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "MyActivityModel.h"

@implementation InfoFieldModel

- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
}

- (void)copy:(InfoFieldModel*)model{
    self.infoid = model.infoid;
    self.infoname = model.infoname;
    self.infotype = model.infotype;
    self.infovalue = model.infovalue;
}

@end

@implementation MyActivityModel
-(void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
    CGFloat heigth = [NSHelper heightOfString:self.name font:[UIFont systemFontOfSize:17] width:WIDTH - 32];
    if (heigth > 25) {
        heigth =  42;
    }
    self.cellHeight  = heigth+96+(WIDTH - 32) * 193/343 - 4 ;
    
    self.infofields = [NSMutableArray array];
    for(NSDictionary *paramDict in [CommonMethod paramArrayIsNull:dict[@"infofields"]]){
        InfoFieldModel *model = [[InfoFieldModel alloc] initWithDict:paramDict];
        [self.infofields addObject:model];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}
@end
