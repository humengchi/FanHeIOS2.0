//
//  TickerDetailController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/11.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "TickerDetailController.h"
#import "ApplySucceedController.h"
@interface TickerDetailController ()<UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *tickerDetailView;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *acountLabel;
@property (weak, nonatomic) IBOutlet UILabel *acountAllLabel;
@property (weak, nonatomic) IBOutlet UILabel *sideLabel;
@property (weak, nonatomic) IBOutlet UITextView *tickerSideTextView;
@property (weak, nonatomic) IBOutlet UILabel *showAcountLabel;
@property (strong, nonatomic) IBOutlet UIView *applyView;
@property (weak, nonatomic) IBOutlet UIButton *applyBut;
@property (weak, nonatomic) IBOutlet UIView *textView;
@property (nonatomic ,strong) UILabel *placeLabel;
@end

@implementation TickerDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"报名"];
    self.textView.layer.masksToBounds = YES;
    self.textView.layer.cornerRadius = 2.0;
    self.textView.layer.borderWidth = 0.5;
    self.textView.layer.borderColor = [UIColor colorWithHexString:@"D9D9D9"].CGColor;
    self.applyBut.layer.masksToBounds = YES;
    self.applyBut.layer.cornerRadius = 5.0;
    CGFloat heigt = [NSHelper heightOfString:self.model.remark font:[UIFont systemFontOfSize:14] width:WIDTH - 50];
    if (heigt > 0) {
        heigt += 16;
    }
    self.tickerDetailView.frame = CGRectMake(0, 64, WIDTH, heigt + 67);
    [self.view addSubview:self.tickerDetailView];
    self.typeLabel.text = self.model.name;
    if (self.model.price.integerValue == 0) {
        self.acountLabel.text = @"免费";
    }else{
        self.acountLabel.text = [NSString stringWithFormat:@"¥%@元/人",self.model.price];
    }
    if (self.model.remainnum.integerValue == -1) {
        self.acountAllLabel.text = @"名额不限";
    }else{
        self.acountAllLabel.text = [NSString stringWithFormat:@"剩余:%@",self.model.remainnum];
    }
       self.placeLabel = [UILabel createLabel:CGRectMake(10, 6, WIDTH - 32, 20) font:[UIFont systemFontOfSize:14] bkColor:[UIColor colorWithHexString:@"F8F8FA"] textColor:[UIColor grayColor]];
    self.placeLabel.text = @"给主办方留言…";
    [self.tickerSideTextView addSubview:self.placeLabel];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewEditChanged:)name:@"UITextViewTextDidChangeNotification"object:self.tickerSideTextView];
    if (self.model.remark.length > 0) {
         self.sideLabel.text = self.model.remark;
    }else{
        self.sideLabel.hidden = YES;
    }
    self.applyView.frame = CGRectMake(0, heigt + 67+64, WIDTH, 150);
    self.tickerSideTextView.delegate = self;
    [self.view addSubview:self.applyView];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)applyJoinActivityAction:(UIButton *)sender {
    [self.tickerSideTextView resignFirstResponder];
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:self.tickerSideTextView.text forKey:@"memo"];
    [requestDict setObject:self.model.ticktid forKey:@"ticketid"];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_ACTIVITY_APPLY paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [hud hideAnimated:YES];
              NSDictionary *dict = [CommonMethod paramDictIsNull:[responseObject objectForKey:@"data"]];
            NSNumber *tapy = dict[@"type"];
            if (tapy.integerValue == 2) {
                ApplySucceedController *succeed = [[ApplySucceedController alloc]init];
                succeed.actModel = self.actModel;
                succeed.needcheck = self.model.needcheck;
                [self.navigationController pushViewController:succeed animated:YES];
            }else if(tapy.integerValue == 1){
                [MBProgressHUD showError:@"报名已满" toView:weakSelf.view];
            }else{
                  [MBProgressHUD showError:@"暂停报名" toView:weakSelf.view];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
    
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.tickerSideTextView resignFirstResponder];
}
-(void)textViewEditChanged:(NSNotification *)obj{
    UITextView *textField = (UITextView *)obj.object;
    if (textField.text.length > 40 ) {
        self.tickerSideTextView.text = [self.tickerSideTextView.text substringToIndex:40];
    }else{
        self.showAcountLabel.text = [NSString stringWithFormat:@"%ld/40",textField.text.length];
    }

    if (textField.text.length > 0) {
        self.placeLabel.hidden = YES;
    }else{
        self.placeLabel.hidden = NO;
    }
}
#pragma mark - Keyboard notification
- (void)onKeyboardNotification:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardEnd.size.height;
    [UIView animateWithDuration:duration animations:^{
        if (WIDTH == 320) {
            if([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
                self.view.frame = CGRectMake(0, -keyboardHeight/2.0, WIDTH, HEIGHT+keyboardHeight);
            }else{
                self.view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
            }
        }
        
    }];
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
