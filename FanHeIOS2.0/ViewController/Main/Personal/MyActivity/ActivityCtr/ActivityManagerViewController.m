//
//  ActivityManagerViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/5.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ActivityManagerViewController.h"
#import "ApplyManagerViewController.h"
#import "ActivityTalkViewController.h"
#import "ActivityDetailController.h"
#import "CreateActivityViewController.h"
#import "DynamicShareView.h"
#import "NONetWorkTableViewCell.h"
#import "ChoiceFriendViewController.h"
#import "TransmitDynamicController.h"

@interface ActivityManagerViewController ()<UIAlertViewDelegate>{
    BOOL _noNetWork;
    BOOL _isNotFirst;
}
@property (nonatomic, strong) MyActivityModel *model;

@end

@implementation ActivityManagerViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(_isNotFirst){
        [self getHttpData];
    }
    _isNotFirst = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"活动管理"];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self getHttpData];
    // Do any additional setup after loading the view from its nib.
}

// 作用：拦截手势触发
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if(self.isPublishSuccess){
        return NO;
    }
    if (self.navigationController.childViewControllers.count == 1){
        // 表示用户在根控制器界面，就不需要触发滑动手势，
        return NO;
    }
    //向左滑动
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        CGPoint translatedPoint = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self.view];
        if(translatedPoint.x < 0 || translatedPoint.y){
            return NO;
        }
        if([gestureRecognizer locationInView:self.view].x>50){
            return NO;
        }
    }
    return YES;
}

- (void)customNavBackButtonClicked{
    if(self.isPublishSuccess){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 管理网络请求
- (void)getHttpData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud;
    if(_isNotFirst==NO){
        hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    }
    _noNetWork = NO;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", self.activityid, [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_ACTIVITY_MY_ACT_DETAIL paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            weakSelf.model = [[MyActivityModel alloc] initWithDict:[CommonMethod paramDictIsNull:responseObject[@"data"]]];
        }
        if(weakSelf.model==nil){
            weakSelf.model = [[MyActivityModel alloc] init];
        }else{
            [weakSelf initTableViewFooterView];
        }
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if(weakSelf.model==nil){
            weakSelf.model = [[MyActivityModel alloc] init];
        }
        _noNetWork = YES;
        [MBProgressHUD showError:@"无法连接到网络" toView:weakSelf.view];
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - 更改报名状态
- (void)changeApplyStatueHttp{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"修改中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.activityid forKey:@"activityid"];
    [requestDict setObject:self.model.canapply forKey:@"canapply"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_ACTIVITY_UPCAN_APPLY paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@",[self.model.canapply isEqualToString:@"Y"]?@"可以报名":@"报名停止"] toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"无法连接到网络" toView:weakSelf.view];
    }];
}

#pragma mark - 活动编辑,获取活动详情
- (void)getActivityDetailHttp{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@", self.activityid] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_ACTIVITY_EDIT_INFO paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            ActivityCreateModel *model = [[ActivityCreateModel alloc] initWithDict:[CommonMethod paramDictIsNull:responseObject[@"data"]]];
            CreateActivityViewController *vc = [[CreateActivityViewController alloc] init];
            vc.model = model;
            vc.isEdit = YES;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }else{
            [MBProgressHUD showError:@"无法连接到网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"无法连接到网络" toView:weakSelf.view];
    }];
}

#pragma mark - 取消删除活动
- (void)deleteActivityHttp:(NSInteger)type reason:(NSString*)reason{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:type==0?@"取消中...":@"删除中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:self.activityid forKey:@"activityid"];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:(type==0?@"cel":@"del") forKey:@"act"];
    [requestDict setObject:reason forKey:@"reason"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_ACTIVITY_DROP_ATY paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:(type==0?@"活动已取消":@"活动已删除") toView:weakSelf.view];
            if(type==0){
                weakSelf.model.status = @(2);
                [weakSelf initTableViewFooterView];
                [weakSelf.tableView reloadData];
            }else{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                });
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"无法连接到网络" toView:weakSelf.view];
    }];
}

#pragma mark - footerview
- (void) initTableViewFooterView{
    CGFloat height = 0;//52;
    if(self.model.status.integerValue == 2){//已取消
        height = 52;
    }
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 72+height)];
    footerView.backgroundColor = kTableViewBgColor;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundColor:height?HEX_COLOR(@"e24943"):HEX_COLOR(@"afb6c1")];
    btn.frame = CGRectMake((WIDTH-250)/2, 22+height, 250, 40);
    [btn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
    [btn setTitle:height?@"删除活动记录":@"取消活动" forState:UIControlStateNormal];
    if(height){
        [btn addTarget:self action:@selector(deleteActivityClicked:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [btn addTarget:self action:@selector(cancleActivityClicked:) forControlEvents:UIControlEventTouchUpInside];    }
    btn.titleLabel.font = FONT_SYSTEM_SIZE(17);
    btn.layer.cornerRadius = 5;
    btn.layer.masksToBounds = YES;
    [footerView addSubview:btn];
    if(self.model.status.integerValue == 1){//已结束
        btn.enabled = NO;
    }
    
    if(height){
        UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake((WIDTH-250)/2, 22, 250, 40) backColor:HEX_COLOR(@"e6e8eb") textColor:WHITE_COLOR test:@"活动已取消" font:17 number:1 nstextLocat:NSTextAlignmentCenter];
        contentLabel.layer.cornerRadius = 5;
        contentLabel.layer.masksToBounds = YES;
        [footerView addSubview:contentLabel];
        [btn addTarget:self action:@selector(deleteActivityClicked:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [btn addTarget:self action:@selector(cancleActivityClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.tableView.tableFooterView = footerView;
}

#pragma mark - 按钮
- (void)cancleActivityClicked:(UIButton*)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"取消活动" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *txtName = [alert textFieldAtIndex:0];
    txtName.placeholder = @"输入原因，限30个字（必填）";
    [alert show];
}

- (void)deleteActivityClicked:(UIButton*)sender{
    [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"是否删除该活动记录" message:@"\n删除后该活动记录消失且不可恢复" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
    } confirm:^{
        [self deleteActivityHttp:1 reason:@""];
    }];
}

#pragma mark -UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    UITextField *txtName = [alertView textFieldAtIndex:0];
    if(buttonIndex==1 && txtName.text.length){
        [self deleteActivityHttp:0 reason:txtName.text];
    }
}

#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.model==nil){
        return 0;
    }else if(self.model.activityid.integerValue == 0 && _noNetWork){
        return 1;
    }else{
        return 7;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.model.activityid.integerValue == 0 && _noNetWork){
        return self.tableView.frame.size.height;
    }else{
        if(indexPath.row==0){
            return WIDTH*9/16.0;
        }else if(indexPath.row==1){
            return 75;
        }else{
            return 49;
        }
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.model.activityid.integerValue == 0 && _noNetWork){
        static NSString *identify = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NONetWorkTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }else{
        static NSString *identify = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        if(indexPath.row==0){
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, WIDTH*9/16.0)];
            [imageView sd_setImageWithURL:[NSURL URLWithString:self.model.image] placeholderImage:kImageWithName(@"activity_bg")];
            [cell.contentView addSubview:imageView];
            UILabel *hudLabel = [UILabel createrLabelframe:CGRectMake(WIDTH-100, WIDTH*9/16.0-34, 90, 24) backColor:[BLACK_COLOR colorWithAlphaComponent:0.5] textColor:WHITE_COLOR test:@"查看活动详情" font:12 number:1 nstextLocat:NSTextAlignmentCenter];
            [CALayer updateControlLayer:hudLabel.layer radius:4 borderWidth:0 borderColor:nil];
            [cell.contentView addSubview:hudLabel];
        }else if(indexPath.row==1){
            UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(16, 15, WIDTH-32, 19) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:self.model.name font:17 number:1 nstextLocat:NSTextAlignmentLeft];
            [cell.contentView addSubview:contentLabel];
            UILabel *numLabel = [UILabel createrLabelframe:CGRectMake(16, 45, WIDTH-120, 16) backColor:WHITE_COLOR textColor:HEX_COLOR(@"afb6c1") test:[NSString stringWithFormat:@"报名 %@  讨论 %@  浏览 %@", [CommonMethod paramNumberIsNull:self.model.applynum], [CommonMethod paramNumberIsNull:self.model.asknum], [CommonMethod paramNumberIsNull:self.model.readcount]] font:12 number:1 nstextLocat:NSTextAlignmentLeft];
            [cell.contentView addSubview:numLabel];
            
            UILabel *startLabel = [UILabel createrLabelframe:CGRectMake(WIDTH-80, 42, 64, 21) backColor:WHITE_COLOR textColor:HEX_COLOR(@"AFB6C1") test:@"" font:12 number:1 nstextLocat:NSTextAlignmentCenter];
            [cell.contentView addSubview:startLabel];
            
            NSString *state;
            startLabel.layer.borderWidth = 0.3;
            startLabel.layer.masksToBounds = YES;
            startLabel.layer.cornerRadius = 2;
            if (self.model.status.integerValue == 2) {
                state = @"已取消";
                startLabel.layer.borderColor = [[UIColor colorWithHexString:@"AFB6C1"] CGColor];
                startLabel.textColor = [UIColor colorWithHexString:@"AFB6C1"];
            }else if (self.model.status.integerValue == 1){
                state = @"已结束";
                startLabel.layer.borderColor = [[UIColor colorWithHexString:@"d8d8d8"] CGColor];
                startLabel.textColor = [UIColor colorWithHexString:@"41464E"];
            }else if (self.model.status.integerValue == 3){
                state = @"已截止";
                startLabel.layer.borderColor = [[UIColor colorWithHexString:@"E24943"] CGColor];
                startLabel.textColor = [UIColor colorWithHexString:@"E24943"];
            }else if (self.model.status.integerValue == 4){
                state = @"已报名";
                startLabel.layer.borderColor = [[UIColor colorWithHexString:@"1ABC9C"] CGColor];
                startLabel.textColor = [UIColor colorWithHexString:@"1ABC9C"];
            }else{//报名中
                state = @"报名中";
                startLabel.layer.borderColor = [[UIColor colorWithHexString:@"1ABC9C"] CGColor];
                startLabel.textColor = [UIColor colorWithHexString:@"1ABC9C"];
            }
            startLabel.text = state;
            UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 74.5, WIDTH-32, 0.5)];
            lineLabel.backgroundColor = kCellLineColor;
            [cell.contentView addSubview:lineLabel];
        }else{
            NSArray *titleArray = @[@"编辑活动",@"报名管理",@"活动讨论",@"报名状态",@"分享活动"];
            NSString *titleStr = titleArray[indexPath.row-2];
            UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(16, 10, 75, 28) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e") test:titleStr font:17 number:1 nstextLocat:NSTextAlignmentLeft];
            [cell.contentView addSubview:titleLabel];
            
            UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-30, 16, 14, 15)];
            iconImageView.contentMode = UIViewContentModeScaleAspectFit;
            iconImageView.image = kImageWithName(@"icon_next_gray");
            [cell.contentView addSubview:iconImageView];
            
            if(indexPath.row==3||indexPath.row==4){
                NSString *num;
                if(indexPath.row==3){
                    num = self.model.newapplynum.stringValue;
                }else{
                    num = self.model.newasknum.stringValue;
                }
                if(num.integerValue){
                    CGFloat width = [NSHelper widthOfString:num font:FONT_SYSTEM_SIZE(14) height:18 defaultWidth:18];
                    if (num.integerValue > 9) {
                        width = [NSHelper widthOfString:num font:FONT_SYSTEM_SIZE(14) height:18 defaultWidth:18]+6;
                    }
                    UILabel *numLabel = [UILabel createrLabelframe:CGRectMake(WIDTH-width-16, 15, width, 18) backColor:HEX_COLOR(@"e24943") textColor:WHITE_COLOR test:num font:14 number:1 nstextLocat:NSTextAlignmentCenter];
                    numLabel.layer.cornerRadius = 9;
                    numLabel.layer.masksToBounds = YES;
                    [cell.contentView addSubview:numLabel];
                }
            }else if(indexPath.row==5){
                UISwitch *switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(WIDTH-63, 9, 47, 27)];
                switchBtn.tintColor = HEX_COLOR(@"d8d8d8");
                switchBtn.backgroundColor = WHITE_COLOR;
                [switchBtn setOnTintColor:HEX_COLOR(@"1abc9c")];
                [cell.contentView addSubview:switchBtn];
                [switchBtn addTarget:self action:@selector(switchButtonClicked:) forControlEvents:UIControlEventValueChanged];
                if([[self.model.canapply uppercaseString] isEqualToString:@"Y"]){
                    [switchBtn setOn:YES];
                }
//                switchBtn.userInteractionEnabled = self.model.canchange;
            }
            if(indexPath.row!=6){
                UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 48.5, WIDTH-32, 0.5)];
                lineLabel.backgroundColor = kCellLineColor;
                [cell.contentView addSubview:lineLabel];
            }
        }
        return cell;
    }
}

#pragma mark - switch
- (void)switchButtonClicked:(UISwitch*)sw{
    NSString *state = @"";
    if (self.model.status.integerValue == 2) {
        state = @"已取消";
    }else if (self.model.status.integerValue == 1){
        state = @"已结束";
    }else if (self.model.status.integerValue == 3){
        state = @"已截止";
    }
    if(state.length && self.model.canchange.integerValue != 1){
        [self.view showToastMessage:[NSString stringWithFormat:@"%@的活动无法停止/开始报名", state]];
        [sw setOn:NO];
    }else{
        if([[self.model.canapply uppercaseString] isEqualToString:@"Y"]){
            self.model.canapply = @"N";
            self.model.status = @(3);
        }else{
            self.model.canapply = @"Y";
            self.model.status = @(0);
        }
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self changeApplyStatueHttp];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.model.activityid.integerValue == 0 && _noNetWork){
        [self getHttpData];
        return;
    }
    if(indexPath.row==0){
        ActivityDetailController *vc = [[ActivityDetailController alloc] init];
        vc.activityid = self.model.activityid;
        [self.navigationController pushViewController:vc animated:YES];
    }else if(indexPath.row==2){
        NSString *state = @"";
        if(self.model.applynum.integerValue){
            state = @"已有人报名";
        }else if (self.model.status.integerValue == 2) {
            state = @"已取消";
        }else if (self.model.status.integerValue == 1){
            state = @"已结束";
        }else if (self.model.status.integerValue == 3){
            state = @"已截止";
        }
        if(state.length){
            [self.view showToastMessage:[NSString stringWithFormat:@"%@的活动无法编辑", state]];
        }else{
            [self getActivityDetailHttp];
        }
    }else if(indexPath.row==3){
        self.model.newapplynum = @(0);
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        ApplyManagerViewController *vc = [[ApplyManagerViewController alloc] init];
        vc.activityid = self.activityid;
        [self.navigationController pushViewController:vc animated:YES];
    }else if(indexPath.row==4){
        ActivityTalkViewController *vc = [[ActivityTalkViewController alloc] init];
        vc.activityid = self.activityid;
        [self.navigationController pushViewController:vc animated:YES];
    }else if(indexPath.row==6){
        DynamicShareView *shareView = [[DynamicShareView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
        [[UIApplication sharedApplication].keyWindow addSubview:shareView];
        [shareView showOrHideView:YES];
        __weak typeof(self) shareSlef = self;
        [shareView setDynamicShareViewIndex:^(NSInteger index) {
            [shareSlef firendClick:index];
        }];

    }
}

- (void)removeShareView:(UITapGestureRecognizer*)tap{
    [tap.view removeFromSuperview];
}

#pragma mark ----------分享 ---
- (void)firendClick:(NSInteger)index{
    NSString *html = [self.model.contents filterHTML];
    NSString *content = html.length>100?[html substringToIndex:100]:html;
    
    NSString *title = self.model.name;
    NSString *imageUrl = self.model.image;
    id imageSource;
    if(imageUrl && imageUrl.length){
        imageSource = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageUrl]];
    }else{
        imageSource = kImageWithName(@"icon-60");
    }
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMSocialPlatformType shareType;
    if(index == 0){
        TransmitDynamicController *jinmai = [[TransmitDynamicController alloc]init];
        DynamicModel *model = [[DynamicModel alloc]init];
        model.activity_id = self.activityid;
        model.activity_image = self.model.image;
        model.activity_title = self.model.name;
        model.activity_timestr = self.model.timestr;
        jinmai.model = model;
        [self presentViewController:jinmai animated:YES completion:nil];
    }else if (index == 1) {
        shareType = UMSocialPlatformType_WechatSession;
    }else if (index == 2) {
        shareType = UMSocialPlatformType_WechatTimeLine;
    }else if (index == 3){
        ChoiceFriendViewController *choseCtr = [CommonMethod getVCFromNib:[ChoiceFriendViewController class]];
        choseCtr.actModel = self.model;
        [self.navigationController pushViewController:choseCtr animated:YES];
        return;
    }else if(index == 4) {
        [MBProgressHUD showSuccess:@"复制成功" toView:nil];
        UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
        [generalPasteBoard setString:[NSString stringWithFormat:@"%@%@", ShareActivityPageURL, self.model.activityid]];
        return;
    }

    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:content thumImage:imageSource];
    shareObject.webpageUrl = [NSString stringWithFormat:@"%@%@", ShareActivityPageURL, self.model.activityid];
    messageObject.shareObject = shareObject;
    [[UMSocialManager defaultManager] shareToPlatform:shareType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.sideMenuViewController hideMenuViewController];
    });
}

@end
