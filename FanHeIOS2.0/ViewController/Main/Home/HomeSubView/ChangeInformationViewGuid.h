//
//  ChangeInformationViewGuid.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/7/20.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangeInformationViewGuid : UIView
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sideLabel;
- (void)tranferString:(NSString *)side name:(NSArray *)nameArray;

@property (nonatomic, strong) void(^clickedChangeInfoViewGuid)();
@end
