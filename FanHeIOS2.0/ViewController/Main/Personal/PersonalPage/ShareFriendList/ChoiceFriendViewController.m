//
//  ChoiceFriendViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/17.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ChoiceFriendViewController.h"
#import "AllFriendsViewController.h"
#import "FriendTableViewCell.h"
#import "NoFriendTableViewCell.h"
#import "ChatViewController.h"

@interface ChoiceFriendViewController ()

@property (nonatomic, strong) NSMutableArray    *recentListArray;
@property (nonatomic, strong) NSMutableArray    *showListArray;

@end

@implementation ChoiceFriendViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createCustomNavigationBar:@"选择好友"];
    self.recentListArray = [NSMutableArray array];
    [self initGroupedTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.backgroundColor = kBackgroundColorDefault;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self loadRecentListArrayData];
}

#pragma mafrk ------ 好友
- (void)loadRecentListArrayData{
    NSMutableArray *friendsList = [NSMutableArray arrayWithArray:[[EMClient sharedClient].chatManager getAllConversations]];
    [friendsList sortUsingComparator:^NSComparisonResult(EMConversation *model1, EMConversation *model2) {
        NSDate *date1 = [NSDate dateWithTimeIntervalInMilliSecondSince1970:[model1 latestMessage].timestamp];
        NSDate *date2 = [NSDate dateWithTimeIntervalInMilliSecondSince1970:[model2 latestMessage].timestamp];
        if([NSDate secondsAwayFrom:date1 dateSecond:date2] > 0){
            return NSOrderedAscending;
        }else{
            return NSOrderedDescending;
        }
    }];
    
    self.recentListArray = [NSMutableArray array];
    self.showListArray = [NSMutableArray array];
    for(EMConversation *model in friendsList){
        if(model.type == EMConversationTypeGroupChat){
            EMGroup *group = [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:model.conversationId error:nil];
            [self.recentListArray addObject:group];
            [self.showListArray addObject:group];
        }else{
            if(![model.conversationId isEqualToString:@"jm_assistant"] && ![model.conversationId isEqualToString:@"activity_assistant"] && ![model.conversationId isEqualToString:@"jm_topic"]){
                NSArray *array = [[DBInstance shareInstance] selectCharttingID:model.conversationId];
                if(array.count){
                    ChartModel *chartModel = array.count?array[0]:[[ChartModel alloc] init];
                    [self.recentListArray addObject:chartModel];
                    [self.showListArray addObject:chartModel];
                }
            }
        }
    }
    [self.tableView reloadData];
}

#pragma mark - 跳转到好友列表
- (void)gotoAllFriendsVCButtonClicked:(id)sender{
    AllFriendsViewController *vc = [CommonMethod getVCFromNib:[AllFriendsViewController class]];
    vc.gooAtStr = self.gooAtStr;
    vc.position = self.position;
    vc.nameCatergoryStr = self.nameCatergoryStr;
    vc.imagUrl = self.imagUrl;
    vc.userID = self.userID;
    vc.isSendCard = YES;
    vc.messageModel = self.messageModel;
    vc.actModel = self.actModel;
    vc.dymodel = self.dymodel;
    vc.useModel = self.useModel;
    vc.isInviteCommend = self.isInviteCommend;
    vc.cardModel = self.cardModel;
    if (self.isViewPoint) {
        vc.isViewPoint = self.isViewPoint;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.showListArray){
        return self.showListArray.count?self.showListArray.count:1;
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.showListArray.count){
        return 52;
    }else{
        return self.tableView.frame.size.height;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 130;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 130)];
    headerView.backgroundColor = kBackgroundColorDefault;
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 44)];
    self.searchBar.showsCancelButton = NO;
    self.searchBar.returnKeyType = UIReturnKeySearch;
    self.searchBar.enablesReturnKeyAutomatically = YES;
    self.searchBar.delegate = self;
    [self.searchBar setPlaceholder:@"搜索姓名、公司、职位"];
    [self.searchBar setSearchTextPositionAdjustment:UIOffsetMake(5, 0)];
    [self.searchBar setBackgroundColor:HEX_COLOR(@"E6E8EB")];
    [self.searchBar setBackgroundImage:kImageWithColor(HEX_COLOR(@"E6E8EB"), self.searchBar.bounds)];
    [self.searchBar setSearchFieldBackgroundImage:kImageWithName(@"searchBackground") forState:UIControlStateNormal];
    [self.searchBar setSearchFieldBackgroundImage:kImageWithName(@"searchBackground") forState:UIControlStateDisabled];
    [headerView addSubview:self.searchBar];
    
    UIButton *allFriendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    allFriendBtn.frame = CGRectMake(0, 44, WIDTH, 53);
    [allFriendBtn setTitle:@"我的全部好友" forState:UIControlStateNormal];
    [allFriendBtn setTitleColor:HEX_COLOR(@"41464E") forState:UIControlStateNormal];
    allFriendBtn.titleLabel.font = FONT_SYSTEM_SIZE(14);
    [allFriendBtn setImage:kImageWithName(@"icon_next_gray") forState:UIControlStateNormal];
    allFriendBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    allFriendBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    allFriendBtn.imageEdgeInsets = UIEdgeInsetsMake(0, WIDTH-25, 0, 0);
    [allFriendBtn setBackgroundColor:WHITE_COLOR];
    [allFriendBtn addTarget:self action:@selector(gotoAllFriendsVCButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:allFriendBtn];
    
    UILabel *titleLabel = [UILabel createLabel:CGRectMake(16, 100, WIDTH-16, 30) font:FONT_SYSTEM_SIZE(14) bkColor:kTableViewBgColor textColor:HEX_COLOR(@"818C9E")];
    titleLabel.text = @"最近聊天";
    [headerView addSubview:titleLabel];
    return headerView;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.showListArray.count){
        static NSString *identify = @"FriendTableViewCell";
        FriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"FriendTableViewCell"];
        }
        if([self.showListArray[indexPath.row] isKindOfClass:[ChartModel class]]){
            ChartModel *model = self.showListArray[indexPath.row];
            if([CommonMethod paramStringIsNull:model.realname].length == 0){
                model.realname = @"不是好友";
            }
            [cell updateDisplayOnlyName:model];
        }else{
            EMGroup *group = self.showListArray[indexPath.row];
            [cell updateDisplayGroup:group];
        }
        return cell;
    }else{
        static NSString *identify = @"NoFriendTableViewCell";
        NoFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NoFriendTableViewCell"];
        }
        [cell updateDisplay:YES isSearch:NO];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.searchBar endEditing:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.showListArray.count){
        NSString *nameStr = @"";
        NSString *conversationId = @"";
        if([self.showListArray[indexPath.row] isKindOfClass:[ChartModel class]]){
            ChartModel *model = self.showListArray[indexPath.row];
            nameStr = model.realname;
            conversationId = model.userid.stringValue;
        }else{
            EMGroup *group = self.showListArray[indexPath.row];
            nameStr = group.subject;
            conversationId = group.groupId;
        }
        if(self.isInviteCommend){
            __weak typeof(self) weakSelf = self;
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:
             [NSString stringWithFormat:@"确定邀请%@来点评您吗？", nameStr] cancelButtonTitle:@"否" otherButtonTitle:@"是" cancle:^{
             } confirm:^{
                 __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"发送中..." toView:self.view];
                 NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
                 [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
                 [requestDict setObject:@(conversationId.integerValue) forKey:@"otherid"];
                 [self requstType:RequestType_Post apiName:API_NAME_POST_USER_GETSMBEV paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
                     [hud hideAnimated:YES];
                     if([CommonMethod isHttpResponseSuccess:responseObject]){
                         [MBProgressHUD showSuccess:@"发送成功" toView:weakSelf.view];
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             [weakSelf.navigationController popViewControllerAnimated:YES];
                         });
                     }else{
                         [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
                     }
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
                     [hud hideAnimated:YES];
                     [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
                 }];
             }];
        }else if (self.messageModel) {
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"确定发给：" message:nameStr cancelButtonTitle:@"否" otherButtonTitle:@"是" cancle:^{
            } confirm:^{
                self.tableView.userInteractionEnabled = NO;
                if (self.messageModel.bodyType == EMMessageBodyTypeText) {
                    EMMessage *message;
                    if (self.messageModel.messageType == EMChatTypeGroupChat) {
                       message = [EaseSDKHelper sendTextMessage:self.messageModel.text to:conversationId messageType:EMChatTypeGroupChat messageExt:self.messageModel.message.ext];
                    }else{
                        message = [EaseSDKHelper sendTextMessage:self.messageModel.text to:conversationId messageType:EMChatTypeChat messageExt:self.messageModel.message.ext];
                    }

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
                }else if (self.messageModel.bodyType == EMMessageBodyTypeImage) {
                    UIImage *image = self.messageModel.image?self.messageModel.image:self.messageModel.thumbnailImage;
                    if (!image) {
                        image = [UIImage imageWithContentsOfFile:self.messageModel.fileLocalPath];
                    }
                    if (!image) {
                        image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.messageModel.fileURLPath]]];
                    }
                    EMMessage *message;
                    if (self.messageModel.messageType == EMChatTypeGroupChat) {
                        message= [EaseSDKHelper sendImageMessageWithImage:image to:conversationId messageType:EMChatTypeGroupChat requireEncryption:YES messageExt:self.messageModel.message.ext progress:nil];
                    }else{
                       message= [EaseSDKHelper sendImageMessageWithImage:image to:conversationId messageType:EMChatTypeChat requireEncryption:YES messageExt:self.messageModel.message.ext progress:nil];
                    }
                    
                    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError){
                        if (!aError) {
                            self.tableView.userInteractionEnabled = YES;
                            [MBProgressHUD showSuccess:@"发送成功" toView:self.view];
                        }else{
                            [MBProgressHUD showError:@"发送失败" toView:self.view];
                        }
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self.navigationController popViewControllerAnimated:YES];
                        });
                        
                    }];
                }else if (self.messageModel.bodyType == EMMessageBodyTypeLocation) {
                    EMMessage *message;
                    if (self.messageModel.messageType == EMChatTypeGroupChat) {
                       message= [EaseSDKHelper sendLocationMessageWithLatitude:self.messageModel.latitude longitude:self.messageModel.longitude address:self.messageModel.address to:conversationId messageType:EMChatTypeGroupChat requireEncryption:YES messageExt:self.messageModel.message.ext];
                    }else{
                      message= [EaseSDKHelper sendLocationMessageWithLatitude:self.messageModel.latitude longitude:self.messageModel.longitude address:self.messageModel.address to:conversationId messageType:EMChatTypeChat requireEncryption:YES messageExt:self.messageModel.message.ext];
                    }

                    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError){
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
            }];
        }else if(self.actModel){
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"确定发送给：" message:nameStr cancelButtonTitle:@"取消" otherButtonTitle:@"发送" cancle:^{
            } confirm:^{
                NSString *startTime = [NSDate stringFromDate:[NSDate dateFromString:[CommonMethod paramStringIsNull:self.actModel.starttime] format:kTimeFormat1] format:@"MM-dd HH:mm"];
                NSString *endTime = [NSDate stringFromDate:[NSDate dateFromString:[CommonMethod paramStringIsNull:self.actModel.endtime] format:kTimeFormat1] format:@"MM-dd HH:mm"];
                NSDictionary *dic =  [[NSDictionary alloc]initWithObjectsAndKeys:@"activity",@"money_type_special", [CommonMethod paramNumberIsNull:self.actModel.activityid],@"activityid", [NSString stringWithFormat:@"%@%@ %@",[CommonMethod paramStringIsNull:self.actModel.cityname],[CommonMethod paramStringIsNull:self.actModel.districtname],[CommonMethod paramStringIsNull:self.actModel.address]],@"address", [CommonMethod paramStringIsNull:self.actModel.name],@"name", self.actModel.timestr,@"starttime", [CommonMethod paramStringIsNull:endTime],@"endtime", nil];
                
                EMMessage *message;
                if (self.messageModel.messageType == EMChatTypeGroupChat) {
                   message = [EaseSDKHelper sendTextMessage:@"邀请你参加活动：               " to:conversationId messageType:EMChatTypeGroupChat messageExt:dic];
                }else{
                    message = [EaseSDKHelper sendTextMessage:@"邀请你参加活动：               " to:conversationId messageType:EMChatTypeChat messageExt:dic];
                }

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
            }];
        }else if(self.dymodel && self.isViewPoint == YES){
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"确定发送给：" message:nameStr cancelButtonTitle:@"取消" otherButtonTitle:@"发送" cancle:^{
            } confirm:^{
                NSString *strTitle = [NSString stringWithFormat:@"%@的观点",self.dymodel.userModel.user_realname];
                NSString *realname   =  self.dymodel.userModel.user_realname;
                
                NSDictionary *dic =  [[NSDictionary alloc]initWithObjectsAndKeys:@"viewPoint",@"money_type_special",strTitle,@"title", [CommonMethod paramNumberIsNull:self.dymodel.parent_subject_id],@"dynamicid",self.dymodel.userModel.user_image,@"imageUrl", self.dymodel.content,@"count",realname,@"realname", nil];
                EMMessage *message;
                if (self.messageModel.messageType == EMChatTypeGroupChat) {
                   message = [EaseSDKHelper sendTextMessage:strTitle to:conversationId messageType:EMChatTypeGroupChat messageExt:dic];
                }else{
                   message = [EaseSDKHelper sendTextMessage:strTitle to:conversationId messageType:EMChatTypeChat messageExt:dic];
                }
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
            }];
        }else if(self.dymodel && self.isViewPoint == NO){
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"确定发送给：" message:nameStr cancelButtonTitle:@"取消" otherButtonTitle:@"发送" cancle:^{
            } confirm:^{
                NSString *count;
                if (self.dymodel.type.integerValue == 13) {
                    if (self.dymodel.exttype.integerValue == 3 ||self.dymodel.exttype.integerValue == 8) {
                        count = @"发起了一个话题";
                    }else if (self.dymodel.exttype.integerValue == 4 ||self.dymodel.exttype.integerValue == 9) {
                        count = @"发布了一个活动";
                    }else if (self.dymodel.exttype.integerValue == 5 ||self.dymodel.exttype.integerValue == 10) {
                        count = @"发布了一篇文章";
                    }else if (self.dymodel.exttype.integerValue == 7 ||self.dymodel.exttype.integerValue == 12 ) {
                        count =  @"发表了一个评论";
                    }else if ( self.dymodel.type.integerValue == 6 ||self.dymodel.type.integerValue == 11) {
                        count =  @"发布了一个观点";
                    }else if (self.dymodel.exttype.integerValue == 1) {
                        count = self.dymodel.parent_content;
                    }else if (self.dymodel.exttype.integerValue == 2) {
                        if (self.dymodel.parent_content.length > 0) {
                            count = self.dymodel.parent_content;
                        }else{
                            NSArray *imageArray = [self.dymodel.parent_image componentsSeparatedByString:@","];
                            count = [NSString stringWithFormat:@"分享了%ld张图片",imageArray.count];
                        }
                    }
                }else{
                    if (self.dymodel.type.integerValue == 3 ||self.dymodel.type.integerValue == 8) {
                        count = @"发起了一个话题";
                    }else if (self.dymodel.type.integerValue == 4 ||self.dymodel.type.integerValue == 9) {
                        count = @"发布了一个活动";
                    }else if (self.dymodel.type.integerValue == 5 ||self.dymodel.type.integerValue == 10) {
                        count = @"发布了一篇文章";
                    }else if (self.dymodel.type.integerValue == 7 ||self.dymodel.type.integerValue == 12 ) {
                        count =  @"发表了一个评论";
                    }else if ( self.dymodel.type.integerValue == 6 ||self.dymodel.type.integerValue == 11) {
                        count =  @"发布了一个观点";
                    }else if (self.dymodel.type.integerValue == 1) {
                        count = self.dymodel.content;
                    }else if (self.dymodel.type.integerValue == 2) {
                        if (self.dymodel.content.length > 0) {
                            count = self.dymodel.content;
                        }else{
                            NSArray *imageArray = [self.dymodel.image componentsSeparatedByString:@","];
                            count = [NSString stringWithFormat:@"分享了%ld张图片",imageArray.count];
                        }
                    }
                }
                
                NSString *url = self.dymodel.parent_user_image;
                NSString *strTitle = @"的金脉动态";
                NSString *realname = self.dymodel.parent_user_realname;
                if (self.dymodel.parent_user_realname.length == 0) {
                    if (self.dymodel.type.integerValue == 5 || self.dymodel.exttype.integerValue == 5 ) {
                        realname = self.dymodel.userModel.user_realname;
                        url = self.dymodel.userModel.user_image;
                        count = @"分享了一篇文章";
                    }else if (self.dymodel.type.integerValue == 4 || self.dymodel.exttype.integerValue == 4 ) {
                        realname = self.dymodel.userModel.user_realname;
                        url = self.dymodel.userModel.user_image;
                        count = @"分享了一个活动";
                    }
                }
                NSNumber *dynamicId = [CommonMethod paramNumberIsNull:self.dymodel.dynamic_id];
                if(self.dymodel.type.integerValue == 17){
                    realname = self.dymodel.userModel.user_realname;
                    count = self.dymodel.title;
                    url = self.dymodel.userModel.user_image;
                    strTitle = @"的供需推荐";
                }else if(self.dymodel.type.integerValue == 13 && self.dymodel.exttype.integerValue == 17){
                    realname = self.dymodel.parent_review_user_realname;
                    count = self.dymodel.parent_title;
                    url = self.dymodel.parent_review_user_image;
                    strTitle = @"的供需推荐";
                    dynamicId = [CommonMethod paramNumberIsNull:self.dymodel.parent];
                }
                
                NSString * title = [NSString stringWithFormat:@"%@%@",realname,strTitle];
                NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:@"dynamic",@"money_type_special",title,@"title",dynamicId,@"dynamicid",url,@"imageUrl",count,@"count",realname,@"realname", nil];
                EMMessage *message;
                if (self.messageModel.messageType == EMChatTypeGroupChat) {
                    message = [EaseSDKHelper sendTextMessage:title to:conversationId messageType:EMChatTypeGroupChat messageExt:dic];
                }else{
                   message = [EaseSDKHelper sendTextMessage:title to:conversationId messageType:EMChatTypeChat messageExt:dic];
                }

        
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
            }];
        }else if(self.useModel){
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"确定发送给：" message:nameStr cancelButtonTitle:@"取消" otherButtonTitle:@"发送" cancle:^{
            } confirm:^{
                NSString * title;
                if (self.useModel.sex.integerValue == 1) {
                    title =@"话题推荐               ";
                }else{
                    title =@"专栏推荐               ";
                }
                if (self.useModel.realname.length == 0) {
                    self.useModel.realname = @"[图片]";
                }
                NSDictionary *dic =  [[NSDictionary alloc]initWithObjectsAndKeys:@"activityOrinformation",@"money_type_special",self.useModel.realname,@"title", title,@"count",[CommonMethod paramNumberIsNull:self.useModel.userId],@"activityId",self.useModel.sex,@"type", nil];
                EMMessage *message;
                if (self.messageModel.messageType == EMChatTypeGroupChat) {
                  message = [EaseSDKHelper sendTextMessage:title to:conversationId messageType:EMChatTypeGroupChat messageExt:dic];
                }else{
                    message = [EaseSDKHelper sendTextMessage:title to:conversationId messageType:EMChatTypeChat messageExt:dic];
                }

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
            }];
        }else if(self.cardModel){
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"确定发送给：" message:nameStr cancelButtonTitle:@"取消" otherButtonTitle:@"发送" cancle:^{
            } confirm:^{
                NSString * title = [NSString stringWithFormat:@"%@的名片，请惠存", self.cardModel.name];
                NSMutableString *companyPosition = [NSMutableString string];
                if(self.cardModel.company.count){
                    [companyPosition appendString:self.cardModel.company.firstObject];
                    [companyPosition appendString:@" "];
                }
                if(self.cardModel.position.count){
                    [companyPosition appendString:self.cardModel.position.firstObject];
                }
                if(companyPosition.length==0){
                    [companyPosition appendFormat:@"公司 职位"];
                }
                NSDictionary *dic =  [[NSDictionary alloc]initWithObjectsAndKeys:@"scanCardInformation",@"money_type_special",title,@"title",[CommonMethod paramNumberIsNull:self.cardModel.cardId],@"cardId",self.cardModel.imgurl,@"imageUrl",companyPosition,@"companyPosition", nil];
                
                EMMessage *message;
                if (self.messageModel.messageType == EMChatTypeGroupChat) {
                    message = [EaseSDKHelper sendTextMessage:title to:conversationId messageType:EMChatTypeGroupChat messageExt:dic];
                }else{
                   message = [EaseSDKHelper sendTextMessage:title to:conversationId messageType:EMChatTypeChat messageExt:dic];
                }
                
            
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
            }];
        }else{
            if(self.isSendCard) {
                [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"确定发送给：" message:nameStr cancelButtonTitle:@"取消" otherButtonTitle:@"发送" cancle:^{
                } confirm:^{
                    NSDictionary *dic =  [[NSDictionary alloc]initWithObjectsAndKeys:@"rand",@"money_type_special",self.userID,@"userID",self.position,@"positionStr",self.nameCatergoryStr,@"name",self.gooAtStr,@"gooAtStr",self.imagUrl,@"imagUrl", nil];
                    EMMessage *message;
                    if (self.messageModel.messageType == EMChatTypeGroupChat) {
                       message = [EaseSDKHelper sendTextMessage:@"向您分享一张名片!         " to:conversationId messageType:EMChatTypeGroupChat messageExt:dic];;
                    }else{
                       message = [EaseSDKHelper sendTextMessage:@"向您分享一张名片!         " to:conversationId messageType:EMChatTypeChat messageExt:dic];
                    }

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
                }];
            }
        }
    }
}
#pragma mark -UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

#pragma mark -- SearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(searchBar.text.length == 0){
        self.showListArray = [self.recentListArray mutableCopy];
        [self.tableView reloadData];
    }else{
        [self.showListArray removeAllObjects];
        for(int i=0; i<self.recentListArray.count; i++){
            NSString *nameStr = @"";
            if([self.recentListArray[i] isKindOfClass:[ChartModel class]]){
                ChartModel *model = self.recentListArray[i];
                nameStr = model.realname;
            }else{
                EMGroup *group = self.recentListArray[i];
                nameStr = group.subject;
            }
            if([nameStr containsString:searchText]){
                [self.showListArray addObject:self.recentListArray[i]];
            }
        }
        [self.tableView reloadData];
    }
}
@end
