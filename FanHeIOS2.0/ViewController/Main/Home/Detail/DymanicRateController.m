



//
//  DymanicRateController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/2.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "DymanicRateController.h"

@interface DymanicRateController ()<UITextViewDelegate>
@property (nonatomic,strong) UITextView *textView;
@property (nonatomic ,strong) UILabel *placeLabel;
@property (nonatomic ,strong) UIButton *editBtn;
@end

@implementation DymanicRateController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createCustomNavigationBar:@"发表评论"];
    self.textView = [[UITextView alloc]initWithFrame:CGRectMake(16, 70, WIDTH-32, HEIGHT - 63)];
    self.textView.font = FONT_SYSTEM_SIZE(15);
    self.placeLabel = [UILabel createLabel:CGRectMake(10, 6, WIDTH - 32, 20) font:[UIFont systemFontOfSize:14] bkColor:[UIColor whiteColor] textColor:HEX_COLOR(@"afb6c1")];
    self.textView.delegate = self;
    if (self.fristRate) {
        self.placeLabel.text = @"说点什么吧...";
    }else{
         self.placeLabel.text = [NSString stringWithFormat:@"回复%@",self.nameStr];
    }    
    [self.textView addSubview:self.placeLabel];
    [self.view addSubview:self.textView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewEditChanged:)name:@"UITextViewTextDidChangeNotification"object:self.textView];
    self.editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.editBtn.frame = CGRectMake(WIDTH-60, 20, 50, 44);
    [self.editBtn setTitle:@"发表" forState:UIControlStateNormal];
    [self.editBtn setTitleColor:HEX_COLOR(@"e6e8eb") forState:UIControlStateNormal];
    self.editBtn.titleLabel.font = FONT_SYSTEM_SIZE(16);
    [self.editBtn addTarget:self action:@selector(sendRateDetailButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.editBtn];
    
    [self.textView becomeFirstResponder];
}
- (void)sendRateDetailButtonClicked{
    if (self.textView.text.length <= 0) {
        [MBProgressHUD showError:@"请输入评论" toView:self.view];
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"发表中..." toView:self.view];
    NSString *apiType;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.textView.text forKey:@"content"];
    if (self.fristRate == YES) {
        [requestDict setObject:self.dynamicID forKey:@"dynamicid"];
        apiType = API_NAME_POST_DYNAMICDETAILRATELIT_FRIST;
        UserModel *model = [DataModelInstance shareInstance].userModel;
        [[AppDelegate shareInstance] setZhugeTrack:@"评论动态" properties:@{@"industry":[CommonMethod paramStringIsNull:model.industry], @"business":[CommonMethod paramStringIsNull:model.business],@"city":[CommonMethod paramStringIsNull:model.address], @"dynamicId":[CommonMethod paramNumberIsNull:weakSelf.dynamicModel.dynamic_id],@"dynamicType":[CommonMethod paramNumberIsNull:weakSelf.dynamicModel.type],@"dynamicExtype":[CommonMethod paramNumberIsNull:weakSelf.dynamicModel.exttype]}];
    }else{
        [requestDict setObject:self.dynamicID forKey:@"reviewid"];
        apiType = API_NAME_POST_DYNAMICDETAILRATELIT_ECTYPE;
        UserModel *model = [DataModelInstance shareInstance].userModel;
        [[AppDelegate shareInstance] setZhugeTrack:@"回复他人动态" properties:@{@"industry":[CommonMethod paramStringIsNull:model.industry], @"business":[CommonMethod paramStringIsNull:model.business],@"city":[CommonMethod paramStringIsNull:model.address], @"dynamicId":[CommonMethod paramNumberIsNull:weakSelf.dynamicModel.dynamic_id],@"dynamicType":[CommonMethod paramNumberIsNull:weakSelf.dynamicModel.type],@"dynamicExtype":[CommonMethod paramNumberIsNull:weakSelf.dynamicModel.exttype]}];
    }
    [self requstType:RequestType_Post apiName:apiType paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES]; 
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"发表成功" toView:weakSelf.view];
            if ([self.dymanicRateControllerDelegate respondsToSelector:@selector(succendRateDynamic)]) {
                [self.dymanicRateControllerDelegate succendRateDynamic];
            }
            if ([self.dymanicRateControllerDelegate respondsToSelector:@selector(successDynamicCommentModel:)]) {
                DynamicCommentModel *model = [[DynamicCommentModel alloc] initWithDict:responseObject[@"data"]];
                [self.dymanicRateControllerDelegate successDynamicCommentModel:model];
            }
            [self.textView resignFirstResponder];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
    
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)textViewEditChanged:(NSNotification *)obj{
    UITextView *textField = (UITextView *)obj.object;
    if (textField.text.length > 0) {
        self.placeLabel.hidden = YES;
        [self.editBtn setTitleColor:HEX_COLOR(@"E24943") forState:UIControlStateNormal];
    }else{
        self.placeLabel.hidden = NO;
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length > 1000) {
        textView.text = [textView.text substringToIndex:1000];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)customNavBackButtonClicked{
    [self.textView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
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
