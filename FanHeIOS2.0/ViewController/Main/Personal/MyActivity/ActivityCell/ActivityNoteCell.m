//
//  ActivityNoteCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ActivityNoteCell.h"
#import "ActivityDetailController.h"
#import <EventKit/EventKit.h>

@interface ActivityNoteCell ()

@property (nonatomic, weak) IBOutlet UILabel *actTypeLabel;
@property (nonatomic, weak) IBOutlet UIButton *remindBtn;
@property (nonatomic, weak) IBOutlet UILabel *msgLabel;

@property (nonatomic, weak) IBOutlet UIView *actView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;

@property (nonatomic, weak) IBOutlet UIView *reasonView;
@property (nonatomic, weak) IBOutlet UILabel *reasonLabel;

@property (nonatomic, weak) IBOutlet UILabel *lineLabel;

@property (nonatomic, strong) ActivityNoteModel *model;

@end

@implementation ActivityNoteCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [CALayer updateControlLayer:self.iconImageView.layer radius:18 borderWidth:0 borderColor:nil];
    [CommonMethod viewAddGuestureRecognizer:self.actView tapsNumber:1 withTarget:self withSEL:@selector(gotoActivityDetail)];
    self.lineLabel.backgroundColor = kTableViewBgColor;
}

- (void)gotoActivityDetail{
    ActivityDetailController *vc = [[ActivityDetailController alloc] init];
    vc.activityid = self.model.activityid;
    [[self viewController].navigationController pushViewController:vc animated:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)getCellHeight:(ActivityNoteModel*)model{
    CGFloat height = 0;
    height = [NSHelper heightOfString:[CommonMethod paramStringIsNull:model.msg] font:FONT_SYSTEM_SIZE(14) width:WIDTH-32];
    height += ((NSInteger)(height/FONT_SYSTEM_SIZE(14).lineHeight))*6;
    if(model.status.integerValue == 1 || model.status.integerValue == 2){
        height += 82;
        CGFloat reasonHeight = [NSHelper heightOfString:[CommonMethod paramStringIsNull:model.reason] font:FONT_SYSTEM_SIZE(14) width:WIDTH-32];
        height += ((NSInteger)(reasonHeight/FONT_SYSTEM_SIZE(14).lineHeight))*6+reasonHeight;
    }else{
        height += 136;
    }
    return height;
}

- (void)updateDisplyCell:(ActivityNoteModel*)model{
    self.model = model;
    self.actView.hidden = YES;
    self.reasonView.hidden = YES;
    self.remindBtn.hidden = YES;
    NSString *msg;
    if(model.status.integerValue == 1){
        msg = @"活动被取消";
        self.reasonView.hidden = NO;
    }else if(model.status.integerValue == 2){
        msg = @"活动被取消";
        self.reasonView.hidden = NO;
    }else if(model.status.integerValue == 3){
        msg = @"提问被回复";
        self.actView.hidden = NO;
    }else if(model.status.integerValue == 4){
        msg = @"活动提醒";
        self.actView.hidden = NO;
        self.remindBtn.hidden = NO;
    }else{
        msg = @"活动邀请";
        self.actView.hidden = NO;
    }
    self.actTypeLabel.text = msg;
    if(model.status.integerValue==3){
        self.msgLabel.attributedText = [self setMsgText:[NSString stringWithFormat:@"回复：%@",[CommonMethod paramStringIsNull:model.msg]] isReply:YES];
    }else{
        [self.msgLabel setParagraphText:[CommonMethod paramStringIsNull:model.msg] lineSpace:6];
    }
    //活动
    self.nameLabel.text = [CommonMethod paramStringIsNull:model.name];
    self.timeLabel.text = [CommonMethod paramStringIsNull:model.starttime];
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:[CommonMethod paramStringIsNull:model.image]] placeholderImage:kImageWithName(@"icon_event_bg")];
    
    //原因
    if([CommonMethod paramStringIsNull:model.reason].length){
        [self.reasonLabel setParagraphText:[CommonMethod paramStringIsNull:model.reason] lineSpace:6];
    }else{
        self.reasonLabel.text = @""; 
    }
}

- (NSMutableAttributedString*)setMsgText:(NSString *)text isReply:(BOOL)isReply{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    if(isReply){
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"f76b1c"] range:NSMakeRange(0, 3)];
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:6];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, text.length)];
    return attributedString;
}

- (IBAction)remindButtonClicked:(id)sender{
    //事件市场
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    //6.0及以上通过下面方式写入事件
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]){
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error){
                }else if (!granted){
                    //被用户拒绝，不允许访问日历
                    [[[CommonUIAlert alloc] init] showCommonAlertView:[self viewController] title:@"" message:@"请在iPhone的“设置>隐私>日历”选项中，允许3号圈访问你的日历" cancelButtonTitle:@"取消" otherButtonTitle:@"设置" cancle:^{
                    } confirm:^{
                        if(IOS_X >= 10){
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        }else{
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
                        }
                    }];
                }else{
                    //创建事件
                    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
                    event.title = self.model.name;
                    event.location = self.model.address;
                    event.startDate = [NSDate dateFromString:[CommonMethod paramStringIsNull:self.model.begintime] format:kTimeFormat];
                    event.endDate = [NSDate dateFromString:[CommonMethod paramStringIsNull:self.model.endtime] format:kTimeFormat];
                    event.allDay = YES;
                    
                    //添加提醒
                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * 60.0f * 7]];
                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -60.0f * 24]];
                    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
                    NSError *err;
                    [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                    
                    [MBProgressHUD showSuccess:@"设置成功" toView:[self viewController].view];
                    NSLog(@"保存成功");
                }
            });
        }];
    }
}

@end
