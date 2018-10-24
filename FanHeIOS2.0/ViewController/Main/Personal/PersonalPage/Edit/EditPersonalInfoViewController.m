//
//  EditPersonalInfoViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/25.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "EditPersonalInfoViewController.h"
#import "ChoiceAddressView.h"
#import "DatePikerView.h"
#import "RegisterJobInputViewController.h"
#import "RegisterJobSelectBusinessViewController.h"
#import "RichTextViewController.h"
#import "GoodAtViewController.h"
#import "ChangeIforController.h"
#import "AccountViewController.h"
#import "PersonInterestTagController.h"

@interface EditPersonalInfoViewController ()<RegisterJobInputViewControllerDelegate,TZImagePickerControllerDelegate,GoodAtViewControllerDelegate,ChangeIforControllerDelegate>
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UserModel *userModel;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIView *coveView;
/*
 0 ----- 公司
 1 －－－－职位
 2 －－－－行业
 3 －－－－从业时间
 4 －－－  工作地点
 5 －－－  姓名
 6 ------ 个人简介
 7 －－－ 邮箱号
 8 －－－微信号
 */
@property (nonatomic, assign) NSInteger delectTag;
@property (nonatomic, assign) NSInteger upType;
@property (nonatomic, strong) UILabel *myselfLabel;
@property (nonatomic, assign) BOOL isPresentVC;

@end

@implementation EditPersonalInfoViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setMyselfLabel];
    self.isPresentVC = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (!self.isPresentVC) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self removeViewTapGesture];
    
    self.userModel = [DataModelInstance shareInstance].userModel;
    
    self.dataArray = [NSMutableArray arrayWithObjects:
                      @[@{@"image":@"头像"},
                        @{@"realname":@"姓名"},
                        @{@"company":@"公司"},
                        @{@"industry":@"行业"},
                        @{@"position":@"职位"},
                        @{@"worktime":@"从业时间"},
                        @{@"address":@"工作地点"}],
                      @[@{@"goodjobs":@"擅长业务"}],
                      @[@{@"remark":@"个人简介"}],
                      @[@{@"remark":@"个人标签"}],
                      @[@{@"remark":@"兴趣标签"}],
                      @[@{@"phone":@"手机"},
                        @{@"email":@"邮箱"},
                        @{@"qq":@"微信号"}],
                      nil];
    
    [self createCustomNavigationBar:@"编辑"];
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    editBtn.frame = CGRectMake(WIDTH-60, 20, 50, 44);
    [editBtn setTitle:@"完成" forState:UIControlStateNormal];
    [editBtn setTitleColor:HEX_COLOR(@"818C9E") forState:UIControlStateNormal];
    editBtn.titleLabel.font = FONT_SYSTEM_SIZE(16);
    [editBtn addTarget:self action:@selector(saveInfoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    if (self.saveType !=  SaveType_Normal) {
        [self.view addSubview:editBtn];
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = kTableViewBgColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.0001)];
    UIView *tabHeadeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 50)];
    tabHeadeView.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tapMymessage = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(myMessageRemind)];
    [tabHeadeView addGestureRecognizer:tapMymessage];
    self.tableView.tableHeaderView = tabHeadeView;
    [self.view addSubview:self.tableView];
    
    self.myselfLabel = [UILabel createLabel:CGRectMake(0, 17, WIDTH, 16) font:[UIFont systemFontOfSize:14] bkColor:[UIColor clearColor] textColor:HEX_COLOR(@"F76B1C")];
    self.myselfLabel.textAlignment = NSTextAlignmentCenter;
    [self setMyselfLabel];
    [tabHeadeView addSubview:self.myselfLabel];
    
    UILabel *lineLabel = [UILabel createLabel:CGRectMake(0, 49.5, WIDTH, 0.5) font:[UIFont systemFontOfSize:10] bkColor:kCellLineColor textColor:kCellLineColor];
    [tabHeadeView addSubview:lineLabel];
}

- (void)setMyselfLabel{
    NSInteger rate = [CommonMethod getUserInfoCompletionRate];
    UIColor *circleColor;
    if(rate >= 80){
        circleColor = HEX_COLOR(@"1ABC9C");
    }else if(rate >= 60){
        circleColor = HEX_COLOR(@"F76B1C");
    }else{
        circleColor = HEX_COLOR(@"E24943");
    }
    self.myselfLabel.textColor = circleColor;
    NSString *titleMySelf = [NSString stringWithFormat:@"资料完善度%ld%%",rate];
    NSMutableAttributedString * attriStr = [[NSMutableAttributedString alloc] initWithString:titleMySelf];
    NSTextAttachment *attchImage = [[NSTextAttachment alloc] init];
    attchImage.image = [UIImage imageNamed:@"btn_zy_tw"];
    attchImage.bounds = CGRectMake(8, -2, 14, 14);
    NSAttributedString *stringImage = [NSAttributedString attributedStringWithAttachment:attchImage];
    [attriStr insertAttributedString:stringImage atIndex:titleMySelf.length];
    self.myselfLabel.attributedText = attriStr;
}

- (void)myMessageRemind{
    self.coveView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, HEIGHT) backColor:@""];
    [self.view addSubview:self.coveView];
    self.coveView.backgroundColor = [UIColor colorWithRed:65.0/255.0 green:70.0/255.0 blue:78.0/255 alpha:0.7];
    self.coveView.userInteractionEnabled = YES;
    NSString *str1 = @"1.完善度60%以下不会被推荐到人脉页面";
    NSString *str2 = @"2.完善度越高、曝光度越高";
    NSString *str3 = @"3.完善基本信息、认证信息、均可提升完整度";
    CGFloat heigth1 = [NSHelper heightOfString:str1 font:[UIFont systemFontOfSize:16] width:WIDTH - 140];
    CGFloat heigth2 = [NSHelper heightOfString:str2 font:[UIFont systemFontOfSize:16] width:WIDTH - 140];
    CGFloat heigth3 = [NSHelper heightOfString:str3 font:[UIFont systemFontOfSize:16] width:WIDTH - 140];
    CGFloat total = heigth1 + heigth2 + heigth3 + 100;
    UIView *view = [NSHelper createrViewFrame:CGRectMake(50, HEIGHT/2 - total/2, WIDTH - 100 , total) backColor:@"FFFFFF"];
    view.layer.cornerRadius = 8;
    view.layer.masksToBounds = YES;
    view.userInteractionEnabled = YES;
    [self.coveView addSubview:view];
    
    UILabel *label1 = [UILabel createLabel:CGRectMake(20, 18, WIDTH - 140, heigth1) font:[UIFont systemFontOfSize:16] bkColor:[UIColor clearColor] textColor:HEX_COLOR(@"383838")];
    label1.numberOfLines = 0;
    label1.text = str1;
    [view addSubview:label1];
    UILabel *label2 = [UILabel createLabel:CGRectMake(20,  label1.frame.origin.y + heigth1+ 4, WIDTH - 140, heigth2) font:[UIFont systemFontOfSize:16] bkColor:[UIColor clearColor] textColor:HEX_COLOR(@"383838")];
    label2.text = str2;
    label2.numberOfLines = 0;
    [view addSubview:label2];
    UILabel *label3 = [UILabel createLabel:CGRectMake(20,label2.frame.origin.y+heigth2 + 4 , WIDTH - 140, heigth3) font:[UIFont systemFontOfSize:16] bkColor:[UIColor clearColor] textColor:HEX_COLOR(@"383838")];
    label3.text = str3;
    label3.numberOfLines = 0;
    [view addSubview:label3];
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,total - 50.5, WIDTH, 0.5)];
    lineLabel.backgroundColor = HEX_COLOR(@"D9D9D9");
    [view addSubview:lineLabel];
    UIButton *btn = [NSHelper createButton:CGRectMake(0, total - 50, WIDTH - 100, 49) title:@"确定" unSelectImage:nil selectImage:nil target:self selector:@selector(removeCoveView)];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [view addSubview:btn];
}

- (void)removeCoveView{
    [self.coveView removeFromSuperview];
}

- (void)customNavBackButtonClicked{
    if (self.saveType !=  SaveType_Normal) {
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否放弃编辑资料？" cancelButtonTitle:@"放弃" otherButtonTitle:@"继续编辑" cancle:^{
            [self.navigationController popViewControllerAnimated:YES];
        } confirm:^{
        }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)showError:(NSString*)error{
    [MBProgressHUD showError:error toView:self.view];
}

//点击保存，需做如下判断
- (BOOL)justfiyModel{
    if (self.saveType == SaveType_Identify) {
        if(self.userModel.image.length == 0){
            [self showError:@"请上传头像"];
            return NO;
        }else if(self.userModel.realname.length == 0){
            [self showError:@"请填写姓名"];
            return NO;
        }else if(self.userModel.company.length == 0){
            [self showError:@"请填写公司"];
            return NO;
        }
    }else if (self.saveType == SaveType_AddFriends)  {
        if(self.userModel.image.length == 0){
            [self showError:@"请上传头像"];
            return NO;
        }else if(self.userModel.realname.length == 0){
            [self showError:@"请填写姓名"];
            return NO;
        }else if(self.userModel.company.length == 0){
            [self showError:@"请填写公司"];
            return NO;
        }else if(self.userModel.position.length == 0){
            [self showError:@"请填写职位"];
            return NO;
        }else if (self.userModel.goodjobs.count == 0){
            [self showError:@"请添加擅长业务"];
            return NO;
        }
    }
    return YES;
}

//当该用户为认证用户时，修改了公司、职位、手机信息后，点击提交
- (BOOL)justifyModelNeedIdentify{
    UserModel *tmpModel = [DataModelInstance shareInstance].userModel;
    if((![self.userModel.realname isEqualToString:tmpModel.realname] || ![self.userModel.company isEqualToString:tmpModel.company] || ![self.userModel.position isEqualToString:tmpModel.position] || ![self.userModel.phone isEqualToString:tmpModel.phone]) && tmpModel.hasValidUser.integerValue == 1){
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - 保存
- (void)saveInfoButtonClicked:(UIButton*)sender{
    if (self.saveType == SaveType_Identify) {
        if(![self justfiyModel]){
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"修改资料后，需重新认证。是否确认修改？" cancelButtonTitle:@"确定" otherButtonTitle:@"取消" cancle:^{
                [self postChangeMyMessage];
            } confirm:^{
                
            }];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else if (self.saveType == SaveType_AddFriends) {
        if(![self justfiyModel]){
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"修改资料后，需重新认证。是否确认修改？" cancelButtonTitle:@"确定" otherButtonTitle:@"取消" cancle:^{
                [self postChangeMyMessage];
            } confirm:^{
                
            }];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)postChangeMyMessage{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"保存中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:self.userModel.userId forKey:@"userid"];
    /*
     0 ----- 公司
     1 －－－－职位
     2 －－－－行业
     3 －－－－从业时间
     4 －－－  工作地点
     5 －－－  姓名
     6 --- 个人简介
     7 －－－ 邮箱号
     8 －－－微信号
     9 ---- addd(上传擅长业务)
     
     */
    if (self.upType == 0) {
        [requestDict setObject:self.userModel.company forKey:@"companyname"];
    }else if (self.upType == 1) {
        [requestDict setObject:self.userModel.position forKey:@"position"];
    }else if (self.upType == 2) {
        [requestDict setObject:self.userModel.industry forKey:@"industry"];
    }else if (self.upType == 3) {
        [requestDict setObject:[CommonMethod paramStringIsNull:self.userModel.worktime] forKey:@"worktime"];
    }else if (self.upType == 4) {
        [requestDict setObject:self.userModel.provinceid forKey:@"province"];
        [requestDict setObject:self.userModel.cityid forKey:@"city"];
        [requestDict setObject:self.userModel.districtid forKey:@"district"];
    }else if (self.upType == 6){
        [requestDict setObject:[CommonMethod paramStringIsNull:self.userModel.remark] forKey:@"remark"];
    }else if (self.userModel.career > 0 && self.upType == 9){
        [requestDict setObject:[self.userModel.goodjobs componentsJoinedByString:@","] forKey:@"business"];
    }
    [self requstType:RequestType_Post apiName:API_NAME_SAVE_MY_INFO paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if (weakSelf.upType == 0 ||  weakSelf.upType == 1) {
                if (weakSelf.userModel.hasValidUser.integerValue == 1) {
                    weakSelf.userModel.hasValidUser = [NSNumber numberWithInt:0];
                    [DataModelInstance shareInstance].userModel = weakSelf.userModel;
                }
            }
            weakSelf.userModel.hasValidUser = @(0);
            if(weakSelf.savePersonalInfoSuccess){
                weakSelf.savePersonalInfoSuccess();
            }
            [DataModelInstance shareInstance].userModel = weakSelf.userModel;
            [weakSelf setMyselfLabel];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - UITableViewDelegate/Data
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *array = self.dataArray[section];
    return [array count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0 || indexPath.section == 5){
        if (indexPath.section == 0 && indexPath.row == 0) {
            return 95;
        }
        return 49;
    }else if(indexPath.section == 1 || indexPath.section == 3 || indexPath.section == 4){
        NSArray *array;
        if(indexPath.section == 1){
            array = self.userModel.goodjobs;
        }else if(indexPath.section == 3){
            array = self.userModel.selftag;
        }else{
            array = self.userModel.interesttag;
        }
        CGFloat start_X = 16;
        CGFloat start_Y = 24;
        for(int i = 0; i < array.count; i++){
            NSString *str;
            if(indexPath.section == 1){
                str = [NSString stringWithFormat:@"#%@#", array[i]];
            }else{
                str = array[i];
            }
            CGFloat strWidth = [NSHelper widthOfString:str font:FONT_SYSTEM_SIZE(13) height:29]+13;
            if(start_X+strWidth > WIDTH-57){
                start_X = 16;
                start_Y += 37;
            }
            if(strWidth > WIDTH-57){
                strWidth = WIDTH - 57;
            }
            start_X += strWidth+6;
        }
        
        if(array.count){
            return start_Y+29+24;
        }else{
            return 65;
        }
    }else if(indexPath.section == 2){
        if (self.userModel.remark.length > 0) {
            CGFloat strHeight = [NSHelper heightOfString:self.userModel.remark font:FONT_SYSTEM_SIZE(14) width:WIDTH-48];
            strHeight += (NSInteger)strHeight/FONT_SYSTEM_SIZE(14).lineHeight*11;
            strHeight += 37;
            return strHeight;
        }else{
            return 65;
        }
    }
    return 49;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 32;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString *str = @"";
    switch (section) {
        case 0:
            str = @"基本资料";
            break;
        case 1:
            str = @"擅长业务";
            break;
        case 2:
            str = @"个人简介";
            break;
        case 3:
            str = @"个人标签";
            break;
        case 4:
            str = @"兴趣标签";
            break;
        default:
            str = @"联系方式";
            break;
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 32)];
    headerView.userInteractionEnabled = YES;
    headerView.backgroundColor = kTableViewBgColor;
    UILabel *textLabel = [UILabel createrLabelframe:CGRectMake(16, 0, WIDTH-16, 32) backColor:kTableViewBgColor textColor:HEX_COLOR(@"818C9E") test:str font:14 number:1 nstextLocat:NSTextAlignmentLeft];
    [headerView addSubview:textLabel];
    
    return headerView;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = self.dataArray[indexPath.section][indexPath.row];
    NSString *keyStr = dict.allKeys[0];
    if(indexPath.section == 0){
        static NSString *identify = @"UITableViewCellInfo";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        UILabel *titleLabel = [UILabel createLabel:CGRectMake(16, 16, 75, 18) font:FONT_SYSTEM_SIZE(17) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"AFB6C1")];
        titleLabel.text = dict[keyStr];
        [cell.contentView addSubview:titleLabel];
        if (indexPath.row == 0) {
            titleLabel.frame = CGRectMake(16, 38.5, 75, 18);
            UIImageView *nextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-25, 39, 8, 15)];
            nextImageView.image = kImageWithName(@"icon_next_gray");
            [cell.contentView addSubview:nextImageView];
            
            self.coverImageView = [UIImageView drawImageViewLine:CGRectMake(WIDTH - 95, 16, 62, 62) bgColor:[UIColor whiteColor]];
            self.coverImageView.layer.masksToBounds = YES; //没这句话它圆不起来
            self.coverImageView.layer.cornerRadius = 31.0; //设置图片圆角的尺度
            [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:[self.userModel valueForKey:keyStr]] placeholderImage:KHeadImageDefaultName(self.userModel.realname)];
            [cell.contentView addSubview:self.coverImageView];
        }else{
            UILabel *contentLabel = [UILabel createLabel:CGRectMake(97, 0, WIDTH-113, 49) font:FONT_SYSTEM_SIZE(17) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"41464E")];
            if (self.saveType != SaveType_Normal) {
                contentLabel.textColor = HEX_COLOR(@"E24943");
            }
            if(indexPath.row == 5){
                if(self.userModel.worktime.length){
                    contentLabel.text = [NSDate stringFromDate:[NSDate dateFromString:[self.userModel.worktime substringToIndex:7] format:kTimeFormatMonth] format:kTimeFormatMonthChinese];
                }else{
                    contentLabel.text = [NSString stringWithFormat:@"请选择%@", dict[keyStr]];
                    contentLabel.textColor = HEX_COLOR(@"e6e8eb");
                }
            }else{
                if ([CommonMethod paramStringIsNull:[self.userModel valueForKey:keyStr]].length) {
                    contentLabel.text = [self.userModel valueForKey:keyStr];
                }else{
                    contentLabel.textColor = HEX_COLOR(@"e6e8eb");
                    if (indexPath.row == 6  || indexPath.row == 3) {
                        contentLabel.text = [NSString stringWithFormat:@"请选择%@", dict[keyStr]];
                    }else{
                        contentLabel.text = [NSString stringWithFormat:@"请输入%@", dict[keyStr]];
                    }
                }
            }
            contentLabel.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:contentLabel];
            if(indexPath.row >= 1 && indexPath.row <= 4){
                contentLabel.frame = CGRectMake(97, 0, WIDTH-130, 49);
                UIImageView *nextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-25, 17, 8, 15)];
                nextImageView.image = kImageWithName(@"icon_next_gray");
                [cell.contentView addSubview:nextImageView];
            }
        }
        return cell;
    }else if(indexPath.section == 1 || indexPath.section == 3 || indexPath.section == 4){
        static NSString *identify = @"UITableViewCellGoodjob";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        NSArray *array;
        NSString *color;
        NSString *placeholder;
        if(indexPath.section == 1){
            array = self.userModel.goodjobs;
            color = @"1ABC9C";
            placeholder = @"点击添加擅长业务";
        }else if(indexPath.section == 3){
            array = self.userModel.selftag;
            color = @"1ABC9C";
            placeholder = @"点击添加个人标签";
        }else{
            array = self.userModel.interesttag;
            color = @"3498db";
            placeholder = @"点击添加兴趣标签";
        }
        CGFloat start_X = 16;
        CGFloat start_Y = 24;
        for(int i = 0; i < array.count; i++){
            NSString *str;
            if(indexPath.section == 1){
                str = [NSString stringWithFormat:@"#%@#", array[i]];
            }else{
                str = array[i];
            }
            CGFloat strWidth = [NSHelper widthOfString:str font:FONT_SYSTEM_SIZE(13) height:29]+13;
            if(start_X+strWidth > WIDTH-57){
                start_X = 16;
                start_Y += 37;
            }
            if(strWidth > WIDTH-57){
                strWidth = WIDTH - 57;
            }
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            [btn setTitle:str forState:UIControlStateNormal];
            btn.titleLabel.font = FONT_SYSTEM_SIZE(13);
            [btn setTitleColor:HEX_COLOR(color) forState:UIControlStateNormal];
            btn.frame = CGRectMake(start_X, start_Y, strWidth, 29);
            btn.layer.cornerRadius = 2;
            btn.userInteractionEnabled = NO;
            btn.layer.borderColor = HEX_COLOR(color).CGColor;
            btn.layer.borderWidth = 0.5;
            [cell.contentView addSubview:btn];
            start_X += strWidth+6;
        }
        
        if(array.count == 0) {
            UILabel *label = [UILabel createLabel:CGRectMake(16, 24, WIDTH - 16, 17) font:[UIFont systemFontOfSize:17] bkColor:[UIColor clearColor] textColor:HEX_COLOR(@"E6E8EB")];
            label.text = placeholder;
            [cell.contentView addSubview:label];
            start_Y = 65;
        }else{
            start_Y += 53;
        }
        UIImageView *nextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-25, start_Y/2-7.5, 9, 15)];
        nextImageView.image = kImageWithName(@"icon_next_gray");
        [cell.contentView addSubview:nextImageView];
        return cell;
    }else if(indexPath.section == 2){
        static NSString *identify = @"UITableViewCellJianjie";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        NSString *contentStr = [self.userModel valueForKey:keyStr];
        CGFloat strHeight = [NSHelper heightOfString:self.userModel.remark font:FONT_SYSTEM_SIZE(14) width:WIDTH-48];
        strHeight += (NSInteger)strHeight/FONT_SYSTEM_SIZE(14).lineHeight*11;
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 20, WIDTH-48, strHeight)];
        contentLabel.font = FONT_SYSTEM_SIZE(14);
        contentLabel.textColor = HEX_COLOR(@"41464E");
        if(contentStr.length){
            [contentLabel setParagraphText:contentStr lineSpace:11];
        }else{
            contentLabel.frame = CGRectMake(16, 24, WIDTH-48, 18);
            contentLabel.font = [UIFont systemFontOfSize:17];
            contentLabel.textColor = HEX_COLOR(@"E6E8EB");
            contentLabel.text = @"点击编辑个人简介";
        }
        contentLabel.numberOfLines = 0;
        contentLabel.textAlignment = NSTextAlignmentJustified;
        [cell.contentView addSubview:contentLabel];
        UIImageView *nextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-25, (strHeight+37)/2, 9, 15)];
        if (contentStr.length <= 0) {
            nextImageView.frame = CGRectMake(WIDTH-25, 65/2-7.5, 9, 15);
        }
        
        nextImageView.image = kImageWithName(@"icon_next_gray");
        [cell.contentView addSubview:nextImageView];
        return cell;
    }else{
        static NSString *identify = @"UITableViewCellqq";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        UILabel *titleLabel = [UILabel createLabel:CGRectMake(16, 0, 75, 49) font:FONT_SYSTEM_SIZE(17) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"AFB6C1")];
        titleLabel.text = dict[keyStr];
        [cell.contentView addSubview:titleLabel];
        UILabel *subTitleLabel = [UILabel createLabel:CGRectMake(97, 0, WIDTH-128, 49) font:FONT_SYSTEM_SIZE(17) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"41464E")];
        subTitleLabel.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:subTitleLabel];
        
        UIImageView *nextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-25, 17, 8, 15)];
        nextImageView.image = kImageWithName(@"icon_next_gray");
        [cell.contentView addSubview:nextImageView];
        if(indexPath.row == 0){
            if (self.userModel.phone.length <= 0) {
                subTitleLabel.textColor = HEX_COLOR(@"e6e8eb");
                subTitleLabel.text = [NSString stringWithFormat:@"请输入%@", dict[keyStr]];
            }else{
                subTitleLabel.text = self.userModel.phone;
            }
        }else if(indexPath.row == 1){
            if (self.userModel.email.length <= 0) {
                subTitleLabel.textColor = HEX_COLOR(@"e6e8eb");
                subTitleLabel.text = [NSString stringWithFormat:@"请输入%@", dict[keyStr]];
            }else{
                subTitleLabel.text = self.userModel.email;
            }
        }else if(indexPath.row == 2){
            if (self.userModel.weixin.length <= 0) {
                subTitleLabel.textColor = HEX_COLOR(@"e6e8eb");
                subTitleLabel.text = [NSString stringWithFormat:@"请输入%@", dict[keyStr]];
            }else{
                subTitleLabel.text = self.userModel.weixin;
            }
        }
        [cell.contentView addSubview:subTitleLabel];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    __weak typeof(self) weakSelf = self;
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            self.isPresentVC = YES;
            UploadImageTypeView *view = [CommonMethod getViewFromNib:@"UploadImageTypeView"];
            view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
            [view setUploadImageTypeViewType:UploadImageTypeViewType_UploadHeaderImage];
            view.uploadHeaderImageViewResult = ^(BOOL success){
                if(success){
                    weakSelf.userModel = [DataModelInstance shareInstance].userModel;
                    [weakSelf.coverImageView sd_setImageWithURL:[NSURL URLWithString:weakSelf.userModel.image] placeholderImage:KHeadImageDefaultName(self.userModel.realname)];
                    [weakSelf setMyselfLabel];
                    if(weakSelf.savePersonalInfoSuccess){
                        weakSelf.savePersonalInfoSuccess();
                    }
                }
            };
            [[UIApplication sharedApplication].keyWindow addSubview:view];
            [view showShareNormalView];
        }else if(indexPath.row == 1){
            self.upType = 5;
            self.isPresentVC = YES;
            ChangeIforController *change = [[ChangeIforController alloc]init];
            change.titleStr = @"姓名";
            change.index = 5;
            change.changeDelegate = self;
            [self presentViewController:change animated:YES completion:nil];
        }else if(indexPath.row == 5){
            [self choiceTime];
        }else if(indexPath.row == 6){
            [self choiceLocation];
        }else{
            [self choiceJobType:indexPath.row];
        }
    }else if(indexPath.section == 1){
        self.isPresentVC = YES;
        GoodAtViewController *vc = [[GoodAtViewController alloc]init];
        self.upType = 9;
        vc.array = self.userModel.goodjobs;
        vc.gooJobDelegate = self;
        [self presentViewController:vc animated:YES completion:nil];
    }else if(indexPath.section == 2){
        self.isPresentVC = YES;
        RichTextViewController *vc = [CommonMethod getVCFromNib:[RichTextViewController class]];
        vc.isPersonalRemark = YES;
        vc.content = self.userModel.remark;
        vc.savePersonalRemark = ^(NSString *remark){
            weakSelf.userModel.remark = remark;
            weakSelf.upType = 6;
            [weakSelf postChangeMyMessage];
            [weakSelf.tableView reloadData];
        };
        [self presentViewController:vc animated:YES completion:nil];
    }else if (indexPath.section == 3){
        self.isPresentVC = YES;
        PersonInterestTagController *vc = [CommonMethod getVCFromNib:[PersonInterestTagController class]];
        vc.isSelfTag = YES;
        vc.saveTagSuccess = ^(NSMutableArray *array) {
            weakSelf.userModel.selftag = array;
            [DataModelInstance shareInstance].userModel = weakSelf.userModel;
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
            if(weakSelf.savePersonalInfoSuccess){
                weakSelf.savePersonalInfoSuccess();
            }
        };
        vc.dataArray = [NSMutableArray arrayWithArray:self.userModel.selftag];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.section == 4){
        self.isPresentVC = YES;
        PersonInterestTagController *vc = [CommonMethod getVCFromNib:[PersonInterestTagController class]];
        vc.isSelfTag = NO;
        vc.saveTagSuccess = ^(NSMutableArray *array) {
            weakSelf.userModel.interesttag = array;
            [DataModelInstance shareInstance].userModel = weakSelf.userModel;
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
            if(weakSelf.savePersonalInfoSuccess){
                weakSelf.savePersonalInfoSuccess();
            }
        };
        vc.dataArray = [NSMutableArray arrayWithArray:self.userModel.interesttag];
        [self.navigationController pushViewController:vc animated:YES];
    }else if(indexPath.section == 5){
        if (indexPath.row == 0) {
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"您已绑定此手机号，可通过手机号+密码的方式登录“3号圈”" cancelButtonTitle:@"取消" otherButtonTitle:@"去设置" cancle:^{
            } confirm:^{
                weakSelf.isPresentVC = YES;
                AccountViewController *account = [[AccountViewController alloc]init];
                [weakSelf.navigationController pushViewController:account  animated:YES];
            }];
        }else if(indexPath.row == 1){
            self.upType = 7;
            self.isPresentVC = YES;
            ChangeIforController *change = [[ChangeIforController alloc]init];
            change.titleStr = @"邮箱";
            change.index = 7;
            change.changeDelegate = self;
            [self presentViewController:change animated:YES completion:nil];
        }else{
            self.upType = 8;
            self.isPresentVC = YES;
            ChangeIforController *change = [[ChangeIforController alloc]init];
            change.titleStr = @"微信号";
            change.index = 8;
            change.changeDelegate = self;
            [self presentViewController:change animated:YES completion:nil];
        }
    }
}

#pragma mark--擅长业务 删除
- (void)deleteTagButtonClicked:(UIButton*)sender{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.userModel.goodjobs];
    [array removeObjectAtIndex:sender.tag-200];
    self.userModel.goodjobs = array;
    [self.tableView reloadData];
}

#pragma mark - 选择工作地点
- (void)choiceLocation{
    ChoiceAddressView *modifyView = [CommonMethod getViewFromNib:NSStringFromClass([ChoiceAddressView class])];
    [modifyView updateDisplay:self.userModel.provinceid.stringValue cityId:self.userModel.cityid.stringValue districtId:self.userModel.districtid.stringValue];
    modifyView.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    @weakify(self);
    modifyView.selectAddress = ^(NSString *provinceId, NSString *cityId, NSString *districtId){
        @strongify(self);
        self.userModel.provinceid = @(provinceId.integerValue);
        self.userModel.cityid = @(cityId.integerValue);
        self.userModel.districtid = @(districtId.integerValue);
        self.userModel.address = [NSString stringWithFormat:@"%@%@%@",[[[DBInstance shareInstance] getCitysModelById:provinceId] Name],[[[DBInstance shareInstance] getCitysModelById:cityId] Name],[[[DBInstance shareInstance] getCitysModelById:districtId] Name]];
        self.upType = 4;
        [self postChangeMyMessage];
        [self.tableView reloadData];
    };
    [[UIApplication sharedApplication].keyWindow addSubview:modifyView];
    [modifyView showShareNormalView];
}

#pragma mark - 工作时间
- (void)choiceTime{
    DatePikerView *view = [CommonMethod getViewFromNib:NSStringFromClass([DatePikerView class])];
    view.type = kDatePikerViewTypeMonth;
    view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    if(self.userModel.worktime.length){
        [view updateSelectRow:[NSDate dateFromString:[self.userModel.worktime substringToIndex:7] format:kTimeFormatMonth]];
    }else{
        [view updateSelectRow:[NSDate date]];
    }
    view.pickerSelectBlock = ^(id param, NSString *value){
        if (value == nil) {
            self.userModel.worktime = nil;
        }else if([NSDate daysAwayFromToday:[NSDate dateFromString:value format:kTimeFormatMonth]] >= 0){
            value = [NSDate stringFromDate:[NSDate date] format:kTimeFormatMonthChinese];
        }else{
            value = [NSDate stringFromDate:[NSDate dateFromString:value format:kTimeFormatMonth] format:kTimeFormatMonthChinese];
        }
        self.userModel.worktime = [NSDate stringFromDate:[NSDate dateFromString:value format:kTimeFormatMonthChinese] format:kTimeFormatMonth];
        
        self.upType = 3;
        [self postChangeMyMessage];
        [self.tableView reloadData];
    };
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view showShareNormalView];
}

#pragma mark - 公司、职位、行业
- (void)choiceJobType:(NSInteger)tag{
    self.isPresentVC = YES;
    if(tag == 2){
        self.upType = 0;
        RegisterJobInputViewController *vc = [CommonMethod getVCFromNib:[RegisterJobInputViewController class]];
        vc.delegate = self;
        vc.comapyStr = [DataModelInstance shareInstance].userModel.company;
        vc.jobParamType = JOB_PARAM_COMPANY;
        [self presentViewController:vc animated:YES completion:nil];
        
    }else if(tag == 4){
        self.upType = 1;
        RegisterJobInputViewController *vc = [CommonMethod getVCFromNib:[RegisterJobInputViewController class]];
        vc.delegate = self;
        vc.comapyStr =  [DataModelInstance shareInstance].userModel.position;
        vc.jobParamType = JOB_PARAM_POSITION;
        [self presentViewController:vc animated:YES completion:nil];
    }else{
        self.upType = 2;
        RegisterJobSelectBusinessViewController *vc = [CommonMethod getVCFromNib:[RegisterJobSelectBusinessViewController class]];
        vc.selectBusinessStr = self.userModel.industry;
        vc.selectBusiness = ^(NSString *business){
            self.userModel.industry = business;
            [self postChangeMyMessage];
            
            [self.tableView reloadData];
        };
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - RegisterJobInputViewControllerDelegate
- (void)RegisterJobInputViewControllerDelegateChoiceParam:(NSString *)param isCompany:(JOB_PARAM)jobParam{
    if(jobParam == JOB_PARAM_COMPANY){
        self.userModel.company = param;
        
        [self postChangeMyMessage];
    }else if(jobParam == JOB_PARAM_BUSINESS){
        NSMutableArray *array = [NSMutableArray arrayWithArray:self.userModel.goodjobs];
        if(![array containsObject:param] && array.count < 3){
            [array addObject:param];
            self.userModel.goodjobs = array;
        }
        [self postChangeMyMessage];
    }else if(jobParam == JOB_PARAM_POSITION){
        self.userModel.position = param;
        [self postChangeMyMessage];
    }
    
    [self.tableView reloadData];
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

#pragma mark ----------- GoodAtViewControllerDelegate
- (void)referViewGoodAtJob{
    if(self.savePersonalInfoSuccess){
        self.savePersonalInfoSuccess();
    }
    self.userModel = [DataModelInstance shareInstance].userModel;
    // 获取所点目录对应的indexPath值
    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:selectIndexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)changeMyMessage:(NSString*)changeStr{
    if(self.savePersonalInfoSuccess){
        self.savePersonalInfoSuccess();
    }
    NSInteger index = 0;
    NSInteger section = 0;
    if (self.upType == 5) {
        index = 1;
        self.userModel.realname = changeStr;
        section = 0;
        if([CommonMethod paramStringIsNull:self.userModel.image].length == 0){
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }else if (self.upType == 7) {
        index = 1;
        self.userModel.email = changeStr;
        section = 5;
    }if (self.upType == 8) {
        index = 2;
        self.userModel.weixin = changeStr;
        section = 5;
    }
    [DataModelInstance shareInstance].userModel = self.userModel;
    // 获取所点目录对应的indexPath值
    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:index inSection:section];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:selectIndexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

@end
