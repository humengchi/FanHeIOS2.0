//
//  SearchCompanyViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "SearchCompanyViewController.h"
#import "NeedSupplyErrorView.h"
#import "SearchCompanyHistoryController.h"
#import "WebViewController.h"

@interface SearchCompanyViewController ()

@property (nonatomic, weak) IBOutlet UILabel *freeCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *needCBLabel;
@property (nonatomic, weak) IBOutlet UIView *searchHistoryView;
@property (nonatomic, weak) IBOutlet UIButton *searchBtn;
@property (nonatomic, strong) NSMutableArray *historyArray;

@end

@implementation SearchCompanyViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getSearchHistoryHttpData];
    [self getSearchCountHttpData];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.historyArray = [NSMutableArray array];
    self.view.backgroundColor = kTableViewBgColor;
    [self createCustomNavigationBar:@"企业查询"];
    [self initSearchBar:CGRectMake(16, 158, WIDTH-32, 36)];
    [self.searchBar setPlaceholder:@"请输入工商注册的企业全称"];
    self.searchBar.showsCancelButton = NO;
    [self.searchBar setBackgroundColor:WHITE_COLOR];
    [self.searchBar setBackgroundImage:kImageWithColor(WHITE_COLOR, self.searchBar.bounds)];
    [self.searchBar setSearchFieldBackgroundImage:kImageWithName(@"searchBackground") forState:UIControlStateNormal];
    [self.searchBar setSearchFieldBackgroundImage:kImageWithName(@"searchBackground") forState:UIControlStateDisabled];
    [CALayer updateControlLayer:self.searchBar.layer radius:5 borderWidth:0.5 borderColor:HEX_COLOR(@"979797").CGColor];
    UITextField * searchField = [self.searchBar valueForKey:@"_searchField"];
    if(searchField){
        [searchField setValue:HEX_COLOR(@"afb6c1") forKeyPath:@"_placeholderLabel.textColor"];
    }
    // Do any additional setup after loading the view.
}

- (void)updateView:(NSNumber*)t_searchcmp{
    self.freeCountLabel.text = t_searchcmp.stringValue;
    NSNumber *needCb = @(0);
    if(t_searchcmp.integerValue==0){
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

- (void)createSearchHistoryView:(NSArray*)array{
    CGFloat start_Y = 25;
    NSInteger index = 0;
    for(NSString *str in array){
        if(index == 2){
            break;
        }
        NSInteger width = (NSInteger)[NSHelper widthOfString:str font:FONT_SYSTEM_SIZE(13) height:FONT_SYSTEM_SIZE(13).lineHeight]+1;
        if(width > WIDTH-48){
            width = WIDTH-48;
        }
        NSInteger height = (NSInteger)[NSHelper heightOfString:str font:FONT_SYSTEM_SIZE(13) width:width]+16+1;
        UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(16, start_Y, width+16, height) backColor:kTableViewBgColor textColor:HEX_COLOR(@"818c9e") test:str font:13 number:0 nstextLocat:NSTextAlignmentCenter];
        [CALayer updateControlLayer:contentLabel.layer radius:2 borderWidth:0.5 borderColor:HEX_COLOR(@"818c9e").CGColor];
        [self.searchHistoryView addSubview:contentLabel];
        [CommonMethod viewAddGuestureRecognizer:contentLabel tapsNumber:1 withTarget:self withSEL:@selector(choiceHistoryContent:)];
        start_Y += height+8;
        index++;
    }
    if(index==2){
        NSInteger height = (NSInteger)[NSHelper heightOfString:@"更多浏览历史" font:FONT_SYSTEM_SIZE(13) width:95]+16+1;
        UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(16, start_Y, 95, height) backColor:HEX_COLOR(@"818c9e") textColor:WHITE_COLOR test:@"更多浏览历史" font:13 number:0 nstextLocat:NSTextAlignmentCenter];
        contentLabel.tag = 1000;
        [CALayer updateControlLayer:contentLabel.layer radius:2 borderWidth:0.5 borderColor:HEX_COLOR(@"818c9e").CGColor];
        [self.searchHistoryView addSubview:contentLabel];
        [CommonMethod viewAddGuestureRecognizer:contentLabel tapsNumber:1 withTarget:self withSEL:@selector(choiceHistoryContent:)];
    }
}

#pragma mark -点击
- (void)choiceHistoryContent:(UITapGestureRecognizer*)tap{
    [self.view endEditing:YES];
    UILabel *label = (UILabel*)tap.view;
    if(label.tag == 1000){
        SearchCompanyHistoryController *vc = [[SearchCompanyHistoryController alloc] init];
        vc.dataArray = self.historyArray;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        WebViewController *vc = [[WebViewController alloc] init];
        vc.customTitle = label.text;
        vc.webUrl = [NSString stringWithFormat:@"%@/%@/%@", SEARCH_COMPANY_HISTORY_URL, [DataModelInstance shareInstance].userModel.userId, label.text];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 搜索
- (IBAction)searchButtonClicked:(id)sender{
    if(self.freeCountLabel.text.integerValue){
        [self searchCompany];
    }else{
        if([CommonMethod paramNumberIsNull:[DataModelInstance shareInstance].coffeeBeans].integerValue>=5){
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"是否消耗5咖啡豆查询：" message:self.searchBar.text cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
            } confirm:^{
                [self searchCompany];
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

#pragma mark - 获取剩余的次数
- (void)getSearchCountHttpData{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@", [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_USER_GETUSERSETTING paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *dict = [CommonMethod paramDictIsNull:responseObject[@"data"]];
            NSNumber *t_searchcmp = [CommonMethod paramNumberIsNull:dict[@"t_searchcmp"]];
            [weakSelf updateView:t_searchcmp];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark - 搜索历史
- (void)getSearchHistoryHttpData{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@", [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_USER_GETUSERSETTING paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if([CommonMethod paramArrayIsNull:responseObject[@"data"]].count){
                [weakSelf createSearchHistoryView:[CommonMethod paramArrayIsNull:responseObject[@"data"]]];
                weakSelf.historyArray = [[CommonMethod paramArrayIsNull:responseObject[@"data"]] mutableCopy];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark - 查询
- (void)searchCompany{
    [self.view endEditing:YES];
    if(self.searchBar.text.length==0){
        return;
    }else{
        [[AppDelegate shareInstance] updateMenuNewMsgNum];
        WebViewController *vc = [[WebViewController alloc] init];
        vc.customTitle = self.searchBar.text;
        vc.webUrl = [NSString stringWithFormat:@"%@/%@/%@", SEARCH_COMPANY_URL, [DataModelInstance shareInstance].userModel.userId, self.searchBar.text];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -- SearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
}

@end
