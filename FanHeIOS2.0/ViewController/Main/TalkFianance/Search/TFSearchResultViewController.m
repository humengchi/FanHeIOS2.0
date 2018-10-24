//
//  TFSearchResultViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/20.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "TFSearchResultViewController.h"
#import "NODataTableViewCell.h"
#import "TopicViewController.h"
#import "InformationDetailController.h"

@interface TFSearchResultViewController (){
    NSInteger _currentPage;
}

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation TFSearchResultViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.type == TFSearchResult_Topic) {
         [self createCustomNavigationBar:[NSString stringWithFormat:@"#%@#相关话题",self.tagStr]];
    }else if(self.type == TFSearchResult_Activity){
        [self createCustomNavigationBar:[NSString stringWithFormat:@"#%@#相关活动",self.tagStr]];
    }else if(self.type == TFSearchResult_Report){
        [self createCustomNavigationBar:[NSString stringWithFormat:@"#%@#相关报道",self.tagStr]];
    }else{
        [self createCustomNavigationBar:[NSString stringWithFormat:@"#%@#相关资讯",self.tagStr]];
    }
   
    _currentPage = 1;
    
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    [self loadSearchResultHttpData];
    
    [self.tableView tableViewAddUpLoadRefreshing:^{
        [self loadSearchResultHttpData];
    }];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 网络请求
- (void)loadSearchResultHttpData{
    NSString *api;
    if(self.type == TFSearchResult_Topic){
        api = API_NAME_POST_SEARCH_SUBJECT_TAG;
    }else{
        api = API_NAME_POST_SEARCH_POST_TAG;
    }
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    
    
    if(self.type == TFSearchResult_Report){
         [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld/activityreport",self.tagStr, (long)_currentPage] forKey:@"param"];
    }else{
        [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld",self.tagStr, (long)_currentPage] forKey:@"param"];
    }
    [self requstType:RequestType_Get apiName:api paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(weakSelf.dataArray==nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            for(NSDictionary *dict in array){
                TopicModel *model = [[TopicModel alloc] initWithDict:dict];
                [weakSelf.dataArray addObject:model];
            }
            if(array.count==20){
                [weakSelf.tableView endRefresh];
            }else{
                [weakSelf.tableView endRefreshNoData];
            }
            _currentPage++;
            [weakSelf.tableView reloadData];
        }else{
            [MBProgressHUD showError:@"数据获取失败请重试" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [weakSelf.tableView endRefresh];
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"无法连接到网络" toView:weakSelf.view];
        if(weakSelf.dataArray==nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark -- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.dataArray==nil){
        return 0;
    }else if(self.dataArray.count == 0){
        return 1;
    }else{
        return self.dataArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count == 0){
        return 1;
    }else{
        TopicModel *model = self.dataArray[indexPath.row];
        return model.cellHeight;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count == 0){
        static NSString *identify = @"NODataTableViewCell";
        NODataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NODataTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.mainLabel.text = @"暂无相关搜索结果";
        cell.subLabel.text = @"";
        return cell;
    }else{
        static NSString *identify = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        TopicModel *model = self.dataArray[indexPath.row];
        CGFloat viewHeight = 16;
        NSMutableArray *tagsArray = [NSMutableArray arrayWithArray:[CommonMethod paramArrayIsNull:model.tagname]];
        if([tagsArray containsObject:self.tagStr]){
            [tagsArray removeObject:self.tagStr];
            [tagsArray insertObject:self.tagStr atIndex:0];
        }
        if(tagsArray.count){
            UIView *tagView = [[UIView alloc] initWithFrame:CGRectMake(16, viewHeight, WIDTH-32, 30)];
            CGFloat start_X = 0;
            CGFloat start_Y = 0;
            for (int i=0; i < tagsArray.count; i++) {
                UIButton *tagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [tagBtn setTitle:tagsArray[i] forState:UIControlStateNormal];
                tagBtn.titleLabel.font = FONT_SYSTEM_SIZE(12);
                CGFloat strWidth = [NSHelper widthOfString:tagsArray[i] font:FONT_SYSTEM_SIZE(12) height:20]+16;
                if(start_X+strWidth>WIDTH-32){
                    if(strWidth>WIDTH-32){
                        strWidth = WIDTH-32;
                    }
                    break;
                    start_X = 0;
                    start_Y += 26;
                }
                tagBtn.frame = CGRectMake(start_X, start_Y, strWidth, 21);
                tagBtn.tag = i;
                NSString *color;
                if([tagsArray[i] isEqualToString:self.tagStr]){
                    color = @"e24943";
                }else{
                    color = @"1ABC9C";
                }
                [tagBtn setTitleColor:HEX_COLOR(color) forState:UIControlStateNormal];
                [CALayer updateControlLayer:tagBtn.layer radius:2 borderWidth:0.5 borderColor:HEX_COLOR(color).CGColor];
                [tagView addSubview:tagBtn];
                start_X += strWidth+6;
            }
            tagView.frame = CGRectMake(16, viewHeight, WIDTH-32, start_Y+21);
            [cell.contentView addSubview:tagView];
            viewHeight += start_Y+35;
        }
        
        CGFloat titleHeight = [NSHelper heightOfString:model.title font:FONT_SYSTEM_SIZE(15) width:WIDTH-32];
        titleHeight += (NSInteger)(titleHeight/[FONT_SYSTEM_SIZE(15) lineHeight])*6;
        UILabel *titleLabel = [UILabel createLabel:CGRectMake(16, viewHeight, WIDTH-32, (NSInteger)titleHeight) font:FONT_SYSTEM_SIZE(15) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e")];
        titleLabel.numberOfLines = 0;
        [titleLabel setParagraphText:model.title lineSpace:6];
        [cell.contentView addSubview:titleLabel];
        viewHeight += titleHeight+10;
        
        UILabel *numLabel = [UILabel createLabel:CGRectMake(16, viewHeight, WIDTH-32, [FONT_SYSTEM_SIZE(12) lineHeight]) font:FONT_SYSTEM_SIZE(12) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"AFB6C1")];
        if(self.type == TFSearchResult_Topic){
            numLabel.text = [NSString stringWithFormat:@"关注 %@   观点 %@   评论 %@", [NSString getNumStr:model.attentcount],[NSString getNumStr:model.replycount],[NSString getNumStr:model.reviewcount]];
        }else{
            numLabel.text = [NSString stringWithFormat:@"阅读 %@   评论 %@", [NSString getNumStr:model.readcount],[NSString getNumStr:model.reviewcount]];
        }
        [cell.contentView addSubview:numLabel];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, model.cellHeight-0.5, WIDTH, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [cell.contentView addSubview:lineLabel];
       
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.dataArray.count){
        TopicModel *model = self.dataArray[indexPath.row];
        if(self.type == TFSearchResult_Topic){
            TopicViewController *vc = [CommonMethod getVCFromNib:[TopicViewController class]];
            vc.subjectId = model.sid;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            InformationDetailController *vc = [CommonMethod getVCFromNib:[InformationDetailController class]];
            vc.postID = model.pid;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

@end
