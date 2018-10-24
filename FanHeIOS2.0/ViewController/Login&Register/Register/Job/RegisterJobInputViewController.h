//
//  RegisterJobInputViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/2.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

//资讯类型posts
typedef NS_ENUM(NSInteger, JOB_PARAM) {
    JOB_PARAM_COMPANY,
    JOB_PARAM_POSITION,
    JOB_PARAM_BUSINESS,
    JOB_PARAM_ADDBUSINESS,
    
};

#import "BaseKeyboardViewController.h"

@protocol RegisterJobInputViewControllerDelegate <NSObject>

- (void)RegisterJobInputViewControllerDelegateChoiceParam:(NSString*)param isCompany:(JOB_PARAM)jobParam;

@end

@interface RegisterJobInputViewController : BaseKeyboardViewController
@property (nonatomic, strong)  NSString *comapyStr;
@property (nonatomic, assign) JOB_PARAM  jobParamType;
@property (nonatomic, assign)  BOOL isWorkHistory;
@property (nonatomic, weak) id<RegisterJobInputViewControllerDelegate>delegate;

@end
