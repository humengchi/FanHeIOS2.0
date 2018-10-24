//
//  AddUrlController.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/2/8.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"


@protocol AddUrlControllerDelegate <NSObject>

- (void)backAddUrlControllerDic:(NSMutableDictionary *)dic;

@end

@interface AddUrlController : BaseViewController
@property (nonatomic ,strong) NSMutableDictionary  *dic;
@property (nonatomic, weak) id<AddUrlControllerDelegate>addUrlControllerDelegate;
@end
