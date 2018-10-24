//
//  TouTiaoModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/28.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"

@interface TouTiaoModel : BaseModel

@property (nonatomic, strong) NSMutableArray *modelArray;

@property (nonatomic, copy) NSString *sendtime;

@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, strong) NSMutableArray *heightArray;

@end
