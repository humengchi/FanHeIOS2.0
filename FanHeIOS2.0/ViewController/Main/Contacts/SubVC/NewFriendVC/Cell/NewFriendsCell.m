//
//  NewFriendsCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/29.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "NewFriendsCell.h"

@implementation NewFriendsCell

- (void)awakeFromNib{
    [super awakeFromNib];
    self.headerImageVIew.layer.masksToBounds = YES; //没这句话它圆不起来
    self.headerImageVIew.layer.cornerRadius = 22; //设置图片圆角的尺度
}

- (IBAction)addFriendsAsk:(UIButton *)sender {
    if ([self.friendsDelegate respondsToSelector:@selector(sendAddFriends:)]) {
        [self.friendsDelegate sendAddFriends:self.index];
    }
}

- (void)sendGoodFriends:(ChartModel *)model{
    [self.headerImageVIew sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    
    self.vipImageView.hidden = model.usertype.integerValue != 9;
    self.nameLabel.text = [NSString stringWithFormat:@"%@%@%@",model.realname,model.company,model.position];
    if (model.audio.length != 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDictionary *opts = [NSDictionary dictionaryWithObject:@(NO) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
            AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL URLWithString:model.audio] options:opts];
            NSInteger totalTime = audioAsset.duration.value / audioAsset.duration.timescale; // 获取视频总时长,单位秒
            NSString *time = [NSString stringWithFormat:@"[语音%ld\"]", totalTime];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                self.messageTypeLabel.attributedText = [self tranferStr:[NSString stringWithFormat:@"%@请求添加你为好友 %@",model.realname, time] length:time.length];
            });
        });
    }else{
        self.messageTypeLabel.text = model.reason;
    }
    if (model.status.integerValue == 1) {
        [self.attionBtn setTitle:@"已忽略" forState:UIControlStateNormal];
        [self.attionBtn setTitleColor:[UIColor colorWithHexString:@"E6E8EB"] forState:UIControlStateNormal];
        [self.attionBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }else if (model.status.integerValue == 2) {
        [self.attionBtn setTitle:@"已接受" forState:UIControlStateNormal];
         [self.attionBtn setTitleColor:[UIColor colorWithHexString:@"E6E8EB"] forState:UIControlStateNormal];
        [self.attionBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
}

- (NSMutableAttributedString *)tranferStr:(NSString *)str length:(NSInteger)length{
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:str];
    [AttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"27AE61"] range:NSMakeRange(str.length - length, length)];
    return AttributedStr;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
