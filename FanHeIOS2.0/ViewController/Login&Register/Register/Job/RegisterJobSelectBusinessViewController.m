//
//  RegisterJobSelectBusinessViewController.m
//  JinMai
//
//  Created by 胡梦驰 on 16/5/9.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "RegisterJobSelectBusinessViewController.h"

@interface RegisterJobSelectBusinessViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>{
    NSInteger _selectIndex;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation RegisterJobSelectBusinessViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //移除滑动手势
    for (UIPanGestureRecognizer *ges in self.view.gestureRecognizers){
        [self.view removeGestureRecognizer:ges];
    }
    _selectIndex = -1;
    self.dataArray = [NSMutableArray array];
    //确定是水平滚动，还是垂直滚动
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:
     UICollectionViewScrollDirectionVertical];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(15, 180, WIDTH-30, HEIGHT-180) collectionViewLayout:flowLayout];
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
      [self.searchBar resignFirstResponder];
    if(self.selectBusiness && _selectIndex != -1){
        self.selectBusiness(self.dataArray[_selectIndex]);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

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
    CGFloat strWidth = [NSHelper widthOfString:self.dataArray[indexPath.row] font:FONT_SYSTEM_SIZE(17) height:27];
    strWidth = (WIDTH-80)/3.0;//strWidth>(WIDTH-50)/3.0?strWidth:(WIDTH-50)/3.0;
    if(indexPath.row == _selectIndex){
        UILabel *label = [UILabel createrLabelframe:CGRectMake(0, 0, strWidth, 27) backColor:HEX_COLOR(@"E23608") textColor:WHITE_COLOR test:self.dataArray[indexPath.row] font:17 number:1 nstextLocat:NSTextAlignmentCenter];
        [CALayer updateControlLayer:label.layer radius:3 borderWidth:0 borderColor:WHITE_COLOR.CGColor];
        [cell.contentView addSubview:label];
    }else if(self.selectBusinessStr && [self.selectBusinessStr isEqualToString:self.dataArray[indexPath.row]]){
        UILabel *label = [UILabel createrLabelframe:CGRectMake(0, 0, strWidth, 27) backColor:HEX_COLOR(@"E23608") textColor:WHITE_COLOR test:self.dataArray[indexPath.row] font:17 number:1 nstextLocat:NSTextAlignmentCenter];
        [CALayer updateControlLayer:label.layer radius:3 borderWidth:0 borderColor:WHITE_COLOR.CGColor];
        [cell.contentView addSubview:label];
    }else{
        UILabel *label = [UILabel createrLabelframe:CGRectMake(0, 0, strWidth, 27) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464E") test:self.dataArray[indexPath.row] font:17 number:1 nstextLocat:NSTextAlignmentCenter];
        [CALayer updateControlLayer:label.layer radius:3 borderWidth:1 borderColor:HEX_COLOR(@"D9D9D9").CGColor];
        [cell.contentView addSubview:label];
    }
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat strWidth = [NSHelper widthOfString:self.dataArray[indexPath.row] font:FONT_SYSTEM_SIZE(17) height:27];
    strWidth = (WIDTH-80)/3.0;//strWidth>(WIDTH-50)/3.0?strWidth:(WIDTH-50)/3.0;
    return CGSizeMake(strWidth, 27);
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
    _selectIndex = indexPath.row;
    self.selectBusinessStr = @"";
    [self.collectionView reloadData];
    
    if(self.selectBusiness && _selectIndex != -1){
        self.selectBusiness(self.dataArray[_selectIndex]);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
