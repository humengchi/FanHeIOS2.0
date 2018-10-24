//
//  WriteRateController.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

@protocol WriteRateControllerDelegate <NSObject>

- (void)senderRateSuccendBack:(BOOL)isRefer;

@end


@interface WriteRateController : BaseViewController
@property (nonatomic,strong) NSNumber *postID;
@property (nonatomic,assign) BOOL backRate;
@property (nonatomic,assign) BOOL referType;
@property (nonatomic,strong) NSString *nameStr;
@property (nonatomic,weak) id<WriteRateControllerDelegate>writeRateControllerDelegate;
@end
