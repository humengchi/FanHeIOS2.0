//
//  CardDetailViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/17.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "CardDetailViewController.h"
#import "MenuView.h"
#import "EditCardViewController.h"
#import "WebViewController.h"
#import "CardGroupViewController.h"
#import "RichTextViewController.h"
#import "ShareNormalView.h"
#import "ChoiceFriendViewController.h"
#import <AddressBook/AddressBook.h>
#import "ChatViewController.h"
#import "NewAddFriendController.h"


#define ShowIconImageStr @"ShowIconImageStr"

@interface CardDetailViewController ()

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *rightBtn;
@property (nonatomic, weak) IBOutlet UIButton *myShareBtn;
@property (nonatomic, weak) IBOutlet UIButton *taInviteBtn;
@property (nonatomic, weak) IBOutlet UIButton *taShareBtn;

@property (nonatomic, strong) MenuView *menuView;
@property (nonatomic, assign) BOOL menuShow;

@property (nonatomic, strong) CardScanModel *model;

@end

@implementation CardDetailViewController

// 作用：拦截手势触发
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if(self.menuShow){
        self.menuShow = NO;
        [self.menuView showMenuWithAnimation:self.menuShow];
        self.menuView = nil;
    }
    if (self.navigationController.childViewControllers.count == 1){
        return NO;
    }
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self getCardDtailHttpData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    
    [self initGroupedTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.separatorColor = kCellLineColor;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 42, 0, 16);
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)createParams{
    BOOL isOtherCard = self.model.user_id.integerValue != [DataModelInstance shareInstance].userModel.userId.integerValue;
    self.titleLabel.text = self.model.name;
    if(self.model.ismycard.integerValue){
        [self.rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [self.rightBtn setImage:nil forState:UIControlStateNormal];
        self.myShareBtn.hidden = NO;
        self.taShareBtn.hidden = YES;
        self.taInviteBtn.hidden = YES;
        if(self.model.btn.integerValue==1){
            [self.taInviteBtn setTitle:@"邀请好友" forState:UIControlStateNormal];
        }else if(self.model.btn.integerValue==2){
            [self.taInviteBtn setTitle:@"添加好友" forState:UIControlStateNormal];
        }else{
            [self.taInviteBtn setTitle:@"发消息" forState:UIControlStateNormal];
        }
    }else{
        [self.rightBtn setImage:kImageWithName(@"btn_tab_more") forState:UIControlStateNormal];
        self.myShareBtn.hidden = YES;
        self.taShareBtn.hidden = NO;
        self.taInviteBtn.hidden = NO;
    }
    self.tableView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64-55);
    if(isOtherCard){
        self.rightBtn.hidden = YES;
        self.myShareBtn.hidden = NO;
        self.taShareBtn.hidden = YES;
        self.taInviteBtn.hidden = YES;
        [self.myShareBtn setTitle:@"添加" forState:UIControlStateNormal];
    }
    
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 213*WIDTH/375.0)];
    [headerImageView sd_setImageWithURL:[NSURL URLWithString:self.model.imgurl] placeholderImage:KWidthImageDefault];
    headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    headerImageView.clipsToBounds = YES;
    self.tableView.tableHeaderView = headerImageView;
    
    [self.dataArray removeAllObjects];
    NSInteger showIconImageIndex = 0;
    if([CommonMethod paramStringIsNull:self.model.name].length){
        [self.dataArray addObject:[NSMutableArray arrayWithObject:@{@"name":[self.model.name stringByAppendingString:ShowIconImageStr]}]];
    }
    if(self.model.ismycard.integerValue==0 && !isOtherCard){
        //分组
        [self.dataArray addObject:[NSMutableArray arrayWithObject:@{@"groups":[[self.model.groups componentsJoinedByString:@","] stringByAppendingString:ShowIconImageStr]}]];
        //备注
        [self.dataArray addObject:[NSMutableArray arrayWithObject:@{@"remark":[self.model.remark stringByAppendingString:ShowIconImageStr]}]];
    }
    if(!isOtherCard){
        NSMutableArray *phoneArray = [NSMutableArray array];
        if([CommonMethod paramStringIsNull:self.model.phone].length){
            [phoneArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"phone":[self.model.phone stringByAppendingString:ShowIconImageStr]}]];
            showIconImageIndex++;
        }
        for(NSString *jobphone in self.model.jobphone){
            if(showIconImageIndex==0){
                [phoneArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"jobphone":[CommonMethod paramStringIsNull:[jobphone stringByAppendingString:ShowIconImageStr]]}]];
            }else{
                [phoneArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"jobphone":[CommonMethod paramStringIsNull:jobphone]}]];
            }
            showIconImageIndex++;
        }
        for(NSString *fax in self.model.fax){
            [phoneArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"fax":[CommonMethod paramStringIsNull:fax]}]];
        }
        if(phoneArray.count){
            [self.dataArray addObject:phoneArray];
        }
    }
    showIconImageIndex = 0;
    NSMutableArray *companyArray = [NSMutableArray array];
    for(NSString *company in self.model.company){
        if(showIconImageIndex==0){
            [companyArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"company":[CommonMethod paramStringIsNull:[company stringByAppendingString:ShowIconImageStr]]}]];
        }else{
            [companyArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"company":[CommonMethod paramStringIsNull:company]}]];
        }
        showIconImageIndex++;
    }
    if(companyArray.count){
        [self.dataArray addObject:companyArray];
    }
    
    if(!isOtherCard){
        showIconImageIndex = 0;
        NSMutableArray *moreInfoArray = [NSMutableArray array];
        for(NSString *email in self.model.email){
            if(showIconImageIndex==0){
                [moreInfoArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"email":[CommonMethod paramStringIsNull:[email stringByAppendingString:ShowIconImageStr]]}]];
            }else{
                [moreInfoArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"email":[CommonMethod paramStringIsNull:email]}]];
            }
            showIconImageIndex++;
        }
        showIconImageIndex = 0;
        for(NSString *website in self.model.website){
            if(showIconImageIndex==0){
                [moreInfoArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"website":[CommonMethod paramStringIsNull:[website stringByAppendingString:ShowIconImageStr]]}]];
            }else{
                [moreInfoArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"website":[CommonMethod paramStringIsNull:website]}]];
            }
            showIconImageIndex++;
        }
        showIconImageIndex = 0;
        for(NSString *address in self.model.address){
            if(showIconImageIndex==0){
                [moreInfoArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"address":[CommonMethod paramStringIsNull:[address stringByAppendingString:ShowIconImageStr]]}]];
            }else{
                [moreInfoArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"address":[CommonMethod paramStringIsNull:address]}]];
            }
            showIconImageIndex++;
        }
        showIconImageIndex = 0;
        for(NSString *qq in self.model.qq){
            if(showIconImageIndex==0){
                [moreInfoArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"qq":[CommonMethod paramStringIsNull:[qq stringByAppendingString:ShowIconImageStr]]}]];
            }else{
                [moreInfoArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"qq":[CommonMethod paramStringIsNull:qq]}]];
            }
            showIconImageIndex++;
        }
        showIconImageIndex = 0;
        for(NSString *wx in self.model.wx){
            if(showIconImageIndex==0){
                [moreInfoArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"wx":[CommonMethod paramStringIsNull:[wx stringByAppendingString:ShowIconImageStr]]}]];
            }else{
                [moreInfoArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"wx":[CommonMethod paramStringIsNull:wx]}]];
            }
            showIconImageIndex++;
        }
        if([CommonMethod paramStringIsNull:self.model.birthday].length){
            [moreInfoArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"birthday":[self.model.birthday stringByAppendingString:ShowIconImageStr]}]];
        }
        if(moreInfoArray.count){
            [self.dataArray addObject:moreInfoArray];
        }
    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 名片详情
- (void)getCardDtailHttpData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud;
    if(!self.model){
        hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    }
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", [DataModelInstance shareInstance].userModel.userId, self.cardId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_USER_CARDDETAIL paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *dict = [CommonMethod paramDictIsNull:[responseObject objectForKey:@"data"]];
            weakSelf.model = [[CardScanModel alloc] initWithDict:dict];
            [weakSelf createParams];
        }else{
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud){
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - 删除名片
- (void)deleteCardHttpData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"删除中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", [DataModelInstance shareInstance].userModel.userId, self.model.cardId] forKey:@"param"];
    [self requstType:RequestType_Delete apiName:API_NAME_DELETE_USER_DELCARD paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"删除成功" toView:weakSelf.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }else{
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - 保存分享的名片
- (void)saveShareCardHttpData{
    if([CommonMethod paramNumberIsNull:self.model.cardId].integerValue==0){
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"保存中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.model.cardId forKey:@"cardid"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_USER_ADDSHARECARD paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"保存成功" toView:weakSelf.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        }else{
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - method
- (IBAction)navBackButtonClicked:(id)sender{
    if(self.menuShow){
        self.menuShow = NO;
        [self.menuView showMenuWithAnimation:self.menuShow];
        self.menuView = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)rightButtonClicked:(id)sender{
    if(self.model.ismycard.integerValue){
        EditCardViewController *vc = [CommonMethod getVCFromNib:[EditCardViewController class]];
        vc.model = self.model;
        vc.isEdit = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        _menuShow = !_menuShow;
        [self.menuView showMenuWithAnimation:_menuShow];
        if(_menuShow==NO){
            self.menuView = nil;
        }
    }
}

- (IBAction)shareButtonClicked:(id)sender{
    if(self.model.user_id.integerValue != [DataModelInstance shareInstance].userModel.userId.integerValue){
        [self saveShareCardHttpData];
    }else{
        ShareNormalView *shareView = [CommonMethod getViewFromNib:@"ShareNormalViewFour"];
        shareView.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        @weakify(self);
        shareView.shareIndex = ^(NSInteger index){
            @strongify(self);
            if (index == 2) {
                ChoiceFriendViewController *choseCtr = [CommonMethod getVCFromNib:[ChoiceFriendViewController class]];
                choseCtr.cardModel = self.model;
                [self.navigationController pushViewController:choseCtr animated:YES];
            }else if(index==3){
                UIPasteboard *paste = [UIPasteboard generalPasteboard];
                [paste setString:[NSString stringWithFormat:@"%@/%@",ShareCardUrl, self.model.cardId]];
                [MBProgressHUD showSuccess:@"复制成功" toView:self.view];
            }else{
                [self firendClickWX:index];
            }
        };
        [[UIApplication sharedApplication].keyWindow addSubview:shareView];
        [shareView showShareNormalView];
    }
}

- (IBAction)inviteButtonClicked:(id)sender{
    if(self.model.btn.integerValue==1){//邀请好友
        NSString *title = [NSString stringWithFormat:@"我正在使用“3号圈”拓展金融人脉！推荐你来看看【%@】", DownloadUrl];
        [self showMessageView:@[self.model.phone] title:title];
    }else if(self.model.btn.integerValue==2){//添加好友
        NewAddFriendController *vc = [[NewAddFriendController alloc] init];
        vc.userID = self.model.otherid;
        vc.realname = self.model.name;
        [self.navigationController pushViewController:vc animated:YES];
    }else{//发消息
        NSString *chartId = [NSString stringWithFormat:@"%@",self.model.otherid];
        ChatViewController *chatVC = [[ChatViewController alloc]initWithConversationChatter:chartId conversationType:EMConversationTypeChat];
        chatVC.title = self.model.name;
        NSMutableString *str = [NSMutableString string];
        if(self.model.company.count){
            [str appendString:self.model.company.firstObject];
        }
        if(self.model.position.count){
            [str appendString:self.model.position.firstObject];
        }
        chatVC.position = str;
        chatVC.phoneNumber = self.model.phone;
        chatVC.pushIndex = 888;
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

#pragma mark ----------分享 ---
- (void)firendClickWX:(NSInteger)index{
    NSString *title = [NSString stringWithFormat:@"%@的名片", self.model.name];
    NSMutableString *content = [NSMutableString string];
    if(self.model.company.count){
        [content appendString:self.model.company.firstObject];
        [content appendString:@" "];
    }
    if(self.model.company.count){
        [content appendString:self.model.position.firstObject];
    }
    UIImage *imageSource = kImageWithName(@"icon-60");
    
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMSocialPlatformType shareType;
    if (index == 0) {
        shareType = UMSocialPlatformType_WechatSession;
    }else{
        shareType = UMSocialPlatformType_WechatTimeLine;
    }
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:content thumImage:imageSource];
    shareObject.webpageUrl = [NSString stringWithFormat:@"%@/%@",ShareCardUrl, self.model.cardId];
    messageObject.shareObject = shareObject;
    [[UMSocialManager defaultManager] shareToPlatform:shareType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
    }];
}

#pragma mark -保存至通讯录
- (void)addToContact{
    //创建一条空的联系人
    ABRecordRef record = ABPersonCreate();
    CFErrorRef error;
    //姓名
    ABRecordSetValue(record, kABPersonFirstNameProperty, (__bridge CFTypeRef)self.model.name, &error);
    //手机号
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)self.model.phone,kABPersonPhoneIPhoneLabel, NULL);
    //工作电话
    for(NSString *str in self.model.jobphone){
        ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)str, (__bridge CFStringRef)@"工作电话", NULL);
    }
    //传真
    for(NSString *str in self.model.fax){
        ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)str,kABPersonPhoneWorkFAXLabel, NULL);
    }
    ABRecordSetValue(record, kABPersonPhoneProperty, multi, &error);
    
    //公司
    if(self.model.company.count){
        ABRecordSetValue(record, kABPersonOrganizationProperty, (__bridge CFTypeRef)[self.model.company componentsJoinedByString:@"  "], &error);
    }
    //职位
    if(self.model.position.count){
        ABRecordSetValue(record, kABPersonOrganizationProperty, (__bridge CFTypeRef)[self.model.position componentsJoinedByString:@"  "], &error);
    }
    //邮箱
    if(self.model.email.count){
        multi = ABMultiValueCreateMutable(kABPersonEmailProperty);
        for(NSString *str in self.model.email){
            ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)str, (__bridge CFStringRef)@"邮箱", NULL);
        }
        ABRecordSetValue(record, kABPersonEmailProperty, multi, &error);
    }
    
    //网址
    if(self.model.website.count){
        multi = ABMultiValueCreateMutable(kABPersonURLProperty);
        for(NSString *str in self.model.website){
            ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)str,(__bridge CFStringRef)@"网页", NULL);
        }
        ABRecordSetValue(record, kABPersonURLProperty, multi, &error);
    }
    //地址
    if(self.model.address.count){
        multi = ABMultiValueCreateMutable(kABPersonAddressProperty);
        for(NSString *str in self.model.address){
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:str forKey:(NSString*)kABPersonAddressStreetKey];
            ABMultiValueAddValueAndLabel(multi, (__bridge CFDictionaryRef)dict,(__bridge CFStringRef)@"地址", NULL);
        }
        ABRecordSetValue(record, kABPersonAddressProperty, multi, &error);
    }
    //qq、wx
    if(self.model.qq.count || self.model.wx.count){
        //qq
        multi = ABMultiValueCreateMutable(kABPersonInstantMessageProperty);
        for(NSString *str in self.model.qq){
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:@"QQ" forKey:(NSString*)kABPersonInstantMessageServiceKey];
            [dict setValue:str forKey:(NSString*)kABPersonInstantMessageUsernameKey];
            ABMultiValueAddValueAndLabel(multi, (__bridge CFDictionaryRef)dict,(__bridge CFStringRef)@"QQ", NULL);
        }
        //wx
        for(NSString *str in self.model.wx){
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:@"微信" forKey:(NSString*)kABPersonInstantMessageServiceKey];
            [dict setValue:str forKey:(NSString*)kABPersonInstantMessageUsernameKey];
            ABMultiValueAddValueAndLabel(multi, (__bridge CFDictionaryRef)dict,(__bridge CFStringRef)@"微信", NULL);
        }
        ABRecordSetValue(record, kABPersonInstantMessageProperty, multi, &error);
    }
    
    if(self.model.birthday.length){
        ABRecordSetValue(record, kABPersonBirthdayProperty, (__bridge CFDateRef)[NSDate dateFromString:self.model.birthday format:kShortTimeFormat], &error);
    }
    
    ABAddressBookRef addressBook = nil;
    addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    //等待同意后向下执行
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error){
        dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    if (!addressBook){
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"无法访问通讯录" message:@"请在设置中打开通讯录权限，以保存联系人到手机通讯录" cancelButtonTitle:@"取消" otherButtonTitle:@"去设置" cancle:^{
            
        } confirm:^{
            if(IOS_X >= 10){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
            }
        }];
        return;
    }
    // 将新建联系人记录添加如通讯录中
    BOOL success = ABAddressBookAddRecord(addressBook, record, &error);
    if (!success) {
        [MBProgressHUD showError:@"保存失败，请重试" toView:self.view];
    }else{
        // 如果添加记录成功，保存更新到通讯录数据库中
        success = ABAddressBookSave(addressBook, &error);
        [MBProgressHUD showSuccess:@"保存成功" toView:self.view];
    }
}

//弹出下拉菜单
- (MenuView *)menuView{
    if (!_menuView) {
        NSArray *dataArray = @[@{@"itemName" : @"保存至通讯录", @"imageName":@""},@{@"itemName" : @"编辑", @"imageName":@""},@{@"itemName" : @"添加备注", @"imageName":@""},@{@"itemName" : @"删除", @"imageName":@""}];
        
        __weak typeof(self) weakSelf = self;
        _menuView = [MenuView createMenuWithFrame:CGRectMake(0, 0, 150, dataArray.count * 40) target:self dataArray:dataArray itemsClickBlock:^(NSString *str, NSInteger tag) {
            if(tag==0){
                [self addToContact];
            }else if(tag==1){
                EditCardViewController *vc = [CommonMethod getVCFromNib:[EditCardViewController class]];
                vc.model = self.model;
                vc.isEdit = YES;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }else if(tag==2){
                RichTextViewController *vc = [CommonMethod getVCFromNib:[RichTextViewController class]];
                vc.isCard = YES;
                vc.cardModel = self.model;
                [weakSelf presentViewController:vc animated: YES completion:nil];
            }else{
                [[[CommonUIAlert alloc] init] showCommonAlertView:weakSelf title:@"" message:@"是否删除该名片" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
                } confirm:^{
                    [weakSelf deleteCardHttpData];
                }];
            }
            _menuShow = NO;
            _menuView = nil;
        } backViewTap:^{
            _menuShow = NO;
            _menuView = nil;
        }];
    }
    return _menuView;
}


#pragma mark - UITableViewDelegate/datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *array = self.dataArray[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.000001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 10)];
    footerView.backgroundColor = kTableViewBgColor;
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *array = self.dataArray[indexPath.section];
    NSDictionary *dict = array[indexPath.row];
    NSString *keyStr = dict.allKeys[0];
    NSString *valueStr = [dict objectForKey:keyStr];
    CGFloat width = WIDTH-58;
    if([keyStr isEqualToString:@"remark"]){
        width = WIDTH-68;
    }
    CGFloat height = [NSHelper heightOfString:[valueStr stringByReplacingOccurrencesOfString:ShowIconImageStr withString:@""] font:FONT_SYSTEM_SIZE(17) width:width defaultHeight:FONT_SYSTEM_SIZE(17).lineHeight];
    if([keyStr isEqualToString:@"company"]){
        if([valueStr containsString:ShowIconImageStr]){
            height += 26;
        }
        if(self.model.position.count>indexPath.row){
            height += 20;
        }
        return height+32;
    }else if([keyStr isEqualToString:@"name"]||[keyStr isEqualToString:@"groups"]||[keyStr isEqualToString:@"remark"]){
        return height+32;
    }else{
        return height+47;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    NSMutableArray *array = self.dataArray[indexPath.section];
    NSDictionary *dict = array[indexPath.row];
    NSString *keyStr = dict.allKeys[0];
    NSString *valueStr = [dict objectForKey:keyStr];
    CGFloat width = WIDTH-58;
    if([keyStr isEqualToString:@"remark"]){
        width = WIDTH-68;
    }
    CGFloat height = [NSHelper heightOfString:[valueStr stringByReplacingOccurrencesOfString:ShowIconImageStr withString:@""] font:FONT_SYSTEM_SIZE(17) width:width defaultHeight:FONT_SYSTEM_SIZE(17).lineHeight];
    if([valueStr containsString:ShowIconImageStr]){
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 18, 17, 17)];
        iconImageView.image = kImageWithName([self getIconImageByType:keyStr needType:NO]);
        iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:iconImageView];
    }
    UILabel *valueLabel = [UILabel createLabel:CGRectMake(42, 16, width, (NSInteger)height+1) font:FONT_SYSTEM_SIZE(17) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e")];
    valueLabel.numberOfLines = 0;
    valueLabel.text = [valueStr stringByReplacingOccurrencesOfString:ShowIconImageStr withString:@""];
    [cell.contentView addSubview:valueLabel];
    if([keyStr isEqualToString:@"company"]){
        CGFloat start_Y = 16;
        if([valueStr containsString:ShowIconImageStr]){
            UILabel *titleLabel = [UILabel createLabel:CGRectMake(42, 16, WIDTH-58, 18) font:FONT_SYSTEM_SIZE(17) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e")];
            titleLabel.text = @"公司";
            [cell.contentView addSubview:titleLabel];
            start_Y = 42;
        }
        valueLabel.frame = CGRectMake(42, start_Y, WIDTH-58, (NSInteger)height+1);
        start_Y += (NSInteger)height+7;
        if(self.model.position.count>indexPath.row){
            UILabel *positionLabel = [UILabel createLabel:CGRectMake(42, start_Y, WIDTH-58, 15) font:FONT_SYSTEM_SIZE(14) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e")];
            positionLabel.text = self.model.position[indexPath.row];
            [cell.contentView addSubview:positionLabel];
        }
    }else if([keyStr isEqualToString:@"name"]){
    }else if([keyStr isEqualToString:@"groups"]){
        if(![valueStr stringByReplacingOccurrencesOfString:ShowIconImageStr withString:@""].length){
            valueLabel.text = @"未分组";
        }
    }else if([keyStr isEqualToString:@"remark"]){
        if(![valueStr stringByReplacingOccurrencesOfString:ShowIconImageStr withString:@""].length){
            valueLabel.text = @"未备注";
        }
        UIImageView *nextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-25, (height+32)/2-7, 9, 15)];
        nextImageView.image = kImageWithName(@"icon_next_gray");
        [cell.contentView addSubview:nextImageView];
    }else{
        UILabel *typeLabel = [UILabel createLabel:CGRectMake(42, (NSInteger)height+23, 75, 11) font:FONT_SYSTEM_SIZE(10) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e")];
        typeLabel.text = [self getIconImageByType:keyStr needType:YES];
        [cell.contentView addSubview:typeLabel];
    }
    if([keyStr isEqualToString:@"phone"]){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(WIDTH-46, 0, 30, 49);
        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        btn.tag = 1000*indexPath.section+indexPath.row;
        [btn addTarget:self action:@selector(takePhone:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:kImageWithName(@"btn_mpd_message") forState:UIControlStateNormal];
        [cell.contentView addSubview:btn];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableArray *array = self.dataArray[indexPath.section];
    NSDictionary *dict = array[indexPath.row];
    NSString *keyStr = dict.allKeys[0];
    NSString *valueStr = [dict objectForKey:keyStr];
    valueStr = [valueStr stringByReplacingOccurrencesOfString:ShowIconImageStr withString:@""];
    if([keyStr isEqualToString:@"phone"] || [keyStr isEqualToString:@"jobphone"]){
        NSString *str = [NSString stringWithFormat:@"tel:%@",valueStr];
        UIWebView *callWebView = [[UIWebView alloc]init];
        [callWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self.view addSubview:callWebView];
    }else if([keyStr isEqualToString:@"email"] || [keyStr isEqualToString:@"qq"] || [keyStr isEqualToString:@"wx"]){
        UIPasteboard *paste = [UIPasteboard generalPasteboard];
        [paste setString:valueStr];
        [MBProgressHUD showSuccess:@"复制成功" toView:self.view];
    }else if([keyStr isEqualToString:@"website"]){
        WebViewController *vc = [[WebViewController alloc] init];
        vc.customTitle = @" ";
        vc.webUrl = valueStr;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([keyStr isEqualToString:@"groups"]){
        CardGroupViewController *vc = [CommonMethod getVCFromNib:[CardGroupViewController class]];
        vc.isShowGroupList = NO;
        vc.model = self.model;
        [self.navigationController pushViewController:vc animated:YES];
    }else if([keyStr isEqualToString:@"remark"]){
        RichTextViewController *vc = [CommonMethod getVCFromNib:[RichTextViewController class]];
        vc.isCard = YES;
        vc.cardModel = self.model;
        [self presentViewController:vc animated: YES completion:nil];
    }else if([keyStr isEqualToString:@"address"]){
    }
}

- (void)takePhone:(UIButton*)sender{
    NSInteger section = sender.tag/1000;
    NSInteger row = sender.tag%1000;
    NSMutableArray *array = self.dataArray[section];
    NSDictionary *dict = array[row];
    NSString *keyStr = dict.allKeys[0];
    NSString *valueStr = [dict[keyStr] stringByReplacingOccurrencesOfString:ShowIconImageStr withString:@""];
    [self showMessageView:@[valueStr] title:@""];
}

- (NSString*)getIconImageByType:(NSString*)keyStr needType:(BOOL)isKeyStrChinese;{
    NSString *iconStr = @"";
    NSString *keyStrChinese = @"";
    if([keyStr isEqualToString:@"name"]){
        iconStr = @"icon_mpd_name";
        keyStrChinese = @"姓名";
    }else if([keyStr isEqualToString:@"groups"]){
        iconStr = @"icon_mpd_fenzu";
        keyStrChinese = @"分组";
    }else if([keyStr isEqualToString:@"remark"]){
        iconStr = @"icon_mpd_beizhu";
        keyStrChinese = @"备注";
    }else if([keyStr isEqualToString:@"phone"]){
        iconStr = @"icon_mpd_tele";
        keyStrChinese = @"手机";
    }else if([keyStr isEqualToString:@"jobphone"]){
        iconStr = @"icon_mpd_tele";
        keyStrChinese = @"工作电话";
    }else if([keyStr isEqualToString:@"fax"]){
        iconStr = @"icon_mpd_tele";
        keyStrChinese = @"工作传真";
    }else if([keyStr isEqualToString:@"email"]){
        iconStr = @"icon_mpd_email";
        keyStrChinese = @"邮箱";
    }else if([keyStr isEqualToString:@"company"]){
        iconStr = @"icon_mpd_gszw";
        keyStrChinese = @"公司";
    }else if([keyStr isEqualToString:@"position"]){
        iconStr = @"职位";
        keyStrChinese = @"职位";
    }else if([keyStr isEqualToString:@"website"]){
        iconStr = @"icon_mpd_link";
        keyStrChinese = @"公司网站";
    }else if([keyStr isEqualToString:@"address"]){
        iconStr = @"icon_mpd_add";
        keyStrChinese = @"地址";
    }else if([keyStr isEqualToString:@"birthday"]){
        iconStr = @"icon_mpd_birthday";
        keyStrChinese = @"生日";
    }else if([keyStr isEqualToString:@"qq"]){
        iconStr = @"icon_mpd_qq";
        keyStrChinese = @"QQ";
    }else if([keyStr isEqualToString:@"wx"]){
        iconStr = @"icon_mpd_weixin";
        keyStrChinese = @"微信";
    }
    if(isKeyStrChinese){
        return keyStrChinese;
    }else{
        return iconStr;
    }
}

@end
