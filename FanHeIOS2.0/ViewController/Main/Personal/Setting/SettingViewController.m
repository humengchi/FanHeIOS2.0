//
//  SettingViewController.m
//  JinMai
//
//  Created by 胡梦驰 on 16/5/5.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "SettingViewController.h"
#import "AccountViewController.h"
#import "AboutOurController.h"
#import "NotSetController.h"
#import "AdviceViewController.h"
#import "PrivacySettingController.h"
#import "InterestBusinessController.h"
#import "VisitPhoneBookView.h"

#import "ShareNormalView.h"
#import "SynchronizationPhoneCtr.h"

#import <AddressBook/AddressBook.h>

#import <StoreKit/SKStoreReviewController.h>

@interface SettingViewController ()

@property (nonatomic, strong) NSMutableArray        *dataArray;

@property (nonatomic, assign) BOOL isBack;

@end

@implementation SettingViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    self.isBack = YES;
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(self.isBack){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"设置"];
    self.view.backgroundColor = kTableViewBgColor;

    self.dataArray = [NSMutableArray arrayWithObjects:@[@"账号设置",@"通知设置",@"设置感兴趣的行业",@"联系人和隐私"],@[@"更新通讯录至3号圈",@"邀请好友加入3号圈"], @[@"关于3号圈",@"问题反馈",@"清除缓存"], nil];

    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 80)];
    footView.userInteractionEnabled = YES;
    UIButton *quitBtn =  [NSHelper createButton:CGRectMake(62, footView.frame.size.height - 40, WIDTH - 124, 40) title:@"退出登录" unSelectImage:[UIImage imageNamed:@""] selectImage:nil target:self selector:@selector(quitBtnAction)];
    [quitBtn setTitleColor:KTextColor forState:UIControlStateNormal];
    [quitBtn setBackgroundImage:[UIImage imageNamed:@"btn_tc"] forState:UIControlStateNormal];
    footView.backgroundColor = kTableViewBgColor;
    [footView addSubview:quitBtn];
    self.tableView.tableFooterView = footView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = kTableViewBgColor;
    // Do any additional setup after loading the view from its nib.
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(IOS_X >= 10.3){
            [SKStoreReviewController requestReview];
        }
    });
}

- (void)quitBtnAction{
    [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"确认退出？" message:@"退出当前账号，且不能同步账号信息" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
        
    } confirm:^{
        [DataModelInstance shareInstance].userModel = nil;
        [[AppDelegate shareInstance] gotoRegisterGuide];
    }];
}

#pragma mark - UITableViewDelegate/Data
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if([DataModelInstance shareInstance].userModel){
        return self.dataArray.count;
    }else{
        return self.dataArray.count-1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [(NSMutableArray*)self.dataArray[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 5)];
    headerView.backgroundColor = kTableViewBgColor;
    return headerView;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    if (indexPath.row == 0){
        UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [cell.contentView addSubview:lineLabel];
        UILabel *lineLabel1 = [[UILabel alloc]initWithFrame:CGRectMake(16, 49.5, WIDTH - 32, 0.5)];
        lineLabel1.backgroundColor = kCellLineColor;
        [cell.contentView addSubview:lineLabel1];
    }else if (indexPath.row == [(NSArray*)self.dataArray[indexPath.section] count]-1){
        UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 49.5, WIDTH, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [cell.contentView addSubview:lineLabel];
    }else{
        UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 49.5, WIDTH - 32, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [cell.contentView addSubview:lineLabel];
    }
    
    cell.textLabel.textColor = KTextColor;
    cell.textLabel.font = FONT_SYSTEM_SIZE(17);
    cell.textLabel.text = self.dataArray[indexPath.section][indexPath.row];
    if(indexPath.section == 1 ||(indexPath.section == 2 && indexPath.row < 2)||indexPath.section == 0){
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-24, 17, 9, 16)];
        arrowImageView.image = kImageWithName(@"icon_next_gray");
        [cell.contentView addSubview:arrowImageView];
    }
    if(indexPath.section == 2 && indexPath.row == 2){
        CGFloat size =  ([[SDImageCache sharedImageCache] getSize]/1024.0f);
        size = size/1024.0f;
        NSString *str = [NSString stringWithFormat:@"%.2fM",size];
        UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(WIDTH-76, 16, 60, 15)];
        sizeLabel.textAlignment = NSTextAlignmentRight;
        sizeLabel.text = str;
        sizeLabel.textColor = HEX_COLOR(@"41464E");
        sizeLabel.font = FONT_SYSTEM_SIZE(17);
        [cell.contentView addSubview:sizeLabel];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.isBack = NO;
    if(indexPath.section == 0){
        if (indexPath.row == 0){
            AccountViewController *account = [[AccountViewController alloc]init];
            [self.navigationController pushViewController:account animated:YES];
        }else if (indexPath.row == 1){
            NotSetController *notice = [[NotSetController alloc]init];
            [self.navigationController pushViewController:notice animated:YES];
        }else if(indexPath.row == 2){
            InterestBusinessController *vc = [[InterestBusinessController alloc] init];
            vc.isShowBack = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }else if(indexPath.row == 3){
            PrivacySettingController *vc = [[PrivacySettingController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            if(![[NSUserDefaults standardUserDefaults] boolForKey:NotFirstVisitingPhoneBook]){
                VisitPhoneBookView *view = [CommonMethod getViewFromNib:@"VisitPhoneBookView"];
                view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
                view.visitPhoneBookViewResult = ^(BOOL result){
                    if(result){
                        SynchronizationPhoneCtr *vc = [[SynchronizationPhoneCtr alloc] init];
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                };
                [[UIApplication sharedApplication].keyWindow addSubview:view];
            }else{
                SynchronizationPhoneCtr *vc = [[SynchronizationPhoneCtr alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }else{
            ShareNormalView *shareView = [CommonMethod getViewFromNib:@"ShareNormalViewFour"];
            shareView.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
            shareView.foureLabel.text = @"短信";
            shareView.fourImageView.image = kImageWithName(@"btn_pop_sns");
            @weakify(self);
            shareView.shareIndex = ^(NSInteger index){
                @strongify(self);
                if (index == 2) {
                    [self showMessageView:[NSArray new] title:[NSString stringWithFormat:@"我在使用“3号圈”，真实的金融人脉拓展平台，你也来试试吧:%@",DownloadUrl]];
                }else if(index==3){
                    UIPasteboard *paste = [UIPasteboard generalPasteboard];
                    [paste setString:DownloadUrl];
                    [MBProgressHUD showSuccess:@"复制成功" toView:self.view];
                }else{
                    [self firendClickWX:index];
                }
            };
            [[UIApplication sharedApplication].keyWindow addSubview:shareView];
            [shareView showShareNormalView];
        }
    }else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            AboutOurController *vc = [[AboutOurController alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (indexPath.row == 1) {
            AdviceViewController * advice = [[AdviceViewController alloc]init];
            [self.navigationController pushViewController:advice animated:YES];
        }else{
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"是否要清空缓存？" message:@"草稿、离线内容均会被清除" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
            } confirm:^{
                [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
                    
                }];
                [self.tableView reloadData];
            }];
        }
      
    }
}

#pragma mark ----------分享 ---
- (void)firendClickWX:(NSInteger)index{
    NSString *content = @"靠谱的金融人脉拓展平台！";
    NSString *title = @"我正在使用“3号圈”拓展金融人脉！推荐你来看看。";
    UIImage *imageSource = kImageWithName(@"icon-60");
    
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMSocialPlatformType shareType;
    if (index == 0) {
        shareType = UMSocialPlatformType_WechatSession;
    }else{
        shareType = UMSocialPlatformType_WechatTimeLine;
    }
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:content thumImage:imageSource];
    shareObject.webpageUrl = DownloadUrl;
    messageObject.shareObject = shareObject;
    [[UMSocialManager defaultManager] shareToPlatform:shareType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.sideMenuViewController hideMenuViewController];
    });
}

//去掉UItableview headerview黏性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 10;//section的高度
    
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0)
    {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight)
    {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

@end
