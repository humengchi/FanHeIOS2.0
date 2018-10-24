//
//  AdminGetCoffeeViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/9/5.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "AdminGetCoffeeViewController.h"
#import "AdminGetCoffeeResultViewController.h"

@interface AdminGetCoffeeViewController ()

@property (nonatomic, weak) IBOutlet UITableView    *theTableView;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UIButton *callBackBtn;
@property (weak, nonatomic) IBOutlet UIButton *exchangeBtn;
@property (weak, nonatomic) IBOutlet UIButton *hangCoffeeBtn;

@end

@implementation AdminGetCoffeeViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kBackgroundColorDefault;
    self.theTableView.delegate = self;
    self.theTableView.backgroundColor = kBackgroundColorDefault;
    self.theTableView.dataSource = self;
    self.theTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.theTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.codeLabel.text = [CommonMethod paramStringIsNull:self.model.code];
}

#pragma mark - method
- (IBAction)backButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)methodButtonClicked:(UIButton*)sender{
    NSString *msg;
    switch (sender.tag) {
        case 201:
            msg = @"是否确认回收此咖啡杯？";
            break;
        case 203:
            msg = @"是否确认兑换？";
            break;
        case 204:
            [self tapUploadImage];
            return;
        default:
            break;
    }
    __weak typeof(self) weakSelf = self;
    [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:msg cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
        
    } confirm:^{
        if(sender.tag == 201){
            [weakSelf setCallbackHttp];
        }else if(sender.tag == 204){
            [weakSelf tapUploadImage];
        }else{
            [weakSelf getCoffeeHttp:sender.tag];
        }
    }];
}

#pragma mark - 网络请求
- (void)getCoffeeHttp:(NSInteger)type{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:self.model.coffid forKey:@"coffid"];
    [requestDict setObject:[DataModelInstance shareInstance].adminUserModel.userid forKey:@"adminid"];
    [requestDict setObject:type==202?@"phone":@"cup" forKey:@"type"];
    
    [self requstType:RequestType_Post apiName:API_NAME_MANGER_POST_MAKESURE_EXCHANGECOFFER paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            AdminGetCoffeeResultViewController *vc = [CommonMethod getVCFromNib:[AdminGetCoffeeResultViewController class]];
            vc.resultType = Result_Type_GetCoffee;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }else{
            [MBProgressHUD showError:@"兑换失败，请重试" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - 回收
- (void)setCallbackHttp{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"回收中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:self.model.coffid forKey:@"coffid"];
    [self requstType:RequestType_Post apiName:API_NAME_MANGER_POST_MAKESURE_GOBACKCOFFER paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            AdminGetCoffeeResultViewController *vc = [CommonMethod getVCFromNib:[AdminGetCoffeeResultViewController class]];
            vc.resultType = Result_Type_Callback;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }else{
            [MBProgressHUD showError:@"回收失败，请重试" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - 挂出咖啡
- (void)hangCoffeeHttp:(NSString*)imageUrl hud:(MBProgressHUD*)hud{
    __weak typeof(self) weakSelf = self;
    hud.label.text = @"挂出中...";
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:self.model.coffid forKey:@"coffid"];
    [requestDict setObject:imageUrl forKey:@"image"];
    [self requstType:RequestType_Post apiName:API_NAME_USER_ADMIN_SHOW_COFFEE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            AdminGetCoffeeResultViewController *vc = [CommonMethod getVCFromNib:[AdminGetCoffeeResultViewController class]];
            vc.resultType = Result_Type_HangCoffee;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }else{
            [MBProgressHUD showError:@"挂出失败，请重试" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark -拍照挂出咖啡
- (void)tapUploadImage{
    __weak typeof(self) weakSelf = self;
    UploadImageTypeView *view = [CommonMethod getViewFromNib:@"UploadImageTypeView"];
    view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    [view setUploadImageTypeViewType:UploadImageTypeViewType_UploadNormalImage];
    view.uploadImageViewImage = ^(UIImage *image){
        [weakSelf uploadHeadImage:image];
    };
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view showShareNormalView];
}

//上传图片
- (void)uploadHeadImage:(UIImage *)image {
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud =
    [MBProgressHUD showMessag:@"上传图片中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    NSData *imageData =  UIImageJPEGRepresentation(image, 0.5);
    [requestDict setObject:imageData forKey:@"pphoto"];
    [self requstType:RequestType_UPLOAD_IMG apiName:API_NAME_UPLOAD_IMAGE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            NSString *urlStr = [responseObject objectForKey:@"msg"];
            [weakSelf hangCoffeeHttp:urlStr hud:hud];
        }else{
            [hud hideAnimated:YES];
            [MBProgressHUD showError:@"图片上传失败" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"图片上传失败" toView:weakSelf.view];
    }];
}

#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.model){
        return 2;
    }else{
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 3;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return 49;
    }else{
        return 78;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    if(indexPath.section == 0){
        UILabel *titleLabel = [UILabel createLabel:CGRectMake(16, 0, 75, 49) font:[UIFont systemFontOfSize:17] bkColor:WHITE_COLOR textColor:HEX_COLOR(@"AFB6C1")];
        titleLabel.text = @[@"领取者",@"公司",@"职位"][indexPath.row];
        [cell.contentView addSubview:titleLabel];
        NSString *contentStr;
        if(indexPath.row == 0){
            contentStr = [CommonMethod paramStringIsNull:self.model.getname];
        }else if(indexPath.row == 1){
            contentStr = [CommonMethod paramStringIsNull:self.model.company];
        }else{
            contentStr = [CommonMethod paramStringIsNull:self.model.position];
        }
        UIColor *textColor = HEX_COLOR(@"41464E");
        if(contentStr.length == 0){
            contentStr = @"暂无";
            textColor = HEX_COLOR(@"E6E8EB");
        }
        UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(100, 0, WIDTH-115, 49) backColor:WHITE_COLOR textColor:textColor test:contentStr font:17 number:1 nstextLocat:NSTextAlignmentRight];
        [cell.contentView addSubview:contentLabel];
        
        if(indexPath.row != 2){
            UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 48.5, WIDTH-30, .5)];
            lineLabel.backgroundColor = kCellLineColor;
            [cell.contentView addSubview:lineLabel];
        }
    }else{
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 5)];
        lineLabel.backgroundColor = HEX_COLOR(@"eFEFF4");
        [cell.contentView addSubview:lineLabel];
        
        UILabel *titleLabel = [UILabel createLabel:CGRectMake(16, 21, 75, 18) font:[UIFont systemFontOfSize:17] bkColor:WHITE_COLOR textColor:HEX_COLOR(@"AFB6C1")];
        titleLabel.text = @"状态";
        [cell.contentView addSubview:titleLabel];
        
        UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(16, 48, WIDTH-31, 15) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818C9E") test:[NSString stringWithFormat:@"*%@",self.model.msg] font:14 number:1 nstextLocat:NSTextAlignmentRight];
        [cell.contentView addSubview:contentLabel];
        
        UIButton *statueBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        statueBtn.frame = CGRectMake(100, 21, WIDTH-115, 18);
        NSString *statueStr;
        UIColor *statueColor;
        UIImage *statueImage;
        
//        1待挂出   2已挂出  3已扫码，4已领取未回收，5已领取并回收
        if(self.model.rst.integerValue == 2){
            statueStr = @"未领取";
            statueColor = HEX_COLOR(@"f76B1C");
        }else if(self.model.rst.integerValue == 1){
            statueStr = @"待挂出";
            statueColor = HEX_COLOR(@"f76B1C");
            self.hangCoffeeBtn.hidden = NO;
        }else if(self.model.rst.integerValue == 3){
            statueStr = @"可兑换";
            statueColor = HEX_COLOR(@"27AE61");
            statueImage = kImageWithName(@"icon_gly_ysm");
            self.exchangeBtn.hidden = NO;
        }else{
            statueStr = @"已兑换";
            statueColor = HEX_COLOR(@"C1392B");
            statueImage = kImageWithName(@"icon_gly_wsm");
            self.callBackBtn.hidden = YES;
        }
//        else if(self.model.rst.integerValue == 5){
//            statueStr = @"已回收";
//            statueColor = HEX_COLOR(@"C1392B");
//            statueImage = kImageWithName(@"icon_gly_wsm");
//        }
        [statueBtn setTitle:statueStr forState:UIControlStateNormal];
        [statueBtn setImage:statueImage forState:UIControlStateNormal];
        [statueBtn setTintColor:statueColor];
        [statueBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
        statueBtn.titleLabel.font = FONT_SYSTEM_SIZE(17);
        [statueBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        statueBtn.userInteractionEnabled = NO;
        [cell.contentView addSubview:statueBtn];
    }
    
    return cell;
}


@end
