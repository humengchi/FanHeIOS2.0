//
//  AddUrlController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/2/8.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "AddUrlController.h"
#import "UrlShowView.h"
@interface AddUrlController ()<UITextFieldDelegate,UrlShowViewDelegate>
@property (nonatomic , strong)UITextField *inputFile;
@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic ,strong)UrlShowView *urlView;
@property (nonatomic ,assign) BOOL isShow;
@property  (nonatomic ,assign) BOOL isRefer;
@end

@implementation AddUrlController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray new];
    [self createCustomNavigationBar:@"添加链接"];
    self.isShow = NO;
    self.isRefer = NO;
    
    UIView *view = [NSHelper createrViewFrame:CGRectMake(0, 64, WIDTH, 5) backColor:@"EFEFF4"];
    [self.view addSubview:view];
    
    self.inputFile = [[UITextField alloc]initWithFrame:CGRectMake(16, 21+64, WIDTH - 32, 19)];
    self.inputFile.delegate = self;
    self.inputFile.keyboardType = UIKeyboardTypeWebSearch;
    self.inputFile.placeholder = @"请输入网址";
    [self.view addSubview:self.inputFile];
    
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 64+54.5, WIDTH, 0.5)];
    lineLabel.backgroundColor = [UIColor colorWithHexString:@"D9D9D9"];
    [self.view addSubview:lineLabel];
}

- (void)cretaerInputUrlView{
    UIView *backView = [self.view viewWithTag:2000];
    if(backView){
        [backView removeFromSuperview];
    }
    backView = [NSHelper createrViewFrame:CGRectMake(0, 64+55, WIDTH, HEIGHT - 64) backColor:@"FFFFFF"];
    backView.tag = 2000;
    [self.view addSubview:backView];
    
    NSString *url = self.dic[@"title"];
    if (self.isRefer == NO) {
        if (url.length > 0) {
            self.inputFile.text = url;
        }
    }
    NSMutableArray *array = [NSMutableArray arrayWithObjects:self.dic, nil];
    if (url.length > 0) {
        UILabel *showUrlLabel = [UILabel createLabel:CGRectMake(16, 71-55, WIDTH - 32, 15) font:[UIFont systemFontOfSize:15] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"818C9E"]];
        showUrlLabel.text = @"请选择结果：";
        [backView addSubview:showUrlLabel];
        backView.userInteractionEnabled = YES;
        self.urlView = [[UrlShowView alloc]initWithFrame:CGRectMake(0, 86-55, WIDTH, 52)];
        [self.urlView createrUrlView:array];
        self.urlView.urlShowViewDelegate = self;
        [backView addSubview:self.urlView];
    }else{
        UILabel *showUrlLabel = [UILabel createLabel:CGRectMake(16, 82-55, WIDTH - 32, 15) font:[UIFont systemFontOfSize:14] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"818C9E"]];
        showUrlLabel.textAlignment = NSTextAlignmentCenter;
        showUrlLabel.text = @"暂无结果";
        if (self.isShow == YES) {
            showUrlLabel.hidden = NO;
        }else{
            showUrlLabel.hidden = YES;
        }
        [backView addSubview:showUrlLabel];
    }
}

#pragma mark -------UrlShowViewDelegate
- (void)gotoMakeUrl:(NSInteger)index{
    if ([self.addUrlControllerDelegate respondsToSelector:@selector(backAddUrlControllerDic:)]) {
        [self.addUrlControllerDelegate backAddUrlControllerDic:self.dic];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        textField.text  = [textField.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    if(position && (range.length==0 || string.length==0)){
        return YES;
    }else{
        NSString *str;
        if ([string isEqualToString:@"\n"]) {
            str = textField.text;
        }else{
           str = [textField.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:string];
        }
        if ([self urlValidation:str]) {
            [self getAboutUrl:str];
        }else{
            self.dic = [@{@"title":@""} mutableCopy];
            UIView *backView = [self.view viewWithTag:2000];
            if(backView){
                [backView removeFromSuperview];
            }
        }
    }
    return YES;
}

- (void)getAboutUrl:(NSString *)url{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:url forKey:@"url"];
    [self requstType:RequestType_Post apiName:API_NAME_GET_URLDETAILABOUTALL paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if(url.length >= self.inputFile.text.length && [self urlValidation:self.inputFile.text]){
                NSMutableDictionary *dic = responseObject[@"data"];
                NSString *str = dic[@"title"];
                if (str.length > 0) {
                    self.dic = dic;
                }else{
                    self.isShow = YES;
                }
                self.isRefer = YES;
                [self cretaerInputUrlView];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}
/**
 * 网址正则验证 1或者2使用哪个都可以
 *
 *  @param string 要验证的字符串
 *
 *  @return 返回值类型为BOOL
 */
- (BOOL)urlValidation:(NSString *)string {
    NSError *error;
    // 正则1
    //    NSString *regulaStr =@"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
    NSString *regulaStr =@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr options:NSRegularExpressionCaseInsensitive error:&error];
    
    
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    for (NSTextCheckingResult *match in arrayOfAllMatches){
        NSString* substringForMatch = [string substringWithRange:match.range];
        NSLog(@"匹配");
        return YES;
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
