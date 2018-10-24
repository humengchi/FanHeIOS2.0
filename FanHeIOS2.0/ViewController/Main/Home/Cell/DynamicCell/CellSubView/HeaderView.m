//
//  HeaderView.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/3/1.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "HeaderView.h"
#import "MenuCustomView.h"
#import "ReportViewController.h"
#import "DynamicCell.h"

@interface HeaderView ()

@property (nonatomic, weak) IBOutlet UIImageView *headerImageView;
@property (nonatomic, weak) IBOutlet UIImageView *vipImageView;
@property (nonatomic, weak) IBOutlet UIImageView *zfImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *companyLabel;
@property (nonatomic, weak) IBOutlet UILabel *spaceLabel;
@property (nonatomic, weak) IBOutlet UILabel *relationLabel;


@end

@implementation HeaderView

- (void)drawRect:(CGRect)rect {
//    [CALayer updateControlLayer:self.headerImageView.layer radius:22 borderWidth:0 borderColor:nil];
}

- (void)updateDisplay:(DynamicModel *)dynamicModel{
    self.model = dynamicModel;
    DynamicUserModel *model = dynamicModel.userModel;
    if(model.user_id.integerValue == [DataModelInstance shareInstance].userModel.userId.integerValue){
        [self.choiceBtn setImage:kImageWithName(@"btn_dt_dele") forState:UIControlStateNormal];
    }
    //他的动态列表隐藏头部的删除按钮
    self.choiceBtn.hidden = dynamicModel.isTaDynamicList;
    
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[CommonMethod paramStringIsNull:model.user_image]] placeholderImage:KHeadImageDefaultName([CommonMethod paramStringIsNull:model.user_realname])];
    self.nameLabel.text = [CommonMethod paramStringIsNull:model.user_realname];
    
    self.companyLabel.text = [NSString stringWithFormat:@"%@%@",[CommonMethod paramStringIsNull:model.user_company], [CommonMethod paramStringIsNull:model.user_position]];
    
    self.relationLabel.hidden = [CommonMethod paramStringIsNull:model.relationship].length==0;
    self.relationLabel.text = [CommonMethod paramStringIsNull:model.relationship];
    if(self.relationLabel.text.length){
        [CALayer updateControlLayer:self.relationLabel.layer radius:5.5 borderWidth:0.5 borderColor:HEX_COLOR(@"818c9e").CGColor];
    }
    
    self.vipImageView.hidden = model.user_usertype.integerValue != 9;
    self.zfImageView.hidden = model.user_othericon.integerValue != 1;
    if(model.user_othericon.integerValue==1){
        self.spaceLabel.text = @"这是一个";
    }else{
        self.spaceLabel.text = @"";
    }
    if(dynamicModel.dynamic_id.integerValue<0){
        self.choiceBtn.enabled = NO;
    }else{
        self.choiceBtn.enabled = YES;
    }
}

- (IBAction)choiceButtonClicked:(id)sender{
    if(!self.model.enabledHeaderBtnClicked){
        return;
    }
    if(self.model.userModel.user_id.integerValue == [DataModelInstance shareInstance].userModel.userId.integerValue){
        [[[CommonUIAlert alloc] init] showCommonAlertView:[self viewController] title:@"" message:@"是否删除该条动态？" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
        
        } confirm:^{
            self.model.enabledHeaderBtnClicked = NO;
            if(self.deleteDynamic){
                self.deleteDynamic();
            }
        }];
    }else{
        UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
        CGRect rect = [self convertRect:self.bounds toView:window];
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        bgView.backgroundColor = [BLACK_COLOR colorWithAlphaComponent:0.5];
        [[UIApplication sharedApplication].keyWindow addSubview:bgView];
        UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        [bgView addSubview:tapView];
        [CommonMethod viewAddGuestureRecognizer:tapView tapsNumber:1 withTarget:self withSEL:@selector(removeMenuView:)];
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(removeMenuView:)];
        swipe.direction = UISwipeGestureRecognizerDirectionUp|UISwipeGestureRecognizerDirectionDown;
        [tapView addGestureRecognizer:swipe];
        BOOL isTop = NO;
        CGRect frame = CGRectMake(65, 36+rect.origin.y, WIDTH-75, 158);
        if(rect.origin.y>HEIGHT/2){
            frame.origin.y = rect.origin.y-158+16;
            isTop = YES;
        }
        BOOL isAttent = YES;
        if(![[CommonMethod paramStringIsNull:self.model.userModel.relationship] isEqualToString:@"关注"]){
            isAttent = NO;
        }
        MenuCustomView *menu = [[MenuCustomView alloc] initWithFrame:frame isTop:isTop isAttent:isAttent];
        __weak typeof(self) weakSelf = self;
        menu.menuSelectedIndex = ^(NSInteger index){
            if(index==0){
                [weakSelf ignoreDynamicHttp];
            }else if(index==1){
                ReportViewController *vc = [CommonMethod getVCFromNib:[ReportViewController class]];
                vc.reportType = ReportType_Dynamic;
                vc.reportId = weakSelf.model.dynamic_id;
                [[weakSelf viewController].navigationController pushViewController:vc animated:YES];
            }else{
                if(isAttent){
                    [weakSelf unAttentUserHttp];
                }else{
                    [weakSelf ignoreRCMUserHttp];
                }
                
            }
        };
        [bgView addSubview:menu];
    }
}

- (void)removeMenuView:(UIGestureRecognizer*)tap{
    [tap.view.superview removeFromSuperview];
}

- (IBAction)gotoHomePageButtonClicked:(id)sender{
    if([CommonMethod paramNumberIsNull:self.model.userModel.user_id].integerValue){
        NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
        vc.userId = [CommonMethod paramNumberIsNull:self.model.userModel.user_id];
        vc.attentUser = ^(BOOL isAttent){
            DynamicCell *cell = (DynamicCell*)self.superview;
            if(cell.attentUser){
                cell.attentUser(isAttent);
            }
        };
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
}

//取消关注某人
- (void)unAttentUserHttp{
    self.model.enabledHeaderBtnClicked = NO;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.model.userModel.user_id forKey:@"otherid"];
    [[self viewController] requstType:RequestType_Post apiName:API_NAME_USER_GET_CANCELATION paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"已取消关注" toView:[self viewController].view];dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if(self.deleteUserDynamic){
                    self.deleteUserDynamic(self.model.userModel.user_id);
                }
            });
        }else{
            self.model.enabledHeaderBtnClicked = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        self.model.enabledHeaderBtnClicked = YES;
    }];
}

//不感兴趣
- (void)ignoreDynamicHttp{
    if(self.ignoreDynamic){
        self.ignoreDynamic();
    }
    self.model.enabledHeaderBtnClicked = NO;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.model.dynamic_id forKey:@"dynamicid"];
    [[self viewController] requstType:RequestType_Post apiName:API_NAME_POST_DYNAMIC_IGNORE_DY paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            UserModel *model = [DataModelInstance shareInstance].userModel;
            [[AppDelegate shareInstance] setZhugeTrack:@"屏蔽动态" properties:@{@"industry":[CommonMethod paramStringIsNull:model.industry], @"business":[CommonMethod paramStringIsNull:model.business],@"city":[CommonMethod paramStringIsNull:model.address], @"dynamicId":[CommonMethod paramNumberIsNull:self.model.dynamic_id],@"dynamicType":[CommonMethod paramNumberIsNull:self.model.type],@"dynamicExtype":[CommonMethod paramNumberIsNull:self.model.exttype]}];
        }else{
            self.model.enabledHeaderBtnClicked = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        self.model.enabledHeaderBtnClicked = YES;
    }];
}

//不再推荐该人的动态
- (void)ignoreRCMUserHttp{
    self.model.enabledHeaderBtnClicked = NO;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.model.userModel.user_id forKey:@"otherid"];
    [[self viewController] requstType:RequestType_Post apiName:API_NAME_POST_DYNAMIC_IGNORE_SMB paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"设置成功" toView:[self viewController].view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if(self.deleteUserDynamic){
                    self.deleteUserDynamic(self.model.userModel.user_id);
                }
            });
        }else{
            self.model.enabledHeaderBtnClicked = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        self.model.enabledHeaderBtnClicked = YES;
    }];
}

@end
