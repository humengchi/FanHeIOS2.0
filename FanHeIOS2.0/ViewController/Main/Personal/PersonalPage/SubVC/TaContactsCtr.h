//
//  TaContactsCtr.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/12.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, AttionStatType)
{
    TaAttionStat,
    AttionTaStant,
   
    
};

@interface TaContactsCtr : BaseViewController
@property (nonatomic, strong)   NSNumber *userID;
@property (nonatomic, strong)   NSNumber *attentionhenum;
@property (nonatomic, strong)   NSNumber *hisattentionnum ;

@property (nonatomic, strong)   NSNumber *comfriendnum;
@property (nonatomic, strong)   NSNumber *friendnum;
@property (nonatomic,assign)    AttionStatType type;
@end
