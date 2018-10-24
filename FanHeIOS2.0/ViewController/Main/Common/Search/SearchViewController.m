//
//  SearchViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/22.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "SearchFriendViewController.h"
#import "SearchViewController.h"
#import "SearchFriendListViewController.h"
#import "SearchFriendTableViewCell.h"
#import "SearchAvtivityAndFianaceController.h"
#import "BaseTabbarViewController.h"
#import "ActivityAndTopicOrFianaceCell.h"
#import "ActivityDetailController.h"
#import "TopicViewController.h"
#import "InformationDetailController.h"

@interface SearchViewController (){
    BOOL _noNetWork;
    BOOL _isRefresh;
}

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic, strong) NSMutableArray  *dataArray;

@property (nonatomic, strong) UITableView *showTableView;
@property (nonatomic, strong) NSMutableArray  *showArray;

@end

@implementation SearchViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray = [NSMutableArray array];
    self.showArray = [NSMutableArray array];
    
    [self initSearchBar];
    if (self.isFrist) {
        [self.searchBar becomeFirstResponder];
    }
    //初始展示列表
    self.showTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT-64) style:UITableViewStyleGrouped];
    self.showTableView.backgroundColor = kTableViewBgColor;
    self.showTableView.delegate = self;
    self.showTableView.dataSource = self;
    [self.view addSubview:self.showTableView];
    self.showTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.showTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.headerView.frame =  CGRectMake(0, 64, WIDTH, 115);
    self.showTableView.tableHeaderView = self.headerView;
    //搜索结果列表
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = kTableViewBgColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.hidden = YES;
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, WIDTH, 0.5)];
    lineLabel.backgroundColor = kCellLineColor;
    [self.view addSubview:lineLabel];
    if (self.searchTitle.length > 0) {
        self.searchBar.text = self.searchTitle;
        [self loadResultDataHttp:YES];
    }
    [self loadShowDataHttp];
}

- (void)initSearchBar{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, -64, WIDTH, 64)];
    view.backgroundColor = kDefaultColor;
    [self.view addSubview:view];
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 20, WIDTH-55, 44)];
    self.searchBar.showsCancelButton = NO;
    self.searchBar.returnKeyType = UIReturnKeySearch;
    self.searchBar.enablesReturnKeyAutomatically = YES;
    self.searchBar.delegate = self;
    self.searchBar.barTintColor = HEX_COLOR(@"818C9E");
    [self.searchBar setPlaceholder:@"搜索"];
    [self.searchBar setBackgroundColor:WHITE_COLOR];
    [self.searchBar setBackgroundImage:kImageWithColor(WHITE_COLOR, self.searchBar.bounds)];
    [self.searchBar setSearchFieldBackgroundImage:[kImageWithName(@"searchBackground") imageWithColor:HEX_COLOR(@"EFEFF4")] forState:UIControlStateNormal];
    [self.searchBar setSearchFieldBackgroundImage:[kImageWithName(@"searchBackground") imageWithColor:HEX_COLOR(@"EFEFF4")] forState:UIControlStateDisabled];
    [self.searchBar setSearchTextPositionAdjustment:UIOffsetMake(5, 0)];
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

#pragma mark - 按钮方法
//查看更多
- (void)gotoFriendListVCButtonClicked:(UIButton*)sender{
    NSString *textStr = [self.dataArray[sender.tag] allKeys][0];
    if([textStr isEqualToString:@"friend"]||[textStr isEqualToString:@"users"]){
        SearchFriendListViewController *vc = [[SearchFriendListViewController alloc] init];
        vc.searchStr = self.searchBar.text;
        vc.searchType = textStr;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        SearchAvtivityAndFianaceController *vc = [[SearchAvtivityAndFianaceController alloc] init];
        if([textStr isEqualToString:@"subjects"]){
            vc.type = SearchResult_Topic;
        }else if([textStr isEqualToString:@"posts"]){
            vc.type = SearchResult_Post;
        }else{
            vc.type = SearchResult_Activity;
        }
        vc.searchText = self.searchBar.text;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 网络请求数据
- (void)loadResultDataHttp:(BOOL)handRefresh{
    _noNetWork = NO;
    self.tableView.hidden = NO;
    _isRefresh = YES;
    [self.dataArray removeAllObjects];
    [self.tableView reloadData];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%@/%@/%@",[DataModelInstance shareInstance].userModel.userId,self.searchBar.text,@"all",@(1)] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_AJAX_SEARCH paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(weakSelf.dataArray.count){
            [weakSelf.dataArray removeAllObjects];
        }
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *tmpDict = [CommonMethod paramDictIsNull:responseObject[@"data"]];
            NSDictionary *dict1;
            NSDictionary *dict2;
            NSDictionary *dict3;
            NSDictionary *dict4;
            NSDictionary *dict5;
            NSInteger i = 0;
            for(NSArray *array in tmpDict.allValues){
                NSMutableArray *tmpArray = [NSMutableArray array];
                for(NSDictionary *dict in array){
                    SearchModel *model = [[SearchModel alloc] initWithDict:dict];
                    [tmpArray addObject:model];
                }
                if(tmpArray.count){
                    NSString *keyStr = tmpDict.allKeys[i];
                    if([keyStr isEqualToString:@"friend"]){
                        dict1 = @{keyStr:tmpArray};
                    }else if([keyStr isEqualToString:@"users"]){
                        dict2 = @{keyStr:tmpArray};
                    }else if([keyStr isEqualToString:@"subjects"]){
                        dict3 = @{keyStr:tmpArray};
                    }else if([keyStr isEqualToString:@"activitys"]){
                        dict4 = @{keyStr:tmpArray};
                    }else if([keyStr isEqualToString:@"posts"]){
                        dict5 = @{keyStr:tmpArray};
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
            if(dict3){
                [weakSelf.dataArray addObject:dict3];
            }
            if(dict4){
                [weakSelf.dataArray addObject:dict4];
            }
            if(dict5){
                [weakSelf.dataArray addObject:dict5];
            }
        }else{
            [weakSelf.dataArray removeAllObjects];
        }
        _isRefresh = NO;
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        _isRefresh = NO;
        _noNetWork = YES;
        [weakSelf.dataArray removeAllObjects];
        [weakSelf.tableView reloadData];
    }];
}

//热门推荐
- (void)loadShowDataHttp{
    _noNetWork = NO;
    __weak typeof(self) weakSelf = self;
    [self requstType:RequestType_Get apiName:API_NAME_GET_AJAX_HOT_SEARCH paramDict:nil hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSDictionary *tmpDict = [CommonMethod paramDictIsNull:responseObject[@"data"]];
            NSDictionary *dict1;
            NSDictionary *dict2;
            NSInteger i = 0;
            [weakSelf.showArray removeAllObjects];
            for(NSArray *array in tmpDict.allValues){
                NSMutableArray *tmpArray = [NSMutableArray array];
                for(NSDictionary *dict in array){
                    SearchModel *model = [[SearchModel alloc] initWithDict:dict];
                    [tmpArray addObject:model];
                }
                if(tmpArray.count){
                    NSString *keyStr = tmpDict.allKeys[i];
                    if([keyStr isEqualToString:@"hotsubject"]){
                        dict1 = @{keyStr:tmpArray};
                    }else if([keyStr isEqualToString:@"hotactivity"]){
                        dict2 = @{keyStr:tmpArray};
                    }
                }
                i++;
            }
            if(dict1){
                [weakSelf.showArray addObject:dict1];
            }
            if(dict2){
                [weakSelf.showArray addObject:dict2];
            }
        }
        [weakSelf.showTableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

#pragma mark - UITableViewDelegate/Data
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(tableView == self.tableView){
        if(self.dataArray.count){
            return self.dataArray.count;
        }else{
            return 1;
        }
    }else{
        return self.showArray.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == self.tableView){
        if(self.dataArray.count){
            NSArray *tmpArray = [self.dataArray[section] allValues][0];
            return tmpArray.count>3?3:tmpArray.count;
        }else{
            return 1;
        }
    }else{
        NSArray *tmpArray = [self.showArray[section] allValues][0];
        return tmpArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == self.tableView){
        if(_noNetWork){
            return 120;
        }else{
            if(self.dataArray.count){
                SearchModel *model = [self.dataArray[indexPath.section] allValues][0][indexPath.row];
                NSString *textStr = [self.dataArray[indexPath.section] allKeys][0];                if([textStr isEqualToString:@"friend"]||[textStr isEqualToString:@"users"]){
                    return 85;
                }else{
                    RSearchResult type;
                    if([textStr isEqualToString:@"subjects"]){
                        type = SearchResult_Topic;
                    }else if([textStr isEqualToString:@"posts"]){
                        type = SearchResult_Post;
                    }else{
                        type = SearchResult_Activity;
                    }
                    return [ActivityAndTopicOrFianaceCell backActivityAndTopicOrFianaceCellHeigth:model searchType:type];
                }
            }else{
                return 85;
            }
        }
    }else{
        SearchModel *model = [self.showArray[indexPath.section] allValues][0][indexPath.row];
        NSString *textStr = [self.showArray[indexPath.section] allKeys][0];
        if([textStr isEqualToString:@"hotsubject"]){
            return 74;
        }else{
            NSString *titleStr = model.name;
            CGFloat titleHeight = (int)[NSHelper heightOfString:titleStr font:FONT_SYSTEM_SIZE(17) width:WIDTH-32 defaultHeight:20];
            if(titleHeight>FONT_SYSTEM_SIZE(17).lineHeight*2){
                titleHeight = FONT_SYSTEM_SIZE(17).lineHeight*2+6;
            }else if(titleHeight>FONT_SYSTEM_SIZE(17).lineHeight){
                titleHeight += 6;
            }
            return 80+titleHeight;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(tableView == self.tableView){
        if(self.dataArray.count){
            return 32;
        }else{
            return 0.00001;
        }
    }else{
        return 43;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(tableView == self.tableView){
        if(self.dataArray.count){
            NSString *textStr = [self.dataArray[section] allKeys][0];
            if([textStr isEqualToString:@"friend"]){
                textStr = @"好友";
            }else if([textStr isEqualToString:@"users"]){
                textStr = @"人脉";
            }else if([textStr isEqualToString:@"subjects"]){
                textStr = @"话题";
            }else if([textStr isEqualToString:@"activitys"]){
                textStr = @"活动";
            }else if([textStr isEqualToString:@"posts"]){
                textStr = @"文章";
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
    }else{
        NSString *textStr = [self.showArray[section] allKeys][0];
        if([textStr isEqualToString:@"hotsubject"]){
            textStr = @"大家都在聊";
        }else{
            textStr = @"热门活动";
        }
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 43)];
        headerView.backgroundColor = WHITE_COLOR;
        UILabel *textLabel = [UILabel createrLabelframe:CGRectMake(16, 5, WIDTH-16, 38) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818C9E") test:textStr font:14 number:1 nstextLocat:NSTextAlignmentLeft];
        [headerView addSubview:textLabel];
        
        UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 42.5, WIDTH, 0.5)];
        lineLabel1.backgroundColor = kCellLineColor;
        [headerView addSubview:lineLabel1];
        
        UILabel *lineLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 5)];
        lineLabel2.backgroundColor = kTableViewBgColor;
        [headerView addSubview:lineLabel2];
        return headerView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(tableView == self.tableView){
        if(self.dataArray.count){
            NSArray *tmpArray = [self.dataArray[section] allValues][0];
            return tmpArray.count>=3?40:0.00001;
        }else{
            return 0.00001;
        }
    }else{
        return 0.00001;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if(tableView == self.tableView){
        if(self.dataArray.count && [(NSArray*)([self.dataArray[section] allValues][0]) count]>=3){
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 40)];
            footerView.backgroundColor = WHITE_COLOR;
            UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            moreBtn.frame = CGRectMake(0, 0, WIDTH, 40);
            
            NSString *textStr = [self.dataArray[section] allKeys][0];
            if([textStr isEqualToString:@"friend"]){
                [moreBtn setTitle:@"更多好友" forState:UIControlStateNormal];
            }else if([textStr isEqualToString:@"users"]){
                [moreBtn setTitle:@"更多人脉" forState:UIControlStateNormal];
            }else if([textStr isEqualToString:@"subjects"]){
                [moreBtn setTitle:@"更多话题" forState:UIControlStateNormal];
            }else if([textStr isEqualToString:@"posts"]){
                [moreBtn setTitle:@"更多文章" forState:UIControlStateNormal];
            }else{
                [moreBtn setTitle:@"更多活动" forState:UIControlStateNormal];
            }
            [moreBtn setTitleColor:HEX_COLOR(@"818C9E") forState:UIControlStateNormal];
            [moreBtn setImage:kImageWithName(@"icon_next_double_gray") forState:UIControlStateNormal];
            moreBtn.tag = section;
            moreBtn.titleLabel.font = FONT_SYSTEM_SIZE(14);
            moreBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 130, 0, 0);
            moreBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
            [moreBtn addTarget:self action:@selector(gotoFriendListVCButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [footerView addSubview:moreBtn];
            
            UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 39.5, WIDTH, 0.5)];
            lineLabel1.backgroundColor = kCellLineColor;
            [footerView addSubview:lineLabel1];
            return footerView;
        }else{
            return nil;
        }
    }else{
        return nil;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == self.tableView){
        if(self.dataArray.count){
            SearchModel *model = [self.dataArray[indexPath.section] allValues][0][indexPath.row];
            NSString *textStr = [self.dataArray[indexPath.section] allKeys][0];
            if([textStr isEqualToString:@"friend"]||[textStr isEqualToString:@"users"]){
                static NSString *identify = @"SearchFriendTableViewCell";
                SearchFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
                if(!cell){
                    cell = [CommonMethod getViewFromNib:@"SearchFriendTableViewCell"];
                }
                if([textStr isEqualToString:@"users"]){
                    [cell updateDisplaySearch:model showAddBtn:YES searchText:self.searchBar.text];
                }else{
                    [cell updateDisplaySearch:model showAddBtn:NO searchText:self.searchBar.text];
                }
                return cell;
            }else{
                static NSString *identify = @"ActivityAndTopicOrFianaceCell";
                ActivityAndTopicOrFianaceCell *cell =[tableView dequeueReusableCellWithIdentifier:identify];
                if(!cell){
                    cell = [CommonMethod getViewFromNib:@"ActivityAndTopicOrFianaceCell"];
                }
                RSearchResult type;
                if([textStr isEqualToString:@"subjects"]){
                    type = SearchResult_Topic;
                }else if([textStr isEqualToString:@"posts"]){
                    type = SearchResult_Post;
                }else{
                    type = SearchResult_Activity;
                }
                [cell tranferActivityAndTopicOrFianaceCellModel:model searchText:self.searchBar.text searchType:type];
                return cell;
            }
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
    }else{
        static NSString *identify = @"UITableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        SearchModel *model = [self.showArray[indexPath.section] allValues][0][indexPath.row];
        NSString *textStr = [self.showArray[indexPath.section] allKeys][0];
        NSString *titleStr = model.name;
        NSString *contentStr;
        CGFloat titleHeight = 20;
        CGFloat font = 12;
        if([textStr isEqualToString:@"hotsubject"]){
            contentStr = [NSString stringWithFormat:@"关注 %@  观点 %@  评论 %@", model.attentcount, model.replycount, model.reviewcount];
        }else{
            font = 14;
            contentStr = model.timestr;
            titleHeight = (int)[NSHelper heightOfString:titleStr font:FONT_SYSTEM_SIZE(17) width:WIDTH-32 defaultHeight:20];
            if(titleHeight>FONT_SYSTEM_SIZE(17).lineHeight*2){
                titleHeight = FONT_SYSTEM_SIZE(17).lineHeight*2+6;
            }else if(titleHeight>FONT_SYSTEM_SIZE(17).lineHeight){
                titleHeight += 6;
            }
        }
        UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(16, 14, WIDTH-32, titleHeight) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:titleStr font:17 number:2 nstextLocat:NSTextAlignmentLeft];
        [cell.contentView addSubview:titleLabel];
        
        UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(16, titleLabel.frame.size.height+24, WIDTH-32, FONT_SYSTEM_SIZE(font).lineHeight) backColor:WHITE_COLOR textColor:HEX_COLOR(@"AFB6C1") test:contentStr font:font number:1 nstextLocat:NSTextAlignmentLeft];
        [cell.contentView addSubview:contentLabel];
        
        titleHeight = contentLabel.frame.size.height+contentLabel.frame.origin.y+16;
        
        if([textStr isEqualToString:@"hotactivity"]){
            if((titleHeight-(contentLabel.frame.size.height+contentLabel.frame.origin.y+16))>FONT_SYSTEM_SIZE(17).lineHeight){
                [titleLabel setParagraphText:titleStr lineSpace:6];
            }
            NSString *locationStr = [NSString stringWithFormat:@"%@%@",model.cityname, model.districtname];
            CGFloat locationWidth = [NSHelper widthOfString:locationStr font:FONT_SYSTEM_SIZE(14) height:17];
            if(locationWidth>WIDTH-142 && 1){
                locationWidth = WIDTH-142;
            }else if(locationWidth>WIDTH-32){
                locationWidth = WIDTH-32;
            }
            UILabel *locationLabel = [UILabel createrLabelframe:CGRectMake(16, contentLabel.frame.size.height+contentLabel.frame.origin.y+10, locationWidth, 17) backColor:WHITE_COLOR textColor:HEX_COLOR(@"AFB6C1") test:locationStr font:14 number:1 nstextLocat:NSTextAlignmentLeft];
            [cell.contentView addSubview:locationLabel];
            
          
            CGFloat wideth = locationLabel.frame.origin.x + locationLabel.frame.size.width + 16;
            
            CGFloat wideth1 = [NSHelper widthOfString:model.guestname font:[UIFont systemFontOfSize:14] height:14] + 8;
            
            CGFloat wideth2 = [NSHelper widthOfString:model.price font:[UIFont systemFontOfSize:17] height:17];
            if(model.guestname.length > 0){
            
                if (wideth1 >  (WIDTH - wideth2 - wideth - 16 - 16)) {
                    wideth1 = WIDTH - wideth - wideth2  - 16 - 16;
                }
                NSInteger guestnameLabelWideth = wideth1;
                UILabel *guestnameLabel = [[UILabel alloc]init];
                guestnameLabel.frame =CGRectMake(wideth + 8, locationLabel.frame.origin.y - 2, guestnameLabelWideth, 20);
                guestnameLabel.textColor = HEX_COLOR(@"B0A175");
                guestnameLabel.backgroundColor = HEX_COLOR(@"FAF5E0");
                guestnameLabel.layer.masksToBounds = YES;
                guestnameLabel.layer.cornerRadius = 5;
               guestnameLabel.font = [UIFont systemFontOfSize:14];
                if (model.guestname.length > 0) {
                    guestnameLabel.text = [NSString stringWithFormat:@" %@ ",model.guestname];
                }else{
                    guestnameLabel.hidden = YES;
                }

                
                [cell.contentView addSubview:guestnameLabel];
            }
            if(model.price.length > 0){
                UILabel *tagLabel = [UILabel createrLabelframe:CGRectMake(WIDTH - wideth2 - 16, locationLabel.frame.origin.y-2, wideth2, 17) backColor:HEX_COLOR(@"FFFFFF") textColor:[UIColor colorWithHexString:@"000000"] test:model.price font:17 number:1 nstextLocat:NSTextAlignmentCenter];
                if ([model.price isEqualToString:@"免费"]) {
                    tagLabel.textColor = [UIColor colorWithHexString:@"1ABC9C"];
                }else if ([model.price isEqualToString:@"已结束"]) {
                    tagLabel.textColor = [UIColor colorWithHexString:@"AFB6C1"];
                }else{
                    tagLabel.textColor = [UIColor colorWithHexString:@"F76B1C"];
                }
              
                [cell.contentView addSubview:tagLabel];
            }

            titleHeight += 24;
        }
        if(indexPath.row != [(NSMutableArray*)[self.showArray[indexPath.section] allValues][0] count]-1){
            UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, titleHeight-0.5, WIDTH-32, 0.5)];
            lineLabel.backgroundColor = kCellLineColor;
            [cell.contentView addSubview:lineLabel];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(tableView == self.tableView){
        if(_noNetWork){
            [self loadResultDataHttp:YES];
        }else if(self.dataArray.count){
            [self.view endEditing:YES];
            SearchModel *model = [self.dataArray[indexPath.section] allValues][0][indexPath.row];
            NSString *textStr = [self.dataArray[indexPath.section] allKeys][0];
            if([textStr isEqualToString:@"friend"]||[textStr isEqualToString:@"users"]){
                NewMyHomePageController *myhome = [[NewMyHomePageController alloc]init];
                myhome.userId = model.rid;
                [self.navigationController pushViewController:myhome animated:YES];
            }else{
                if([textStr isEqualToString:@"subjects"]){
                    TopicViewController *vc = [[TopicViewController alloc] init];
                    vc.subjectId = model.rid;
                    [self.navigationController pushViewController:vc animated:YES];
                }else if([textStr isEqualToString:@"posts"]){
                    InformationDetailController *vc = [[InformationDetailController alloc] init];
                    vc.postID = model.rid;
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
                    ActivityDetailController *vc = [[ActivityDetailController alloc] init];
                    vc.activityid = model.rid;
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
        }
    }else{
        SearchModel *model = [self.showArray[indexPath.section] allValues][0][indexPath.row];
        NSString *textStr = [self.showArray[indexPath.section] allKeys][0];
        if([textStr isEqualToString:@"hotsubject"]){
            TopicViewController *vc = [[TopicViewController alloc] init];
            vc.subjectId = model.rid;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            ActivityDetailController *vc = [[ActivityDetailController alloc] init];
            vc.activityid = model.rid;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}


#pragma mark -- SearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(searchText.length){
        [self loadResultDataHttp:NO];
    }else{
        self.tableView.hidden = YES;
        [self.dataArray removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ------ 人脉搜索
- (IBAction)gotoHisMainPage:(UITapGestureRecognizer *)sender {
    SearchFriendViewController *vc = [CommonMethod getVCFromNib:[SearchFriendViewController class]];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark ----- 话题搜索
- (IBAction)gotoTalkFianance:(UITapGestureRecognizer *)sender {
    SearchAvtivityAndFianaceController *vc = [CommonMethod getVCFromNib:[SearchAvtivityAndFianaceController class]];
    vc.type = SearchResult_Topic;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark ----- 活动搜索
- (IBAction)gotoActivity:(UITapGestureRecognizer *)sender {
    SearchAvtivityAndFianaceController *vc = [CommonMethod getVCFromNib:[SearchAvtivityAndFianaceController class]];
    vc.type = SearchResult_Activity;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

@end
