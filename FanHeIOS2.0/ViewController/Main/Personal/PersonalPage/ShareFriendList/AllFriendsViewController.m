//
//  AllFriendsViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/18.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "AllFriendsViewController.h"
#import "FriendTableViewCell.h"
#import "NoFriendTableViewCell.h"
#import "ChatViewController.h"

@interface AllFriendsViewController (){
    BOOL _handScrollView;//手动滑动
}

@property (nonatomic, strong) NSMutableArray    *friendsListArray;

@end

@implementation AllFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.isDynamicAt){
        [self createCustomNavigationBar:@"选择@的好友"];
    }else{
        [self createCustomNavigationBar:@"好友列表"];
    }
    
    [self initTableView:CGRectMake(0, 108, WIDTH, HEIGHT-108)];
    self.tableView.backgroundColor = kBackgroundColorDefault;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self initSearchBar:CGRectMake(0, 64, WIDTH, 44)];
    self.searchBar.showsCancelButton = NO;
    [self.searchBar setPlaceholder:@"搜索姓名、公司、职位"];
    [self loadfriendsListArrayData];
    
    //右检索背景颜色
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    //右检索字体颜色
    self.tableView.sectionIndexColor = [UIColor colorWithHexString:@"41464E"];
}

- (void)customNavBackButtonClicked{
    if (self.messageModel) {
        UIViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
        [self.navigationController popToViewController:vc animated:YES];
        
    }else if (self.nameCatergoryStr){
        UIViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
        [self.navigationController popToViewController:vc animated:YES];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mafrk ------ 好友
- (void)loadfriendsListArrayData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@", [DataModelInstance shareInstance].userModel.userId] forKey:@"param"];
    
    [self requstType:RequestType_Get apiName:API_NAME_USER_GET_ALLFRIENDS paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *tmpArray = [CommonMethod paramArrayIsNull:[responseObject objectForKey:@"data"]];
            NSMutableArray *dataArray = [NSMutableArray array];
            for(NSDictionary *dict in tmpArray){
                ChartModel *model = [[ChartModel alloc] initWithDict:dict];
                [dataArray addObject:model];
            }
            if(dataArray.count == 0){
                dataArray = [[DBInstance shareInstance] getAllChartsModel];
            }else{
                [[DBInstance shareInstance] saveChartModelArray:dataArray];
            }
            [weakSelf sort:dataArray];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [weakSelf sort:[[DBInstance shareInstance] getAllChartsModel]];
    }];
}

#pragma mafrk ------ 搜索好友
- (void)loadSearchFriendsListArrayData{
    [self.friendsListArray removeAllObjects];
    [self sort:[[DBInstance shareInstance] getAllChartsModelBySearch:self.searchBar.text]];
}

//排序
- (void)sort:(NSMutableArray*)array{
    if(self.friendsListArray == nil){
        self.friendsListArray = [NSMutableArray array];
    }else{
        [self.friendsListArray removeAllObjects];
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

- (void)filter:(NSString*)str array:(NSMutableArray*)array{
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
        [self.friendsListArray addObject:@{str:tempArray}];
    }
}

#pragma mark - UITableViewDelegate/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.friendsListArray){
        if(self.friendsListArray.count){
            return self.friendsListArray.count;
        }else{
            return 1;
        }
    }else{
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.friendsListArray.count){
        NSDictionary *dict = self.friendsListArray[section];
        NSArray *array = dict[dict.allKeys[0]];
        return [array count];
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.friendsListArray.count){
        return 32;
    }else{
        return 0.00001;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(self.friendsListArray.count){
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 32)];
        headerView.backgroundColor = kTableViewBgColor;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, WIDTH-16, 32)];
        label.textColor = HEX_COLOR(@"818C9E");
        label.font = FONT_SYSTEM_SIZE(14);
        [headerView addSubview:label];
        NSDictionary *dic = self.friendsListArray[section];
        label.text = dic.allKeys[0];
        
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
        label2.backgroundColor = kCellLineColor;
        [headerView addSubview:label2];
        
        UILabel *label3 = [[UILabel alloc]initWithFrame:CGRectMake(0, 31.5, WIDTH, 0.5)];
        label3.backgroundColor = kCellLineColor;
        [headerView addSubview:label3];
        
        return headerView;
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.friendsListArray.count){
        return 52;
    }else{
        return self.tableView.frame.size.height;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.friendsListArray.count){
        static NSString *identify = @"FriendTableViewCell";
        FriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"FriendTableViewCell"];
        }
        NSDictionary *dict = self.friendsListArray[indexPath.section];
        NSMutableArray *array = dict[dict.allKeys[0]];
        ChartModel *model = array[indexPath.row];
        [cell updateDisplay:model];
        return cell;
    }else{
        static NSString *identify = @"NoFriendTableViewCell";
        NoFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"NoFriendTableViewCell"];
        }
        if(self.searchBar.text.length){
            [cell updateDisplay:NO isSearch:YES];
        }else{
            [cell updateDisplay:NO isSearch:NO];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.friendsListArray.count){
        NSDictionary *dict = self.friendsListArray[indexPath.section];
        NSMutableArray *array = dict[dict.allKeys[0]];
        ChartModel *model = array[indexPath.row];
        if(self.isInviteCommend){
            __weak typeof(self) weakSelf = self;
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:
             [NSString stringWithFormat:@"确定邀请%@来点评您吗？", model.realname] cancelButtonTitle:@"否" otherButtonTitle:@"是" cancle:^{
             } confirm:^{
                 __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"发送中..." toView:self.view];
                 NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
                 [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
                 [requestDict setObject:model.userid forKey:@"otherid"];
                 [self requstType:RequestType_Post apiName:API_NAME_POST_USER_GETSMBEV paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
                     [hud hideAnimated:YES];
                     if([CommonMethod isHttpResponseSuccess:responseObject]){
                         [MBProgressHUD showSuccess:@"发送成功" toView:weakSelf.view];
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             UIViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
                             [self.navigationController popToViewController:vc animated:YES];
                         });
                     }else{
                         [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
                     }
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
                     [hud hideAnimated:YES];
                     [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
                 }];
             }];
        }else if(self.isDynamicAt){
            if(self.dynamicAtUser){
                self.dynamicAtUser(model);
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else if(self.messageModel) {
            self.tableView.userInteractionEnabled = NO;
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"确定发给：" message:model.realname cancelButtonTitle:@"否" otherButtonTitle:@"是" cancle:^{
                
            } confirm:^{
                if (self.messageModel.bodyType == EMMessageBodyTypeText) {
                    
                    
                    EMMessage *message;
                    if (self.messageModel.messageType == EMChatTypeGroupChat) {
                      message = [EaseSDKHelper sendTextMessage:self.messageModel.text to:model.userid.stringValue messageType:EMChatTypeGroupChat messageExt:self.messageModel.message.ext];
                        message.chatType = EMChatTypeGroupChat;
                        
                    }else{
                       message = [EaseSDKHelper sendTextMessage:self.messageModel.text to:model.userid.stringValue messageType:EMChatTypeChat messageExt:self.messageModel.message.ext];
                        message.chatType = EMChatTypeChat;
                    }

                    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
                        if (!aError) {
                            [MBProgressHUD showSuccess:@"发送成功" toView:self.view];
                            self.tableView.userInteractionEnabled = YES;
                            
                        }else{
                            [MBProgressHUD showError:@"发送失败" toView:self.view];
                        }
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            UIViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
                            [self.navigationController popToViewController:vc animated:YES];
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
                        message= [EaseSDKHelper sendImageMessageWithImage:image to:model.userid.stringValue messageType:EMChatTypeGroupChat requireEncryption:YES messageExt:self.messageModel.message.ext progress:nil];
                          message.chatType = EMChatTypeGroupChat;
                        
                    }else{
                       message= [EaseSDKHelper sendImageMessageWithImage:image to:model.userid.stringValue messageType:EMChatTypeChat requireEncryption:YES messageExt:self.messageModel.message.ext progress:nil];
                          message.chatType = EMChatTypeChat;
                    }
                    

                    
                    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError){
                        if (!aError) {
                            [MBProgressHUD showSuccess:@"发送成功" toView:self.view];
                            self.tableView.userInteractionEnabled = YES;
                            
                        }else{
                            [MBProgressHUD showError:@"发送失败" toView:self.view];
                        }
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            UIViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
                            [self.navigationController popToViewController:vc animated:YES];
                        });
                    }];
                }
                else if (self.messageModel.bodyType == EMMessageBodyTypeLocation) {
                    EMMessage *message;
                    if (self.messageModel.messageType == EMChatTypeGroupChat) {
                         message= [EaseSDKHelper sendLocationMessageWithLatitude:self.messageModel.latitude longitude:self.messageModel.longitude address:self.messageModel.address to:model.userid.stringValue messageType:EMChatTypeGroupChat requireEncryption:YES messageExt:self.messageModel.message.ext];
                         message.chatType = EMChatTypeGroupChat;
                        
                    }else{
                       message= [EaseSDKHelper sendLocationMessageWithLatitude:self.messageModel.latitude longitude:self.messageModel.longitude address:self.messageModel.address to:model.userid.stringValue messageType:EMChatTypeChat requireEncryption:YES messageExt:self.messageModel.message.ext];
                         message.chatType = EMChatTypeChat;
                    }

                
                    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError){
                        if (!aError) {
                            [MBProgressHUD showSuccess:@"发送成功" toView:self.view];
                            self.tableView.userInteractionEnabled = YES;
                            
                        }else{
                            [MBProgressHUD showError:@"发送失败" toView:self.view];
                        }
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            UIViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
                            [self.navigationController popToViewController:vc animated:YES];
                        });
                    }];
                }}];
        }else if(self.actModel){
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"确定发送给：" message:model.realname cancelButtonTitle:@"取消" otherButtonTitle:@"发送" cancle:^{
            } confirm:^{
                
                NSString *startTime = [NSDate stringFromDate:[NSDate dateFromString:[CommonMethod paramStringIsNull:self.actModel.starttime] format:kTimeFormat1] format:@"MM-dd HH:mm"];
                NSString *endTime = [NSDate stringFromDate:[NSDate dateFromString:[CommonMethod paramStringIsNull:self.actModel.endtime] format:kTimeFormat1] format:@"MM-dd HH:mm"];
                NSDictionary *dic =  [[NSDictionary alloc]initWithObjectsAndKeys:@"activity",@"money_type_special", [CommonMethod paramNumberIsNull:self.actModel.activityid],@"activityid", [NSString stringWithFormat:@"%@%@ %@",[CommonMethod paramStringIsNull:self.actModel.cityname],[CommonMethod paramStringIsNull:self.actModel.districtname],[CommonMethod paramStringIsNull:self.actModel.address]],@"address", [CommonMethod paramStringIsNull:self.actModel.name],@"name",self.actModel.timestr,@"starttime", [CommonMethod paramStringIsNull:endTime],@"endtime", nil];
                EMMessage *message;
                if (self.messageModel.messageType == EMChatTypeGroupChat) {
                   message = [EaseSDKHelper sendTextMessage:@"邀请你参加活动：               " to:model.userid.stringValue messageType:EMChatTypeGroupChat messageExt:dic];
                       message.chatType = EMChatTypeGroupChat;
                    
                }else{
                   message = [EaseSDKHelper sendTextMessage:@"邀请你参加活动：               " to:model.userid.stringValue messageType:EMChatTypeChat messageExt:dic];
                       message.chatType = EMChatTypeChat;
                }

        
                [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
                    if (!aError) {
                        [MBProgressHUD showSuccess:@"发送成功" toView:self.view];
                        self.tableView.userInteractionEnabled = YES;
                    }else{
                        [MBProgressHUD showError:@"发送失败" toView:self.view];
                    }
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        UIViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
                        [self.navigationController popToViewController:vc animated:YES];
                    });
                }];
            }];
        }else if(self.dymodel && self.isViewPoint == YES){
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"确定发送给：" message:model.realname cancelButtonTitle:@"取消" otherButtonTitle:@"发送" cancle:^{
            } confirm:^{
                NSString *strTitle = [NSString stringWithFormat:@"%@的观点",self.dymodel.userModel.user_realname];
                NSString *realname   =  self.dymodel.userModel.user_realname;
                
                NSDictionary *dic =  [[NSDictionary alloc]initWithObjectsAndKeys:@"viewPoint",@"money_type_special",strTitle,@"title", [CommonMethod paramNumberIsNull:self.dymodel.parent_subject_id],@"dynamicid",self.dymodel.userModel.user_image,@"imageUrl", self.dymodel.content,@"count",realname,@"realname", nil];
                
                EMMessage *message;
                if (self.messageModel.messageType == EMChatTypeGroupChat) {
                   message = [EaseSDKHelper sendTextMessage:strTitle to:model.userid.stringValue messageType:EMChatTypeGroupChat messageExt:dic];
                    message.chatType = EMChatTypeGroupChat;
                    
                }else{
                    message = [EaseSDKHelper sendTextMessage:strTitle to:model.userid.stringValue messageType:EMChatTypeChat messageExt:dic];
                    message.chatType = EMChatTypeChat;

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
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"确定发送给：" message:model.realname cancelButtonTitle:@"取消" otherButtonTitle:@"发送" cancle:^{
            } confirm:^{
                NSString *count;
                if (self.dymodel.type.integerValue == 13) {
                    if (self.dymodel.exttype.integerValue == 3 ||self.dymodel.exttype.integerValue == 8) {
                        count = @"发起了一个话题";
                    }
                    if (self.dymodel.exttype.integerValue == 4 ||self.dymodel.exttype.integerValue == 9) {
                        count = @"发布了一个活动";
                    }
                    if (self.dymodel.exttype.integerValue == 5 ||self.dymodel.exttype.integerValue == 10) {
                        count = @"发布了一篇文章";
                        
                    }
                    if ( self.dymodel.type.integerValue == 6 ||self.dymodel.type.integerValue == 11) {
                        count =  @"发布了一个观点";
                    }
                    if (self.dymodel.exttype.integerValue == 7 ||self.dymodel.exttype.integerValue == 12 ) {
                        count =  @"发表了一个评论";
                        
                    }
                    if (self.dymodel.exttype.integerValue == 1) {
                        //村文本
                        count = self.dymodel.parent_content;
                    }
                    if (self.dymodel.exttype.integerValue == 2) {
                        //村文本
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
                    }
                    if (self.dymodel.type.integerValue == 4 ||self.dymodel.type.integerValue == 9) {
                        count = @"发布了一个活动";
                    }
                    if (self.dymodel.type.integerValue == 5 ||self.dymodel.type.integerValue == 10) {
                        count = @"发布了一篇文章";
                        
                    }
                    
                    if (self.dymodel.type.integerValue == 7 ||self.dymodel.type.integerValue == 12 ) {
                        count =  @"发表了一个评论";
                        
                    }
                    if ( self.dymodel.type.integerValue == 6 ||self.dymodel.type.integerValue == 11) {
                        count =  @"发布了一个观点";
                    }
                    if (self.dymodel.type.integerValue == 1) {
                        //村文本
                        count = self.dymodel.content;
                    }
                    if (self.dymodel.type.integerValue == 2) {
                        //村文本
                        if (self.dymodel.content.length > 0) {
                            count = self.dymodel.content;
                            
                        }else{
                            NSArray *imageArray = [self.dymodel.image componentsSeparatedByString:@","];
                            count = [NSString stringWithFormat:@"分享了%ld张图片",imageArray.count];
                        }
                    }
                }
                
                NSString *url = self.dymodel.parent_user_image;
                NSString *strTitle =@"的金脉动态";
                NSString *realname   =  self.dymodel.parent_user_realname;
                if (self.dymodel.parent_user_realname.length == 0) {
                    if (self.dymodel.type.integerValue == 5 || self.dymodel.exttype.integerValue == 5 ) {
                        realname = self.dymodel.userModel.user_realname;
                        url = self.dymodel.userModel.user_image;
                        count = @"分享了一篇文章";
                    }
                    if (self.dymodel.type.integerValue == 4 || self.dymodel.exttype.integerValue == 4 ) {
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
                NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:@"dynamic",@"money_type_special",title,@"title", dynamicId,@"dynamicid",url,@"imageUrl",count,@"count",realname,@"realname", nil];
                
                EMMessage *message;
                if (self.messageModel.messageType == EMChatTypeGroupChat) {
                    message = [EaseSDKHelper sendTextMessage:title to:model.userid.stringValue messageType:EMChatTypeGroupChat messageExt:dic];
                    message.chatType = EMChatTypeGroupChat;
                   
                }else{
                   message = [EaseSDKHelper sendTextMessage:title to:model.userid.stringValue messageType:EMChatTypeChat messageExt:dic];
                    message.chatType = EMChatTypeChat;
                }
                
                [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
                    if (!aError) {
                        [MBProgressHUD showSuccess:@"发送成功" toView:self.view];
                        self.tableView.userInteractionEnabled = YES;
                    }else{
                        [MBProgressHUD showError:@"发送失败" toView:self.view];
                    }
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        UIViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
                        [self.navigationController popToViewController:vc animated:YES];
                    });
                }];
            }];
        }else if(self.useModel){
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"确定发送给：" message:model.realname cancelButtonTitle:@"取消" otherButtonTitle:@"发送" cancle:^{
            } confirm:^{
                
                NSString * title;
                if (self.useModel.sex.integerValue == 1) {
                    title =@"话题推荐                    ";
                }else{
                    title =@"专栏推荐                    ";
                }
                if (self.useModel.realname.length == 0) {
                    self.useModel.realname = @"[图片]";
                }
                NSDictionary *dic =  [[NSDictionary alloc] initWithObjectsAndKeys:@"activityOrinformation",@"money_type_special",self.useModel.realname,@"title", title,@"count",[CommonMethod paramNumberIsNull:self.useModel.userId],@"activityId",self.useModel.sex,@"type", nil];
                EMMessage *message;
                if (self.messageModel.messageType == EMChatTypeGroupChat) {
                    message = [EaseSDKHelper sendTextMessage:title to:model.userid.stringValue messageType:EMChatTypeGroupChat messageExt:dic];
                     message.chatType = EMChatTypeGroupChat;
                }else{
                    message = [EaseSDKHelper sendTextMessage:title to:model.userid.stringValue messageType:EMChatTypeChat messageExt:dic];
                     message.chatType = EMChatTypeChat;
                }
                [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
                    if (!aError) {
                        [MBProgressHUD showSuccess:@"发送成功" toView:self.view];
                        self.tableView.userInteractionEnabled = YES;
                    }else{
                        [MBProgressHUD showError:@"发送失败" toView:self.view];
                    }
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        UIViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
                        [self.navigationController popToViewController:vc animated:YES];
                    });
                }];
            }];
        }else if(self.cardModel){
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"确定发送给：" message:model.realname cancelButtonTitle:@"取消" otherButtonTitle:@"发送" cancle:^{
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
                    message = [EaseSDKHelper sendTextMessage:title to:model.userid.stringValue messageType:EMChatTypeGroupChat messageExt:dic];
                      message.chatType = EMChatTypeGroupChat;
                }else{
                    message = [EaseSDKHelper sendTextMessage:title to:model.userid.stringValue messageType:EMChatTypeChat messageExt:dic];
                      message.chatType = EMChatTypeChat;
                }
              
                [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
                    if (!aError) {
                        [MBProgressHUD showSuccess:@"发送成功" toView:self.view];
                        self.tableView.userInteractionEnabled = YES;
                    }else{
                        [MBProgressHUD showError:@"发送失败" toView:self.view];
                    }
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        UIViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
                        [self.navigationController popToViewController:vc animated:YES];
                    });
                }];
            }];
        }else{
            if (self.isSendCard) {
                [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"确定发送给：" message:model.realname cancelButtonTitle:@"取消" otherButtonTitle:@"发送" cancle:^{
                } confirm:^{
                    NSDictionary *dic =  [[NSDictionary alloc]initWithObjectsAndKeys:@"rand",@"money_type_special",self.userID,@"userID",self.position,@"positionStr",self.nameCatergoryStr,@"name",self.gooAtStr,@"gooAtStr",self.imagUrl,@"imagUrl", nil];
                    EMMessage *message;
                    if (self.messageModel.messageType == EMChatTypeGroupChat) {
                       message = [EaseSDKHelper sendTextMessage:@"向您分享一张名片!         " to:model.userid.stringValue messageType:EMChatTypeGroupChat messageExt:dic];
                         message.chatType = EMChatTypeGroupChat;
                    }else{
                       message = [EaseSDKHelper sendTextMessage:@"向您分享一张名片!         " to:model.userid.stringValue messageType:EMChatTypeChat messageExt:dic];
                         message.chatType = EMChatTypeChat;
                    }
                    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
                        if (!aError) {
                            [MBProgressHUD showSuccess:@"发送成功" toView:self.view];
                            self.tableView.userInteractionEnabled = YES;
                        }else{
                            [MBProgressHUD showError:@"发送失败" toView:self.view];
                        }
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            UIViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
                            [self.navigationController popToViewController:vc animated:YES];
                        });
                    }];
                }];
            }
        }
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSMutableArray *newArray = [NSMutableArray array];
    for (NSInteger i = 0 ; i< self.friendsListArray.count; i++) {
        NSDictionary *dic = self.friendsListArray[i];
        [newArray addObject:dic.allKeys[0]];
    }
    return newArray;
}

#pragma mark -- SearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(searchBar.text.length == 0){
        [self loadfriendsListArrayData];
    }else{
        [self loadSearchFriendsListArrayData];
    }
}


@end
