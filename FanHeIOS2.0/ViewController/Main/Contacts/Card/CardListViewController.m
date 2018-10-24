//
//  CardListViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/11.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "CardListViewController.h"
#import "NODataTableViewCell.h"
#import "NONetWorkTableViewCell.h"
#import "ScanCameraController.h"
#import "MenuView.h"
#import "VisitPhoneBookView.h"
#import <AddressBook/AddressBook.h>
#import "CardListCell.h"
#import "CardGroupViewController.h"
#import "CardDetailViewController.h"

@interface CardListViewController (){
    BOOL _noNetWork;
    CGRect _choiceBtnFrame;
    NSInteger _sortIndex;
}

@property (nonatomic, strong) NSMutableArray *dataArray;//列表展示
@property (nonatomic, strong) MenuView *menuView;
@property (nonatomic, assign) BOOL menuShow;
@property (nonatomic, strong) NSMutableArray *phoneNumberArray;
@property (nonatomic, strong) UIView *tableHeaderView;

@end

@implementation CardListViewController
// 作用：拦截手势触发
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if(self.menuShow){
        self.menuShow = NO;
        [self.menuView showMenuWithAnimation:self.menuShow];
        self.menuView = nil;
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
    if(self.searchBar.text.length){
        [self getCardListHttpDataBySearchText:self.searchBar.text];
    }else{
        [self getCardListHttpData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"名片列表"];
    _noNetWork = NO;
    _sortIndex = 1;
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self initTableHeaderView];
    
    [self getCardListHttpData];
    return;
    //这个变量用于记录授权是否成功，即用户是否允许我们访问通讯录
    int __block tip = 1;
    //获取通讯录权限
    ABAddressBookRef addressBooks =  ABAddressBookCreateWithOptions(NULL, NULL);
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBooks, ^(bool granted, CFErrorRef error){
        //greanted为YES是表示用户允许，否则为不允许
        if (!granted) {
            tip = 0;
        }
        dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    if(tip){
        [self getContactList:addressBooks];
    }else{
        VisitPhoneBookView *view = [CommonMethod getViewFromNib:@"VisitPhoneBookView"];
        view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        view.subTitleLabel.text = @"智能管理你的联系人和名片信息";
        view.visitPhoneBookViewResult = ^(BOOL result){
            if(result){
                if(IOS_X >= 10){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }else{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
                }
            }
        };
        [[UIApplication sharedApplication].keyWindow addSubview:view];
    }
}

- (void)getContactList:(ABAddressBookRef)addressBooks{
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
//        addressBook.recordID = (int)ABRecordGetRecordID(person);;
        if(nameString == nil || nameString.length == 0){
            continue;
        }
        ABPropertyID multiProperties[] = {
            kABPersonPhoneProperty,
            kABPersonEmailProperty,
            kABPersonBirthdayProperty,
            kABPersonOrganizationProperty,
            kABPersonJobTitleProperty
        };
        NSInteger multiPropertiesTotal = sizeof(multiProperties) / sizeof(ABPropertyID);
        for (NSInteger j = 0; j < multiPropertiesTotal; j++) {
            ABPropertyID property = multiProperties[j];
            ABMultiValueRef valuesRef = ABRecordCopyValue(person, property);
            NSInteger valuesCount = 0;
            if (valuesRef != nil){
                valuesCount = ABMultiValueGetCount(valuesRef);
            }
            //获取电话号码和email
            for (NSInteger k = 0; k < valuesCount; k++) {
                CFTypeRef value = ABMultiValueCopyValueAtIndex(valuesRef, k);
                NSString *valueStr = (__bridge NSString*)value;
                switch (j) {
                    case 0: {// 电话
                        valueStr = [valueStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
                        if([valueStr hasPrefix:@"+86"]){
                            valueStr = [valueStr stringByReplacingOccurrencesOfString:@"+86" withString:@""];
                        }
                        addressBook.phone = valueStr;
                        break;
                    }
                    case 1: {// 邮箱
                        addressBook.letter = valueStr;
                        break;
                    }
                    case 2: {// 生日
                        addressBook.reason = valueStr;
                        break;
                    }
                    case 3: {// 公司
                        addressBook.company = valueStr;
                        break;
                    }
                    case 4: {// 职位
                        addressBook.position = valueStr;
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
        }
        if (abName) CFRelease(abName);
        if (abLastName) CFRelease(abLastName);
        if (abFullName) CFRelease(abFullName);
    }
    [self.tableView reloadData];
}

- (void)initTableHeaderView{
    self.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 55+76*WIDTH/375.0)];
    self.tableHeaderView.clipsToBounds = YES;
    self.tableHeaderView.backgroundColor = kTableViewBgColor;
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 44)];
    self.searchBar.showsCancelButton = NO;
    self.searchBar.returnKeyType = UIReturnKeySearch;
    self.searchBar.enablesReturnKeyAutomatically = YES;
    self.searchBar.delegate = self;
    [self.searchBar setPlaceholder:@"搜索"];
    [self.searchBar setSearchTextPositionAdjustment:UIOffsetMake(5, 0)];
    [self.searchBar setBackgroundColor:HEX_COLOR(@"E6E8EB")];
    [self.searchBar setBackgroundImage:kImageWithColor(HEX_COLOR(@"E6E8EB"), self.searchBar.bounds)];
    [self.searchBar setSearchFieldBackgroundImage:kImageWithName(@"searchBackground") forState:UIControlStateNormal];
    [self.searchBar setSearchFieldBackgroundImage:kImageWithName(@"searchBackground") forState:UIControlStateDisabled];
    [self.tableHeaderView addSubview:self.searchBar];
    
    //buttonviews
    UIButton *carBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    carBtn.backgroundColor = WHITE_COLOR;
    carBtn.frame = CGRectMake(0, 44, WIDTH/2.0, 76*WIDTH/375.0);
    [carBtn addTarget:self action:@selector(cardButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [carBtn setBackgroundImage:kImageWithName(@"btn_mplist_sbmp") forState:UIControlStateNormal];;
    [self.tableHeaderView addSubview:carBtn];

    UILabel *verticalLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(WIDTH/2.0-0.5, 44, 0.5, 76*WIDTH/375.0)];
    verticalLineLabel.backgroundColor = kCellLineColor;
    [self.tableHeaderView addSubview:verticalLineLabel];
    
    UIButton *groupBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    groupBtn.backgroundColor = WHITE_COLOR;
    groupBtn.frame = CGRectMake(WIDTH/2.0, 44, WIDTH/2.0, 76*WIDTH/375.0);
    [groupBtn addTarget:self action:@selector(groupButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [groupBtn setBackgroundImage:kImageWithName(@"btn_mplist_mpfz") forState:UIControlStateNormal];;
    [self.tableHeaderView addSubview:groupBtn];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 44+76*WIDTH/375.0, WIDTH, 11)];
    lineLabel.backgroundColor = kTableViewBgColor;
    [self.tableHeaderView addSubview:lineLabel];
    
    self.tableView.tableHeaderView = self.tableHeaderView;
}

#pragma mark - 获取网络数据
- (void)getCardListHttpData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud;
    if(!self.dataArray){
        hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    }
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld", [DataModelInstance shareInstance].userModel.userId, (long)_sortIndex] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_USER_CARDLIST paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(weakSelf.dataArray == nil){
            weakSelf.dataArray = [NSMutableArray array];
        }else{
            [weakSelf.dataArray removeAllObjects];
        }
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *subArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *subDic in subArray) {
                CardScanModel *model = [[CardScanModel alloc] initWithDict:subDic];
                [weakSelf.dataArray addObject:model];
            }
            if(weakSelf.dataArray.count==0){
                CardScanModel *model = [[CardScanModel alloc] initWithDict:[NSDictionary new]];
                model.ismycard = @(1);
                [weakSelf.dataArray addObject:model];
                
                CardScanModel *model1 = [[CardScanModel alloc] initWithDict:[NSDictionary new]];
                model1.ismycard = @(2);
                [weakSelf.dataArray addObject:model1];
            }else if(weakSelf.dataArray.count==1){
                CardScanModel *model = weakSelf.dataArray.firstObject;
                if(model.ismycard.integerValue == 1){
                    CardScanModel *model1 = [[CardScanModel alloc] initWithDict:[NSDictionary new]];
                    model1.ismycard = @(2);
                    [weakSelf.dataArray addObject:model1];
                }
            }
            if(weakSelf.dataArray.count){
                CardScanModel *model = weakSelf.dataArray.firstObject;
                if(model.ismycard.integerValue != 1){
                    CardScanModel *model1 = [[CardScanModel alloc] initWithDict:[NSDictionary new]];
                    model1.ismycard = @(1);
                    [weakSelf.dataArray insertObject:model1 atIndex:0];
                }
            }
        }
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        if(weakSelf.dataArray == nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - 获取网络数据
- (void)getCardListHttpDataBySearchText:(NSString*)search{
    __weak typeof(self) weakSelf = self;
    if(self.dataArray){
        [self.dataArray removeAllObjects];
        [self.tableView reloadData];
    }
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", [DataModelInstance shareInstance].userModel.userId, search] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_USER_CARDSEARCH paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(weakSelf.dataArray == nil){
            weakSelf.dataArray = [NSMutableArray array];
        }else{
            [weakSelf.dataArray removeAllObjects];
        }
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *subArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            for (NSDictionary *subDic in subArray) {
                CardScanModel *model = [[CardScanModel alloc] initWithDict:subDic];
                [weakSelf.dataArray addObject:model];
            }
        }
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        if(weakSelf.dataArray == nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
    }];
}

#pragma mark - 删除名片
- (void)deleteCardHttpData:(NSInteger)row{
    CardScanModel *model = self.dataArray[row];
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"删除中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", [DataModelInstance shareInstance].userModel.userId, model.cardId] forKey:@"param"];
    [self requstType:RequestType_Delete apiName:API_NAME_DELETE_USER_DELCARD paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [weakSelf.dataArray removeObjectAtIndex:row];
            if(weakSelf.dataArray.count){
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                [weakSelf.tableView endUpdates];
            }
            if(weakSelf.dataArray.count==1){
                CardScanModel *model = weakSelf.dataArray.firstObject;
                if(model.ismycard.integerValue == 1){
                    CardScanModel *model1 = [[CardScanModel alloc] initWithDict:[NSDictionary new]];
                    model1.ismycard = @(2);
                    [weakSelf.dataArray addObject:model1];
                }
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
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
- (void)customNavBackButtonClicked{
    [self.navigationController popViewControllerAnimated:YES];
    self.menuShow = NO;
    [self.menuView showMenuWithAnimation:self.menuShow];
    self.menuView = nil;
}

- (void)cardButtonClicked:(UIButton*)sender{
    self.menuShow = NO;
    [self.menuView showMenuWithAnimation:self.menuShow];
    self.menuView = nil;
    ScanCameraController *vc = [CommonMethod getVCFromNib:[ScanCameraController class]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)groupButtonClicked:(UIButton*)sender{
    self.menuShow = NO;
    [self.menuView showMenuWithAnimation:self.menuShow];
    self.menuView = nil;
    CardGroupViewController *vc = [CommonMethod getVCFromNib:[CardGroupViewController class]];
    vc.isShowGroupList = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)choiceButtonClicked:(UIButton*)sender{
    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    _choiceBtnFrame = [sender convertRect:sender.bounds toView:window];
    _menuShow = !_menuShow;
    [self.menuView showMenuWithAnimation:_menuShow];
    if(_menuShow==NO){
        self.menuView = nil;
    }
}

//弹出下拉菜单
- (MenuView *)menuView{
    if (!_menuView) {
        NSArray *dataArray = @[@{@"itemName" : @"按日期", @"imageName":@""},@{@"itemName" : @"按姓名", @"imageName":@""}];
        
        __weak typeof(self)weakSelf = self;
        _menuView = [MenuView createMenuWithFrame:CGRectMake(0, 0, 150, dataArray.count * 40) target:self dataArray:dataArray itemsClickBlock:^(NSString *str, NSInteger tag) {
            if(tag+1 != _sortIndex){
                _sortIndex = tag+1;
                [weakSelf getCardListHttpData];
            }
            _menuShow = NO;
            _menuView = nil;
        } backViewTap:^{
            _menuShow = NO;
            _menuView = nil;
        }];
        _menuView.frame = CGRectMake(0, _choiceBtnFrame.origin.y+45, WIDTH, HEIGHT-(_choiceBtnFrame.origin.y+45));
    }
    return _menuView;
}

#pragma mark - UITableViewDelegate/datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(!self.dataArray){
        return 0;
    }else if(self.dataArray.count){
        return self.dataArray.count;
    }else if(self.dataArray.count==0 && _noNetWork){
        return 1;
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count==0 && _noNetWork){
        return HEIGHT-250;
    }else{
        return 65;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(!self.searchBar.text.length){
        return 45;
    }else{
        return 0.000001;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(!self.searchBar.text.length){
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 45)];
        headerView.backgroundColor = WHITE_COLOR;
        NSInteger count = 0;
        for(CardScanModel *model in self.dataArray){
            if(model.cardId.integerValue){
                count++;
            }
        }
        UILabel *countLabel = [UILabel createrLabelframe:CGRectMake(16, 0, 200, 45) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:[NSString stringWithFormat:@"名片（%lu张）", (unsigned long)count] font:14 number:1 nstextLocat:NSTextAlignmentLeft];
        [headerView addSubview:countLabel];
        
        UIButton *choiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        choiceBtn.frame = CGRectMake(WIDTH-86, 0, 70, 45);
        choiceBtn.contentHorizontalAlignment = NSTextAlignmentRight;
        NSMutableAttributedString *btnAttriStr;
        if(_sortIndex==1){
            btnAttriStr = [[NSMutableAttributedString alloc] initWithString:@"按日期 "];
        }else{
            btnAttriStr = [[NSMutableAttributedString alloc] initWithString:@"按姓名 "];
        }
        [btnAttriStr addAttributes:@{NSForegroundColorAttributeName:HEX_COLOR(@"41464e"), NSFontAttributeName:[UIFont systemFontOfSize:15]} range:NSMakeRange(0, 3)];
        NSTextAttachment *btnAttchImage = [[NSTextAttachment alloc] init];
        btnAttchImage.image = kImageWithName(@"icon_barrow_grey");
        btnAttchImage.bounds = CGRectMake(0, 0, 10, 6);
        NSAttributedString *btnStringImage = [NSAttributedString attributedStringWithAttachment:btnAttchImage];
        [btnAttriStr appendAttributedString:btnStringImage];
        [choiceBtn setAttributedTitle:btnAttriStr forState:UIControlStateNormal];
        [choiceBtn setTitleColor:HEX_COLOR(@"41464e") forState:UIControlStateNormal];
        [choiceBtn addTarget:self action:@selector(choiceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:choiceBtn];
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 44.5, WIDTH, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [headerView addSubview:lineLabel];
        return headerView;
    }else{
        return nil;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(_noNetWork && self.dataArray.count==0){
        static NSString *identify = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NONetWorkTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }else{
        static NSString *identify = @"CardListCell";
        CardListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"CardListCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell updateDisplay:self.dataArray[indexPath.row]];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_noNetWork&&self.dataArray.count==0){
        return;
    }
    CardScanModel *model = self.dataArray[indexPath.row];
    if(model.cardId.integerValue){
        CardDetailViewController *vc = [CommonMethod getVCFromNib:[CardDetailViewController class]];
        vc.cardId = model.cardId;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        ScanCameraController *vc = [CommonMethod getVCFromNib:[ScanCameraController class]];
        vc.isMyCard = model.ismycard.integerValue==1;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    CardScanModel *model = self.dataArray[indexPath.row];
    if(model.cardId.integerValue && !model.ismycard.integerValue){
        __weak typeof(self) weakSelf = self;
        NSMutableArray *array = [NSMutableArray array];
        for(int i=0; i<4; i++){
            __block NSInteger tag = i;
            UITableViewRowAction *rowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"       " handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
                [weakSelf tapRowAction:indexPath.row type:tag];
            }];
            rowAction.backgroundColor = HEX_COLOR(@"afb6c1");
            [array addObject:rowAction];
        }
        return array;
    }else{
        return @[];
    }
}

- (void)tapRowAction:(NSInteger)row type:(NSInteger)type{
    CardScanModel *model = self.dataArray[row];
    if(type==0){
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否删除该名片" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
        } confirm:^{
            [self deleteCardHttpData:row];
        }];
    }else if(type==1){
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        CardGroupViewController *vc = [CommonMethod getVCFromNib:[CardGroupViewController class]];
        vc.isShowGroupList = NO;
        vc.model = model;
        [self.navigationController pushViewController:vc animated:YES];
    }else if(type==2){
        if(model.phone.length==0){
            [self.view showToastMessage:@"手机号为空"];
            return;
        }
        NSString *str = [NSString stringWithFormat:@"tel:%@",model.phone];
        UIWebView *callWebView = [[UIWebView alloc]init];
        [callWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self.view addSubview:callWebView];
    }else{
        if(model.phone.length==0){
            [self.view showToastMessage:@"手机号为空"];
            return;
        }
        [self showMessageView:[NSArray arrayWithObjects:model.phone, nil] title:@""];
    }
}

#pragma mark -- SearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    if(searchBar.text.length){
        self.tableHeaderView.frame = CGRectMake(0, 0, WIDTH, 44);
        self.tableView.tableHeaderView = self.tableHeaderView;
        [self getCardListHttpDataBySearchText:searchBar.text];
    }else{
        self.tableHeaderView.frame = CGRectMake(0, 0, WIDTH, 55+76*WIDTH/375.0);
        self.tableView.tableHeaderView = self.tableHeaderView;
        [self getCardListHttpData];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(searchText.length){
        self.tableHeaderView.frame = CGRectMake(0, 0, WIDTH, 44);
        self.tableView.tableHeaderView = self.tableHeaderView;
        [self getCardListHttpDataBySearchText:searchText];
    }else{
        self.tableHeaderView.frame = CGRectMake(0, 0, WIDTH, 55+76*WIDTH/375.0);
        self.tableView.tableHeaderView = self.tableHeaderView;
        [self getCardListHttpData];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    self.menuShow = NO;
    [self.menuView showMenuWithAnimation:self.menuShow];
    self.menuView = nil;
    return YES;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

@end
