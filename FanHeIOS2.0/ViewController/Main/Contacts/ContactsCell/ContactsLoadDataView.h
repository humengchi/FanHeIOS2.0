//
//  ContactsLoadDataView.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RequestOvertime) ();

@interface ContactsLoadDataView : UIView

@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) IBOutlet UILabel *showLabel;

@property (nonatomic, strong) RequestOvertime requestOvertime;

- (void)startProgressing;
- (void)stopProgressing;
- (void)setProgressFinished;

@end
