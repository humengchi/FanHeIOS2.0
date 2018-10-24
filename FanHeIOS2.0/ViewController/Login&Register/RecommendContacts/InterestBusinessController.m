//
//  InterestBusinessController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/22.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "InterestBusinessController.h"
#import "NewRecommendController.h"

@interface InterestBusinessController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UIButton *attentBtn;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSMutableArray *selectedArray;

@end

@implementation InterestBusinessController

// 作用：拦截手势触发
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.isShowBack){
        [self createCustomNavigationBar:@"设置"];
    }
    
    CGRect frame = CGRectMake(10, 110, WIDTH-20, HEIGHT-110-60);
    self.selectedArray = [NSMutableArray arrayWithArray:[DataModelInstance shareInstance].userModel.intersted_industrys];
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
    
    [self loadHttpData];
}

#pragma mark - method
- (IBAction)gotoHomeButtonClicked:(id)sender{
    [self newThreadForAvoidButtonRepeatClick:sender];
    NewRecommendController *vc = [CommonMethod getVCFromNib:[NewRecommendController class]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)attentButtonClicked:(id)sender{
    [self newThreadForAvoidButtonRepeatClick:sender];
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"关注中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:[self.selectedArray componentsJoinedByString:@","] forKey:@"industry"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_DYNAMIC_SAVE_INDUSTRY paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            UserModel *model = [DataModelInstance shareInstance].userModel;
            model.intersted_industrys = weakSelf.selectedArray;
            [DataModelInstance shareInstance].userModel = model;
            [MBProgressHUD showSuccess:@"关注成功" toView:weakSelf.view];
            if(weakSelf.saveInterestBusiness){
                weakSelf.saveInterestBusiness();
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if(weakSelf.isShowBack){
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }else{
                    NewRecommendController *vc = [CommonMethod getVCFromNib:[NewRecommendController class]];
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }
            });
        }else{
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - 标签网络请求
- (void)loadHttpData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [self requstType:RequestType_Get apiName:API_NAME_GET_DYNAMIC_INDUSTRY paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
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
        [self.selectedArray addObject:tagStr];
    }
    [self.collectionView reloadData];
    self.attentBtn.enabled = self.selectedArray.count>0;
}

@end
