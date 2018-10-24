//
//  LocationMapController.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/29.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationMapController : BaseViewController
@property (nonatomic,assign)float latitude;
@property (nonatomic,assign)float longitude;
@property (nonatomic,assign)float userLatitude;
@property (nonatomic,assign)float userLongitude;

@property (nonatomic,assign)float guserLatitude;
@property (nonatomic,assign)float guserLongitude;
@property (nonatomic ,strong) NSString *addressStr;


@end
