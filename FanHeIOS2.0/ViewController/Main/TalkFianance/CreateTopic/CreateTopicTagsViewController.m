
//
//  CreateTopicTagsViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/19.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "CreateTopicTagsViewController.h"
#import "InviteAnswerViewController.h"

@interface CreateTopicTagsViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>{
    BOOL _publishDynamic;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, weak) IBOutlet UIButton *publishBtn;

@property (nonatomic, strong) NSMutableArray *selectedArray;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation CreateTopicTagsViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBarHidden = YES;
}

- (void)switchButtonClicked:(UISwitch*)sender{
    _publishDynamic = sender.on;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat start_Y = 0;
    _publishDynamic = YES;
    NSString *baStr;
    if(self.isActivity){
        self.selectedArray = [NSMutableArray arrayWithArray:self.actSelectedArray];
        UILabel *subLabel = [UILabel createrLabelframe:CGRectMake(25, 109, WIDTH-50, 20) backColor:WHITE_COLOR textColor:HEX_COLOR(@"8e8e93") test:@"(最多不超过3个)" font:14 number:1 nstextLocat:NSTextAlignmentLeft];
        [self.view addSubview:subLabel];
        [self.publishBtn setTitle:@"确定" forState:UIControlStateNormal];
        self.titleLabel.text = @"活动标签";
        baStr = @"请为您的活动选择标签：";
    }else{
        self.selectedArray = [NSMutableArray arrayWithArray:self.tdModel.tags];
        if(self.tdModel.subjectid.integerValue){
            self.titleLabel.text = @"编辑话题";
        }
        start_Y = 71;
        baStr = @"请为您的话题选择标签：";
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, 71)];
        topView.backgroundColor = kTableViewBgColor;
        [self.view addSubview:topView];
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 5.5, WIDTH, 60)];
        contentView.backgroundColor = WHITE_COLOR;
        [topView addSubview:contentView];
        UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(16, 12, 100, 18) backColor:WHITE_COLOR textColor:HEX_COLOR(@"afb6c1") test:@"发布至动态" font:17 number:1 nstextLocat:NSTextAlignmentLeft];
        [contentView addSubview:titleLabel];
        UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(16, 36, 230, 13) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e") test:@"关注你的人、同行可以看到你发起的话题" font:12 number:1 nstextLocat:NSTextAlignmentLeft];
        [contentView addSubview:contentLabel];
        UISwitch *switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(WIDTH-67, 15, 51, 31)];
        switchBtn.tintColor = HEX_COLOR(@"d8d8d8");
        switchBtn.backgroundColor = WHITE_COLOR;
        [switchBtn setOnTintColor:HEX_COLOR(@"1abc9c")];
        switchBtn.on = YES;
        [contentView addSubview:switchBtn];
        [switchBtn addTarget:self action:@selector(switchButtonClicked:) forControlEvents:UIControlEventValueChanged];
    }
    
    UILabel *titleBaLabel = [UILabel createLabel:CGRectMake(25, 86+start_Y, WIDTH-50, 20) font:FONT_SYSTEM_SIZE(17) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"858585")];
    titleBaLabel.text = baStr;
    [self.view addSubview:titleBaLabel];
    CGRect frame = CGRectMake(10, 128+start_Y, WIDTH-20, HEIGHT-128-start_Y);
    self.publishBtn.enabled = self.selectedArray.count!=0;
    //移除滑动手势
    for (UIPanGestureRecognizer *ges in self.view.gestureRecognizers){
        [self.view removeGestureRecognizer:ges];
    }
    self.dataArray = [NSMutableArray array];
    //确定是水平滚动，还是垂直滚动
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:
     UICollectionViewScrollDirectionVertical];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
    self.collectionView.dataSource=self;
    self.collectionView.delegate=self;
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
    //注册Cell，必须要有
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"myHeaderView"];
    [self.view addSubview:self.collectionView];
    
    [self loadData];
}

#pragma mark - method
- (IBAction)backNavButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)publishButtonClicked:(id)sender{
    [self newThreadForAvoidButtonRepeatClick:sender];
    if(self.isActivity){
        if(self.activitySeletedTags){
            self.activitySeletedTags([self.selectedArray componentsJoinedByString:@","]);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self createTopic];
    }
}

- (void)createTopic{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"发布中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.tdModel.title forKey:@"title"];
    [requestDict setObject:[CommonMethod paramStringIsNull:self.tdModel.content] forKey:@"content"];
    [requestDict setObject:[self.selectedArray componentsJoinedByString:@","] forKey:@"tags"];
    [requestDict setObject:[CommonMethod paramNumberIsNull:self.tdModel.subjectid] forKey:@"subjectid"];
    if(_publishDynamic){
        [requestDict setObject:@(1) forKey:@"adddynamic"];
    }
    [self requstType:RequestType_Post apiName:API_NAME_POST_ADD_SUBJECT paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if(weakSelf.tdModel.subjectid.integerValue == 0){
                InviteAnswerViewController *vc = [[InviteAnswerViewController alloc] init];
                weakSelf.tdModel.subjectid = [CommonMethod paramNumberIsNull:responseObject[@"data"]];
                vc.tdModel = weakSelf.tdModel;
                vc.isCreateTopic = YES;
                NSInteger sum = self.navigationController.viewControllers.count;
                [weakSelf.navigationController setViewControllers:@[self.navigationController.viewControllers[sum-4], vc] animated:YES];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"publishOrEditTopicSaveSuccess" object:nil];
                NSInteger sum = self.navigationController.viewControllers.count;
                [weakSelf.navigationController popToViewController:self.navigationController.viewControllers[sum-4] animated:YES];
            }
        }else{
            [MBProgressHUD showError:[responseObject objectForKey:@"msg"] toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - 标签网络请求
- (void)loadData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [self requstType:RequestType_Get apiName:API_NAME_MATCH_PROPERTY_INDUSTRY paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            weakSelf.dataArray = [[CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]] mutableCopy];
            [weakSelf.collectionView reloadData];
        }else{
            [MBProgressHUD showError:[responseObject objectForKey:@"msg"] toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark -- UICollectionViewDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(WIDTH,5);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"myHeaderView" forIndexPath:indexPath];
    for(UIView *view in headView.subviews){
        [view removeFromSuperview];
    }
    
    
    return headView;
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"UICollectionViewCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    for(UIGestureRecognizer *gesture in cell.gestureRecognizers){
        [cell removeGestureRecognizer:gesture];
    }
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    NSString *tagStr = self.dataArray[indexPath.row];
    CGFloat strWidth = [NSHelper widthOfString:tagStr font:FONT_SYSTEM_SIZE(13) height:29];
    strWidth = (WIDTH-80)/3.0;
    if([self.selectedArray containsObject:tagStr]){
        UILabel *label = [UILabel createrLabelframe:CGRectMake(0, 0, strWidth, 29) backColor:HEX_COLOR(@"1abc9c") textColor:WHITE_COLOR test:tagStr font:13 number:1 nstextLocat:NSTextAlignmentCenter];
        [CALayer updateControlLayer:label.layer radius:3 borderWidth:1 borderColor:HEX_COLOR(@"1abc9c").CGColor];
        [cell.contentView addSubview:label];
    }else{
        UILabel *label = [UILabel createrLabelframe:CGRectMake(0, 0, strWidth, 29) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464E") test:tagStr font:13 number:1 nstextLocat:NSTextAlignmentCenter];
        [CALayer updateControlLayer:label.layer radius:3 borderWidth:.5 borderColor:HEX_COLOR(@"afb6c1").CGColor];
        [cell.contentView addSubview:label];
    }
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat strWidth = [NSHelper widthOfString:self.dataArray[indexPath.row] font:FONT_SYSTEM_SIZE(13) height:29];
    strWidth = (WIDTH-80)/3.0;//strWidth>(WIDTH-50)/3.0?strWidth:(WIDTH-50)/3.0;
    return CGSizeMake(strWidth, 29);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(15, 10, 15, 10);
}

#pragma mark --UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *tagStr = self.dataArray[indexPath.row];
    if([self.selectedArray containsObject:tagStr]){
        [self.selectedArray removeObject:tagStr];
    }else{
        if(self.isActivity&&self.selectedArray.count>=3){
            [self.view showToastMessage:@"最多只能选中3个标签"];
            return;
        }
        [self.selectedArray addObject:tagStr];
    }
    [self.collectionView reloadData];
    self.publishBtn.enabled = self.selectedArray.count!=0;
}

@end
