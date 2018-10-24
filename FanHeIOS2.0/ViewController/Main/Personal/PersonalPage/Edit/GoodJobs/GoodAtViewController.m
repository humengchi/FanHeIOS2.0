//
//  GoodAtViewController.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/11/3.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "GoodAtViewController.h"
#import "NONetWorkTableViewCell.h"
#import "GoodJobCell.h"
#import "JobTextFile.h"
#define kMaxLength  10
@interface GoodAtViewController ()<UITextFieldDelegate,keyInputJobTextFileDelegate>

@property (nonatomic,strong)NSMutableArray *dataArray;
//所有业务
@property (nonatomic,strong)NSMutableArray *friendsArray;
//热门业务
@property (nonatomic,strong)NSMutableArray *hotBunessArray;
@property (nonatomic,assign) BOOL netWorkStat;
@property (nonatomic,strong) JobTextFile *textFile;
@property (nonatomic,strong)  UIScrollView *scrollViewHeaderView;
//选取的擅长业务
@property (nonatomic,strong) NSMutableArray *titleArray;
@property (nonatomic,strong) UIView *hotView;
@property (nonatomic,strong) UIButton *makeSureBtn;
//搜索业务
@property (nonatomic,strong) NSMutableArray *searchArray;

@property (nonatomic,assign)  NSInteger indexSearch;

@end

@implementation GoodAtViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchArray = [NSMutableArray new];
    self.jobShoweType = BUNESS_ALL_JOBTYPE;
    self.indexSearch = -1;
    self.titleArray = [NSMutableArray arrayWithArray:self.array];
    self.hotBunessArray = [NSMutableArray new];
    
    if(!self.needSupplyTagsSuccess){
        [self createCustomNavigationBar:@"擅长业务"];
    }else{
        [self createCustomNavigationBar:@"标签"];
    }
    [self createrSearchMyLikeJob];
    [self initTableView:CGRectMake(0,64+50, WIDTH,HEIGHT - 50-64)];
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = HEX_COLOR(@"41464E");
    [self getAllHotBuness];
    self.makeSureBtn = [NSHelper createButton:CGRectMake(WIDTH - 86, 34, 76, 16) title:[NSString stringWithFormat:@"保存(%ld/3)",(unsigned long)self.titleArray.count] unSelectImage:nil selectImage:nil target:self selector:@selector(makeSureGoodAtAction:)];
    if (self.titleArray.count > 0) {
        [self.makeSureBtn setTitleColor:[UIColor colorWithHexString:@"E24943"] forState:UIControlStateNormal];
    }else{
        [self.makeSureBtn setTitleColor:[UIColor colorWithHexString:@"E6E8EB"] forState:UIControlStateNormal];
    }
    [self.view addSubview:self.makeSureBtn];
}
- (void)customNavBackButtonClicked{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)createrSearchMyLikeJob{
    
    for (UIView *view  in self.scrollViewHeaderView.subviews) {
        [view removeFromSuperview];
    }
    [self.makeSureBtn setTitle:[NSString stringWithFormat:@"保存(%ld/3)",(unsigned long)self.titleArray.count] forState:UIControlStateNormal];
    if (self.titleArray.count > 0) {
        [self.makeSureBtn setTitleColor:[UIColor colorWithHexString:@"E24943"] forState:UIControlStateNormal];
    }else{
        [self.makeSureBtn setTitleColor:[UIColor colorWithHexString:@"E6E8EB"] forState:UIControlStateNormal];
    }
    
    self.scrollViewHeaderView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, WIDTH, 50)];
    UIView *lineView = [NSHelper createrViewFrame:CGRectMake(0, 49.5, WIDTH, 0.5) backColor:@"d9d9d9"];
    [self.scrollViewHeaderView addSubview:lineView];
    
    [self.view addSubview:self.scrollViewHeaderView];
    self.textFile = [[JobTextFile alloc]initWithFrame:CGRectMake(16, 10, WIDTH - 16, 30)];
    self.textFile.font = [UIFont systemFontOfSize:14];
    self.textFile.placeholder = @"搜索";
    self.textFile.delegate = self;
    self.textFile.keyInputDelegate = self;
    
    self.textFile.returnKeyType = UIReturnKeySearch;
    if (self.titleArray.count == 0) {
        UIImageView *searchImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 13, 13)];
        searchImageView.image = [UIImage imageNamed:@"icon_rm_search"];
        self.textFile.leftViewMode = UITextFieldViewModeAlways;
        self.textFile.leftView = searchImageView;
    }else{
        CGFloat x = 0;
        for (NSInteger i = 0; i < self.titleArray.count; i++) {
            CGFloat wideth = [NSHelper widthOfString:self.titleArray[i] font:[UIFont systemFontOfSize:14] height:31]+20;
            UILabel *label = [UILabel createLabel:CGRectMake(16+x, 10, wideth, 31) font:[UIFont systemFontOfSize:13] bkColor:[UIColor colorWithHexString:@"1ABC9C"] textColor:[UIColor whiteColor]];
            label.layer.borderWidth = 2.0;
            label.layer.borderColor = [UIColor colorWithHexString:@"1ABC9C"].CGColor;
            label.textAlignment = NSTextAlignmentCenter;
            label.text = self.titleArray[i];
            label.layer.masksToBounds = YES;
            label.layer.cornerRadius = 5.0;
            label.tag = i;
            UITapGestureRecognizer *remove = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeGoodJob:)];
            [label addGestureRecognizer:remove];
            label.userInteractionEnabled = YES;
            [self.scrollViewHeaderView addSubview:label];
            x += wideth + 10;
            
            self.textFile.frame = CGRectMake(x + 18,  10,90, 30);
            
            if (WIDTH - x - 18 - 100 < 0) {
                self.scrollViewHeaderView.contentSize = CGSizeMake(x + 50, 0);
            }
            
        }
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiledEditChanged:)name:@"UITextFieldTextDidChangeNotification"object:self.textFile];
    self.scrollViewHeaderView.showsVerticalScrollIndicator = YES;
    [self.scrollViewHeaderView addSubview:self.textFile];
    
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)textFiledEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if (toBeString.length <= 0) {
        self.jobShoweType = BUNESS_HOT_JOBTYPE;
        [self createrHotBuness];
        [self createrSearchMyLikeJob];
        
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
                
                [self getSearchBuness];
            }
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
            [self getSearchBuness];
        }
    }
}
#pragma mark ------ 点击删除
- (void)removeGoodJob:(UITapGestureRecognizer *)g{
    NSInteger index = g.view.tag;
    if (self.jobShoweType == BUNESS_ALL_JOBTYPE || self.jobShoweType == BUNESS_SEARCH_JOBTYPE) {
        [self.titleArray removeObjectAtIndex:index];
        [self.tableView reloadData];
    }else {
        SubjectModel *model  = [[SubjectModel alloc]init];
        model.business   = self.titleArray[index];
        [self.hotBunessArray addObject:model];
        [self.titleArray removeObjectAtIndex:index];
        [self createrHotBuness];
        
    }
    [self createrSearchMyLikeJob];
}
#pragma mark ------ 上传擅长业务
- (void)makeSureGoodAtAction:(UIButton *)btn{
    if (self.titleArray.count == 0) {
        [self showHint:@"至少选择一个擅长业务"];
        return;
    }
    //发布供需，选择标签
    if(self.needSupplyTagsSuccess){
        self.needSupplyTagsSuccess(self.titleArray);
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:[self.titleArray componentsJoinedByString:@","] forKey:@"business"];
    
    [self requstType:RequestType_Post apiName:API_NAME_SAVE_MY_INFO paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            UserModel *userModel = [DataModelInstance shareInstance].userModel;
            userModel.business = [weakSelf.dataArray componentsJoinedByString:@","];
            userModel.goodjobs = weakSelf.titleArray;
            [DataModelInstance shareInstance].userModel = userModel;
            if (self.gooJobDelegate && [self.gooJobDelegate respondsToSelector:@selector(referViewGoodAtJob)]) {
                [self.gooJobDelegate referViewGoodAtJob];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }else{
            [MBProgressHUD showError:[responseObject objectForKey:@"msg"] toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
    
}
#pragma mafrk ------ 业务
- (void)getAllHotBuness{
    __weak typeof(self) weakSelf = self;
    if(self.friendsArray){
        [self.friendsArray removeAllObjects];
    }
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    [[[UIViewController alloc] init] requstType:RequestType_Get apiName:API_NAME_GET_ALLHOTBUSINESS paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        self.netWorkStat = NO;
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *dic = [CommonMethod paramDictIsNull:[responseObject objectForKey:@"data"]];
            NSMutableArray *array = [NSMutableArray new];
            NSArray *dataArray = [CommonMethod paramArrayIsNull:dic[@"business"]];
            NSArray *hotArray =  [CommonMethod paramArrayIsNull:dic[@"hotbusiness"]];
            for(NSDictionary *dict in dataArray){
                SubjectModel *model = [[SubjectModel alloc] initWithDict:dict];
                model.businessID = dict[@"id"];
                [array addObject:model];
            }
            for(NSDictionary *dict in hotArray){
                SubjectModel *model = [[SubjectModel alloc] initWithDict:dict];
                model.businessID = dict[@"id"];
                [self.hotBunessArray addObject:model];
            }
            [weakSelf sort:array];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        self.netWorkStat = YES;
    }];
}

#pragma mark -- UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.jobShoweType == BUNESS_ALL_JOBTYPE) {
        return self.friendsArray.count;
    }else if (self.jobShoweType == BUNESS_SEARCH_JOBTYPE) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.jobShoweType == BUNESS_ALL_JOBTYPE) {
        NSDictionary *dict = self.friendsArray[section];
        NSArray *array = dict[dict.allKeys[0]];
        return [array count];
    }else if (self.jobShoweType == BUNESS_SEARCH_JOBTYPE) {
        return self.searchArray.count;
    }else if(self.netWorkStat == YES){
        return 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.jobShoweType == BUNESS_SEARCH_JOBTYPE) {
        return 0;
    }
    return 32;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat == YES){
        return self.tableView.frame.size.height;
    }else {
        return 52;
    }
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
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
    label2.backgroundColor = kCellLineColor;
    [headerView addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(0, 31.5, WIDTH, 0.5)];
    label3.backgroundColor = kCellLineColor;
    [headerView addSubview:label3];
    return headerView;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.netWorkStat){
        static NSString *cellID = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([NONetWorkTableViewCell class])];
        }
        self.tableView.tableHeaderView = [UIView new];
        return cell;
    }else{
        static NSString *cellReID = @"cellReID";
        GoodJobCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReID];
        if (!cell) {
            cell = [CommonMethod getViewFromNib:NSStringFromClass([GoodJobCell class])];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (self.jobShoweType == BUNESS_ALL_JOBTYPE) {
            NSDictionary *dict = self.friendsArray[indexPath.section];
            NSMutableArray *array = dict[dict.allKeys[0]];
            SubjectModel *model = array[indexPath.row];
            BOOL isSelect = NO;
            if ([self.titleArray containsObject:model.business]) {
                isSelect = YES;
            }else{
                isSelect = NO;
            }
            [cell goodAtlokeJob:model row:indexPath.row section:indexPath.section select:isSelect isSearch:nil];
        }else if (self.jobShoweType == BUNESS_SEARCH_JOBTYPE)
        {
            SubjectModel *model = [[SubjectModel alloc]init];
            model.business = self.searchArray[indexPath.row];
            BOOL isSelect = NO;
            if ([self.titleArray containsObject:model.business]) {
                isSelect = YES;
            }else{
                isSelect = NO;
            }
            if ([self.textFile.text isEqualToString:model.business]) {
                [cell goodAtlokeJob:model row:indexPath.row section:indexPath.section select:isSelect isSearch:nil];
            }else{
                [cell goodAtlokeJob:model row:indexPath.row section:indexPath.section select:isSelect isSearch:self.textFile.text];
            }
            
        }
        return cell;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.jobShoweType == BUNESS_ALL_JOBTYPE) {
        NSDictionary *dict = self.friendsArray[indexPath.section];
        NSMutableArray *array = dict[dict.allKeys[0]];
        SubjectModel *model = array[indexPath.row];
        if (self.titleArray.count >= 3) {
            if(![self.titleArray containsObject:model.business]){
                [[[CommonUIAlert alloc] init] showCommonAlertView:self title:nil message:@"仅可设置3个擅长业务" cancelButtonTitle:nil otherButtonTitle:@"确定" cancle:^{
                } confirm:^{
                }];
            }else{
                [self.titleArray removeObject:model.business];
            }
        }else{
            if(![self.titleArray containsObject:model.business]){
                [self.titleArray addObject:model.business];
            }else{
                [self.titleArray removeObject:model.business];
            }
        }
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        [self createrSearchMyLikeJob];
    }else if(self.jobShoweType == BUNESS_SEARCH_JOBTYPE){
        
        SubjectModel *model = [[SubjectModel alloc]init];
        model.business = self.searchArray[indexPath.row];
        if (self.titleArray.count >= 3) {
            if(![self.titleArray containsObject:model.business]){
                [[[CommonUIAlert alloc] init] showCommonAlertView:self title:nil message:@"仅可设置3个擅长业务" cancelButtonTitle:nil otherButtonTitle:@"确定" cancle:^{
                } confirm:^{
                }];
            }else{
                [self.titleArray removeObject:model.business];
            }
        }else{
            
            if(![self.titleArray containsObject:model.business]){
                self.jobShoweType = BUNESS_ALL_JOBTYPE;
                [self.titleArray addObject:model.business];
            }else{
                [self.titleArray removeObject:model.business];
            }
        }
        [self.tableView reloadData];
        [self createrSearchMyLikeJob];
    }
    
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
        for(SubjectModel *model in array){
            if([EaseChineseToPinyin sortSectionTitle:[EaseChineseToPinyin pinyinFromChineseString:model.business]] == '#'){
                
                [tempArray addObject:model];
                
            }
        }
    }else{
        for(SubjectModel *model in array){
            if([[[EaseChineseToPinyin pinyinFromChineseString:model.business] uppercaseString] hasPrefix:str]){
                
                [tempArray addObject:model];
                
            }
        }
    }
    if(tempArray.count){
        [self.friendsArray addObject:@{str:tempArray}];
    }
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    self.dataArray = [NSMutableArray new];
    NSArray *newArray = [NSArray new];
    if (self.jobShoweType == BUNESS_ALL_JOBTYPE) {
        for (NSInteger i = 0 ; i< self.friendsArray.count; i++) {
            NSDictionary *dic = self.friendsArray[i];
            
            [self.dataArray addObject:dic.allKeys[0]];
        }
        newArray = self.dataArray;
        return newArray;
    }else {
        return newArray;
    }
    
}

#pragma mark -------keyInputJobTextFileDelegate删除事件
- (void) deleteBackwardJob{
    
    if (self.indexSearch != -1) {
        self.indexSearch -= 1;
    }
    if (self.jobShoweType == BUNESS_ALL_JOBTYPE) {
        if (self.indexSearch == -1) {
            if (self.titleArray.count > 0) {
                NSInteger index = self.titleArray.count;
                [self.titleArray removeObjectAtIndex:index - 1];
                [self createrSearchMyLikeJob];
                [self.tableView reloadData];
            }
        }
    }else if (self.jobShoweType == BUNESS_HOT_JOBTYPE){
        if (self.indexSearch == -1) {
            if (self.titleArray.count > 0) {
                NSInteger index = self.titleArray.count;
                SubjectModel *model  = [[SubjectModel alloc]init];
                model.business   = self.titleArray[index - 1];
                [self.hotBunessArray addObject:model];
                [self.titleArray removeObjectAtIndex:index - 1];
                [self createrHotBuness];
                [self createrSearchMyLikeJob];
            }
        }
    }else if (self.jobShoweType == BUNESS_SEARCH_JOBTYPE){
        if (self.indexSearch == -1) {
            if (self.titleArray.count > 0) {
                NSInteger index = self.titleArray.count;
                [self.titleArray removeObjectAtIndex:index - 1];
                [self createrSearchMyLikeJob];
                [self.tableView reloadData];
            }
        }
        
    }
    
    [self.textFile becomeFirstResponder];
}
#pragma mark ----- 热门业务
-(void)createrHotBuness{
    if(self.hotView){
        [self.hotView removeFromSuperview];
        self.hotView = nil;
    }
    self.jobShoweType = BUNESS_HOT_JOBTYPE;
    if(self.hotView==nil){
        self.hotView = [NSHelper createrViewFrame:CGRectMake(0, 114, WIDTH, HEIGHT - 114) backColor:@"FFFFFF"];
        [self.view addSubview:self.hotView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backAllPosition)];
        [self.hotView addGestureRecognizer:tap];
    }
    
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0.5, WIDTH , 0.5)];
    lineLabel.backgroundColor = HEX_COLOR(@"D9D9D9");
    [self.hotView addSubview:lineLabel];
    UILabel *titleLabel = [UILabel createLabel:CGRectMake(0, 0, WIDTH, 32) font:[UIFont systemFontOfSize:14] bkColor:[UIColor colorWithHexString:@"EFEFF4"] textColor:[UIColor colorWithHexString:@"818C9E"]];
    titleLabel.text = @"    热门业务";
    [self.hotView addSubview:titleLabel];
    CGFloat start_X = 16;
    CGFloat start_Y = 56;
    CGRect btnFrame = CGRectMake(0, 0, 100, 29);
    for(int i = 0; i < self.hotBunessArray.count; i++){
        SubjectModel *model = self.hotBunessArray[i];
        if (self.titleArray.count > 0) {
            if([self.titleArray containsObject:model.business]){
                [self.hotBunessArray removeObjectAtIndex:i];
            }
        }
    }
    NSArray *goodJobsArray = self.hotBunessArray;
    for(int i = 0; i < goodJobsArray.count; i++){
        SubjectModel *model = goodJobsArray[i];
        NSString *str = model.business;
        CGFloat strWidth = [NSHelper widthOfString:str font:FONT_SYSTEM_SIZE(13) height:29]+40;
        if(start_X+strWidth > WIDTH-32){
            start_X = 16;
            start_Y += 43;
        }
        if(strWidth > WIDTH-32){
            strWidth = WIDTH - 32;
        }
        btnFrame.size.width = strWidth;
        btnFrame.origin.x = start_X;
        btnFrame.origin.y = start_Y;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = btnFrame;
        //设置button正常状态下的背景图
        [btn setBackgroundImage:[UIImage imageNamed:@"bg_rmyw_hs"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"bg_rmyw_ls"] forState:UIControlStateSelected];
        btn.tag = i;
        //设置button正常状态下的背景图
        [btn setImage:[UIImage imageNamed:@"btn_zy_sc_w"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"btn_zy_sc_y"] forState:UIControlStateSelected];
        //设置button高亮状态下的背景图
        //button图片的偏移量，距上左下右分别(10, 10, 10, 60)像素点
        btn.imageEdgeInsets = UIEdgeInsetsMake(6.5, 7.5, 6.5,strWidth - 26);
        //button标题的偏移量，这个偏移量是相对于图片的
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, -4, 0, 0);
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn setTitle:str forState:UIControlStateNormal];
        [btn setTitleColor:HEX_COLOR(@"1ABC9C") forState:UIControlStateSelected];
        [btn setTitleColor:HEX_COLOR(@"41464E") forState:UIControlStateNormal];
        [self.hotView addSubview:btn];
        // 设置圆角
        
        start_X += strWidth+20;
        [btn addTarget:self action:@selector(selectLikeJob:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.tableView.hidden = YES;
}
- (void)backAllPosition{
    //返回所有
    [self.hotView removeFromSuperview];
    [self.textFile resignFirstResponder];
    self.tableView.hidden = NO;
    self.jobShoweType = BUNESS_ALL_JOBTYPE;
    [self.tableView reloadData];
    
    //    [self createrSearchMyLikeJob];
    
}
#pragma mark --------  选择热门业务
- (void)selectLikeJob:(UIButton *)btn{
    NSInteger index = btn.tag;
    SubjectModel *model = self.hotBunessArray[index];
    if (self.titleArray.count >= 3) {
        if(![self.titleArray containsObject:model.business]){
            [self.view showToastMessage:@"仅可设置3个擅长业务"];
            return ;
        }else{
            [self.titleArray removeObject:model.business];
        }
    }else{
        
        if(![self.titleArray containsObject:model.business]){
            [self.titleArray addObject:model.business];
            [self.hotBunessArray removeObject:model.business];
        }else{
            [self.titleArray removeObject:model.business];
            [self.hotBunessArray addObject:model.business];
        }
    }
    //返回所有
    self.jobShoweType = BUNESS_ALL_JOBTYPE;
    [self.tableView reloadData];
    self.tableView.hidden = NO;
    [self.hotView removeFromSuperview];
    [self createrSearchMyLikeJob];
}
#pragma mark --------UITextViewDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self createrHotBuness];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.text.length == 0) {
        NSString *tem = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]componentsJoinedByString:@""];
        if (![string isEqualToString:tem]) {
            return NO;
        }
    }
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    if(position && (range.length==0 || string.length==0)){
        return YES;
    }else{
        NSString *str = [textField.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:string];
        if(str.length>10){
            self.textFile.text = [str substringToIndex:10];
            return NO;
        }
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textFile resignFirstResponder];
    
    [self getSearchBuness];
    return  YES;
}
#pragma mark ------  搜素业务
-(void)getSearchBuness{
    self.tableView.hidden = NO;
    [self.hotView removeFromSuperview];
    __weak typeof(self) weakSelf = self;
    self.jobShoweType = BUNESS_SEARCH_JOBTYPE;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    if(self.textFile.text && self.textFile.text.length){
        [requestDict setObject:[NSString stringWithFormat:@"/%@",self.textFile.text] forKey:@"param"];
    }
    [self requstType:RequestType_Get apiName:API_NAME_MATCH_PROPERTY_BUSINESS paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            self.netWorkStat = NO;
            [weakSelf.searchArray removeAllObjects];
            [weakSelf.searchArray addObjectsFromArray:[CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]]];
            if (self.textFile.text) {
                [self.searchArray insertObject:self.textFile.text atIndex:0];
            }
            [weakSelf.tableView reloadData];
        }else{
            [MBProgressHUD showError:[responseObject objectForKey:@"msg"] toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        //        [hud hideAnimated:YES];
        self.netWorkStat = YES;
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
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
