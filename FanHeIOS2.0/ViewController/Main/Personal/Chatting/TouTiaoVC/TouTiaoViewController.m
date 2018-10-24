//
//  TouTiaoViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/25.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "TouTiaoViewController.h"
#import "InformationDetailController.h"

@interface TouTiaoViewController (){
    NSInteger _currentPage;
}

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation TouTiaoViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"金脉头条"];
    _currentPage = 1;
    self.dataArray = [NSMutableArray array];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 20)];
    footerView.backgroundColor = kTableViewBgColor;
    self.tableView.tableFooterView = footerView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView tableViewAddDownLoadRefreshing:^{
        _currentPage++;
        [self getHttpData];
    }];
    [self getHttpData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 获取
- (void)getHttpData{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%ld",(long)_currentPage] forKey:@"param"];
    __block NSInteger index = _currentPage;
    [self requstType:RequestType_Get apiName:API_NAME_GET_USER_IMTOPIC paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [weakSelf.tableView endRefresh];
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            NSArray *array = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            for(NSDictionary *dict in array){
                TouTiaoModel *model = [[TouTiaoModel alloc] initWithDict:dict];
                if(model.modelArray.count){
                    [weakSelf.dataArray insertObject:model atIndex:0];
                }
            }
            if(weakSelf.dataArray.count){
                [weakSelf.tableView reloadData];
                if(index==1){
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.dataArray.count-1 inSection:0];
                        [weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    });
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [weakSelf.tableView endRefresh];
    }];
}

#pragma mark - UITableViewDelegate/datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TouTiaoModel *model = self.dataArray[indexPath.row];
    return model.cellHeight;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    TouTiaoModel *model = self.dataArray[indexPath.row];
    UILabel *timeLabel = [UILabel createrLabelframe:CGRectMake(0, 0, WIDTH, 38) backColor:kTableViewBgColor textColor:HEX_COLOR(@"afb6c1") test:model.sendtime font:10 number:1 nstextLocat:NSTextAlignmentCenter];
    [cell.contentView addSubview:timeLabel];
    
    UIView *contentsView = [[UIView alloc] initWithFrame:CGRectMake(16, 38, WIDTH-32, model.cellHeight-38)];
    contentsView.backgroundColor = WHITE_COLOR;
    [cell.contentView addSubview:contentsView];
    [CALayer updateControlLayer:contentsView.layer radius:5 borderWidth:0.3 borderColor:kCellLineColor.CGColor];
    
    CGFloat height = [(NSNumber*)model.heightArray[0] floatValue];
    TalkFianaceModel *tfmModel = model.modelArray[0];
    
    UIImageView *firstImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, WIDTH-56, 155)];
    firstImageView.tag = 200+indexPath.row*10000;
    firstImageView.contentMode = UIViewContentModeScaleAspectFill;
    firstImageView.clipsToBounds = YES;
    [firstImageView sd_setImageWithURL:[NSURL URLWithString:tfmModel.image] placeholderImage:KWidthImageDefault];
    [CommonMethod viewAddGuestureRecognizer:firstImageView tapsNumber:1 withTarget:self withSEL:@selector(gotoInfoDetail:)];
    [contentsView addSubview:firstImageView];

    UILabel *bgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 155-(height+20), WIDTH-56, height+20)];
    bgLabel.backgroundColor = [HEX_COLOR(@"41464e") colorWithAlphaComponent:0.7];
    [firstImageView addSubview:bgLabel];
    
    UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(12, 155-(height+20), WIDTH-80, height+20) backColor:nil textColor:WHITE_COLOR test:tfmModel.title font:16 number:2 nstextLocat:NSTextAlignmentLeft];
    if(height>FONT_SYSTEM_SIZE(16).lineHeight){
        [titleLabel setParagraphText:tfmModel.title lineSpace:6];
    }
    [firstImageView addSubview:titleLabel];
    
    CGFloat start_Y = 179;
    for(int i=1; i<model.modelArray.count; i++){
        height = [(NSNumber*)model.heightArray[i] floatValue];
        tfmModel = model.modelArray[i];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, start_Y, WIDTH-32, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [contentsView addSubview:lineLabel];
        
        UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(12, start_Y, WIDTH-108, height+22) backColor:nil textColor:HEX_COLOR(@"222222") test:tfmModel.title font:16 number:0 nstextLocat:NSTextAlignmentLeft];
        if(height>FONT_SYSTEM_SIZE(16).lineHeight){
            [titleLabel setParagraphText:tfmModel.title lineSpace:6];
        }
        [contentsView addSubview:titleLabel];
        
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-88, start_Y+8, 44, 44)];
        iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        iconImageView.clipsToBounds = YES;
        [iconImageView sd_setImageWithURL:[NSURL URLWithString:tfmModel.image] placeholderImage:KWidthImageDefault];
        [contentsView addSubview:iconImageView];
        
        titleLabel.tag = 200+i+indexPath.row*10000;
        [CommonMethod viewAddGuestureRecognizer:titleLabel tapsNumber:1 withTarget:self withSEL:@selector(gotoInfoDetail:)];
        iconImageView.tag = 200+i+indexPath.row*10000;
        [CommonMethod viewAddGuestureRecognizer:iconImageView tapsNumber:1 withTarget:self withSEL:@selector(gotoInfoDetail:)];
        start_Y += height+22;
    }
    cell.backgroundColor = kTableViewBgColor;
    return cell;
}

#pragma mark -资讯详情
- (void)gotoInfoDetail:(UITapGestureRecognizer*)tap{
    NSInteger row = tap.view.tag/10000;
    NSInteger tag = tap.view.tag%10000-200;
    TouTiaoModel *model = self.dataArray[row];
    TalkFianaceModel *tfmModel = model.modelArray[tag];
    InformationDetailController *vc = [[InformationDetailController alloc] init];
    vc.postID = tfmModel.postid;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
