//
//  GetWallCoffeeDetailViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/26.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "GetWallCoffeeDetailViewController.h"
#import "GetWallCoffeeReplyTableViewCell.h"
#import "GetWallCoffeeTakeTableViewCell.h"
#import "NONetWorkTableViewCell.h"

@interface GetWallCoffeeDetailViewController (){
    BOOL _noNetWork;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) MyGetCoffeeModel *model;

@property (weak, nonatomic) IBOutlet UIView *keyBoardView;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (weak, nonatomic) IBOutlet UILabel *inputTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;

@end

@implementation GetWallCoffeeDetailViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [CALayer updateControlLayer:self.inputTextView.layer radius:5 borderWidth:0.3 borderColor:HEX_COLOR(@"818C9E").CGColor];
    [CALayer updateControlLayer:self.sendBtn.layer radius:5 borderWidth:0 borderColor:nil];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT-64) style:UITableViewStylePlain];
    self.tableView.backgroundColor = kTableViewBgColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view insertSubview:self.tableView belowSubview:self.keyBoardView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self loadHttpDataMyGetCoffeeDetail];
    
    if(self.type.integerValue == 1){
        [self setReadMsgHttp];
    }
    [self.inputTextView.rac_textSignal subscribeNext:^(NSString *text) {
        if(text.length > 50){
            self.inputTextView.text = [text substringToIndex:50];
        }
        self.inputTextLabel.text = self.inputTextView.text;
    }];
    [CommonMethod viewAddGuestureRecognizer:self.titleLabel tapsNumber:1 withTarget:self withSEL:@selector(gotoHomePage)];
}

- (void)gotoHomePage{
    NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
    vc.userId = self.model.userid;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setTitleLabel{
    if (!self.isMygetCoffee && self.model.revert.length==0) {
        self.keyBoardView.hidden = NO;
    }else{
        self.keyBoardView.hidden = YES;;
    }
    NSMutableAttributedString * attriStr = [[NSMutableAttributedString alloc] initWithString:self.model.realname];
    NSTextAttachment *attchImage = [[NSTextAttachment alloc] init];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.model.image]];
    UIImage *headImage = [UIImage imageWithData:data];
    // 表情图片
    attchImage.image = [headImage roundedCornerImageWithCornerRadius:CGRectMake(0, 0, 24, 24)];
    // 设置图片大小
    attchImage.bounds = CGRectMake(-4, -4, 24, 24);
    NSAttributedString *stringImage = [NSAttributedString attributedStringWithAttachment:attchImage];
    [attriStr insertAttributedString:stringImage atIndex:0];
    self.titleLabel.attributedText = attriStr;
}

#pragma mark -网络请求
- (void)loadHttpDataMyGetCoffeeDetail{
    _noNetWork = NO;
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", self.coffeegetid, [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_USER_GET_MY_COFFEE_DETAIL paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            weakSelf.model = [[MyGetCoffeeModel alloc] initWithDict:[CommonMethod paramDictIsNull:responseObject[@"data"]]];
            [weakSelf setTitleLabel];
        }else{
            [MBProgressHUD showError:@"请求失败，请重试" toView:weakSelf.view];
            _noNetWork = YES;
        }
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        _noNetWork = YES;
        [weakSelf.tableView reloadData];
    }];
}

//消息已读
- (void)setReadMsgHttp{
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.coffeegetid forKey:@"msgid"];
    if(self.isMygetCoffee){
        [requestDict setObject:@"2" forKey:@"type"];
    }else{
        [requestDict setObject:@"1" forKey:@"type"];
    }
    [self requstType:RequestType_Post apiName:API_NAME_USER_READ_COFF_MSG paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

//回复消息
- (IBAction)replyCoffeeHttp:(id)sender{
    if(self.inputTextView.text.length==0){
        return;
    }
    [self.inputTextView endEditing:YES];
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"回复中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.model.msgid forKey:@"msgid"];
    [requestDict setObject:self.inputTextView.text forKey:@"msg"];
    [self requstType:RequestType_Post apiName:API_NAME_USER_REPLY_COFF_MSG paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            weakSelf.model.revert = self.inputTextView.text;
            weakSelf.model.reverttime = [NSDate currentTimeString:kTimeFormat];
            if (self.isMygetCoffee && self.model.revert.length==0) {
                self.keyBoardView.hidden = NO;
            }else{
                self.keyBoardView.hidden = YES;;
            }
            [weakSelf.tableView reloadData];
            if(weakSelf.replySuccess){
                weakSelf.replySuccess(weakSelf.inputTextView.text);
            }
        }else{
            [MBProgressHUD showError:@"发送失败，请重试" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark- method
- (IBAction)backButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.model){
        if(self.model.revert.length){
            return 2;
        }else{
            return 1;
        }
    }else if(_noNetWork){
        return 1;
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.model){
        if(indexPath.row==0){
            return [GetWallCoffeeTakeTableViewCell getCellHeight:self.model isMyGetCodffee:self.isMygetCoffee];
        }else{
            return [GetWallCoffeeReplyTableViewCell getCellHeight:self.model];
        }
    }else{
        return self.tableView.frame.size.height;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.model){
        if(indexPath.row==0){
            static NSString *identify = @"GetWallCoffeeTakeTableViewCell";
            GetWallCoffeeTakeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
            if(!cell){
                cell = [CommonMethod getViewFromNib:self.isMygetCoffee?@"GetWallCoffeeTakeTableViewCellMy":@"GetWallCoffeeTakeTableViewCellOther"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell updateDisply:self.model isMyGetCodffee:self.isMygetCoffee];
            return cell;
        }else{
            static NSString *identify = @"GetWallCoffeeReplyTableViewCell";
            GetWallCoffeeReplyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
            if(!cell){
                cell = [CommonMethod getViewFromNib:self.isMygetCoffee?@"GetWallCoffeeReplyTableViewCellOther":@"GetWallCoffeeReplyTableViewCellMy"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell updateDisply:self.model isMyGetCodffee:self.isMygetCoffee];
            return cell;
        }
    }else{
        static NSString *identify = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NONetWorkTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.model){
    }else{
        [self loadHttpDataMyGetCoffeeDetail];
    }
}

#pragma mark - Keyboard status
- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardEnd.size.height;
    [UIView animateWithDuration:duration animations:^{
        if([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
            self.view.frame = CGRectMake(0, 0, WIDTH, HEIGHT-keyboardHeight);
        }else{
            self.view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        }
    }];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if (self.tableView.contentOffset.y < 0) {
//        self.tableView.scrollEnabled = NO;
//        [self.tableView setContentOffset:CGPointMake(0, 0)];
//    }else{
//        self.tableView.scrollEnabled = YES;
//    }
    [self.inputTextView endEditing:YES];
}
@end
