//
//  BuyCoffeeBeansController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BuyCoffeeBeansController.h"
#import "ULBCollectionViewFlowLayout.h"
#import "RechargeIntroController.h"
#import "NormalQuestionController.h"
#import "AddFriendError.h"
#import "IAPShare.h"
#import "NSString+Base64.h"

@interface BuyCoffeeBeansController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, ULBCollectionViewDelegateFlowLayout, UITextViewDelegate>{
    NSInteger _currentSelected;
    NSString *_currentProId;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *collectionArray;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSData *receipt;

@end

@implementation BuyCoffeeBeansController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveReceipt) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self saveReceipt];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionArray = [NSMutableArray array];
    _currentSelected = 0;
    
    ULBCollectionViewFlowLayout *flowLayout=[[ULBCollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT-64) collectionViewLayout:flowLayout];
    self.collectionView.dataSource=self;
    self.collectionView.delegate=self;
    [self.collectionView setBackgroundColor:kTableViewBgColor];
    
    //注册Cell，必须要有
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerView"];
    [self.view addSubview:self.collectionView];
    
    [self loadHttpData];
}

#pragma mark -网络请求
- (void)loadHttpData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [self requstType:RequestType_Get apiName:API_NAME_GET_USER_COFFEEBEANSLIST paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            for(NSDictionary *dict in [CommonMethod paramArrayIsNull:responseObject[@"data"]]) {
                RechargeModel *model = [[RechargeModel alloc] initWithDict:dict];
                [weakSelf.collectionArray addObject:model];
            }
            [weakSelf.collectionView reloadData];
        }else{
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark -method
- (IBAction)navbackButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)gotoNormalQuestionVC:(id)sender{
    NormalQuestionController *vc = [[NormalQuestionController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark --  ULBCollectionViewDelegateFlowLayout
- (UIColor *)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout colorForSectionAtIndex:(NSInteger)section{
    return WHITE_COLOR;
}

#pragma mark -- UICollectionViewDataSource
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if(self.collectionArray.count){
        return 1;
    }else{
        return 0;
    }
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.collectionArray.count;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((WIDTH-47)/2, 53);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(16, 16, 16, 16);
}

//这个是两行cell之间的间距（上下行cell的间距）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 12;
}

//两个cell之间的间距（同一行的cell的间距）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 15;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(WIDTH, 33);
}

- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader) {
        static NSString *identify = @"headerView";
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:identify forIndexPath:indexPath];
        if(!headerView){
            headerView = [[UICollectionReusableView alloc] init];
        }
        headerView.backgroundColor = kTableViewBgColor;
        for(UIView *view in headerView.subviews){
            [view removeFromSuperview];
        }
        UILabel *label = [UILabel createLabel:CGRectMake(16, 0, WIDTH-32, 33) font:FONT_SYSTEM_SIZE(14) bkColor:kTableViewBgColor textColor:HEX_COLOR(@"818c9e")];
        label.text = @"请选择充值金额";
        [headerView addSubview:label];
        return headerView;
    }else{
        static NSString *identify = @"footerView";
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:identify forIndexPath:indexPath];
        if(!footerView){
            footerView = [[UICollectionReusableView alloc] init];
        }
        footerView.backgroundColor = kTableViewBgColor;
        for(UIView *view in footerView.subviews){
            [view removeFromSuperview];
        }
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(16, 25, WIDTH-32, 40);
        [btn setTitle:@"去充值" forState:UIControlStateNormal];
        [btn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
        [btn setBackgroundImage:kImageWithName(@"btn_rm_off_red") forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(buyProdution:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:btn];
        
        UILabel *label = [UILabel createLabel:CGRectMake(16, 83, WIDTH-32, 15) font:FONT_BOLD_SYSTEM_SIZE(14) bkColor:kTableViewBgColor textColor:HEX_COLOR(@"818c9e")];
        label.text = @"充值说明：";
        [footerView addSubview:label];
        
        NSString *describe = @"1、苹果公司规定，虚拟商品必须使用苹果系统充值购买，充值的金融不可自定义，且不能用于安卓、网页等其他平台\n2、咖啡豆充值成功后无法退款，不可提现\n3、使用苹果系统充值可参看充值流程说明\n4、如果存在无法充值或者充值失败，可联系电话021-65250669转823";
        CGFloat height = [NSHelper heightOfString:describe font:FONT_SYSTEM_SIZE(14) width:WIDTH-32];
        height += height/FONT_SYSTEM_SIZE(14).lineHeight*6;
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(16, 109, WIDTH-32, height)];
        textView.editable = NO;
        textView.textColor = HEX_COLOR(@"818c9e");
        textView.font = FONT_SYSTEM_SIZE(14);
        textView.backgroundColor = kTableViewBgColor;
        textView.delegate = self;
        textView.scrollEnabled = NO;
        [footerView addSubview:textView];
        NSMutableAttributedString *atr = [[NSMutableAttributedString alloc] initWithString:describe];
        [atr setAttributes:@{NSFontAttributeName:FONT_SYSTEM_SIZE(14), NSForegroundColorAttributeName:HEX_COLOR(@"818c9e")} range:NSMakeRange(0, describe.length)];
        NSRange range1 = [describe rangeOfString:@"充值流程说明"];
        [atr setAttributes:@{NSForegroundColorAttributeName:HEX_COLOR(@"3498db"),NSFontAttributeName:FONT_SYSTEM_SIZE(14)} range:range1];
        [atr setAttributes:@{NSLinkAttributeName:@"recharge"} range:range1];
        NSRange range2 = [describe rangeOfString:@"021-65250669转823"];
        [atr setAttributes:@{NSForegroundColorAttributeName:HEX_COLOR(@"3498db"),NSFontAttributeName:FONT_SYSTEM_SIZE(14)} range:range2];
        [atr setAttributes:@{NSLinkAttributeName:@"telephone"} range:range2];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyle setLineSpacing:6];
        [atr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, describe.length)];
        textView.tintColor = HEX_COLOR(@"3498db");
        textView.attributedText = atr;
        textView.font = FONT_SYSTEM_SIZE(14);
        textView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
        [textView setTextContainerInset:UIEdgeInsetsZero];
        textView.textContainer.lineFragmentPadding = 0;
        [textView setContentInset:UIEdgeInsetsMake(0, 0, 0, 1)];
        [textView setTextAlignment:NSTextAlignmentJustified];//并设置左对齐
        
        return footerView;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    NSString *describe = @"1、苹果公司规定，虚拟商品必须使用苹果系统充值购买，充值的金融不可自定义，且不能用于安卓、网页等其他平台\n2、咖啡豆充值成功后无法退款，不可提现\n3、使用苹果系统充值可参看充值流程说明\n4、如果存在无法充值或者充值失败，可联系电话021-65250669转823";
    CGFloat height = [NSHelper heightOfString:describe font:FONT_SYSTEM_SIZE(14) width:WIDTH-32];
    height += height/FONT_SYSTEM_SIZE(14).lineHeight*6+109;
    return CGSizeMake(WIDTH, height);
}

//每个UICollectionView展示的内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"UICollectionViewCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    RechargeModel *model = self.collectionArray[indexPath.row];
    UIColor *bgColor = WHITE_COLOR;
    UIColor *borderColor = HEX_COLOR(@"afb6c1");
    UIColor *moneyColor = HEX_COLOR(@"41464e");
    UIColor *countColor = HEX_COLOR(@"818c9e");
    if(_currentSelected == indexPath.row){
        borderColor=moneyColor=countColor=HEX_COLOR(@"e24943");
        bgColor = HEX_COLOR(@"fdf0f0");
    }
    cell.backgroundColor = bgColor;
    [CALayer updateControlLayer:cell.layer radius:5 borderWidth:0.5 borderColor:borderColor.CGColor];
    UILabel *moneyLabel = [UILabel createrLabelframe:CGRectMake(0, 8, (WIDTH-47)/2, 18) backColor:nil textColor:moneyColor test:[NSString stringWithFormat:@"%@元",model.price] font:17 number:1 nstextLocat:NSTextAlignmentCenter];
    [cell.contentView addSubview:moneyLabel];
    UILabel *countLabel = [UILabel createrLabelframe:CGRectMake(0, 31, (WIDTH-47)/2, 15) backColor:nil textColor:moneyColor test:[NSString stringWithFormat:@"%ld咖啡豆",model.cb.integerValue+model.gift.integerValue] font:14 number:1 nstextLocat:NSTextAlignmentCenter];
    [cell.contentView addSubview:countLabel];
    
    if([CommonMethod paramNumberIsNull:model.gift].integerValue){
        UIImageView *giftImageView = [[UIImageView alloc] init];
        giftImageView.image = kImageWithName(@"icon_cz_tag");
        [cell.contentView addSubview:giftImageView];
        
        UILabel *giftLabel = [UILabel createrLabelframe:CGRectMake(0, 31, WIDTH, 33) backColor:HEX_COLOR(@"e24943") textColor:WHITE_COLOR test:@"" font:10 number:1 nstextLocat:NSTextAlignmentCenter];
        [cell.contentView addSubview:giftLabel];
        NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"送%@",model.gift]];
        NSTextAttachment *attchImage = [[NSTextAttachment alloc] init];
        attchImage.image = kImageWithName(@"icon_kfd_white");
        attchImage.bounds = CGRectMake(1, -2, 9, 10);
        NSAttributedString *stringImage = [NSAttributedString attributedStringWithAttachment:attchImage];
        [attriStr appendAttributedString:stringImage];
        giftLabel.attributedText = attriStr;
        CGRect rect = [attriStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 11) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin context:nil];
        giftLabel.frame = CGRectMake(6, 7, rect.size.width, 11);
        giftImageView.frame = CGRectMake(0, 5, 20+rect.size.width, 16);
    }
    return cell;
}

#pragma mark --UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    _currentSelected = indexPath.row;
    [self.collectionView reloadData];
}

#pragma mark -UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    if([[CommonMethod paramStringIsNull:URL.absoluteString] isEqualToString:@"recharge"]){
        RechargeIntroController *vc = [[RechargeIntroController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if([[CommonMethod paramStringIsNull:URL.absoluteString] isEqualToString:@"telephone"]){
        NSString *str = [NSString stringWithFormat:@"tel:021-65250669"];
        UIWebView *callWebView = [[UIWebView alloc]init];
        [callWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [[UIApplication sharedApplication].keyWindow addSubview:callWebView];
    }
    return YES;
}

#pragma mark - 开始充值
- (void)buyProdution:(UIButton *)sender{
    self.hud = [MBProgressHUD showMessag:@"支付中..." toView:self.view];
    RechargeModel *model = self.collectionArray[_currentSelected];
    _currentProId = [NSString stringWithFormat:@"com.fortunecoffee.51JinMai%@", model.num];
    if([SKPaymentQueue canMakePayments]){
        [self requestProductData:_currentProId];//com.fortunecoffee.51JinMaicb1501
    }else{
        [self.hud hideAnimated:YES];
        NSLog(@"不允许程序内付费");
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"不允许程序内付费" message:@"请在iPhone的“设置>通用>访问限制”选项中，允许“App内购买项目”" cancelButtonTitle:@"取消" otherButtonTitle:@"设置" cancle:^{
        } confirm:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-prefs:root=General"]];
        }];
    }
}

//去苹果服务器请求商品
- (void)requestProductData:(NSString *)productId{
    NSSet* dataSet = [[NSSet alloc] initWithArray:@[productId]];
    [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
#if DEBUG==1
    [IAPShare sharedHelper].iap.production = NO;
#else
    [IAPShare sharedHelper].iap.production = YES;
#endif
    // 请求商品信息
    [[IAPShare sharedHelper].iap requestProductsWithCompletion:^(SKProductsRequest* request,SKProductsResponse* response){
         if(response.products.count > 0 ) {
             SKProduct *product = response.products[0];
             [[IAPShare sharedHelper].iap buyProduct:product onCompletion:^(SKPaymentTransaction* trans){
                 if(trans.error){
                     [self.hud hideAnimated:YES];
                     [MBProgressHUD showError:@"购买失败，请重试" toView:self.view];
                }else if(trans.transactionState == SKPaymentTransactionStatePurchased) {
                    self.receipt = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
                    [self justifyIAP:self.hud];
                }else if(trans.transactionState == SKPaymentTransactionStateFailed) {
                    if (trans.error.code == SKErrorPaymentCancelled) {
                        [self.hud hideAnimated:YES];
                    }else{
                        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"购买失败，请重试" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
                            [self.hud hideAnimated:YES];
                            [self saveReceipt];
                        } confirm:^{
                            [self justifyIAP:self.hud];
                        }];
                    }
                }
            }];
         }else{
             [self.hud hideAnimated:YES];
             [MBProgressHUD showError:@"购买失败，请重试" toView:self.view];
         }
     }];
}

#pragma mark - ios iap应用内支付二次验证
- (void)justifyIAP:(MBProgressHUD*)hud{
    if(hud==nil){
        hud = [MBProgressHUD showMessag:@"支付中..." toView:self.view];
    }
    NSString *receiptBase64 = [NSString base64StringFromData:self.receipt length:[self.receipt length]];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:[CommonMethod paramStringIsNull:receiptBase64] forKey:@"data"];
    [self requstType:RequestType_Post apiName:API_NAME_USER_POST_USER_IAPSECONDVALID paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            weakSelf.receipt = nil;
            [hud hideAnimated:YES];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else{
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"购买失败，请重试" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
                [hud hideAnimated:YES];
                [weakSelf saveReceipt];
            } confirm:^{
                [weakSelf justifyIAP:hud];
            }];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"购买失败，请重试" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
            [hud hideAnimated:YES];
            [weakSelf saveReceipt];
        } confirm:^{
            [weakSelf justifyIAP:hud];
        }];
    }];
}

//持久化存储用户购买凭证(这里最好还要存储当前日期，用户id等信息，用于区分不同的凭证)
- (void)saveReceipt{
    if(self.receipt && self.receipt.length){
        NSString *fileName = [NSString genUUID];
        NSString *savedPath = [NSString stringWithFormat:@"%@%@.plist", AppStoreInfoLocalFilePath, fileName];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys: self.receipt, IAP_RECEIPT,[DataModelInstance shareInstance].userModel.userId,IAP_USER_ID,nil];
        BOOL result = [dic writeToFile:savedPath atomically:YES];
        NSLog(@"%d",result);
        self.receipt = nil;
    }
}


@end
