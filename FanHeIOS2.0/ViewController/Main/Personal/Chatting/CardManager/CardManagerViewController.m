//
//  CardListViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/11.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "CardManagerViewController.h"
#import "NODataTableViewCell.h"
#import "NONetWorkTableViewCell.h"
#import "CardListCell.h"

@interface CardManagerViewController (){
    BOOL _noNetWork;
    NSInteger _sortIndex;
}

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation CardManagerViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _sortIndex = 1;
    [self createCustomNavigationBar:@"名片夹"];
    _noNetWork = NO;
    [self initGroupedTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = [UIColor colorWithHexString:@"41464E"];
    
    [self getCardListHttpData];
}

#pragma mark - 获取网络数据
- (void)getCardListHttpData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud;
    if(!self.dataArray){
        hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    }
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@/%ld", [DataModelInstance shareInstance].userModel.userId, (long)_sortIndex] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_USER_CARDLIST paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(weakSelf.dataArray == nil){
            weakSelf.dataArray = [NSMutableArray array];
        }else{
            [weakSelf.dataArray removeAllObjects];
        }
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *subArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            NSMutableArray *array = [NSMutableArray array];
            for (NSDictionary *subDic in subArray) {
                CardScanModel *model = [[CardScanModel alloc] initWithDict:subDic];
                [array addObject:model];
            }
            [weakSelf sort:array];
        }else{
            [weakSelf.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        if(weakSelf.dataArray == nil){
            weakSelf.dataArray = [NSMutableArray array];
        }
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark - UITableViewDelegate/datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(!self.dataArray){
        return 0;
    }else if(self.dataArray.count){
        return self.dataArray.count;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.dataArray.count){
        NSDictionary *dict = self.dataArray[section];
        NSMutableArray *array = dict[dict.allKeys[0]];
        return array.count;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count){
        return 65;
    }else{
        return HEIGHT-64;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.dataArray.count){
        return 6;
    }else{
        return 0.000001;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(self.dataArray.count){
        return 10;
    }else{
        return 0.000001;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGFloat height = 0;
    if(self.dataArray.count){
        height = 6;
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, height)];
    headerView.backgroundColor = kTableViewBgColor;
    return headerView;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    CGFloat height = 0;
    if(self.dataArray.count){
        height = 10;
    }
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, height)];
    footerView.backgroundColor = kTableViewBgColor;
    return footerView;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dataArray.count){
        static NSString *identify = @"CardListCell";
        CardListCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"CardListCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        NSDictionary *dict = self.dataArray[indexPath.section];
        NSMutableArray *array = dict[dict.allKeys[0]];
        CardScanModel *model = array[indexPath.row];
        [cell updateDisplayIsChatRoom:model];
        return cell;
    }else if(_noNetWork){
        static NSString *identify = @"NONetWorkTableViewCell";
        NONetWorkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NONetWorkTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }else{
        static NSString *identify = @"NODataTableViewCell";
        NODataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NODataTableViewCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.coverImageView.image = kImageWithName(@"icon_warm_oncard");
        cell.mainLabel.text = @"你还没有扫描任何名片";
        cell.subLabel.text = @"";
        [cell.btnImageView setTitle:@"前往扫描" forState:UIControlStateNormal];
        cell.btnImageView.hidden = YES;
        cell.clickButton = ^{
            
        };
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_noNetWork&&self.dataArray.count==0){
        
    }else if(self.dataArray.count){
        NSDictionary *dict = self.dataArray[indexPath.section];
        NSMutableArray *array = dict[dict.allKeys[0]];
        CardScanModel *cardModel = array[indexPath.row];
        NSString *title = [NSString stringWithFormat:@"%@的名片，请惠存", cardModel.name];
        NSMutableString *companyPosition = [NSMutableString string];
        if(cardModel.company.count){
            [companyPosition appendString:cardModel.company.firstObject];
            [companyPosition appendString:@" "];
        }
        if(cardModel.position.count){
            [companyPosition appendString:cardModel.position.firstObject];
        }
        if(companyPosition.length==0){
            [companyPosition appendFormat:@"公司 职位"];
        }
        NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:@"scanCardInformation",@"money_type_special",title,@"title",[CommonMethod paramNumberIsNull:cardModel.cardId],@"cardId",cardModel.imgurl,@"imageUrl",companyPosition,@"companyPosition", nil];
        EMMessage *message = [EaseSDKHelper sendTextMessage:title to:self.conversation.conversationId messageType:self.chatType messageExt:dic];
        message.chatType = self.chatType;
        [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
            if (!aError) {
                [MBProgressHUD showSuccess:@"发送成功" toView:self.view];
                self.tableView.userInteractionEnabled = YES;
            }else{
                [MBProgressHUD showError:@"发送失败" toView:self.view];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSMutableArray *newArray = [NSMutableArray new];
    for (NSInteger i = 0 ; i< self.dataArray.count; i++) {
        NSDictionary *dic = self.dataArray[i];
        [newArray addObject:dic.allKeys[0]];
    }
    return newArray;
}

#pragma mark - 排序
- (void)sort:(NSMutableArray*)array{
    if(self.dataArray == nil){
        self.dataArray = [NSMutableArray array];
    }else{
        [self.dataArray removeAllObjects];
    }
    if(array.count){
        [self filter:@"#" array:array];
        char pre = 'A';
        for(int i = 0; i < 26; i++){
            [self filter:[NSString stringWithFormat:@"%C", (unichar)(pre+i)] array:array];
        }
    }
    [self.tableView reloadData];
}

- (void)filter:(NSString*)str array:(NSMutableArray*)array{
    NSMutableArray *tempArray = [NSMutableArray array];
    if([str isEqualToString:@"#"]){
        for(CardScanModel *model in array){
            if(model.otherid.intValue == [DataModelInstance shareInstance].userModel.userId.intValue){
                [tempArray addObject:model];
            }
        }
    }else{
        for(CardScanModel *model in array){
            if([[[EaseChineseToPinyin pinyinFromChineseString:model.name] uppercaseString] hasPrefix:str]){
                if(model.otherid.intValue != [DataModelInstance shareInstance].userModel.userId.intValue){
                    [tempArray addObject:model];
                }
            }
        }
    }
    if(tempArray.count){
        [self.dataArray addObject:@{str:tempArray}];
    }
}

@end
