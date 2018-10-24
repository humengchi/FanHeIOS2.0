//
//  HelpView.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/24.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HelpViewDelegate <NSObject>

- (void)clearHistoryChart;

@end

@interface HelpView : UIView
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic)id<HelpViewDelegate>helpDelegate;
@end
