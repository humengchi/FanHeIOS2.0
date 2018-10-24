//
//  SearchFriendViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/22.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "SearchFriendViewController.h"
#import "SearchViewController.h"
#import "SearchFriendListViewController.h"
#import "SearchFriendTableViewCell.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import "BaseTabbarViewController.h"

@interface SearchFriendViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>{
    BOOL _noNetWork;
    BOOL _isRefresh;
}

@property (nonatomic, strong) UICollectionView     *collectionView;

@property (nonatomic, strong) NSMutableArray    *dataArray;

@property (nonatomic, strong) NSMutableArray        *tagsArray;

@end

@implementation SearchFriendViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray = [NSMutableArray array];
    self.tagsArray = [NSMutableArray array];
    
    [self initSearchBar];
    [self.searchBar becomeFirstResponder];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = kTableViewBgColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.0001)];
    
    [self initCollectionView];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, WIDTH, 0.5)];
    lineLabel.backgroundColor = kCellLineColor;
    [self.view addSubview:lineLabel];
}

- (void)navBackButtonClicked:(UIButton*)btn{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initSearchBar{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -64, WIDTH, 64)];
    view.backgroundColor = kDefaultColor;
    [self.view addSubview:view];
    
    if(!self.isHideNavBack){
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 20, 44, 44);
        [backBtn setImage:kImageWithName(@"btn_tab_back") forState:UIControlStateNormal];
        [backBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [backBtn addTarget:self action:@selector(navBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:backBtn];
        
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(44, 20, WIDTH-44-55, 44)];
    }else{
        self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 20, WIDTH-55, 44)];
    }
    self.searchBar.showsCancelButton = NO;
    self.searchBar.returnKeyType = UIReturnKeySearch;
    self.searchBar.enablesReturnKeyAutomatically = YES;
    self.searchBar.delegate = self;
    self.searchBar.barTintColor = HEX_COLOR(@"818C9E");
    [self.searchBar setPlaceholder:@"搜索人脉"];
    [self.searchBar setImage:[UIImage imageNamed:@"icon_search_people"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.searchBar setSearchTextPositionAdjustment:UIOffsetMake(5, 0)];
    [self.searchBar setBackgroundColor:WHITE_COLOR];
    [self.searchBar setBackgroundImage:kImageWithColor(WHITE_COLOR, self.searchBar.bounds)];
    [self.searchBar setSearchFieldBackgroundImage:[kImageWithName(@"searchBackground") imageWithColor:HEX_COLOR(@"EFEFF4")] forState:UIControlStateNormal];
    [self.searchBar setSearchFieldBackgroundImage:[kImageWithName(@"searchBackground") imageWithColor:HEX_COLOR(@"EFEFF4")] forState:UIControlStateDisabled];
    [self.view addSubview:self.searchBar];
    
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancleBtn.frame = CGRectMake(WIDTH-60, 20, 60, 44);
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:HEX_COLOR(@"e24943") forState:UIControlStateNormal];
    [cancleBtn addTarget:self action:@selector(backRootVC) forControlEvents:UIControlEventTouchUpInside];
    cancleBtn.titleLabel.font = FONT_SYSTEM_SIZE(16);
    [self.view addSubview:cancleBtn];
}

- (void)backRootVC{
    NSMutableArray *vcArray = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    for(int i=self.navigationController.viewControllers.count-1; i>0;i--){
        id vc = self.navigationController.viewControllers[i];
        if([vc isKindOfClass:[SearchViewController class]]||[vc isKindOfClass:[SearchFriendViewController class]]||[vc isKindOfClass:[SearchFriendListViewController class]]){
            [vcArray removeObjectAtIndex:i];
        }else{
            break;
        }
    }
    if([vcArray.lastObject isKindOfClass:[BaseTabbarViewController class]]){
        [self.navigationController setViewControllers:vcArray animated:NO];
    }else{
        [self.navigationController setViewControllers:vcArray animated:YES];
    }
}

- (void)initCollectionView{
    //确定是水平滚动，还是垂直滚动
    UICollectionViewLeftAlignedLayout *flowLayout=[[UICollectionViewLeftAlignedLayout alloc] init];
    [flowLayout setScrollDirection:
     UICollectionViewScrollDirectionVertical];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT-64) collectionViewLayout:flowLayout];
    self.collectionView.dataSource=self;
    self.collectionView.delegate=self;
    [self.collectionView setBackgroundColor:kTableViewBgColor];
    
    //注册Cell，必须要有
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"myHeaderView"];
    [self.view addSubview:self.collectionView];
    
    [self loadHotTagsData];
}

#pragma mark - 网络请求标签
- (void)loadHotTagsData{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:@"/user" forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_AJAX_GET_HOT_SEARCH paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *tmpDict = [CommonMethod paramDictIsNull:responseObject[@"data"]];
            NSDictionary *dict1;
            NSDictionary *dict2;
            NSInteger i = 0;
            for(NSArray *array in tmpDict.allValues){
                if(array.count){
                    NSString *keyStr = tmpDict.allKeys[i];
                    if([keyStr isEqualToString:@"business"]){
                        dict2 = @{keyStr:array};
                    }else if([keyStr isEqualToString:@"position"]){
                        dict1 = @{keyStr:array};
                    }
                }
                i++;
            }
            if(dict1){
                [weakSelf.tagsArray addObject:dict1];
            }
            if(dict2){
                [weakSelf.tagsArray addObject:dict2];
            }
        }
        [weakSelf.collectionView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark - 选择标签
- (void)gotoFriendListVCButtonClicked:(UIButton*)sender{
    SearchFriendListViewController *vc = [[SearchFriendListViewController alloc] init];
    vc.searchStr = self.searchBar.text;
    vc.searchType = [self.dataArray[sender.tag] allKeys][0];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 网络请求数据
- (void)loadResultDataHttp:(BOOL)handRefresh{
    _noNetWork = NO;
    _isRefresh = YES;
    [self.dataArray removeAllObjects];
    [self.tableView reloadData];
    self.collectionView.hidden = YES;
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%@/%@",[DataModelInstance shareInstance].userModel.userId,self.searchBar.text,@"connection",@(1)] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_AJAX_SEARCH paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *tmpDict = [CommonMethod paramDictIsNull:responseObject[@"data"]];
            NSDictionary *dict1;
            NSDictionary *dict2;
            NSInteger i = 0;
            for(NSArray *array in tmpDict.allValues){
                NSMutableArray *tmpArray = [NSMutableArray array];
                for(NSDictionary *dict in array){
                    SearchModel *model = [[SearchModel alloc] initWithDict:dict];
                    [tmpArray addObject:model];
                }
                if(tmpArray.count){
                    NSString *keyStr = tmpDict.allKeys[i];
                    if([keyStr isEqualToString:@"users"]){
                        dict2 = @{keyStr:tmpArray};
                    }else{
                        dict1 = @{keyStr:tmpArray};
                    }
                }
                i++;
            }
            if(dict1){
                [weakSelf.dataArray addObject:dict1];
            }
            if(dict2){
                [weakSelf.dataArray addObject:dict2];
            }
        }
        _isRefresh = NO;
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        _isRefresh = NO;
        _noNetWork = YES;
        [weakSelf.tableView reloadData];
        if(handRefresh){
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }
    }];
}

#pragma mark - UITableViewDelegate/Data
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.dataArray.count){
        return self.dataArray.count;
    }else if(self.searchBar.text.length==0){
        return 0;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.dataArray.count){
        NSArray *tmpArray = [self.dataArray[section] allValues][0];
        return tmpArray.count>3?3:tmpArray.count;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count){
        return 85;
    }else{
        return 120;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.dataArray.count){
        return 32;
    }else{
        return 0.00001;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(self.dataArray.count){
        NSString *textStr = [self.dataArray[section] allKeys][0];
        if([textStr isEqualToString:@"friend"]){
            textStr = @"好友";
        }else{
            textStr = @"人脉";
        }
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 32)];
        headerView.backgroundColor = kTableViewBgColor;
        UILabel *textLabel = [UILabel createrLabelframe:CGRectMake(16, 0, WIDTH-16, 32) backColor:kTableViewBgColor textColor:HEX_COLOR(@"818C9E") test:textStr font:14 number:1 nstextLocat:NSTextAlignmentLeft];
        [headerView addSubview:textLabel];
        
        UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 31.5, WIDTH, 0.5)];
        lineLabel1.backgroundColor = kCellLineColor;
        [headerView addSubview:lineLabel1];
        return headerView;
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(self.dataArray.count){
        NSArray *tmpArray = [self.dataArray[section] allValues][0];
        return tmpArray.count>=3?40:0.00001;
    }else{
        return 0.00001;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if(self.dataArray.count && [(NSArray*)([self.dataArray[section] allValues][0]) count]>=3){
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 40)];
        footerView.backgroundColor = WHITE_COLOR;
        UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        moreBtn.frame = CGRectMake(0, 0, WIDTH, 40);
        NSString *textStr = [self.dataArray[section] allKeys][0];
        if([textStr isEqualToString:@"users"]){
            [moreBtn setTitle:@"更多人脉" forState:UIControlStateNormal];
        }else{
            [moreBtn setTitle:@"更多好友" forState:UIControlStateNormal];
        }
        [moreBtn setTitleColor:HEX_COLOR(@"818C9E") forState:UIControlStateNormal];
        [moreBtn setImage:kImageWithName(@"icon_next_double_gray") forState:UIControlStateNormal];
        moreBtn.titleLabel.font = FONT_SYSTEM_SIZE(14);
        moreBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 130, 0, 0);
        moreBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
        moreBtn.tag = section;
        [moreBtn addTarget:self action:@selector(gotoFriendListVCButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:moreBtn];
        
        UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 39.5, WIDTH, 0.5)];
        lineLabel1.backgroundColor = kCellLineColor;
        [footerView addSubview:lineLabel1];
        return footerView;
    }else{
        return nil;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count){
        static NSString *identify = @"SearchFriendTableViewCell";
        SearchFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"SearchFriendTableViewCell"];
        }
        SearchModel *model = [self.dataArray[indexPath.section] allValues][0][indexPath.row];
        NSString *textStr = [self.dataArray[indexPath.section] allKeys][0];
        if([textStr isEqualToString:@"users"]){
            [cell updateDisplaySearch:model showAddBtn:YES searchText:self.searchBar.text];
        }else{
            [cell updateDisplaySearch:model showAddBtn:NO searchText:self.searchBar.text];
        }
        return cell;
    }else{
        static NSString *identify = @"UITableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        NSString *errorStr = @"";
        if(_noNetWork){
            errorStr = @"无法链接到网络，点击屏幕重试";
        }else if(_isRefresh){
            errorStr = @"正在加载中...";
        }else{
            errorStr = @"没有找到相关搜索";
        }
        UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake((WIDTH-250)/2, 28, 250, 19) backColor:kTableViewBgColor textColor:HEX_COLOR(@"AFB6C1") test:errorStr font:17 number:1 nstextLocat:NSTextAlignmentCenter];
        [cell.contentView addSubview:contentLabel];
        cell.backgroundColor = kTableViewBgColor;
        
        if(_isRefresh){
            CGFloat width = [NSHelper widthOfString:errorStr font:FONT_SYSTEM_SIZE(17) height:19];
            UIImageView *hudImageView = [[UIImageView alloc] initWithFrame:CGRectMake((WIDTH-width)/2-35, 27, 31, 21)];
            [hudImageView setAnimationImages:@[kImageWithName(@"loading_toutiao_p1"), kImageWithName(@"loading_toutiao_p2"), kImageWithName(@"loading_toutiao_p3")]];
            [hudImageView setAnimationDuration:1.f];
            [hudImageView setAnimationRepeatCount:0];
            [hudImageView startAnimating];
            [cell.contentView addSubview:hudImageView];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_noNetWork){
        [self loadResultDataHttp:YES];
    }else if(self.dataArray.count){
        [self.view endEditing:YES];
        ContactsModel *model = [self.dataArray[indexPath.section] allValues][0][indexPath.row];
        NewMyHomePageController *myhome = [[NewMyHomePageController alloc]init];
        myhome.userId = model.rid;
        [self.navigationController pushViewController:myhome animated:YES];
    }
}

#pragma mark -- UICollectionViewDataSource
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(WIDTH,35);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"myHeaderView" forIndexPath:indexPath];
    for(UIView *view in headView.subviews){
        [view removeFromSuperview];
    }
    NSString *keyStr = [self.tagsArray[indexPath.section] allKeys][0];
    NSString *text;
    if([keyStr isEqualToString:@"position"]){
        text = @"热搜职位";
    }else{
        text = @"擅长业务";
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, WIDTH-50, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [headView addSubview:lineLabel];
    }
    UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(25, 20, WIDTH-25, 15) backColor:kTableViewBgColor textColor:HEX_COLOR(@"818C9E") test:text font:14 number:1 nstextLocat:NSTextAlignmentLeft];
    [headView addSubview:titleLabel];
    return headView;
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSArray *tmpArray = [self.tagsArray[section] allValues][0];
    return tmpArray.count;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.tagsArray.count;
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
    NSString *text;
    UIColor *backColor;
    UIColor *textColor;
    UIColor *borderColor;
    NSString *tagstr = [self.tagsArray[indexPath.section] allValues][0][indexPath.row];
    NSString *keyStr = [self.tagsArray[indexPath.section] allKeys][0];
    if([keyStr isEqualToString:@"position"]){
        text = tagstr;
        backColor = WHITE_COLOR;
        textColor = HEX_COLOR(@"41464E");
        borderColor = HEX_COLOR(@"AFB6C1");
    }else{
        text = [NSString stringWithFormat:@"#%@#",tagstr];
        backColor = kTableViewBgColor;
        textColor = HEX_COLOR(@"1abc9c");
        borderColor = HEX_COLOR(@"1abc9c");
    }
    CGFloat strWidth = [NSHelper widthOfString:text font:FONT_SYSTEM_SIZE(13) height:29]+16;
    UILabel *label = [UILabel createrLabelframe:CGRectMake(0, 0, strWidth, 29) backColor:backColor textColor:textColor test:text font:13 number:1 nstextLocat:NSTextAlignmentCenter];
    [CALayer updateControlLayer:label.layer radius:2 borderWidth:0.5 borderColor:borderColor.CGColor];
    [cell.contentView addSubview:label];
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *tagstr = [self.tagsArray[indexPath.section] allValues][0][indexPath.row];
    NSString *keyStr = [self.tagsArray[indexPath.section] allKeys][0];
    NSString *text;
    if([keyStr isEqualToString:@"position"]){
        text = tagstr;
    }else{
        text = [NSString stringWithFormat:@"#%@#",tagstr];
    }
    CGFloat strWidth = [NSHelper widthOfString:text font:FONT_SYSTEM_SIZE(13) height:29]+12;
    return CGSizeMake(strWidth, 30);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(16, 25, 16, 25);
}

#pragma mark --UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *tagstr = [self.tagsArray[indexPath.section] allValues][0][indexPath.row];
    self.searchBar.text = tagstr;
    self.collectionView.hidden = YES;
    [self loadResultDataHttp:NO];
}

#pragma mark -- SearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(searchText.length){
        [self loadResultDataHttp:NO];
    }else{
        self.collectionView.hidden = NO;
        [self.dataArray removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

@end
