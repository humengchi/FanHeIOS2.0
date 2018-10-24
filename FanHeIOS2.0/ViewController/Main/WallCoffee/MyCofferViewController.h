//
//  MyCofferViewController.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/4.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseTabbarViewController.h"

//上架类型
typedef NS_ENUM(NSInteger, WallCoffeeType) {
    WallCoffeeType_WaitHang = 1,//挂出中...
    WallCoffeeType_HasHang,//上架了
    WallCoffeeType_NotHang_NoCoffee,//没有挂过，也没有咖啡
    WallCoffeeType_NotHang_HasCoffee,//没有挂过，但有咖啡(挂出首杯人脉咖啡)
    WallCoffeeType_CoffeeBeenGot_HasCoffee,//有人领取我的咖啡（有咖啡）
    WallCoffeeType_CoffeeBeenGot_NoCoffee,//有人领取我的咖啡（无咖啡）
};

@interface MyCofferViewController : BaseTabbarViewController

@property (nonatomic, assign) BOOL showBackBtn;

- (void)updateVCDisplay;

@end
