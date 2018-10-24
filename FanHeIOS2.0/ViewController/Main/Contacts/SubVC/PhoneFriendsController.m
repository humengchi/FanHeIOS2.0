



//
//  PhoneFriendsController.m
//  JinMai
//
//  Created by renhao on 16/5/20.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "PhoneFriendsController.h"
#import <AddressBook/AddressBook.h>
#import "UITableSectionIndexView.h"
#import "AddFriendsCell.h"
#import "NewAddFriendController.h"
#import <MessageUI/MessageUI.h>
#import "EditPersonalInfoViewController.h"
#import "NODataTableViewCell.h"
#import "VisitPhoneBookView.h"

@interface PhoneFriendsController ()<UITableSectionIndexViewDelegate, AddFriendsCellDelegate>{
    BOOL _handScrollView;//手动滑动
}

@property (nonatomic ,strong)  NSMutableArray *phoneNumberArray;
@property (nonatomic ,strong)  NSMutableArray *showArray;

@property (nonatomic, strong) UITableSectionIndexView *sectionIndexView;
@end

@implementation PhoneFriendsController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:NotFirstVisitingPhoneBook]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:NotFirstVisitingPhoneBook];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self getPhoneNumberArray];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"手机联系人"];
    self.view.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    self.phoneNumberArray = [NSMutableArray array];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = HEX_COLOR(@"F7F7F7");
    self.sectionIndexView = [[UITableSectionIndexView alloc] initWithFrame:CGRectMake(WIDTH-20, 64, 15, HEIGHT-64) sectionArray:self.showArray];
    self.sectionIndexView.delegate = self;
    [self.view addSubview:self.sectionIndexView];
}

//获取电话联系人
- (void)getPhoneNumberArray{
    if(self.phoneNumberArray){
        [self.phoneNumberArray removeAllObjects];
    }
    //这个变量用于记录授权是否成功，即用户是否允许我们访问通讯录
    int __block tip=0;
    ABAddressBookRef addressBooks = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0){
        addressBooks =  ABAddressBookCreateWithOptions(NULL, NULL);
        //获取通讯录权限
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBooks, ^(bool granted, CFErrorRef error){
            //greanted为YES是表示用户允许，否则为不允许
            if (!granted) {
                tip=1;
            }
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }else{
        addressBooks = ABAddressBookCreate();
    }
    if(tip){
        VisitPhoneBookView *view = [CommonMethod getViewFromNib:@"VisitPhoneBookView"];
        view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        view.subTitleLabel.text = @"请在手机 “设置>隐私>通讯录” 中找到“3号圈”，点亮右侧按钮。";
        view.subTitleLabel.font = FONT_SYSTEM_SIZE(15);
        [view.clickedBtn setTitle:@"立即设置" forState:UIControlStateNormal];
        view.visitPhoneBookViewResult = ^(BOOL result){
            if(result){
                if(IOS_X >= 10){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }else{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
                }
            }else{
            }
        };
        [[UIApplication sharedApplication].keyWindow addSubview:view];
        self.showArray = [NSMutableArray array];
        [self.tableView reloadData];
        return;
    }
    //获取通讯录中的所有人
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBooks);
    //通讯录中人数
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBooks);
    
    //循环，获取每个人的个人信息
    for (NSInteger i = 0; i < nPeople; i++){
        //新建一个addressBook model类
        ChartModel *addressBook = [[ChartModel alloc] init];
        //获取个人
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        //获取个人名字
        CFTypeRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        CFTypeRef abLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
        CFStringRef abFullName = ABRecordCopyCompositeName(person);
        NSString *nameString = (__bridge NSString *)abName;
        NSString *lastNameString = (__bridge NSString *)abLastName;
        
        if ((__bridge id)abFullName != nil) {
            nameString = (__bridge NSString *)abFullName;
        }else{
            if((__bridge id)abLastName != nil){
                nameString = [NSString stringWithFormat:@"%@ %@", nameString, lastNameString];
            }
        }
        addressBook.realname = [NSString stringWithFormat:@"%@",nameString];
//                addressBook.recordID = (int)ABRecordGetRecordID(person);;
        if(nameString == nil || nameString.length == 0){
            continue;
        }
        ABPropertyID multiProperties[] = {
            kABPersonPhoneProperty,
            kABPersonEmailProperty
        };
        NSInteger multiPropertiesTotal = sizeof(multiProperties) / sizeof(ABPropertyID);
        for (NSInteger j = 0; j < multiPropertiesTotal; j++) {
            ABPropertyID property = multiProperties[j];
            ABMultiValueRef valuesRef = ABRecordCopyValue(person, property);
            NSInteger valuesCount = 0;
            if (valuesRef != nil) valuesCount = ABMultiValueGetCount(valuesRef);
            if (valuesCount == 0) {
                CFRelease(valuesRef);
                continue;
            }
            //获取电话号码和email
            for (NSInteger k = 0; k < valuesCount; k++) {
                CFTypeRef value = ABMultiValueCopyValueAtIndex(valuesRef, k);
                switch (j) {
                    case 0: {// Phone number
                        NSString *phone = (__bridge NSString*)value;
                        phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
                        if([phone hasPrefix:@"+86"]){
                            phone = [phone stringByReplacingOccurrencesOfString:@"+86" withString:@""];
                        }
                        addressBook.phone = phone;
                        break;
                    }
                }
                CFRelease(value);
            }
            CFRelease(valuesRef);
        }
        //将个人信息添加到数组中，循环完成后addressBookTemp中包含所有联系人的信息
        addressBook.status = @(3);
        if([NSHelper justMobile:addressBook.phone]){
            [self.phoneNumberArray addObject:addressBook];
            NSLog(@"%@-%@",addressBook.phone, addressBook.realname);
        }
        
        if (abName) CFRelease(abName);
        if (abLastName) CFRelease(abLastName);
        if (abFullName) CFRelease(abFullName);
    }
    [self getPhoneContactsHttp:self.phoneNumberArray];
}

#pragma mark - 和服务器上的数据对比，获取已注册，和已互换名片的
- (void)getPhoneContactsHttp:(NSMutableArray*)array{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableArray *strArray = [NSMutableArray array];
    for(ChartModel *model in array){
        if(model.phone && model.phone.length){
            [strArray addObject:model.phone];
        }
    }
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[strArray componentsJoinedByString:@","] forKey:@"phones"];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [self requstType:RequestType_Post apiName:API_NAME_USER_GET_PHONEFRIENDSCONECTION paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            NSMutableArray *dataArray = [NSMutableArray array];
            for(NSDictionary *dict in responseObject[@"data"]){
                ChartModel *model = [[ChartModel alloc] initWithDict:dict];
                [dataArray addObject:model];
            }
            [weakSelf sort:weakSelf.phoneNumberArray httpArray:dataArray];
        }else{
            [weakSelf sort:weakSelf.phoneNumberArray httpArray:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf sort:weakSelf.phoneNumberArray httpArray:nil];
    }];
}

//排序
- (void)sort:(NSMutableArray*)array httpArray:(NSMutableArray*)httpArray{
    if(self.showArray){
        [self.showArray removeAllObjects];
    }else{
        self.showArray = [NSMutableArray array];
    }
    NSMutableArray *noExchangeCardArray = [NSMutableArray array];
    NSMutableArray *newContactsArray = [NSMutableArray array];
    if(httpArray && httpArray.count){
        for(ChartModel *httpModel in httpArray){
            if(httpModel.status.integerValue != 2){
                for(ChartModel *address in array){
                    if([httpModel.phone isEqualToString:address.phone]){
                        httpModel.reason = [NSString stringWithFormat:@"%@（%@）", httpModel.realname, address.realname];
                        [noExchangeCardArray addObject:httpModel];
                        break;
                    }
                }
            }
        }
        for(ChartModel *model in array){
            BOOL containt = NO;
            for(ChartModel *httpModel in httpArray){
                if(httpModel.status.integerValue == 2 && [model.phone isEqualToString:httpModel.phone]){
                    [newContactsArray addObject:httpModel];
                    containt = YES;
                    break;
                }
                if([model.phone isEqualToString:httpModel.phone]){
                    containt = YES;
                    break;
                }
            }
            if(containt == NO){
                [newContactsArray addObject:model];
            }
        }
    }else{
        newContactsArray = array;
    }
    char pre = 'A';
    for(int i = 0; i < 26; i++){
        [self filter:[NSString stringWithFormat:@"%C", (unichar)(pre+i)] array:newContactsArray];
    }
    [self filter:@"#" array:newContactsArray];
    if(noExchangeCardArray.count){
        [self.showArray insertObject:@{@"未交换":noExchangeCardArray} atIndex:0];
    }
    if(self.showArray.count){
        [self.tableView reloadData];
        [self.sectionIndexView loadView:self.showArray];
    }
}

- (void)filter:(NSString*)str array:(NSMutableArray*)array{
    NSMutableArray *tempArray = [NSMutableArray array];
    if([str isEqualToString:@"#"]){
        for(ChartModel *model in array){
            if([EaseChineseToPinyin sortSectionTitle:[EaseChineseToPinyin pinyinFromChineseString:model.realname]] == '#'){
                if(model.userid.intValue != [DataModelInstance shareInstance].userModel.userId.intValue){
                    [tempArray addObject:model];
                }
            }
        }
    }else{
        for(ChartModel *model in array){
            if([[[EaseChineseToPinyin pinyinFromChineseString:model.realname] uppercaseString] hasPrefix:str]){
                if(model.userid.intValue != [DataModelInstance shareInstance].userModel.userId.intValue){
                    [tempArray addObject:model];
                }
            }
        }
    }
    if(tempArray.count){
        [self.showArray addObject:@{str:tempArray}];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.showArray.count){
        NSDictionary *dict = self.showArray[section];
        NSArray *array = dict[dict.allKeys[0]];
        return [array count];
    }else{
        return 1;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.showArray.count){
        return 53;
    }else{
        return self.tableView.frame.size.height;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.showArray==nil){
        return 0;
    }else if(self.showArray.count){
        return self.showArray.count;
    }else{
        return 1;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(self.showArray.count){
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 40)];
        headerView.backgroundColor = kTableViewBgColor;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 9, WIDTH-16, 14)];
        label.textColor = HEX_COLOR(@"818C9E");
        label.font = FONT_SYSTEM_SIZE(14);
        [headerView addSubview:label];
        NSDictionary *dic = self.showArray[section];
        label.text = dic.allKeys[0];
        
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
        label2.backgroundColor = kCellLineColor;
        [headerView addSubview:label2];
        
        UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(0, 31.5, WIDTH, 0.5)];
        label3.backgroundColor = kCellLineColor;
        [headerView addSubview:label3];
        
        return headerView;
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.showArray.count){
        return 32;
    }else{
        return 0.00001;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.showArray.count){
        if(indexPath.section == 0){
            NSDictionary *dict = self.showArray[0];
            if([dict.allKeys[0] isEqualToString:@"未交换"]){
                NSMutableArray *array = dict[dict.allKeys[0]];
                ChartModel *model = array[indexPath.row];
                NSString *cellID = @"AddFriendsCell";
                AddFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (!cell){
                    cell = [CommonMethod getViewFromNib:NSStringFromClass([AddFriendsCell class])];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                if(indexPath.row != array.count-1){
                    cell.lineLabel.hidden = NO;
                }else{
                    cell.lineLabel.hidden = YES;
                }
                cell.tag = indexPath.row;
                [cell exchangeAddFriends:model];
                cell.exchangeDelegate = self;
                return cell;
            }
        }
        NSString *cellID = @"cellID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell){
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        
        NSDictionary *dict = self.showArray[indexPath.section];
        NSMutableArray *array = dict[dict.allKeys[0]];
        ChartModel *model = array[indexPath.row];
        if(indexPath.row != array.count-1){
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(16, 52.5, WIDTH-32, 0.5)];
            label.backgroundColor = kCellLineColor;
            [cell.contentView addSubview:label];
        }
        
        UILabel *nameLabel = [UILabel createLabel:CGRectMake(16, 20, WIDTH-32, 14) font:FONT_SYSTEM_SIZE(14) bkColor:[UIColor clearColor] textColor:HEX_COLOR(@"222222")];
        nameLabel.text = model.realname;
        [cell.contentView addSubview:nameLabel];
        
        UIButton *inviteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        inviteBtn.frame = CGRectMake(WIDTH-82, 15, 66, 22);
        [inviteBtn setBackgroundImage:[UIImage imageNamed:@"btn_agree_small"] forState:UIControlStateNormal];
        inviteBtn.titleLabel.font = FONT_SYSTEM_SIZE(14);
        [inviteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        inviteBtn.layer.cornerRadius = 11;
        inviteBtn.layer.masksToBounds = YES;
        inviteBtn.tag = indexPath.row+indexPath.section*1000;
        [inviteBtn addTarget:self action:@selector(inviteFriendClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:inviteBtn];
        [inviteBtn setTitle:@"邀请" forState:UIControlStateNormal];
           return cell;
    }else{
        static NSString *identify = @"NODataTableViewCell";
        NODataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NODataTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.mainLabel.text = @"暂无通讯录获取权限";
        cell.subLabel.text = @"无法查看";
//        cell.subLabel.textColor = kDefaultColor;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(self.showArray.count){
        if(indexPath.section == 0){
            NSDictionary *dict = self.showArray[0];
            if([dict.allKeys[0] isEqualToString:@"未交换"]){
                NSMutableArray *array = dict[dict.allKeys[0]];
                ChartModel *model = array[indexPath.row];
                NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
                vc.userId = model.userid;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }else{
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AddFriendsCellDelegate
- (void)exchangeChatCard:(NSInteger)index{
    if(![CommonMethod getUserCanAddFriend]){
        CompleteUserInfoView *completeUserInfoView = [[CompleteUserInfoView alloc] initWithType:CompleteUserInfoViewType_AddFriend];
        completeUserInfoView.completeUserInfoViewEditInfo = ^(){
            EditPersonalInfoViewController *vc = [[EditPersonalInfoViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        };
        return;
    }
    
    NSDictionary *dict = self.showArray[0];
    NSMutableArray *array = dict[dict.allKeys[0]];
    ChartModel *model = array[index];
    NewAddFriendController *addFriends = [[NewAddFriendController alloc] init];
    addFriends.userID = model.userid;
    __weak typeof(self) weakSelf = self;
    addFriends.exchangeSuccess = ^(BOOL success){
        model.status = @(0);
        [weakSelf.tableView reloadData];
    };
    addFriends.phone = model.phone;
    addFriends.realname = model.realname;
    [self.navigationController pushViewController:addFriends animated:YES];
}

#pragma mark - 邀请好友
- (void)inviteFriendClicked:(UIButton*)sender{
    NSInteger section = sender.tag/1000;
    NSInteger row = sender.tag%1000;
    NSDictionary *dict = self.showArray[section];
    NSMutableArray *array = dict[dict.allKeys[0]];
    ChartModel *model = array[row];
      UserModel *model1 = [DataModelInstance shareInstance].userModel;
    NSString *contentUrl = [NSString stringWithFormat:@"我在使用“3号圈”，真实的金融人脉拓展平台，你也来试试吧:%@%@",InvitFriendRegisterUrl, model1 .userId];
    [self showMessageView:[NSArray arrayWithObjects:model.phone, nil] title:contentUrl];
}

#pragma mark - UITableSectionIndexViewDelegate
- (void)indexViewChangeToIndex:(NSInteger)index{
    _handScrollView = NO;
    // 获取所点目录对应的indexPath值
    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:index];
    // 让table滚动到对应的indexPath位置
    [self.tableView scrollToRowAtIndexPath:selectIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollVie{
    _handScrollView = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView == self.tableView && _handScrollView){
        UITableViewCell *cell = [self.tableView.visibleCells firstObject];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self.sectionIndexView changeBtnIndex:indexPath.section];
    }
}
@end
