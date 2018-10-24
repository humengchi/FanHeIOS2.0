//
//  CreateActivityViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/30.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "CreateActivityViewController.h"
#import "TFSearchResultViewController.h"
#import "DatePikerView.h"
#import "CreateTopicTagsViewController.h"
#import "ActivityCoverViewController.h"
#import "ZSSRichTextEditor.h"
#import "ActivityLocationViewController.h"
#import "ApplySettingViewController.h"
#import "GuestSettingViewController.h"
#import "ActivityManagerViewController.h"
#import "ChoseActivityViewController.h"

#define ActivityCashKey [NSString stringWithFormat:@"publishActivity_%@",[DataModelInstance shareInstance].userModel.userId]

@interface CreateActivityViewController ()<UITextFieldDelegate>{
    BOOL _publishDynamic;
}

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *publishBtn;

@end

@implementation CreateActivityViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _publishDynamic = YES;
    //移除滑动手势
    for (UIPanGestureRecognizer *ges in self.view.gestureRecognizers)
    {
        [self.view removeGestureRecognizer:ges];
    }

    [self removeViewTapGesture];
    if(self.model==nil){
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:ActivityCashKey];
        if(data){
            self.model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }else{
            self.model = [[ActivityCreateModel alloc] init];
            self.model.image = @"http://image.51jinmai.com/mr_hd_03.jpg";
        }
    }
    if(self.isEdit){
        self.titleLabel.text = @"编辑活动";
        [self.publishBtn setTitle:@"保存" forState:UIControlStateNormal];
    }
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 10)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.dataArray = [NSMutableArray arrayWithObjects:@[@{@"name":@"封面"},@{@"name":@"标题"},@{@"name":@"开始时间"},@{@"name":@"结束时间"},@{@"name":@"地点"},@{@"name":@"标签"},@{@"name":@"活动简介"}], @[@{@"name":@"报名设置"},@{@"name":@"活动嘉宾"}], @[@{@"name":@"发布至动态"}], nil];
}

#pragma mark -按钮方法
- (IBAction)navBackButtonClicked:(id)sender{
    if(!(![self.model.image isEqualToString:@"http://image.51jinmai.com/mr_hd_03.jpg"] || self.model.name.length || self.model.begintime.length || self.model.endtime.length || self.model.address.length || self.model.tags.length || self.model.intro.length || self.model.tickets.count || self.model.guests.count)){
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if(self.model.activityid.integerValue==0){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            
        }];
        
        UIAlertAction* saveAction = [UIAlertAction actionWithTitle:@"保存内容" style:UIAlertActionStyleDefault                                                                 handler:^(UIAlertAction * action) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.model];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:ActivityCashKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        UIAlertAction* backAction = [UIAlertAction actionWithTitle:@"清空内容" style:UIAlertActionStyleDefault                                                             handler:^(UIAlertAction * action) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:ActivityCashKey];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        if([UIDevice currentDevice].systemVersion.intValue > 8){
            [cancelAction setValue:HEX_COLOR(@"040000") forKey:@"_titleTextColor"];
            [saveAction setValue:HEX_COLOR(@"040000") forKey:@"_titleTextColor"];
            [backAction setValue:HEX_COLOR(@"e23000") forKey:@"_titleTextColor"];
        }
        [alertController addAction:cancelAction];
        [alertController addAction:saveAction];
        [alertController addAction:backAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否放弃编辑活动？" cancelButtonTitle:@"放弃" otherButtonTitle:@"取消" cancle:^{
            [self.navigationController popViewControllerAnimated:YES];
        } confirm:^{
        }];
    }
}

- (IBAction)publishButtonClicked:(id)sender{
    if(!self.model.name.length){
        [self.view showToastMessage:@"活动标题必填"];
        return;
    }
    if(!self.model.begintime.length){
        [self.view showToastMessage:@"活动开始时间必填"];
        return;
    }
    if(self.model.endtime.length && [NSDate secondsAwayFrom:[NSDate dateFromString:self.model.endtime format:kTimeFormat1] dateSecond:[NSDate dateFromString:self.model.begintime format:kTimeFormat1]]<=0){
        [self.view showToastMessage:@"开始时间必须小于结束时间"];
        return;
    }
    if(!self.model.address.length){
        [self.view showToastMessage:@"活动地点必填"];
        return;
    }
    if(!self.model.tags.length){
        [self.view showToastMessage:@"活动标签必填"];
        return;
    }
    if(!self.model.intro.length){
        [self.view showToastMessage:@"活动简介必填"];
        return;
    }
    
    if(self.model.applyendtime.length && self.model.endtime.length && [NSDate secondsAwayFrom:[NSDate dateFromString:self.model.endtime format:kTimeFormat1] dateSecond:[NSDate dateFromString:self.model.applyendtime format:kTimeFormat1]]<=0){
        [self.view showToastMessage:@"报名截止时间必须小于结束时间"];
        return;
    }
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"发布中..." toView:self.view];
    if(self.model.imagePhoto){
        [self uploadCoverImage:hud];
    }else{
        [self publishHttpData:hud];
    }
}

#pragma mark - 上传封面
- (void)uploadCoverImage:(MBProgressHUD*)hud{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    NSData *imageData = UIImageJPEGRepresentation(self.model.imagePhoto, 0.5);
    [requestDict setObject:imageData forKey:@"pphoto"];
    [self requstType:RequestType_UPLOAD_IMG apiName:API_NAME_UPLOAD_IMAGE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            NSString *urlStr = [responseObject objectForKey:@"msg"];
            weakSelf.model.image = urlStr;
            weakSelf.model.imagePhoto = nil;
            [weakSelf publishHttpData:hud];
        }else{
            [hud hideAnimated:YES];
            [MBProgressHUD showError:@"图片上传失败" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"无法连接到网络" toView:weakSelf.view];
    }];
}

#pragma mark - 发布
- (void)publishHttpData:(MBProgressHUD*)hud{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:[CommonMethod paramNumberIsNull:self.model.activityid] forKey:@"activityid"];
    [requestDict setObject:self.model.name forKey:@"name"];
    [requestDict setObject:self.model.image forKey:@"image"];
    [requestDict setObject:self.model.begintime forKey:@"begintime"];
    [requestDict setObject:[CommonMethod paramStringIsNull:self.model.endtime] forKey:@"endtime"];
    [requestDict setObject:self.model.tags forKey:@"tags"];
    [requestDict setObject:self.model.intro forKey:@"intro"];
    [requestDict setObject:[CommonMethod paramStringIsNull:self.model.provincename] forKey:@"provincename"];
    [requestDict setObject:[CommonMethod paramStringIsNull:self.model.cityname] forKey:@"cityname"];
    [requestDict setObject:[CommonMethod paramStringIsNull:self.model.districtname] forKey:@"districtname"];
    [requestDict setObject:[CommonMethod paramStringIsNull:self.model.address] forKey:@"address"];
    [requestDict setObject:[CommonMethod paramNumberIsNull:self.model.lat] forKey:@"lat"];
    [requestDict setObject:[CommonMethod paramNumberIsNull:self.model.lng] forKey:@"lng"];
    [requestDict setObject:[CommonMethod paramStringIsNull:self.model.phone] forKey:@"phone"];
    [requestDict setObject:[CommonMethod paramStringIsNull:self.model.applyendtime] forKey:@"applyendtime"];
    [requestDict setObject:[CommonMethod paramStringIsNull:[self objArrayToJSON:self.model.tickets]] forKey:@"tickets"];
    [requestDict setObject:[CommonMethod paramStringIsNull:[self objArrayToJSON:self.model.guests]] forKey:@"guests"];
    if(_publishDynamic){
        [requestDict setObject:@(1) forKey:@"adddynamic"];
    }
    [self requstType:RequestType_Post apiName:API_NAME_POST_Add_ACTIVITY paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            [MBProgressHUD showSuccess:@"活动发布成功" toView:weakSelf.view];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:ActivityCashKey];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if(weakSelf.isEdit){
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }else{
                    ActivityManagerViewController *vc = [[ActivityManagerViewController alloc] init];
                    vc.activityid = [CommonMethod paramNumberIsNull:responseObject[@"data"]];
                    vc.isPublishSuccess = YES;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }
            });
        }else{
            NSString *msg = [CommonMethod paramStringIsNull:responseObject[@"msg"]];
            [MBProgressHUD showError:msg.length?msg:@"发布失败" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"无法连接到网络" toView:weakSelf.view];
    }];
}

- (NSString *)objArrayToJSON:(NSArray *)array {
    if(array == nil){
        return @"";
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    if ([jsonData length] > 0 && error == nil){
        return [[[[NSString alloc] initWithData:jsonData
                              encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
    }else{
        return @"";
    }
}

#pragma mark -UITableViewDelegate/datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 7;
    }else if(section==1){
        return 2;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section==0){
        return 0;
    }else{
        return 10;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section){
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 10)];
        headerView.backgroundColor = kTableViewBgColor;
        return headerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 && indexPath.row == 0){
        return WIDTH*9/16.0;
    }else if(indexPath.section==0 && indexPath.row==4&&[CommonMethod paramStringIsNull:self.model.address].length){
        return 98;
    }else if(indexPath.section==2&&indexPath.row==0){
        return 60;
    }
    return 49;
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
    if(indexPath.section==0&&indexPath.row==0){
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, WIDTH*9/16.0)];
        if(self.model.imagePhoto){
            imageView.image = self.model.imagePhoto;
        }else{
            [imageView sd_setImageWithURL:[NSURL URLWithString:self.model.image] placeholderImage:kImageWithName(@"activity_bg")];
        }
        [cell.contentView addSubview:imageView];
        UILabel *hudLabel = [UILabel createrLabelframe:CGRectMake(WIDTH-120, WIDTH*9/16.0-34, 110, 24) backColor:[BLACK_COLOR colorWithAlphaComponent:0.5] textColor:WHITE_COLOR test:@"点击更换活动封面" font:12 number:1 nstextLocat:NSTextAlignmentCenter];
        [CALayer updateControlLayer:hudLabel.layer radius:4 borderWidth:0 borderColor:nil];
        [cell.contentView addSubview:hudLabel];
    }else{
        NSString *titleStr = self.dataArray[indexPath.section][indexPath.row][@"name"];
        UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(16, 10, 75, 30) backColor:WHITE_COLOR textColor:HEX_COLOR(@"afb6c1") test:titleStr font:17 number:1 nstextLocat:NSTextAlignmentLeft];
        [cell.contentView addSubview:titleLabel];
        if(!((indexPath.section==2&&indexPath.row==0)||(indexPath.section==1&&indexPath.row==1)||(indexPath.section==0&&indexPath.row==6))){
            UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 48.5, WIDTH-32, 0.5)];
            lineLabel.backgroundColor = kCellLineColor;
            [cell.contentView addSubview:lineLabel];
        }
        if(indexPath.section==2&&indexPath.row==0){
            titleLabel.frame = CGRectMake(16, 12, 100, 18);
            UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(16, 36, 230, 13) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e") test:@"关注你的人、同行可以看到你发布的活动" font:12 number:1 nstextLocat:NSTextAlignmentLeft];
            [cell.contentView addSubview:contentLabel];
            UISwitch *switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(WIDTH-67, 15, 51, 31)];
            switchBtn.tintColor = HEX_COLOR(@"d8d8d8");
            switchBtn.backgroundColor = WHITE_COLOR;
            [switchBtn setOnTintColor:HEX_COLOR(@"1abc9c")];
            [cell.contentView addSubview:switchBtn];
            [switchBtn addTarget:self action:@selector(switchButtonClicked:) forControlEvents:UIControlEventValueChanged];
            [switchBtn setOn:_publishDynamic];
        }else if(indexPath.section==0&&indexPath.row==1){
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(59, 10, WIDTH-59-16, 30)];
            textField.textColor = HEX_COLOR(@"41464e");
            textField.placeholder = @"不超过30个字";
            textField.font = FONT_SYSTEM_SIZE(17);
            textField.textAlignment = NSTextAlignmentRight;
             [textField setReturnKeyType:UIReturnKeyDone];
            textField.delegate = self;
            textField.tag = 201;
            [cell.contentView addSubview:textField];
            if([CommonMethod paramStringIsNull:self.model.name].length){
                textField.text = self.model.name;
            }
        }else{
            UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(97, 10, WIDTH-97-37, 30) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:@"" font:17 number:1 nstextLocat:NSTextAlignmentRight];
            [cell.contentView addSubview:contentLabel];
            
            UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-30, 16, 14, 15)];
            iconImageView.contentMode = UIViewContentModeScaleAspectFit;
            iconImageView.image = kImageWithName(@"icon_next_gray");
            [cell.contentView addSubview:iconImageView];
            
            if(indexPath.section==0){
                if(indexPath.row == 2){//开始时间
                    iconImageView.image = kImageWithName(@"icon_calendar_c");
                    contentLabel.text = [CommonMethod paramStringIsNull:self.model.begintime];
                }else if(indexPath.row == 3){//结束时间
                    iconImageView.image = kImageWithName(@"icon_calendar_c");
                    contentLabel.text = [CommonMethod paramStringIsNull:self.model.endtime];
                }else if(indexPath.row == 4){//地点
                    iconImageView.image = kImageWithName(@"icon_address_a");
                    contentLabel.text = [NSString stringWithFormat:@"%@ %@", [CommonMethod paramStringIsNull:self.model.cityname],[CommonMethod paramStringIsNull:self.model.districtname]];
                    if([CommonMethod paramStringIsNull:self.model.address].length){
                        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(38, 59, WIDTH-76, 30)];
                        textField.textColor = HEX_COLOR(@"41464e");
                        textField.placeholder = @"不超过30个字";
                        textField.font = FONT_SYSTEM_SIZE(17);
                        textField.textAlignment = NSTextAlignmentRight;
                        [cell.contentView addSubview:textField];
                        if([CommonMethod paramStringIsNull:self.model.address].length){
                            textField.text = self.model.address;
                        }
                        [textField.rac_textSignal subscribeNext:^(NSString *text) {
                            if(text.length>30){
                                textField.text = [text substringToIndex:30];
                            }
                            self.model.address = text;
                        }];
                        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 97.5, WIDTH-32, 0.5)];
                        lineLabel.backgroundColor = kCellLineColor;
                        [cell.contentView addSubview:lineLabel];
                    }
                }else if(indexPath.row == 5){//标签
                    CGFloat start_X = 0;
                    NSArray *tags = [CommonMethod paramArrayIsNull:[self.model.tags componentsSeparatedByString:@","]];
                    for (int i=0; i < tags.count; i++) {
                        NSString *tagStr = tags[i];
                        UIButton *tagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                        [tagBtn setTitle:tagStr forState:UIControlStateNormal];
                        [tagBtn setTitleColor:HEX_COLOR(@"1ABC9C") forState:UIControlStateNormal];
                        tagBtn.titleLabel.font = FONT_SYSTEM_SIZE(12);
                        CGFloat strWidth = [NSHelper widthOfString:tagStr font:FONT_SYSTEM_SIZE(12) height:21]+16;
                        tagBtn.frame = CGRectMake(WIDTH-37-start_X-strWidth, 14, strWidth, 21);
                        tagBtn.tag = i;
                        tagBtn.userInteractionEnabled = NO;
                        [CALayer updateControlLayer:tagBtn.layer radius:2 borderWidth:0.5 borderColor:HEX_COLOR(@"1ABC9C").CGColor];
                        [cell.contentView addSubview:tagBtn];
                        start_X += strWidth+6;
                    }
                }else if(indexPath.row == 6){
                    if([CommonMethod paramStringIsNull:self.model.intro].length){
                        contentLabel.text = @"已填写";
                    }else{
                        contentLabel.text = @"";
                    }
                }
            }else{
                if(indexPath.row == 0){
                    if([CommonMethod paramArrayIsNull:self.model.tickets].count||[CommonMethod paramStringIsNull:self.model.phone].length||[CommonMethod paramStringIsNull:self.model.applyendtime].length){
                        contentLabel.text = @"已设置";
                    }else{
                        contentLabel.text = @"免费/人数不限";
                    }
                }else if(indexPath.row == 1){
                    if([CommonMethod paramArrayIsNull:self.model.guests].count){
                        contentLabel.text = @"已填写";
                    }else{
                        contentLabel.text = @"";
                    }
                }
            }
        }
    }
    return cell;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
     [textField resignFirstResponder];
    return YES;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            ActivityCoverViewController *vc = [[ActivityCoverViewController alloc] init];
            vc.selectedCover = ^(UIImage *coverImage, NSString *imageUrl){
                if(coverImage){
                    weakSelf.model.imagePhoto = coverImage;
                    weakSelf.model.image = @"";
                }else{
                    weakSelf.model.imagePhoto = nil;
                    weakSelf.model.image = imageUrl;
                }
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            };
            [self.navigationController pushViewController:vc animated:YES];
        }else if(indexPath.row == 2){
            DatePikerView *view = [CommonMethod getViewFromNib:NSStringFromClass([DatePikerView class])];
            view.type = kDatePikerViewTypeSecond;
            view.sceneType = SceneType_Activity;
            view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
            if([CommonMethod paramStringIsNull:self.model.begintime].length){
                [view updateSelectRow:[NSDate dateFromString:self.model.begintime format:kTimeFormat1]];
            }else{
                [view updateSelectRow:[NSDate date]];
            }
            view.pickerSelectBlock = ^(id param, NSString *value){
                if(value.length && [NSDate secondsAwayFrom:[NSDate dateFromString:value format:kTimeFormat1] dateSecond:[NSDate date]]<=0){
                    [weakSelf.view showToastMessage:@"开始时间必须大于当前时间"];
                    return;
                }
                weakSelf.model.begintime = value;
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            };
            [[UIApplication sharedApplication].keyWindow addSubview:view];
            [view showShareNormalView];
        }else if(indexPath.row == 3){
            DatePikerView *view = [CommonMethod getViewFromNib:NSStringFromClass([DatePikerView class])];
            view.type = kDatePikerViewTypeSecond;
            view.sceneType = SceneType_Activity;
//            view.clearBtn.hidden = NO;
            view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
            if([CommonMethod paramStringIsNull:self.model.endtime].length){
                [view updateSelectRow:[NSDate dateFromString:self.model.endtime format:kTimeFormat1]];
            }else{
                [view updateSelectRow:[NSDate date]];
            }
            view.pickerSelectBlock = ^(id param, NSString *value){
                if(value.length && [NSDate secondsAwayFrom:[NSDate dateFromString:value format:kTimeFormat1] dateSecond:[NSDate date]]<=0){
                    [weakSelf.view showToastMessage:@"结束时间必须大于当前时间"];
                    return;
                }
                if(value.length && [CommonMethod paramStringIsNull:weakSelf.model.begintime].length&&[NSDate secondsAwayFrom:[NSDate dateFromString:value format:kTimeFormat1] dateSecond:[NSDate dateFromString:weakSelf.model.begintime format:kTimeFormat1]]<=0){
                    [weakSelf.view showToastMessage:@"结束时间必须大于开始时间"];
                    return;
                }
                weakSelf.model.endtime = value;
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            };
            [[UIApplication sharedApplication].keyWindow addSubview:view];
            [view showShareNormalView];
        }else if(indexPath.row == 4){
            ActivityLocationViewController *vc = [[ActivityLocationViewController alloc] init];
            vc.selectLoaction = ^(AMapPOI *model){
                weakSelf.model.lat = @(model.location.latitude);
                weakSelf.model.lng = @(model.location.longitude);
                weakSelf.model.provincename = model.province;
                weakSelf.model.cityname = model.city;
                weakSelf.model.districtname = model.district;
                weakSelf.model.address = [NSString stringWithFormat:@"%@ %@",model.name,model.address];
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            };
            [self.navigationController pushViewController:vc animated:YES];
        }else if(indexPath.row == 5){
            
            ChoseActivityViewController *vc = [[ChoseActivityViewController alloc]init];
            if(self.model.tags){
                vc.actSelectedTagArray = [self.model.tags componentsSeparatedByString:@","];
            }
            vc.activitySeletedTagsStr = ^(NSString *tags){
                weakSelf.model.tags = tags;
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:5 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            };
            [self.navigationController pushViewController:vc animated:YES];
        }else if(indexPath.row == 6){
            ZSSRichTextEditor *vc = [CommonMethod getVCFromNib:[ZSSRichTextEditor class]];
            vc.type = EditotType_Activity;
            vc.activityIntroduction = ^(NSString *IntroStr){
                weakSelf.model.intro = IntroStr;
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:6 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            };
            if(self.model.intro){
                vc.activityIntroStr = self.model.intro;
            }
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if(indexPath.section==1){
        if(indexPath.row == 0){
            ApplySettingViewController *vc = [[ApplySettingViewController alloc] init];
            vc.phone = [self.model.phone copy];
            vc.applyendtime = [self.model.applyendtime copy];
            vc.ticketsArray = [self.model.tickets mutableCopy];
            vc.endtime = [self.model.endtime copy];
            vc.applySetting = ^(NSMutableArray *ticketsArray, NSString *phone, NSString *applyendtime){
                weakSelf.model.phone = phone;
                weakSelf.model.applyendtime = applyendtime;
                weakSelf.model.tickets = ticketsArray;
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
            };
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            GuestSettingViewController *vc = [[GuestSettingViewController alloc] init];
            vc.guestsArray = [self.model.guests mutableCopy];
            vc.guestSetting = ^(NSMutableArray *guestsArray){
                weakSelf.model.guests = guestsArray;
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (void)switchButtonClicked:(UISwitch*)sender{
    _publishDynamic = sender.on;
}

#pragma mark - UIScrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
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
        }else{
            self.tableView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64);
        }
    }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField.tag == 201){
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if(position && (range.length==0 || string.length==0)){
            return YES;
        }else{
            NSString *str = [textField.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:string];
            if(str.length>30){
                textField.text = [str substringToIndex:30];
                self.model.name = textField.text;
                return NO;
            }else{
                self.model.name = str;
            }
        }
    }
    return YES;
}

@end
