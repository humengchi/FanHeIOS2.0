//
//  ApplyDetailViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/5.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ApplyDetailViewController.h"
#import "LookHistoryCell.h"

@interface ApplyDetailViewController ()

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) LookHistoryModel *model;

@end

@implementation ApplyDetailViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    self.view.backgroundColor = kTableViewBgColor;
    [self createCustomNavigationBar:@"报名信息"];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64-49)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self getHttpData];
}

- (void)initToolView{
    UIView *toolView = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-49, WIDTH, 49)];
    toolView.backgroundColor = HEX_COLOR(@"f7f7f7");
    [self.view addSubview:toolView];
    
    UIButton *messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [messageBtn setBackgroundColor:WHITE_COLOR];
    messageBtn.frame = CGRectMake(16, 6, 130, 36);
    [messageBtn setTitleColor:HEX_COLOR(@"818c9e") forState:UIControlStateNormal];
    [messageBtn setTitleColor:kDefaultColor forState:UIControlStateHighlighted];
    [messageBtn setTitle:@"发短信" forState:UIControlStateNormal];
    messageBtn.titleLabel.font = FONT_SYSTEM_SIZE(17);
    [CALayer updateControlLayer:messageBtn.layer radius:5 borderWidth:0.3 borderColor:HEX_COLOR(@"afb6c1").CGColor];
    [messageBtn addTarget:self action:@selector(messageButtonClicekd:) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:messageBtn];
    
    UIButton *emailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [emailBtn setBackgroundColor:HEX_COLOR(@"1abc9c")];
    emailBtn.frame = CGRectMake(156, 6, WIDTH-156-16, 36);
    [emailBtn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
    [emailBtn setTitleColor:KTextColor forState:UIControlStateHighlighted];
    [emailBtn setTitle:@"拨打电话" forState:UIControlStateNormal];
    emailBtn.titleLabel.font = FONT_SYSTEM_SIZE(17);
    [CALayer updateControlLayer:emailBtn.layer radius:5 borderWidth:0 borderColor:nil];
    [emailBtn addTarget:self action:@selector(emailButtonClicekd:) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:emailBtn];
}

#pragma mark - 按钮
- (void)messageButtonClicekd:(UIButton*)sender{
    if([CommonMethod paramStringIsNull:self.model.phone].length){
        [self showMessageView:@[self.model.phone] title:@""];
    }
}

- (void)emailButtonClicekd:(UIButton*)sender{
    if([CommonMethod paramStringIsNull:self.model.phone].length){
        NSString *str = [NSString stringWithFormat:@"tel:%@",self.model.phone];
        UIWebView *callWebView = [[UIWebView alloc]init];
        [callWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self.view addSubview:callWebView];
    }
}

#pragma mark - 网络请求
- (void)getHttpData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@", self.ordernum] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_ACTIVITY_APPLY_DETAILNEW paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            weakSelf.model = [[LookHistoryModel alloc] initWithDict:[CommonMethod paramDictIsNull:responseObject[@"data"]]];
            [weakSelf initToolView];
        }
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"无法连接到网络" toView:weakSelf.view];
    }];
}

#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.model){
        return 6+self.model.applyusers.count;
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row==0){
        return 74;
    }else if(indexPath.row==1||indexPath.row==5){
        return 32;
    }else if(indexPath.row > 1 && indexPath.row < 4){
        return 49;
    }else if(indexPath.row==4){
        return [NSHelper heightOfString:self.model.remark font:FONT_SYSTEM_SIZE(17) width:WIDTH-86 defaultHeight:21]+28;
    }else{
        if (self.model.applyusers.count) {
            NSArray *array = self.model.applyusers[0];
            return 27*array.count+25;
        }else{
            return 0;
        }
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row==0){
        static NSString *identify = @"LookHistoryCell";
        LookHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"LookHistoryCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell lookHistoryModel:self.model];
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
        NSArray *titleArray = @[@"报名信息",@"门票",@"电话",@"留言"];
        if(indexPath.row==1){
            UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(16, 7, 60, 18) backColor:kTableViewBgColor textColor:HEX_COLOR(@"818c9e") test:titleArray[indexPath.row-1] font:14 number:1 nstextLocat:NSTextAlignmentLeft];
            [cell.contentView addSubview:titleLabel];
            
            UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(WIDTH-116, 8, 100, 14) backColor:kTableViewBgColor textColor:HEX_COLOR(@"afb6c1") test:[NSString stringWithFormat:@"%@ 报名", self.model.created_at] font:12 number:1 nstextLocat:NSTextAlignmentRight];
            [cell.contentView addSubview:contentLabel];
            cell.backgroundColor = kTableViewBgColor;
        }else if(indexPath.row > 1 && indexPath.row < 5){
            UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(16, 14, 40, 21) backColor:WHITE_COLOR textColor:HEX_COLOR(@"afb6c1") test:titleArray[indexPath.row-1] font:17 number:1 nstextLocat:NSTextAlignmentLeft];
            [cell.contentView addSubview:titleLabel];
            
            UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(70, 14, WIDTH-86, 21) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:@"" font:17 number:1 nstextLocat:NSTextAlignmentLeft];
            [cell.contentView addSubview:contentLabel];
            cell.backgroundColor = WHITE_COLOR;
            if(indexPath.row == 2){
                contentLabel.text = [NSString stringWithFormat:@"%@ x %@张", self.model.price.integerValue?self.model.price.stringValue:@"免费", self.model.ticketnum];
            }else if(indexPath.row == 3){
                contentLabel.text = self.model.phone;
            }else if(indexPath.row == 4){
                contentLabel.text = self.model.remark;
                contentLabel.frame = CGRectMake(70, 14, WIDTH-86, [NSHelper heightOfString:self.model.remark font:FONT_SYSTEM_SIZE(17) width:WIDTH-86 defaultHeight:21]);
                contentLabel.numberOfLines = 0;
            }
            if(indexPath.row!=4){
                UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 48.5, WIDTH-32, 0.5)];
                lineLabel.backgroundColor = kCellLineColor;
                [cell.contentView addSubview:lineLabel];
            }
        }else if(indexPath.row==5){
            UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(16, 7, 200, 18) backColor:kTableViewBgColor textColor:HEX_COLOR(@"818c9e") test:@"参会者信息" font:14 number:1 nstextLocat:NSTextAlignmentLeft];
            [cell.contentView addSubview:titleLabel];
            cell.backgroundColor = kTableViewBgColor;
            UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
            lineLabel.backgroundColor = kCellLineColor;
            [cell.contentView addSubview:lineLabel];
        }else{
            NSArray *array = self.model.applyusers[indexPath.row-6];
            NSInteger i = 0;
            for(InfoFieldModel *model in array){
                UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(16, 10+i*27, 40, 27) backColor:WHITE_COLOR textColor:HEX_COLOR(@"afb6c1") test:model.infoname font:17 number:1 nstextLocat:NSTextAlignmentLeft];
                titleLabel.adjustsFontSizeToFitWidth = YES;
                [cell.contentView addSubview:titleLabel];
                
                UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(70, 10+i*27, WIDTH-86, 27) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:model.infovalue font:17 number:1 nstextLocat:NSTextAlignmentLeft];
                [cell.contentView addSubview:contentLabel];
                i++;
            }
            UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 27*array.count+20, WIDTH, 5)];
            lineLabel.backgroundColor = kTableViewBgColor;
            [cell.contentView addSubview:lineLabel];
            cell.backgroundColor = WHITE_COLOR;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row==0){
        NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
        vc.userId = self.model.userid;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
