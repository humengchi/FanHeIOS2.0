//
//  NewRecommendController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/24.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "NewRecommendController.h"
#import "NewRecommendCell.h"
#import <AddressBook/AddressBook.h>

@interface NewRecommendController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *selectedUserArray;

@end

@implementation NewRecommendController

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
    self.dataArray = [NSMutableArray array];
    self.selectedUserArray = [NSMutableArray array];
    
    UILabel *headerLabel = [UILabel createrLabelframe:CGRectMake(0, 81, WIDTH, 23) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464E") test:@"关注优质人脉 拓展靠谱业务" font:20 number:1 nstextLocat:NSTextAlignmentCenter];
    headerLabel.font = FONT_BOLD_SYSTEM_SIZE(20);
    [self.view addSubview:headerLabel];
    
    //确定是水平滚动，还是垂直滚动
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:
     UICollectionViewScrollDirectionVertical];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(8, 120, WIDTH-16, HEIGHT-120-60) collectionViewLayout:flowLayout];
    self.collectionView.dataSource=self;
    self.collectionView.delegate=self;
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    
    //注册Cell，必须要有
    [self.collectionView registerClass:[NewRecommendCell class] forCellWithReuseIdentifier:@"NewRecommendCell"];
    [self.view addSubview:self.collectionView];
    
    [self loadHttpData];
    
    //获取通讯录权限
    ABAddressBookRef addressBooks =  ABAddressBookCreateWithOptions(NULL, NULL);
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBooks, ^(bool granted, CFErrorRef error){
        //greanted为YES是表示用户允许，否则为不允许
        if (!granted) {
        }
        dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

#pragma mark - 网络请求
- (void)loadHttpData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[CommonMethod paramNumberIsNull:[DataModelInstance shareInstance].userModel.userId] forKey:@"userid"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_DYNAMIC_GET_GOODUSER paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            for(NSDictionary *dict in array){
                UserModel *model = [[UserModel alloc] initWithDict:dict];
                model.isSelected = YES;
                [weakSelf.dataArray addObject:model];
            }
            [weakSelf.collectionView reloadData];
        }else{
            [MBProgressHUD showError:@"请检查网络" toView:self.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"请检查网络" toView:self.view];
    }];
}

- (void)setAttentionUsersHttpData{
    if([DataModelInstance shareInstance].userModel == nil){
        [[AppDelegate shareInstance] updateWindowRootVC];
    }
    [self.selectedUserArray removeAllObjects];
    for(UserModel *model in self.dataArray){
        if(model.isSelected){
            [self.selectedUserArray addObject:model.userId];
        }
    }
    if(self.selectedUserArray.count==0){
        return;
    }
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"关注中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:[self.selectedUserArray componentsJoinedByString:@","] forKey:@"otherid"];
    [self requstType:RequestType_Post apiName:API_NAME_USER_SET_ATTENT_USER paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"关注成功" toView:weakSelf.view];
            [UIView animateWithDuration:0.3 animations:^{
                
            } completion:^(BOOL finished) {
                [[AppDelegate shareInstance] updateWindowRootVC];
            }];
        }else{
            [MBProgressHUD showError:@"关注失败，请重试" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"关注失败，请重试" toView:weakSelf.view];
    }];
}

#pragma mark - method
- (IBAction)gotoButtonClicked:(id)sender{
    [[AppDelegate shareInstance] updateWindowRootVC];
}

- (IBAction)attentionUserButtonClicked:(id)sender{
    [self newThreadForAvoidButtonRepeatClick:sender];
    [self setAttentionUsersHttpData];
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
    UINib *nib = [UINib nibWithNibName:@"NewRecommendCell" bundle: [NSBundle mainBundle]];
    [collectionView registerNib:nib forCellWithReuseIdentifier:@"NewRecommendCell"];
    NewRecommendCell *cell = [[NewRecommendCell alloc]init];
    // Set up the reuse identifier
    cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"NewRecommendCell"forIndexPath:indexPath];
    [cell updateDisplay:self.dataArray[indexPath.row]];
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = (int)((WIDTH-28)/3.0);
    return CGSizeMake(width, 143);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(6, 0, 6, 0);
}

//每个item的间隔
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 6;
}

#pragma mark --UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UserModel *model = self.dataArray[indexPath.row];
    model.isSelected = !model.isSelected;
    
    NewRecommendCell *cell = (NewRecommendCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [cell updateDisplay:model];
    
}



@end
