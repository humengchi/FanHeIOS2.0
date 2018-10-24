//
//  CoffeeIntroduceViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/11/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "CoffeeIntroduceViewController.h"
#import "ContactsCollectionViewCell.h"
#import "CoffeeHelpViewController.h"
#import "MyCofferViewController.h"

@interface CoffeeIntroduceViewController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>{
    NSInteger _currentSec;
}

@property (nonatomic, strong) UICollectionView  *collectionView;

@property (nonatomic, strong) NSMutableArray    *dataArray;

@property (nonatomic, strong) NSTimer   *timer;

@end

@implementation CoffeeIntroduceViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBarHidden = NO;
    if(self.dataArray.count){
        [self reloadCollectionView];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.timer invalidate];
    self.timer = nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"人脉咖啡";
    self.dataArray = [NSMutableArray array];
    
    [self initScrollView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = HEX_COLOR(@"DFCDBA");
    
    CGFloat height = 1543*WIDTH/375.0;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, height)];
    imageView.image = kImageWithName(@"bg_coffee_xcy");
    [self.scrollView addSubview:imageView];
    
    UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(0, height, WIDTH, 28) backColor:nil textColor:HEX_COLOR(@"41464e") test:@"他们在“3号圈”也有一杯自己的咖啡" font:20 number:1 nstextLocat:NSTextAlignmentCenter];
    [self.scrollView addSubview:titleLabel];
    height+=45;
    
    //确定是水平滚动，还是垂直滚动
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:
     UICollectionViewScrollDirectionVertical];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, height, WIDTH, 60*WIDTH/375.0+62) collectionViewLayout:flowLayout];
    self.collectionView.dataSource=self;
    self.collectionView.delegate=self;
    [self.collectionView setBackgroundColor:HEX_COLOR(@"DFCDBA")];
    self.collectionView.bounces = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.scrollEnabled = NO;
    self.collectionView.pagingEnabled = YES;
    //注册Cell，必须要有
    [self.collectionView registerClass:[ContactsCollectionViewCell class] forCellWithReuseIdentifier:@"ContactsCollectionViewCell"];
    [self.scrollView addSubview:self.collectionView];
    height+=60*WIDTH/375.0+62+15;
    
    UILabel *nowLabel = [UILabel createrLabelframe:CGRectMake(0, height, WIDTH, 45) backColor:nil textColor:HEX_COLOR(@"41464e") test:@"现在" font:32 number:1 nstextLocat:NSTextAlignmentCenter];
    [self.scrollView addSubview:nowLabel];
    height+=57;
    
    UILabel *introduceLabel = [UILabel createrLabelframe:CGRectMake(25, height, WIDTH-50, 40) backColor:nil textColor:HEX_COLOR(@"5c636d") test:@"只要分享集满好友的5个赞，就能获得一杯免费的人脉咖啡啦！" font:14 number:2 nstextLocat:NSTextAlignmentCenter];
    [self.scrollView addSubview:introduceLabel];
    height+=56;
    
    UIButton *inviteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    inviteBtn.frame = CGRectMake((WIDTH-250)/2, height, 250, 40);
    [inviteBtn setBackgroundImage:kImageWithName(@"btn_rm_off_red") forState:UIControlStateNormal];
    [inviteBtn setTitle:@"加入他们，开启我的人脉咖啡" forState:UIControlStateNormal];
    [inviteBtn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
    inviteBtn.titleLabel.font = FONT_SYSTEM_SIZE(17);
    [inviteBtn addTarget:self action:@selector(joinButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:inviteBtn];
    height+=56;
    
    UIButton *helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    helpBtn.frame = CGRectMake(62, height, WIDTH-124, 20);
    NSString *str = @"活动规则";
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str];
    [attr setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:FONT_SYSTEM_SIZE(14),NSFontAttributeName, KTextColor,NSForegroundColorAttributeName,@(1),NSUnderlineStyleAttributeName,nil] range:NSMakeRange(0, [str length])];
    [helpBtn setAttributedTitle:attr forState:UIControlStateNormal];
    [helpBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [helpBtn addTarget:self action:@selector(helpButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:helpBtn];
    height+=110;
    
    [self.scrollView setContentSize:CGSizeMake(WIDTH, height)];
    [self loadHttpData];
}

#pragma mark - method
- (void)joinButtonClicked:(id)sender{
    UIViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-2];
    if([vc isKindOfClass:[MyCofferViewController class]]){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [[AppDelegate shareInstance].tabBarController setSelectedIndex:1];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:NO];
        });
    }
}

- (void)helpButtonClicked:(id)sender{
    CoffeeHelpViewController *vc = [[CoffeeHelpViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 加载数据
- (void)reloadCollectionView{
    [self.collectionView reloadData];
    if(self.dataArray.count){
        self.timer = [NSTimer scheduledTimerWithTimeInterval:3.5 target:self selector:@selector(tiemrRunLoop) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
}

- (void)tiemrRunLoop{
    NSInteger allRow = self.dataArray.count/4+(self.dataArray.count%4?1:0);
    _currentSec++;
    [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentSize.height/allRow*(_currentSec%allRow)) animated:YES];
}

#pragma mark - 网络请求
- (void)loadHttpData{
    __weak typeof(self) weakSelf = self;
    [self requstType:RequestType_Get apiName:API_NAME_USER_WALL_COFFEE paramDict:nil hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            for(NSDictionary *dict in [CommonMethod paramArrayIsNull:responseObject[@"data"]]){
                UserModel *model = [[UserModel alloc] initWithDict:dict];
                [weakSelf.dataArray addObject:model];
            }
        }
        [weakSelf reloadCollectionView];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark -- UICollectionViewDataSource
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
    UINib *nib = [UINib nibWithNibName:@"ContactsCollectionViewCellIntroduce" bundle: [NSBundle mainBundle]];
    [collectionView registerNib:nib forCellWithReuseIdentifier:@"ContactsCollectionViewCellIntroduce"];
    ContactsCollectionViewCell *cell = [[ContactsCollectionViewCell alloc]init];
    cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"ContactsCollectionViewCellIntroduce"forIndexPath:indexPath];
    UserModel *model = self.dataArray[indexPath.row];
    [cell updateDisplayUserModelIntroduce:model];
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(60*WIDTH/375.0, 60*WIDTH/375.0+62);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, (WIDTH-60*WIDTH/375.0*4)/5, 0, (WIDTH-60*WIDTH/375.0*4)/5);
}

#pragma mark --UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.scrollView.contentOffset.y < 0) {
        self.scrollView.scrollEnabled = NO;
        [self.scrollView setContentOffset:CGPointMake(0, 0)];
    }else{
        self.scrollView.scrollEnabled = YES;
    }
}

@end
