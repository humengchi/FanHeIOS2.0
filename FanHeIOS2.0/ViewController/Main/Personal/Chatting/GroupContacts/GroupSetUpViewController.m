//
//  GroupSetUpViewController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/8/7.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "GroupSetUpViewController.h"
#import "MessageSidViewController.h"
#import "MyGroupViewController.h"
#import "AddFriendsViewCell.h"
#import "JobTextFile.h"
#define kMaxLength  10
@interface GroupSetUpViewController ()< EMGroupManagerDelegate,UITextFieldDelegate>
@property (nonatomic ,strong )  NSMutableArray *friendsArray;
@property (nonatomic ,strong )  NSMutableDictionary *msgNumDict;
@property (nonatomic   ,strong) NSMutableArray *searchArry;
@property (nonatomic   ,strong) UIButton *settingBtn;
@property (nonatomic,strong) UIScrollView *scrollViewHeaderView;
@property (nonatomic,strong) JobTextFile *textFile;
@property (nonatomic   ,strong) NSMutableArray *scrooryArray;
@property (nonatomic   ,strong) NSArray *groubMemberListArray;
@property (nonatomic   ,strong) NSMutableArray *addFriensArray;
@property (nonatomic   ,strong) NSMutableArray *dataArray;
@end

@implementation GroupSetUpViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"创建群组"];
    
    self.addFriensArray = [NSMutableArray new];
    self.scrooryArray = [NSMutableArray new];
    self.msgNumDict = [NSMutableDictionary dictionary];
    self.settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.settingBtn.frame = CGRectMake(WIDTH-80, 20, 64, 44);
    [self.settingBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.settingBtn setTitleColor:HEX_COLOR(@"e24943") forState:UIControlStateNormal];
    self.settingBtn.titleLabel.font = FONT_SYSTEM_SIZE(16);
    [self.settingBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.settingBtn addTarget:self action:@selector(groupSetupAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.settingBtn];
    [self initTableView:CGRectMake(0, 64+ 56, WIDTH, HEIGHT-64 - 56)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 6)];
    headerView.backgroundColor = kTableViewBgColor;
    self.tableView.tableHeaderView = headerView;
    //右检索背景颜色
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    //右检索字体颜色
    self.tableView.sectionIndexColor = [UIColor colorWithHexString:@"41464E"];
    [self loadAllfriendsListArrayData];
    [self createrTabHeaderView];
    
    
    //EMChatManagerDelegate
    //注册群组回调
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    
    //移除群组回调
    [[EMClient sharedClient].groupManager removeDelegate:self];
    // Do any additional setup after loading the view from its nib.
}

- (void)createrTabHeaderView{
    for (UIView *view  in self.scrollViewHeaderView.subviews) {
        [view removeFromSuperview];
    }
    self.scrollViewHeaderView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, WIDTH, 56)];
    UIView *lineView = [NSHelper createrViewFrame:CGRectMake(0, 55.5, WIDTH, 0.5) backColor:@"d9d9d9"];
    [self.scrollViewHeaderView addSubview:lineView];
    
    [self.view addSubview:self.scrollViewHeaderView];
    self.textFile = [[JobTextFile alloc]initWithFrame:CGRectMake(16, 16, WIDTH - 16, 30)];
    self.textFile.font = [UIFont systemFontOfSize:14];
    self.textFile.placeholder = @"搜索";
    self.textFile.delegate = self;
    self.textFile.returnKeyType = UIReturnKeySearch;
    UIImageView *searchImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 13, 13)];
    searchImageView.image = [UIImage imageNamed:@"icon_rm_search"];
    self.textFile.leftViewMode = UITextFieldViewModeAlways;
    self.textFile.leftView = searchImageView;
    if (self.scrooryArray.count != 0) {
        CGFloat x = 0;
        for (NSInteger i = 0; i < self.scrooryArray.count; i++) {
            ChartModel *model = self.scrooryArray[i];
            UIImageView *coverImageViw = [[UIImageView alloc]initWithFrame:CGRectMake(16+x, 10, 36, 36)];
            [coverImageViw sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
            coverImageViw.userInteractionEnabled = YES;
            coverImageViw.tag = i;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeSetGroup:)];
            [coverImageViw addGestureRecognizer:tap];

            // 设置圆角的大小
            coverImageViw.layer.cornerRadius = 18;
            [coverImageViw.layer setMasksToBounds:YES];
            [self.scrollViewHeaderView addSubview:coverImageViw];
            x += 46;
            self.textFile.frame = CGRectMake(x + 28,  16,90, 30);
            NSLog(@"%f",x);
            if (WIDTH - x - 127 < 0) {
                self.scrollViewHeaderView.contentOffset = CGPointMake(x, 0);;
                self.scrollViewHeaderView.contentSize = CGSizeMake(x + 127, 0);
            }
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:)name:@"UITextFieldTextDidChangeNotification"object:self.textFile];
    self.scrollViewHeaderView.showsVerticalScrollIndicator = YES;
    [self.scrollViewHeaderView addSubview:self.textFile];
    [self.view addSubview:self.scrollViewHeaderView];
}
- (void)removeSetGroup:(UITapGestureRecognizer *)g{
    NSInteger index = g.view.tag;
    [self.scrooryArray removeObjectAtIndex:index];
    [self.addFriensArray removeObjectAtIndex:index];
    [self.tableView reloadData];
    [self createrTabHeaderView];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)textFiledEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
        if (toBeString.length <= 0) {
            [self sort:self.dataArray];
        }
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            //            [self.searchArray removeAllObjects];
            if (toBeString.length > kMaxLength) {
                textField.text = [toBeString substringToIndex:kMaxLength];
            }
            if (toBeString.length <= kMaxLength &&toBeString.length > 0 ) {
                
                NSMutableArray *array = [NSMutableArray new];
                for (NSInteger i =0; i < self.friendsArray.count ;i++) {
                    
                    NSDictionary *dict = self.friendsArray[i];
                    NSMutableArray *arrayData = dict[dict.allKeys[0]];
                    for (NSInteger j = 0; j < arrayData.count ; j++) {
                        ChartModel *model = arrayData[j];
                        NSLog(@"%@ == %@",model.realname,self.textFile.text);
                        
                        if ([self.textFile.text isEqualToString:model.realname]) {
                            [array addObject:model];
                            [self sort:array];
                        }
                        
                    }
                    
                    
                    
                }            }
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        //        [self.searchArray removeAllObjects];
        if (toBeString.length > kMaxLength) {
            textField.text = [toBeString substringToIndex:kMaxLength];
        }
        if (toBeString.length <= kMaxLength &&toBeString.length > 0 ) {
            NSMutableArray *array = [NSMutableArray new];
            for (NSInteger i =0; i < self.friendsArray.count ;i++) {
                
                NSDictionary *dict = self.friendsArray[i];
                NSMutableArray *arrayData = dict[dict.allKeys[0]];
                for (NSInteger j = 0; j < arrayData.count ; j++) {
                    ChartModel *model = arrayData[j];
                    NSLog(@"%@ == %@",model.realname,self.textFile.text);
                    
                    if ([self.textFile.text isEqualToString:model.realname]) {
                        [array addObject:model];
                        [self sort:array];
                    }
                    
                }
                
                
                
            }
        }
    }
}
#pragma mafrk ------ 好友
- (void)loadAllfriendsListArrayData{
    __weak typeof(self) weakSelf = self;
    if(self.friendsArray){
        [self.friendsArray removeAllObjects];
    }
    __weak NSMutableArray *array = [[DBInstance shareInstance] getAllChartsModel];
    
    
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@", [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_USER_GET_ALLFRIENDS paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *tmpArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            self.dataArray = [NSMutableArray array];
            for(NSDictionary *dict in tmpArray){
                ChartModel *model = [[ChartModel alloc] initWithDict:dict];
                [self.dataArray addObject:model];
            }
            if(self.dataArray.count){
                [[DBInstance shareInstance] saveChartModelArray:self.dataArray];
                
                [self.dataArray sortUsingComparator:^NSComparisonResult(ChartModel *obj1, ChartModel *obj2){
                    return obj1.userid.integerValue > obj2.userid.integerValue;
                }];
                [array sortUsingComparator:^NSComparisonResult(ChartModel *obj1, ChartModel *obj2){
                    return obj1.userid.integerValue > obj2.userid.integerValue;
                }];
                if(self.dataArray.count != array.count || self.dataArray.count == 0){
                    [weakSelf sort:self.dataArray];
                }else{
                    BOOL refresh = NO;
                    for(int i = 0; i < self.dataArray.count; i++){
                        ChartModel *model1 = self.dataArray[i];
                        ChartModel *model2 = self.dataArray[i];
                        if(model1.userid.integerValue != model2.userid.integerValue){
                            refresh = YES;
                            break;
                        }
                    }
                    if(refresh){
                        [weakSelf sort:self.dataArray];
                    }
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [weakSelf sort:[[DBInstance shareInstance] getAllChartsModel]];
    }];
}
#pragma mark -- UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.friendsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *dict = self.friendsArray[section];
    NSArray *array = dict[dict.allKeys[0]];
    return [array count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 32;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 32)];
    headerView.backgroundColor = kTableViewBgColor;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, WIDTH-16, 32)];
    label.textColor = HEX_COLOR(@"818C9E");
    label.font = FONT_SYSTEM_SIZE(14);
    [headerView addSubview:label];
    NSDictionary *dic = self.friendsArray[section];
    label.text = dic.allKeys[0];
    
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(0, 31.5, WIDTH, 0.5)];
    label3.backgroundColor = kCellLineColor;
    [headerView addSubview:label3];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"AddFriendsViewCell";
    AddFriendsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [CommonMethod getViewFromNib:@"AddFriendsViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *dict = self.friendsArray[indexPath.section];
    NSMutableArray *array = dict[dict.allKeys[0]];
    ChartModel *model = array[indexPath.row];
    [cell tranferChartModel:model groupMembers:self.groubMemberListArray addFriends:self.addFriensArray];
    UIView *lineView = [NSHelper createrViewFrame:CGRectMake(0, 53.5, WIDTH, 0.5) backColor:@"D9D9D9"];
    [cell.contentView addSubview:lineView];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = self.friendsArray[indexPath.section];
    NSMutableArray *array = dict[dict.allKeys[0]];
    ChartModel *model = array[indexPath.row];
    if ([self.addFriensArray containsObject:model.userid]) {
        [self.addFriensArray removeObject:model.userid];
        [self.scrooryArray removeObject:model];
    }else{
        [self.addFriensArray addObject:model.userid];
        [self.scrooryArray addObject:model];
    }
    if (self.addFriensArray.count > 0) {
        [self.settingBtn setTitle:[NSString stringWithFormat:@"确定(%ld)",self.addFriensArray.count] forState:UIControlStateNormal];
    }else{
        [self.settingBtn setTitle:@"确定" forState:UIControlStateNormal];
    }
    //一个cell刷新
    NSIndexPath *indexPath1=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath1,nil] withRowAnimation:UITableViewRowAnimationNone];
    [self createrTabHeaderView];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    self.searchArry = [NSMutableArray new];
    [self.searchArry addObject:@"♡"];
    NSArray *newArray = [NSArray new];
    for (NSInteger i = 0 ; i< self.friendsArray.count; i++) {
        NSDictionary *dic = self.friendsArray[i];
        [self.searchArry addObject:dic.allKeys[0]];
    }
    newArray = self.searchArry;
    return newArray;
}

//排序
- (void)sort:(NSMutableArray*)array{
    if(self.friendsArray == nil){
        self.friendsArray = [NSMutableArray array];
    }else{
        [self.friendsArray removeAllObjects];
    }
    if(array.count){
        char pre = 'A';
        for(int i = 0; i < 26; i++){
            [self filter:[NSString stringWithFormat:@"%C", (unichar)(pre+i)] array:array];
        }
        [self filter:@"#" array:array];
    }
    
    [self.tableView reloadData];
}

- (void)filter:(NSString*)str array:(NSMutableArray*)array{
    NSMutableArray *tempArray = [NSMutableArray array];
    if([str isEqualToString:@"#"]){
        for(ChartModel *model in array){
            if([EaseChineseToPinyin sortSectionTitle:[EaseChineseToPinyin pinyinFromChineseString:model.realname]] == '#'){
                if(model.userid.intValue != [DataModelInstance shareInstance].userModel.userId.intValue){
                    [tempArray addObject:model];
                }
            }
        }
    }else{
        for(ChartModel *model in array){
            if([[[EaseChineseToPinyin pinyinFromChineseString:model.realname] uppercaseString] hasPrefix:str]){
                if(model.userid.intValue != [DataModelInstance shareInstance].userModel.userId.intValue){
                    [tempArray addObject:model];
                }
            }
        }
    }
    if(tempArray.count){
        [self.friendsArray addObject:@{str:tempArray}];
    }
}

- (void)groupSetupAction:(UIButton *)sender {
    if (self.scrooryArray.count == 0) {
        [self showHint:@"选择组员"];
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"创建群组..." toView:self.view];
    
    EMError *error = nil;
    
    EMGroupOptions *setting = [[EMGroupOptions alloc] init];
    setting.IsInviteNeedConfirm = NO;
    setting.maxUsersCount = 500;
    setting.style = EMGroupStylePrivateMemberCanInvite;// 创建不同类型的群组，这里需要才传入不同的类型
    
    NSMutableArray *nameArray = [NSMutableArray array];
    [nameArray addObject:[CommonMethod paramStringIsNull:[DataModelInstance shareInstance].userModel.realname]];
    for (NSInteger i = 0; i < self.scrooryArray.count; i++) {
        if(i==2){
            break;
        }
        ChartModel *model = self.scrooryArray[i];
        [nameArray addObject:[CommonMethod paramStringIsNull:model.realname]];
    }
    NSString *strName = [nameArray componentsJoinedByString:@"，"];
    NSMutableArray *addArray = [NSMutableArray new];
    for (NSInteger i = 0; i < self.addFriensArray.count ; i++) {
        [addArray addObject:[NSString stringWithFormat:@"%@", self.addFriensArray[i]]];
    }
    [[EMClient sharedClient].groupManager createGroupWithSubject:strName description:@"" invitees:addArray message:@"邀请您加入群组" setting:setting completion:^(EMGroup *aGroup, EMError *aError) {
        [hud hideAnimated:YES];
        if(!error){
            if(weakSelf.createGroupSuccess){
                weakSelf.createGroupSuccess();
            }
            for (NSInteger i = 0 ; i  <  addArray.count ; i++) {
               
                NSString *title = [NSString stringWithFormat:@"%@邀请%@加人群聊",[DataModelInstance shareInstance].userModel.realname ,addArray[i]];
                NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:@"joinGroup",@"money_type_special",title,@"title", nil];
                EMMessage *message = [EaseSDKHelper sendTextMessage:title to:aGroup.groupId  messageType:EMChatTypeGroupChat messageExt:dic];
                message.chatType = EMChatTypeGroupChat;
                [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
                    if (!aError) {
                        [MBProgressHUD showSuccess:@"发送成功" toView:self.view];
                        self.tableView.userInteractionEnabled = YES;
                    }else{
                        [MBProgressHUD showError:@"发送失败" toView:self.view];
                    }
                    
                }];
                
            }

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                MessageSidViewController *chatController = [[MessageSidViewController alloc] initWithConversationChatter:aGroup.groupId conversationType:EMConversationTypeGroupChat];
                chatController.isMakeGroup = YES;
                chatController.titleStr = strName;
                [weakSelf.navigationController pushViewController:chatController animated:YES];
            });
            NSLog(@"创建成功 -- %@",aGroup.occupants);
        }else{
            [MBProgressHUD showError:@"创建失败，请重试" toView:weakSelf.view];
            NSLog(@"创建失败 -- %@",aError.errorDescription);
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.textFile resignFirstResponder];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.textFile resignFirstResponder];
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