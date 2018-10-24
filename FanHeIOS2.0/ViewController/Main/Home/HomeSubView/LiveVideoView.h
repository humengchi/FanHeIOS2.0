//
//  LiveVideoView.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/5/11.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveVideoView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *titlaLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (nonatomic ,strong) NSNumber *videoUrl;
@property (weak, nonatomic) IBOutlet UILabel *liveVideoStat;

@end
