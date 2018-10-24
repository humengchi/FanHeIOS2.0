//
//  GroupMemberViewController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/8/23.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "GroupMemberViewController.h"
#import "InviteFriendsViewCell.h"
@interface GroupMemberViewController ()
@property (nonatomic, strong) EMGroup *aGroupCurrue;
@property (nonatomic ,strong )  NSMutableDictionary *msgNumDict;
@property (nonatomic ,strong )  NSMutableArray *friendsArray;
@property (nonatomic ,strong )  NSMutableArray *searchArry;
@property (strong, nonatomic) NSMutableArray *blockSelectedUsernames;
@end

@implementation GroupMemberViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"选择要提醒的人"];
    
   _blockSelectedUsernames = [NSMutableArray array];
    
    //调用获取群会员
    EMError *error = nil;
    self.aGroupCurrue =   [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:self.groupID  error:&error];
    
    
    self.msgNumDict = [NSMutableDictionary dictionary];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 6)];
    headerView.backgroundColor = kTableViewBgColor;
    self.tableView.tableHeaderView = headerView;
    //右检索背景颜色
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    //右检索字体颜色
    self.tableView.sectionIndexColor = [UIColor colorWithHexString:@"41464E"];
   
    [self getGroupmemberAndHeader:self.aGroupCurrue.occupants];
}



- (void)getGroupmemberAndHeader:(NSArray *)array{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    if (array.count > 0) {
        [requestDict setObject:[array componentsJoinedByString:@","] forKey:@"userid"];
    }
    
    [self requstType:RequestType_Post apiName:API_NAME_POST_CHECKUSER_HEADERANDNAME paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *tmpArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            NSMutableArray *array = [NSMutableArray new];
            for(NSDictionary *dict in tmpArray){
                ChartModel *model = [[ChartModel alloc] initWithDict:dict];
                [array addObject:model];
            }
            [self sortMemberArray:array];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
    
}
//排序
- (void)sortMemberArray:(NSMutableArray *)array{
    if(self.friendsArray == nil){
        self.friendsArray = [NSMutableArray array];
    }else{
        [self.friendsArray removeAllObjects];
    }
    if(array.count){
        char pre = 'A';
        for(int i = 0; i < 26; i++){
            [self filter:[NSString stringWithFormat:@"%C", (unichar)(pre+i)] array:array];
        }
        [self filter:@"#" array:array];
    }
    
    [self.tableView reloadData];
    
}
#pragma mark -- UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.friendsArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSDictionary *dict = self.friendsArray[section];
    NSArray *array = dict[dict.allKeys[0]];
    return [array count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 32;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 32)];
    headerView.backgroundColor = kTableViewBgColor;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, WIDTH-16, 32)];
    label.textColor = HEX_COLOR(@"818C9E");
    label.font = FONT_SYSTEM_SIZE(14);
    [headerView addSubview:label];
    NSDictionary *dic = self.friendsArray[section];
    label.text = dic.allKeys[0];
    
    UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(0, 31.5, WIDTH, 0.5)];
    label3.backgroundColor = kCellLineColor;
    [headerView addSubview:label3];
    
    return headerView;
    
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = self.friendsArray[indexPath.section];
    NSMutableArray *array = dict[dict.allKeys[0]];
    ChartModel *model = array[indexPath.row];
    static NSString *identify = @"AddFriendsViewCell";
    InviteFriendsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [CommonMethod getViewFromNib:@"InviteFriendsViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.indexPath = indexPath;
    cell.isOwer = NO;
    [cell tranferInterChartModel:model];
    UIView *lineView = [NSHelper createrViewFrame:CGRectMake(0, 53.5, WIDTH, 0.5) backColor:@"D9D9D9"];
    [cell.contentView addSubview:lineView];
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dict = self.friendsArray[indexPath.section];
    NSMutableArray *array = dict[dict.allKeys[0]];
    ChartModel *model = array[indexPath.row];
    
    
    if (self.groupMemberViewControllerDelegate && [self.groupMemberViewControllerDelegate respondsToSelector:@selector(viewController:didFinishSelectedSources:)]) {
            [self.groupMemberViewControllerDelegate viewController:self didFinishSelectedSources:model];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    self.searchArry = [NSMutableArray new];
    [self.searchArry addObject:@"#"];
    NSArray *newArray = [NSArray new];
    for (NSInteger i = 0 ; i< self.friendsArray.count; i++) {
        NSDictionary *dic = self.friendsArray[i];
        [self.searchArry addObject:dic.allKeys[0]];
    }
    newArray = self.searchArry;
    return newArray;
}
- (void)filter:(NSString*)str array:(NSArray*)array{
    NSMutableArray *tempArray = [NSMutableArray array];
    if([str isEqualToString:@"#"]){
        for(ChartModel *model in array){
            if([EaseChineseToPinyin sortSectionTitle:[EaseChineseToPinyin pinyinFromChineseString:model.realname]] == '#'){
                if(model.userid.intValue != [DataModelInstance shareInstance].userModel.userId.intValue){
                    [tempArray addObject:model];
                }
            }
        }
    }else{
        for(ChartModel *model in array){
            if([[[EaseChineseToPinyin pinyinFromChineseString:model.realname] uppercaseString] hasPrefix:str]){
                if(model.userid.intValue != [DataModelInstance shareInstance].userModel.userId.intValue){
                    [tempArray addObject:model];
                }
            }
        }
    }
    if(tempArray.count){
        [self.friendsArray addObject:@{str:tempArray}];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
