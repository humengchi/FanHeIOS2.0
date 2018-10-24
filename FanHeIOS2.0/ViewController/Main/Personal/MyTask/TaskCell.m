//
//  TaskCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/8.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "TaskCell.h"
#import "EditPersonalInfoViewController.h"
#import "ScanCameraController.h"
#import "SearchCompanyViewController.h"
#import "IdentityController.h"
#import "ChoiceNeedSupplyController.h"
#import "NeedSupplyErrorView.h"
#import "CreateDynamicController.h"
#import "TopicIdentifyViewController.h"
#import "CreateTopicViewController.h"
#import "CreateActivityViewController.h"

@interface TaskCell ()

@property (nonatomic, weak) IBOutlet UIImageView *headerImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *countLabel;
@property (nonatomic, weak) IBOutlet UIButton *btn;

@property (nonatomic, strong) TaskModel *model;

@end

@implementation TaskCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [CALayer updateControlLayer:self.headerImageView.layer radius:22 borderWidth:0 borderColor:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateDisplay:(TaskModel*)model{
    self.model = model;
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[CommonMethod paramStringIsNull:model.icon]] placeholderImage:KSquareImageDefault];
    self.nameLabel.text = [CommonMethod paramStringIsNull:model.name];
    self.countLabel.text = [NSString stringWithFormat:@"奖励%@",[CommonMethod paramNumberIsNull:model.award_cb]];
    //1-已完成未待领取，2-未完成，3-已领取奖励
    if(model.status.integerValue == 2){
        self.btn.enabled = YES;
        [CALayer updateControlLayer:self.btn.layer radius:4 borderWidth:0.5 borderColor:HEX_COLOR(@"e24943").CGColor];
        [self.btn setTitle:@"去完成" forState:UIControlStateNormal];
        [self.btn setTitleColor:HEX_COLOR(@"e24943") forState:UIControlStateNormal];
    }else if(model.status.integerValue == 1){
        self.btn.enabled = YES;
        [CALayer updateControlLayer:self.btn.layer radius:4 borderWidth:0.5 borderColor:HEX_COLOR(@"1abc9c").CGColor];
        [self.btn setTitle:@"领奖励" forState:UIControlStateNormal];
        [self.btn setTitleColor:HEX_COLOR(@"1abc9c") forState:UIControlStateNormal];
    }else{
        self.btn.enabled = NO;
        [CALayer updateControlLayer:self.btn.layer radius:0 borderWidth:0 borderColor:nil];
        [self.btn setTitle:@"已完成" forState:UIControlStateDisabled];
        [self.btn setTitleColor:HEX_COLOR(@"e6e8eb") forState:UIControlStateDisabled];
    }
}

- (IBAction)buttonClicked:(id)sender{
    //1-已完成未待领取，2-未完成，3-待领取奖励
    if(self.model.status.integerValue == 2){
        //1-资料完善，2-个人主页，3-人脉列表，4-首页，5-话题列表，6-活动列表，7-扫名片，8-企业搜索，9-设置，10-名片认证，11-发动态，12-发话题，13-发活动，14-发供需
        if(self.model.extype.integerValue==1){
            EditPersonalInfoViewController *vc = [[EditPersonalInfoViewController alloc] init];
            [[self viewController].navigationController pushViewController:vc animated:YES];
        }else if(self.model.extype.integerValue==2){
            NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
            vc.userId = [DataModelInstance shareInstance].userModel.userId;
            [[self viewController].navigationController pushViewController:vc animated:YES];
        }else if(self.model.extype.integerValue==3){
            [[self viewController].navigationController popToRootViewControllerAnimated:NO];
            [[AppDelegate shareInstance].tabBarController setSelectedIndex:1];
        }else if(self.model.extype.integerValue==4){
            [[self viewController].navigationController popToRootViewControllerAnimated:NO];
            [[AppDelegate shareInstance].tabBarController setSelectedIndex:0];
        }else if(self.model.extype.integerValue==5){
            [[self viewController].navigationController popToRootViewControllerAnimated:NO];
            [[AppDelegate shareInstance].tabBarController setSelectedIndex:2];
        }else if(self.model.extype.integerValue==6){
            [[self viewController].navigationController popToRootViewControllerAnimated:NO];
            [[AppDelegate shareInstance].tabBarController setSelectedIndex:3];
        }else if(self.model.extype.integerValue==7){
            ScanCameraController *vc = [[ScanCameraController alloc] init];
            [[self viewController].navigationController pushViewController:vc animated:YES];
        }else if(self.model.extype.integerValue==8){
            SearchCompanyViewController *vc = [[SearchCompanyViewController alloc] init];
            [[self viewController].navigationController pushViewController:vc animated:YES];
        }else if(self.model.extype.integerValue==9){
            if(IOS_X >= 10){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=NOTIFICATIONS_ID"]];
            }
        }else if(self.model.extype.integerValue==10){
            if(![CommonMethod getUserCanIdentify]){
                CompleteUserInfoView *completeUserInfoView = [[CompleteUserInfoView alloc] initWithType:CompleteUserInfoViewType_Identify];
                completeUserInfoView.completeUserInfoViewEditInfo = ^(){
                    EditPersonalInfoViewController *vc = [[EditPersonalInfoViewController alloc] init];
                    vc.savePersonalInfoSuccess = ^{
                    };
                    [[self viewController].navigationController pushViewController:vc animated:YES];
                };
                return;
            }
            IdentityController *vc = [CommonMethod getVCFromNib:[IdentityController class]];
            [[self viewController].navigationController pushViewController:vc animated:YES];
        }else if(self.model.extype.integerValue==11){
            if([DataModelInstance shareInstance].userModel.hasValidUser.integerValue==1 || [DataModelInstance shareInstance].userModel.hasPublishDynamic.integerValue!=1){
                CreateDynamicController *vc = [CommonMethod getVCFromNib:[CreateDynamicController class]];
                vc.createDynamicSuccess = ^(DynamicModel *model){
                };
                [[self viewController].navigationController pushViewController:vc animated:YES];
            }else{
                TopicIdentifyViewController *vc = [CommonMethod getVCFromNib:[TopicIdentifyViewController class]];
                vc.publishType = PublishType_Dynamic;
                [[self viewController].navigationController pushViewController:vc animated:YES];
            }
        }else if(self.model.extype.integerValue==12){
            if([DataModelInstance shareInstance].userModel.hasValidUser.integerValue == 1){
                CreateTopicViewController *vc = [[CreateTopicViewController alloc] init];
                [[self viewController].navigationController pushViewController:vc animated:YES];
            }else{
                TopicIdentifyViewController *vc = [CommonMethod getVCFromNib:[TopicIdentifyViewController class]];
                vc.publishType = PublishType_Topic;
                [[self viewController].navigationController pushViewController:vc animated:YES];
            }
        }else if(self.model.extype.integerValue==13){
            if([DataModelInstance shareInstance].userModel.hasValidUser.integerValue == 1){
                CreateActivityViewController *vc = [CommonMethod getVCFromNib:[CreateActivityViewController class]];
                [[self viewController].navigationController pushViewController:vc animated:YES];
            }else{
                TopicIdentifyViewController *vc = [CommonMethod getVCFromNib:[TopicIdentifyViewController class]];
                vc.publishType = PublishType_Activity;
                [[self viewController].navigationController pushViewController:vc animated:YES];
            }
        }else if(self.model.extype.integerValue==14){
            __weak typeof(self) weakSelf = self;
            NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
            [requestDict setObject:[NSString stringWithFormat:@"/%@",[DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
            [[self viewController] requstType:RequestType_Get apiName:API_NAME_GET_USER_RESTGX paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
                if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
                    NSDictionary *dic = [CommonMethod paramDictIsNull:responseObject[@"data"]];
                    NSNumber *rest_times = [CommonMethod paramNumberIsNull:dic[@"rest_times"]];
                    if (rest_times.integerValue > 0) {
                        ChoiceNeedSupplyController *vc = [[ChoiceNeedSupplyController alloc]init];
                        vc.limit_times_cn = [CommonMethod paramStringIsNull:dic[@"limit_times_cn"]];
                        [[weakSelf viewController].navigationController pushViewController:vc animated:YES];
                    }else{
                        NeedSupplyErrorView *view = [CommonMethod getViewFromNib:@"NeedSupplyErrorView"];
                        view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
                        view.limit_times_cn = [CommonMethod paramStringIsNull:dic[@"limit_times_cn"]];
                        view.confirmButtonClicked = ^{
                            ChoiceNeedSupplyController *vc = [[ChoiceNeedSupplyController alloc]init];
                            vc.limit_times_cn = [CommonMethod paramStringIsNull:dic[@"limit_times_cn"]];
                            [[weakSelf viewController].navigationController pushViewController:vc animated:YES];
                        };
                        [[UIApplication sharedApplication].keyWindow addSubview:view];
                    }
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
            }];
        }
    }else if(self.model.status.integerValue == 1){
        __weak typeof(self) weakSelf = self;
        __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"领取中..." toView:[self viewController].view];
        NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
        [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
        [requestDict setObject:self.model.taskid forKey:@"taskid"];
        [[self viewController] requstType:RequestType_Post apiName:API_NAME_POST_TASK_GETAWARD paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
            [hud hideAnimated:YES];
            if([CommonMethod isHttpResponseSuccess:responseObject]){
                [MBProgressHUD showSuccess:@"领取成功" toView:[weakSelf viewController].view];
                weakSelf.model.status = @(3);
                if(weakSelf.taskButtonClicked){
                    weakSelf.taskButtonClicked(weakSelf);
                }
            }else{
                [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:[weakSelf viewController].view];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
            [hud hideAnimated:YES];
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:[weakSelf viewController].view];
        }];
    }
}

@end
