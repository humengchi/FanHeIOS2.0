//
//  MyGroupViewController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/8/8.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "MyGroupViewController.h"
#import "MessageSidViewController.h"
#import "ChattingListCell.h"
#import "EMGroup+Category.h"
#import "NODataTableViewCell.h"
#import "GroupSetUpViewController.h"

@interface MyGroupViewController ()

@property (nonatomic ,strong) NSMutableArray *groupArray;

@end

@implementation MyGroupViewController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.groupArray removeAllObjects];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    for(EMGroup *group in [[EMClient sharedClient].groupManager getJoinedGroups]){
        group.headerImage = KHeadImageDefaultName(@"群组");
        group.hasCreated = @(0);
        group.isMyGroupList = @(1);
        [self.groupArray addObject:group];
    }
    [self.tableView reloadData];
    
    __weak typeof(self) weakSelf = self;
    self.deleteGroup = ^(NSString *groupId) {
        NSInteger index = 0;
        for(EMGroup *group in weakSelf.groupArray){
            if([group.groupId isEqualToString:groupId]){
                break;
            }
            index++;
        }
        [weakSelf.groupArray removeObjectAtIndex:index];
        [weakSelf.tableView reloadData];
    };

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.groupArray = [NSMutableArray new];
    [self createCustomNavigationBar:@"我的群组"];
    
    UIButton *publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    publishBtn.frame = CGRectMake(WIDTH - 56, 20, 40, 44);
    [publishBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [publishBtn setImage:[kImageWithName(@"icon_bjmp_tj") imageWithColor:HEX_COLOR(@"818c9e")] forState:UIControlStateNormal];
    [publishBtn addTarget:self action:@selector(createButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:publishBtn];
    
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
}

#pragma mark -创建群组
- (void)createButtonClicked:(id)sender{
    __weak typeof(self) weakSelf = self;
    GroupSetUpViewController *myGroup = [[GroupSetUpViewController alloc]init];
    myGroup.createGroupSuccess = ^{
        [weakSelf.groupArray removeAllObjects];
        for(EMGroup *group in [[EMClient sharedClient].groupManager getJoinedGroups]){
            group.headerImage = KHeadImageDefaultName(@"群组");
            group.hasCreated = @(0);
            group.isMyGroupList = @(1);
            [weakSelf.groupArray addObject:group];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    };
    [self.navigationController pushViewController:myGroup animated:YES];
}

#pragma mark -- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.groupArray.count){
        return self.groupArray.count;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.groupArray.count){
        return 80;
    }else{
        return HEIGHT-64;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.groupArray.count){
        static NSString *cellID = @"groupID";
        ChattingListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod
                    getViewFromNib:NSStringFromClass([ChattingListCell class])];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        EMGroup *group = self.groupArray[indexPath.row];
        if(group.hasCreated.integerValue==0){
            if([CommonMethod paramArrayIsNull:group.occupants].count==0){
                [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
                    if(aGroup){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.groupArray replaceObjectAtIndex:indexPath.row withObject:aGroup];
                            [cell traderCharttingMessageGroup:aGroup];
                        });
                    }
                }];
            }
        }
        [cell traderCharttingMessageGroup:group];
        return cell;
    }else{
        static NSString *cellID = @"NODataTableViewCell";
        NODataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [CommonMethod
                    getViewFromNib:NSStringFromClass([NODataTableViewCell class])];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.coverImageView.image = kImageWithName(@"icon_warm_noql");
        cell.mainLabel.text = @"暂无群组";
        cell.subLabel.text = @"";
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.groupArray.count){
        EMGroup *group = self.groupArray[indexPath.row];
        MessageSidViewController *chatController = [[MessageSidViewController alloc] initWithConversationChatter:group.groupId conversationType:EMConversationTypeGroupChat];
        chatController.titleStr = group.subject;
        [self.navigationController pushViewController:chatController animated:YES];
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
