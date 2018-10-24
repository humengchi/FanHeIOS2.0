//
//  LiveVideoView.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/11.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "LiveVideoView.h"
#import "ActivityDetailController.h"
@implementation LiveVideoView

- (IBAction)lookLiveVideoAction:(UITapGestureRecognizer *)sender {
    ActivityDetailController *vc = [[ActivityDetailController alloc] init];
    vc.activityid = self.videoUrl;
    [[self viewController].navigationController pushViewController:vc animated:YES];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
