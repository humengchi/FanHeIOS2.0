//
//  NotSetController.m
//  JinMai
//
//  Created by renhao on 16/5/11.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "NotSetController.h"

@interface NotSetController ()

@property (weak, nonatomic) IBOutlet UILabel *startNotLabel;
@property (weak, nonatomic) IBOutlet UISwitch *noteDateailSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *voiceSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *dampingSwitch;

@end

@implementation NotSetController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"通知设置"];
    self.view.backgroundColor = HEX_COLOR(@"EFEFF4");
    UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (setting.types == UIUserNotificationTypeNone){
        self.startNotLabel.text = @"未开启";
    }else{
        self.startNotLabel.text = @"已开启";
    }
    
    if([[[[RKUserDefaults standardUserDefaults] loadUserDefaultsDictionary] allKeys] count] == 0){
        [[RKUserDefaults standardUserDefaults] setBool:YES forKey:ShowDetailKey];
        [[RKUserDefaults standardUserDefaults] setBool:YES forKey:VoiceKey];
        [[RKUserDefaults standardUserDefaults] setBool:YES forKey:DampingKey];
    }
    
    if ([[RKUserDefaults standardUserDefaults] boolForKey:ShowDetailKey]){
        self.noteDateailSwitch.on = YES;
    }else{
        self.noteDateailSwitch.on = NO;
    }
    if ([[RKUserDefaults standardUserDefaults] boolForKey:VoiceKey]){
        self.voiceSwitch.on = YES;
    }else{
        self.voiceSwitch.on = NO;
    }
    if ([[RKUserDefaults standardUserDefaults] boolForKey:DampingKey]){
        self.dampingSwitch.on = YES;
    }else{
        self.dampingSwitch.on = NO;
    }
}

- (IBAction)noteiceShowDatailAction:(UISwitch *)sender {
    [[RKUserDefaults standardUserDefaults] setBool:sender.on forKey:ShowDetailKey];
    //获取全局 APNS 配置
    EMError *error = nil;
    EMPushOptions *options = [[EMClient sharedClient] getPushOptionsFromServerWithError:&error];
    options.displayName = [DataModelInstance shareInstance].userModel.realname;
    if([[RKUserDefaults standardUserDefaults] boolForKey:ShowDetailKey]){
        options.displayStyle = EMPushDisplayStyleMessageSummary;
    }else{
        options.displayStyle = EMPushDisplayStyleSimpleBanner;
    }
    [[EMClient sharedClient] updatePushOptionsToServer];
}

- (IBAction)voiceOffAction:(UISwitch *)sender {
    [[RKUserDefaults standardUserDefaults] setBool:sender.on forKey:VoiceKey];
    if (sender.on == NO){
        AudioServicesDisposeSystemSoundID(1007);
    }else{
        AudioServicesPlaySystemSound(1007);
    }
}

- (IBAction)dampingOffAction:(UISwitch *)sender {
    [[RKUserDefaults standardUserDefaults] setBool:sender.on forKey:DampingKey];
    if (sender.on == NO){
        AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate);
    }else{
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}


@end
