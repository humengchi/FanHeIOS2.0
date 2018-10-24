//
//  EditCardViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/14.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "EditCardViewController.h"
#import "SaveCardSuccessController.h"
#import <AddressBook/AddressBook.h>
#import "DatePikerView.h"
#import "ScanCameraController.h"

@interface EditCardViewController ()<UITextViewDelegate>{
    BOOL _addNewParam;
}

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, weak) IBOutlet UIView *otherTableFooterView;
@property (nonatomic, weak) IBOutlet UIView *myTableFooterView;
@property (nonatomic, weak) IBOutlet UISwitch *contactSwitch;
@end

@implementation EditCardViewController

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _addNewParam = NO;
    self.dataArray = [NSMutableArray array];
    
    [self initGroupedTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.separatorColor = kCellLineColor;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 213*WIDTH/375.0)];
    [headerImageView sd_setImageWithURL:[NSURL URLWithString:self.model.imgurl] placeholderImage:KWidthImageDefault];
    headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    headerImageView.clipsToBounds = YES;
    self.tableView.tableHeaderView = headerImageView;

    if(self.model.ismycard.integerValue && self.isEdit){
        self.myTableFooterView.frame = CGRectMake(0, 0, WIDTH, 120);
        self.tableView.tableFooterView = self.myTableFooterView;
    }else{
        self.otherTableFooterView.frame = CGRectMake(0, 0, WIDTH, 157);
        self.tableView.tableFooterView = self.otherTableFooterView;
    }
    
    [self createParams];
    
    if(self.isEdit){
        [self.backNavBtn setTitle:@"取消" forState:UIControlStateNormal];
    }
    
    //获取通讯录权限
    ABAddressBookRef addressBooks =  ABAddressBookCreateWithOptions(NULL, NULL);
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBooks, ^(bool granted, CFErrorRef error){
        //greanted为YES是表示用户允许，否则为不允许
        if (!granted) {
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"无法访问通讯录" message:@"请在设置中打开通讯录权限，以保存联系人到手机通讯录" cancelButtonTitle:@"取消" otherButtonTitle:@"去设置" cancle:^{
                
            } confirm:^{
                if(IOS_X >= 10){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }else{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
                }
            }];
        }
        self.contactSwitch.on = granted;
        self.contactSwitch.enabled = granted;
        dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

- (void)createParams{
    [self.dataArray removeAllObjects];
    
    [self.dataArray addObject:[NSMutableArray arrayWithObject:[NSMutableDictionary dictionaryWithDictionary:@{@"name":self.model.name}]]];
    NSMutableArray *photoArray = [NSMutableArray array];
    [photoArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"phone":self.model.phone}]];
    if([CommonMethod paramStringIsNull:self.model.phone].length==0){
        self.model.phone = @"手机";
    }
    for(NSString *jobphone in self.model.jobphone){
        [photoArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"jobphone":[CommonMethod paramStringIsNull:jobphone]}]];
    }
    for(NSString *fax in self.model.fax){
        [photoArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"fax":[CommonMethod paramStringIsNull:fax]}]];
    }
    if(photoArray.count){
        [self.dataArray addObject:photoArray];
    }
    
    NSMutableArray *emailArray = [NSMutableArray array];
    for(NSString *email in self.model.email){
        [emailArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"email":[CommonMethod paramStringIsNull:email]}]];
    }
    if(emailArray.count){
        [self.dataArray addObject:emailArray];
    }
    
    NSMutableArray *companyArray = [NSMutableArray array];
    for(int i=0; i<self.model.company.count; i++){
        NSString *company = self.model.company[i];
        NSString *position = @"";
        if(self.model.position.count>i){
            position = self.model.position[i];
        }
        NSMutableArray *params = [NSMutableArray array];
        [params addObject:[CommonMethod paramStringIsNull:company]];
        [params addObject:[CommonMethod paramStringIsNull:position]];
        [companyArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"companyposition": params}]];
    }
    if(companyArray.count){
        [self.dataArray addObject:companyArray];
    }
    
    NSMutableArray *websiteArray = [NSMutableArray array];
    for(NSString *website in self.model.website){
        [websiteArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"website":[CommonMethod paramStringIsNull:website]}]];
    }
    if(websiteArray.count){
        [self.dataArray addObject:websiteArray];
    }
    
    NSMutableArray *addressArray = [NSMutableArray array];
    for(NSString *address in self.model.address){
        [addressArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"address":[CommonMethod paramStringIsNull:address]}]];
    }
    if(addressArray.count){
        [self.dataArray addObject:addressArray];
    }
    
    NSMutableArray *qqWXArray = [NSMutableArray array];
    for(NSString *qq in self.model.qq){
        [qqWXArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"qq":[CommonMethod paramStringIsNull:qq]}]];
    }
    for(NSString *wx in self.model.wx){
        [qqWXArray addObject:[NSMutableDictionary dictionaryWithDictionary:@{@"wx":[CommonMethod paramStringIsNull:wx]}]];
    }
    if(qqWXArray.count){
        [self.dataArray addObject:qqWXArray];
    }
    
    if([CommonMethod paramStringIsNull:self.model.birthday].length){
        [self.dataArray addObject:[NSMutableArray arrayWithObject:[NSMutableDictionary dictionaryWithDictionary:@{@"birthday":self.model.birthday}]]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 保存到通讯录
- (BOOL)addContactRecord:(ABRecordRef)record{
    CFErrorRef error;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, (CFErrorRef *)&error);
    // 将新建联系人记录添加如通讯录中
    BOOL success = ABAddressBookAddRecord(addressBook, record, &error);
    if (!success) {
        return NO;
    }else{
        // 如果添加记录成功，保存更新到通讯录数据库中
        success = ABAddressBookSave(addressBook, &error);
        return success ? YES : NO;
    }
}

#pragma mark - 保存名片
- (void)saveCardHttpData{
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"保存中..." toView:self.view];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.model.ismycard forKey:@"ismycard"];
    if(self.isEdit){
        [requestDict setObject:self.model.cardId forKey:@"cardid"];
    }
    //创建一条空的联系人
    ABRecordRef record = ABPersonCreate();
    CFErrorRef error;
    
    NSString *name = @"";
    NSString *phone = @"";
    NSString *birthday = @"";
    NSMutableArray *jobphone = [NSMutableArray array];
    NSMutableArray *fax = [NSMutableArray array];
    NSMutableArray *company = [NSMutableArray array];
    NSMutableArray *position = [NSMutableArray array];
    NSMutableArray *email = [NSMutableArray array];
    NSMutableArray *website = [NSMutableArray array];
    NSMutableArray *address = [NSMutableArray array];
    NSMutableArray *qq = [NSMutableArray array];
    NSMutableArray *wx = [NSMutableArray array];
    
    for(NSArray *array in self.dataArray){
        for(NSDictionary *dict in array){
            NSString *keyStr = dict.allKeys[0];
            id value = [dict objectForKey:keyStr];
            if([value isKindOfClass:[NSString class]]){
                NSString *valueStr = (NSString*)value;
                if([keyStr isEqualToString:@"name"]){
                    if(!valueStr.length){
                        [hud hideAnimated:YES];
                        [self.view showToastMessage:@"姓名不能为空"];
                        return;
                    }
                    name = valueStr;
                }else if([keyStr isEqualToString:@"phone"]){
                    if(!valueStr.length){
                        [hud hideAnimated:YES];
                        [self.view showToastMessage:@"手机不能为空"];
                        return;
                    }else if(![NSHelper justMobile:valueStr]){
                        [hud hideAnimated:YES];
                        [self.view showToastMessage:[NSString stringWithFormat:@"%@手机格式不对", valueStr]];
                        return;
                    }
                    phone = valueStr;
                }else if([keyStr isEqualToString:@"birthday"]){
                    birthday = valueStr;
                }else{
                    if(valueStr.length==0){
                        continue;
                    }
                    if([keyStr isEqualToString:@"jobphone"]){
                        [jobphone addObject:valueStr];
                    }else if([keyStr isEqualToString:@"fax"]){
                        [fax addObject:valueStr];
                    }else if([keyStr isEqualToString:@"email"]){
                        if(![NSHelper justEmail:valueStr]){
                            [hud hideAnimated:YES];
                            [self.view showToastMessage:[NSString stringWithFormat:@"%@邮箱格式不对", valueStr]];
                            return;
                        }
                        [email addObject:valueStr];
                    }else if([keyStr isEqualToString:@"website"]){
                        [website addObject:valueStr];
                    }else if([keyStr isEqualToString:@"address"]){
                        [address addObject:valueStr];
                    }else if([keyStr isEqualToString:@"qq"]){
                        [qq addObject:valueStr];
                    }else if([keyStr isEqualToString:@"wx"]){
                        [wx addObject:valueStr];
                    }
                }
            }else{
                NSArray *params = (NSArray*)value;
                [company addObject:params[0]];
                [position addObject:params[1]];
            }
        }
    }
    [requestDict setObject:name forKey:@"name"];
    [requestDict setObject:phone forKey:@"phone"];
    if(jobphone.count){
        [requestDict setObject:[self objArrayToJSON:jobphone] forKey:@"jobphone"];
    }
    if(fax.count){
        [requestDict setObject:[self objArrayToJSON:fax] forKey:@"fax"];
    }
    NSInteger count = company.count;
    for(int i=0; i<count; i++){
        if([company[i] length]==0 && [position[i] length]==0){
            [company removeObjectAtIndex:i];
            [position removeObjectAtIndex:i];
        }
    }
    if(company.count){
        [requestDict setObject:[self objArrayToJSON:company] forKey:@"company"];
    }
    if(position.count){
        [requestDict setObject:[self objArrayToJSON:position] forKey:@"position"];
    }
    if(email.count){
        [requestDict setObject:[self objArrayToJSON:email] forKey:@"email"];
    }
    if(website.count){
        [requestDict setObject:[self objArrayToJSON:website] forKey:@"website"];
    }
    if(address.count){
        [requestDict setObject:[self objArrayToJSON:address] forKey:@"address"];
    }
    if(qq.count){
        [requestDict setObject:[self objArrayToJSON:qq] forKey:@"qq"];
    }
    if(wx.count){
        [requestDict setObject:[self objArrayToJSON:wx] forKey:@"wx"];
    }
    if(birthday.length){
        [requestDict setObject:birthday forKey:@"birthday"];
    }
    if(self.model.imgurl.length){
        [requestDict setObject:self.model.imgurl forKey:@"imgurl"];
    }
    
    if(self.contactSwitch.on && !(self.model.ismycard.integerValue && self.isEdit)){
        //姓名
        ABRecordSetValue(record, kABPersonFirstNameProperty, (__bridge CFTypeRef)name, &error);
        //手机号
        ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABPersonPhoneProperty);
        ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)phone,kABPersonPhoneIPhoneLabel, NULL);
        //工作电话
        for(NSString *str in jobphone){
            ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)str, (__bridge CFStringRef)@"工作电话", NULL);
        }
        //传真
        for(NSString *str in fax){
            ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)str,kABPersonPhoneWorkFAXLabel, NULL);
        }
        ABRecordSetValue(record, kABPersonPhoneProperty, multi, &error);
        
        //公司
        if(company.count){
            ABRecordSetValue(record, kABPersonOrganizationProperty, (__bridge CFTypeRef)[company componentsJoinedByString:@"  "], &error);
        }
        //职位
        if(position.count){
            ABRecordSetValue(record, kABPersonOrganizationProperty, (__bridge CFTypeRef)[position componentsJoinedByString:@"  "], &error);
        }
        //邮箱
        if(email.count){
            multi = ABMultiValueCreateMutable(kABPersonEmailProperty);
            for(NSString *str in email){
                ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)str, (__bridge CFStringRef)@"邮箱", NULL);
            }
            ABRecordSetValue(record, kABPersonEmailProperty, multi, &error);
        }
        
        //网址
        if(website.count){
            multi = ABMultiValueCreateMutable(kABPersonURLProperty);
            for(NSString *str in website){
                ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)str,(__bridge CFStringRef)@"网页", NULL);
            }
            ABRecordSetValue(record, kABPersonURLProperty, multi, &error);
        }
        //地址
        if(address.count){
            multi = ABMultiValueCreateMutable(kABPersonAddressProperty);
            for(NSString *str in address){
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setValue:str forKey:(NSString*)kABPersonAddressStreetKey];
                ABMultiValueAddValueAndLabel(multi, (__bridge CFDictionaryRef)dict,(__bridge CFStringRef)@"地址", NULL);
            }
            ABRecordSetValue(record, kABPersonAddressProperty, multi, &error);
        }
        //qq、wx
        if(qq.count || wx.count){
            //qq
            multi = ABMultiValueCreateMutable(kABPersonInstantMessageProperty);
            for(NSString *str in qq){
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setValue:@"QQ" forKey:(NSString*)kABPersonInstantMessageServiceKey];
                [dict setValue:str forKey:(NSString*)kABPersonInstantMessageUsernameKey];
                ABMultiValueAddValueAndLabel(multi, (__bridge CFDictionaryRef)dict,(__bridge CFStringRef)@"QQ", NULL);
            }
            //wx
            for(NSString *str in wx){
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [dict setValue:@"微信" forKey:(NSString*)kABPersonInstantMessageServiceKey];
                [dict setValue:str forKey:(NSString*)kABPersonInstantMessageUsernameKey];
                ABMultiValueAddValueAndLabel(multi, (__bridge CFDictionaryRef)dict,(__bridge CFStringRef)@"微信", NULL);
            }
            ABRecordSetValue(record, kABPersonInstantMessageProperty, multi, &error);
        }
       
        if(birthday.length){
            ABRecordSetValue(record, kABPersonBirthdayProperty, (__bridge CFDateRef)[NSDate dateFromString:birthday format:kShortTimeFormat], &error);
        }
        [self addContactRecord:record];
    }
    [self requstType:RequestType_Post apiName:API_NAME_POST_USER_SAVECARD paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            if(weakSelf.isEdit){
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }else{
                SaveCardSuccessController *vc = [CommonMethod getVCFromNib:[SaveCardSuccessController class]];
                vc.isMyCard = weakSelf.model.ismycard.boolValue;
                weakSelf.model.cardId = [CommonMethod paramNumberIsNull:responseObject[@"data"][@"cardid"]];
                weakSelf.model.name = name;
                vc.model = weakSelf.model;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
        }else{
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

- (NSString *)objArrayToJSON:(NSArray *)array {
    if(array == nil){
        return @"";
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    if ([jsonData length] > 0 && error == nil){
        return [[[[[NSString alloc] initWithData:jsonData
                                       encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    }else{
        return @"";
    }
}

#pragma mark - method
- (IBAction)navBackButtonClicked:(id)sender{
    if(self.isEdit){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"是否放弃本次扫描结果？" message:@"本次消耗的免费次数或咖啡豆不予退还" cancelButtonTitle:@"取消" otherButtonTitle:@"确认" cancle:^{
            
        } confirm:^{
            NSArray *viewControllers = self.navigationController.viewControllers;
            [self.navigationController popToViewController:viewControllers[viewControllers.count-3] animated:NO];
        }];
    }
}

- (IBAction)reScanCameraButtonClicked:(id)sender{
    ScanCameraController *vc = [CommonMethod getVCFromNib:[ScanCameraController class]];
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [viewControllers removeLastObject];
    [viewControllers addObject:vc];
    vc.isMyCard = YES;
    vc.cardId = self.model.cardId;
    [self.navigationController setViewControllers:viewControllers animated:YES];
}

- (IBAction)saveButtonClicked:(id)sender{
    [self saveCardHttpData];
}

- (IBAction)addParamButtonClicked:(id)sender{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        
    }];
    [cancelAction setValue:HEX_COLOR(@"040000") forKey:@"_titleTextColor"];
    [alertController addAction:cancelAction];
    NSMutableArray *paramsArray = [NSMutableArray arrayWithObjects:@"公司和职位", nil];
    if(!self.model.phone.length){
        [paramsArray addObject:@"手机"];
    }
    if(!self.model.birthday.length){
        [paramsArray addObjectsFromArray:@[@"工作电话",@"邮箱",@"网页",@"生日",@"QQ",@"微信",@"公司地址"]];
    }else{
        [paramsArray addObjectsFromArray:@[@"工作电话",@"邮箱",@"网页",@"QQ",@"微信",@"公司地址"]];
    }
    for(NSString *string in paramsArray){
        UIAlertAction* action = [UIAlertAction actionWithTitle:string style:UIAlertActionStyleDefault                                                                 handler:^(UIAlertAction * action) {
            NSString *keyStr = @"";
            if([action.title isEqualToString:@"公司和职位"]){
                keyStr = @"companyposition";
            }else if([action.title isEqualToString:@"工作电话"]){
                keyStr = @"jobphone";
            }else if([action.title isEqualToString:@"邮箱"]){
                keyStr = @"email";
            }else if([action.title isEqualToString:@"网页"]){
                keyStr = @"website";
            }else if([action.title isEqualToString:@"生日"]){
                keyStr = @"birthday";
                self.model.birthday = @"生日";
            }else if([action.title isEqualToString:@"QQ"]){
                keyStr = @"qq";
            }else if([action.title isEqualToString:@"微信"]){
                keyStr = @"wx";
            }else if([action.title isEqualToString:@"公司地址"]){
                keyStr = @"address";
            }else if([action.title isEqualToString:@"手机"]){
                keyStr = @"phone";
                self.model.phone = @"手机";
            }
            if([keyStr isEqualToString:@"companyposition"]){
                [self.dataArray addObject:[NSMutableArray arrayWithObjects:[NSMutableDictionary dictionaryWithDictionary:@{@"companyposition":[NSMutableArray arrayWithObjects:@"",@"", nil]}], nil]];
            }else{
                [self.dataArray addObject:[NSMutableArray arrayWithObject:[NSMutableDictionary dictionaryWithDictionary:@{keyStr:@""}]]];
            }
            _addNewParam = YES;
            [self.tableView reloadData];
        }];
        [action setValue:HEX_COLOR(@"040000") forKey:@"_titleTextColor"];
        [alertController addAction:action];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)openContactButtonClicked:(UISwitch*)sender{
    
}

- (void)choiceBirthDate:(UITapGestureRecognizer*)tap{
    __block UITextView *textView = (UITextView*)tap.view;
    DatePikerView *view = [CommonMethod getViewFromNib:NSStringFromClass([DatePikerView class])];
    view.type = kDatePikerViewTypeDay;
    view.clearBtn.hidden = YES;
    view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    if([CommonMethod paramStringIsNull:self.model.birthday].length){
        [view updateSelectRow:[NSDate dateFromString:self.model.birthday format:kTimeFormat1]];
    }else{
        [view updateSelectRow:[NSDate date]];
    }
    [view updateSelectRow:[NSDate date]];
    view.pickerSelectBlock = ^(id param, NSString *value){
        self.model.birthday = value;
        NSInteger section = textView.tag/1000;
        NSInteger row = textView.tag%1000;
        NSMutableArray *array = self.dataArray[section];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:array[row]];
        NSString *keyStr = dict.allKeys[0];
        [dict setValue:value forKey:keyStr];
        [array replaceObjectAtIndex:row withObject:dict];
        textView.text = value;
//        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:section]] withRowAnimation:UITableViewRowAnimationNone];
    };
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view showShareNormalView];
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
    id valueStr = [dict objectForKey:keyStr];
    if([valueStr isKindOfClass:[NSString class]]){
        CGFloat height = [NSHelper heightOfString:valueStr font:FONT_SYSTEM_SIZE(17) width:WIDTH-133 defaultHeight:FONT_SYSTEM_SIZE(17).lineHeight];
        return height+32;
    }else{
        NSArray *params = (NSArray*)valueStr;
        CGFloat start_Y = 0;
        for(int i=0; i<2; i++){
            CGFloat height = [NSHelper heightOfString:params[i] font:FONT_SYSTEM_SIZE(17) width:WIDTH-133 defaultHeight:FONT_SYSTEM_SIZE(17).lineHeight];
            start_Y += height+32;
        }
        return start_Y;
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
    id valueStr = [dict objectForKey:keyStr];
    if([valueStr isKindOfClass:[NSString class]]){
        NSString *titleStr = @"";
        BOOL isBirth = NO;
        if([keyStr isEqualToString:@"name"]){
            titleStr = @"姓名";
        }else if([keyStr isEqualToString:@"phone"]){
            titleStr = @"手机";
        }else if([keyStr isEqualToString:@"jobphone"]){
            titleStr = @"工作电话";
        }else if([keyStr isEqualToString:@"fax"]){
            titleStr = @"工作传真";
        }else if([keyStr isEqualToString:@"email"]){
            titleStr = @"邮箱";
        }else if([keyStr isEqualToString:@"website"]){
            titleStr = @"网页";
        }else if([keyStr isEqualToString:@"address"]){
            titleStr = @"公司地址";
        }else if([keyStr isEqualToString:@"birthday"]){
            isBirth = YES;
            titleStr = @"生日";
        }else if([keyStr isEqualToString:@"qq"]){
            titleStr = @"QQ";
        }else if([keyStr isEqualToString:@"wx"]){
            titleStr = @"微信";
        }
        CGFloat height = [NSHelper heightOfString:valueStr font:FONT_SYSTEM_SIZE(17) width:WIDTH-133 defaultHeight:FONT_SYSTEM_SIZE(17).lineHeight];
        UILabel *titleLabel = [UILabel createLabel:CGRectMake(16, 0, 75, height+32) font:FONT_SYSTEM_SIZE(17) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e")];
        [cell.contentView addSubview:titleLabel];
        titleLabel.text = titleStr;
        
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(97, 16, WIDTH-133, height)];
        textView.font = FONT_SYSTEM_SIZE(17);
        textView.delegate = self;
        textView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
        [textView setTextContainerInset:UIEdgeInsetsZero];
        textView.textContainer.lineFragmentPadding = 0;
        [textView setContentInset:UIEdgeInsetsMake(0, 0, 0, 1)];
        [textView setTextAlignment:NSTextAlignmentLeft];
        textView.textColor = HEX_COLOR(@"41464e");
        textView.tag = indexPath.section*1000+indexPath.row;
        textView.scrollEnabled = NO;
        textView.returnKeyType = UIReturnKeyDone;
        textView.text = valueStr;
        [cell.contentView addSubview:textView];
        if(isBirth){
            textView.editable = NO;
            [CommonMethod viewAddGuestureRecognizer:textView tapsNumber:1 withTarget:self withSEL:@selector(choiceBirthDate:)];
        }
        if(self.dataArray.count == indexPath.section+1 && array.count == indexPath.row+1 && _addNewParam){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [textView becomeFirstResponder];
            });
        }
    }else{
        NSArray *params = (NSArray*)valueStr;
        CGFloat start_Y = 0;
        for(int i=0; i<2; i++){
            CGFloat height = [NSHelper heightOfString:params[i] font:FONT_SYSTEM_SIZE(17) width:WIDTH-133 defaultHeight:FONT_SYSTEM_SIZE(17).lineHeight];
            UILabel *titleLabel = [UILabel createLabel:CGRectMake(16, start_Y, 75, height+32) font:FONT_SYSTEM_SIZE(17) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e")];
            [cell.contentView addSubview:titleLabel];
            titleLabel.text = i==0?@"公司":@"职位";
            if(i==0){
                UILabel *linelabel = [[UILabel alloc] initWithFrame:CGRectMake(16, height+31.5, WIDTH-32, 0.5)];
                linelabel.backgroundColor = kCellLineColor;
                [cell.contentView addSubview:linelabel];
            }
            
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(97, start_Y+16, WIDTH-133, height)];
            textView.font = FONT_SYSTEM_SIZE(17);
            textView.delegate = self;
            textView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
            [textView setTextContainerInset:UIEdgeInsetsZero];
            textView.textContainer.lineFragmentPadding = 0;
            [textView setContentInset:UIEdgeInsetsMake(0, 0, 0, 1)];
            [textView setTextAlignment:NSTextAlignmentLeft];
            textView.textColor = HEX_COLOR(@"41464e");
            textView.tag = indexPath.section*1000+indexPath.row+(i+1)*10000;
            textView.scrollEnabled = NO;
            textView.returnKeyType = UIReturnKeyDone;
            textView.text = params[i];
            [cell.contentView addSubview:textView];
            if(self.dataArray.count == indexPath.section+1 && i==0 && _addNewParam){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [textView becomeFirstResponder];
                });
            }
            start_Y += height+32;
        }
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *array = self.dataArray[indexPath.section];
    NSDictionary *dict = array[indexPath.row];
    NSString *keyStr = dict.allKeys[0];
    if([keyStr isEqualToString:@"name"] || [keyStr isEqualToString:@"phone"]){
        return NO;
    }else{
        return YES;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *array = self.dataArray[indexPath.section];
    NSDictionary *dict = array[indexPath.row];
    NSString *keyStr = dict.allKeys[0];
    if(array.count==1){
        [self.dataArray removeObjectAtIndex:indexPath.section];
    }else{
        [array removeObjectAtIndex:indexPath.row];
    }
    if([keyStr isEqualToString:@"birthday"]){
        self.model.birthday = @"";
    }else if([keyStr isEqualToString:@"phone"]){
        self.model.phone = @"";
    }
    
    [self.tableView reloadData];
}

#pragma mark -- UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    if(position && (range.length==0 || text.length==0)){
        return YES;
    }else{
        NSString *str = [textView.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:text];
        NSInteger isCompany = textView.tag/10000;
        NSInteger section = textView.tag%10000/1000;
        NSInteger row = textView.tag%1000;
        NSMutableArray *array = self.dataArray[section];
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:array[row]];
        NSString *keyStr = dict.allKeys[0];
        id valueStr = [dict objectForKey:keyStr];
        if([valueStr isKindOfClass:[NSString class]]){
            [dict setValue:str forKey:keyStr];
            [array replaceObjectAtIndex:row withObject:dict];
        }else{
            NSMutableArray *params = (NSMutableArray*)valueStr;
            params[isCompany-1] = str;
            [dict setObject:params forKey:keyStr];
            [array replaceObjectAtIndex:row withObject:dict];
        }
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
}

#pragma mark - Keyboard status
- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardEnd.size.height;
    [UIView animateWithDuration:duration animations:^{
        if([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
            self.tableView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64-keyboardHeight);
            if(_addNewParam){
                [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height-156-self.tableView.frame.size.height) animated:YES];
                _addNewParam = NO;
            }
        }else{
            self.tableView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64);
        }
    }];
}
@end
