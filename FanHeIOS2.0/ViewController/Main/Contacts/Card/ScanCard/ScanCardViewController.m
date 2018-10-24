//
//  ScanCardViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/14.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ScanCardViewController.h"
#import "UIImage+GIF.h"
#import "EditCardViewController.h"
#import "NeedSupplyErrorView.h"

@interface ScanCardViewController (){
}

@property (nonatomic, weak) IBOutlet UILabel *freeCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *needCBLabel;
@property (nonatomic, weak) IBOutlet UIView *loadingView;
@property (nonatomic, weak) IBOutlet UIImageView *cardImageView;
@property (nonatomic, weak) IBOutlet UIImageView *loadingImageView;
@property (nonatomic, weak) IBOutlet UILabel *coverLabel;
@property (nonatomic, weak) IBOutlet UIButton *scanBtn;

@end

@implementation ScanCardViewController

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self getScanCardCountHttpData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@""];
    self.view.backgroundColor = HEX_COLOR(@"41464e");
  
    [self updateView:@(0)];
    if(self.isRegister){
        self.coverLabel.hidden = NO;
        [self.scanBtn setTitle:@"确定" forState:UIControlStateNormal];
    }
}

#pragma mark - 获取网络数据
- (void)getScanCardCountHttpData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@", [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_USER_GETUSERSETTING paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *dict = [CommonMethod paramDictIsNull:responseObject[@"data"]];
            NSNumber *t_scancard = [CommonMethod paramNumberIsNull:dict[@"t_scancard"]];
            [weakSelf updateView:t_scancard];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
    }];
}

- (void)updateView:(NSNumber*)t_scancard{
    self.cardImageView.image = self.imageData;
    self.freeCountLabel.text = t_scancard.stringValue;
    NSNumber *needCb = @(0);
    if(t_scancard.integerValue==0){
        needCb = @(5);
    }
    NSString *needCBStr = [NSString stringWithFormat:@"需要消耗%@ ", needCb];
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:needCBStr];
    NSTextAttachment *attchImage = [[NSTextAttachment alloc] init];
    if(rand()/2){
        [attriStr addAttributes:@{NSForegroundColorAttributeName:HEX_COLOR(@"e24943")} range:NSMakeRange(0, needCBStr.length)];
        attchImage.image = kImageWithName(@"icon_kfd_red");
    }else{
        [attriStr addAttributes:@{NSForegroundColorAttributeName:HEX_COLOR(@"818c9e")} range:NSMakeRange(0, needCBStr.length)];
        attchImage.image = kImageWithName(@"icon_kfd_grey");
    }
    attchImage.bounds = CGRectMake(0, 0, 9, 10);
    NSAttributedString *stringImage = [NSAttributedString attributedStringWithAttachment:attchImage];
    [attriStr appendAttributedString:stringImage];
    self.needCBLabel.attributedText = attriStr;
}

#pragma mark - method
- (void)customNavBackButtonClicked{
    NSArray *vcs = self.navigationController.viewControllers;
    [self.navigationController popToViewController:vcs[vcs.count-3] animated:YES];
}

- (IBAction)reUploadImageButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)scanButtonClicked:(id)sender{
    if(self.freeCountLabel.text.integerValue){
        [self uploadScanImageUrl];
    }else{
        if([CommonMethod paramNumberIsNull:[DataModelInstance shareInstance].coffeeBeans].integerValue>=5){
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"确认是否消耗5咖啡豆" message:@"扫描当前名片" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
            } confirm:^{
                [self uploadScanImageUrl];
            }];
        }else{
            NeedSupplyErrorView *view = [CommonMethod getViewFromNib:@"NeedSupplyErrorView"];
            view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
            view.mainLabel.text = [NSString stringWithFormat:@"你的咖啡豆数量为%@",[CommonMethod paramNumberIsNull:[DataModelInstance shareInstance].coffeeBeans]];
            view.showLabel.text = @"做日常任务赢咖啡豆！";
            [[UIApplication sharedApplication].keyWindow addSubview:view];
        }
    }
}

#pragma mark - 扫描接口
- (void)uploadScanImageUrl{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"smmp" ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    UIImage *image = [UIImage sd_animatedGIFWithData:data];
    self.loadingImageView.image = image;
    self.loadingView.hidden = NO;
    
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    NSData *imageData = UIImageJPEGRepresentation(self.imageData, 0.5);
    [requestDict setObject:imageData forKey:@"cardpic"];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [self requstType:RequestType_UPLOAD_IMG apiName:API_NAME_POST_USER_SCANCARD paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        weakSelf.loadingView.hidden = YES;
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            //更新咖啡豆的数量
            [[AppDelegate shareInstance] updateMenuNewMsgNum];
            CardScanModel *model = [[CardScanModel alloc] initWithDict:[CommonMethod paramDictIsNull:responseObject[@"data"]]];
            model.ismycard = [NSNumber numberWithBool:weakSelf.isMyCard];
            if(weakSelf.isMyCard){
                model.cardId = self.cardId;
            }
            if(weakSelf.isRegister){
                [weakSelf saveCardHttpData:model];
            }else{
                EditCardViewController *vc = [CommonMethod getVCFromNib:[EditCardViewController class]];
                vc.model = model;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
        }else{
            weakSelf.loadingView.hidden = YES;
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        weakSelf.loadingView.hidden = YES;
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - 保存名片
- (void)saveCardHttpData:(CardScanModel*)model{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:model.ismycard forKey:@"ismycard"];
    
    [requestDict setObject:model.name forKey:@"name"];
    [requestDict setObject:model.phone forKey:@"phone"];
    if(model.jobphone.count){
        [requestDict setObject:[self objArrayToJSON:model.jobphone] forKey:@"jobphone"];
    }
    if(model.fax.count){
        [requestDict setObject:[self objArrayToJSON:model.fax] forKey:@"fax"];
    }
    if(model.company.count){
        [requestDict setObject:[self objArrayToJSON:model.company] forKey:@"company"];
    }
    if(model.position.count){
        [requestDict setObject:[self objArrayToJSON:model.position] forKey:@"position"];
    }
    if(model.email.count){
        [requestDict setObject:[self objArrayToJSON:model.email] forKey:@"email"];
    }
    if(model.website.count){
        [requestDict setObject:[self objArrayToJSON:model.website] forKey:@"website"];
    }
    if(model.address.count){
        [requestDict setObject:[self objArrayToJSON:model.address] forKey:@"address"];
    }
    if(model.qq.count){
        [requestDict setObject:[self objArrayToJSON:model.qq] forKey:@"qq"];
    }
    if(model.wx.count){
        [requestDict setObject:[self objArrayToJSON:model.wx] forKey:@"wx"];
    }
    if(model.birthday.length){
        [requestDict setObject:model.birthday forKey:@"birthday"];
    }
    if(model.imgurl.length){
        [requestDict setObject:model.imgurl forKey:@"imgurl"];
    }
    [self requstType:RequestType_Post apiName:API_NAME_POST_USER_SAVECARD paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        weakSelf.loadingView.hidden = YES;
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            [[AppDelegate shareInstance] gotoRecommendContacts];
        }else{
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        weakSelf.loadingView.hidden = YES;
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

@end
