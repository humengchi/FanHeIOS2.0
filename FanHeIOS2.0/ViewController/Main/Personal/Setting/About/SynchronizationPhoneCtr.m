//
//  SynchronizationPhoneCtr.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/7/19.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "SynchronizationPhoneCtr.h"
#import <AddressBook/AddressBook.h>
#import "VisitPhoneBookView.h"
@interface SynchronizationPhoneCtr ()
@property (nonatomic ,strong) NSMutableArray *phoneNumberArray;
@property (nonatomic, weak) IBOutlet UIButton *updateBtn;
@end

@implementation SynchronizationPhoneCtr

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(![[NSUserDefaults standardUserDefaults] boolForKey:NotFirstVisitingPhoneBook]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:NotFirstVisitingPhoneBook];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    self.phoneNumberArray = [NSMutableArray new];
    [self createCustomNavigationBar:@"更新通讯录"];
    self.view.backgroundColor = kTableViewBgColor;
    // Do any additional setup after loading the view from its nib.
}
//获取电话联系人
//获取电话联系人
- (void)getPhoneNumberArraySY{
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
        view.subTitleLabel.text = @"来看看有多少好友在玩“3号圈”";//@"请在手机 “设置>隐私>通讯录” 中找到“金脉+”，点亮右侧按钮。";
//        view.subTitleLabel.font = FONT_SYSTEM_SIZE(15);
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
            [self.phoneNumberArray addObject:addressBook.phone];
        }
        if (abName) CFRelease(abName);
        if (abLastName) CFRelease(abLastName);
        if (abFullName) CFRelease(abFullName);
    }
    [self updateHttpData];
}

- (void)updateHttpData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    NSString *phoneNumber = [self.phoneNumberArray componentsJoinedByString:@","];
    [requestDict setObject:[NSString stringWithFormat:@"%@",[DataModelInstance shareInstance].userModel.userId] forKey:@"userid"];
    [requestDict setObject:phoneNumber forKey:@"phones"];
    
    [self requstType:RequestType_Post apiName:API_NAME_POST_USER_QIEL paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf.tableView endRefresh];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"更新通讯录成功" toView:weakSelf.view];
            weakSelf.updateBtn.enabled = NO;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
    }];
}

- (IBAction)phoneNumberSynchronizationAction:(UIButton *)sender {
    [self getPhoneNumberArraySY];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
