//
//  RegisterJobSelectBusinessViewController.h
//  JinMai
//
//  Created by 胡梦驰 on 16/5/9.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^SelectBusiness)(NSString *business);

@interface RegisterJobSelectBusinessViewController : BaseViewController

@property (nonatomic, strong) SelectBusiness selectBusiness;

@property (nonnull, copy) NSString  *selectBusinessStr;
@property (nonnull, strong) NSString  *positionStr;
@end
