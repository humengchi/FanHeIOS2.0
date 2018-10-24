//
//  GetCoffeeView.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DeleteCoffeeView)();
typedef void(^ReplyCoffeeView)();
typedef void(^SelectedCoffeeView)();

@interface GetCoffeeView : UIView

@property (nonatomic, strong) DeleteCoffeeView deleteCoffeeView;
@property (nonatomic, strong) ReplyCoffeeView replyCoffeeView;
@property (nonatomic, strong) SelectedCoffeeView selectedCoffeeView;

- (void)updateDisplay:(NSDictionary*)dict;

@end
