//
//  BaseViewController.h
//  EnterpriseCommunication
//
//  Created by HuMengChi on 15/6/2.
//  Copyright (c) 2015年 hmc. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^AttentionBtnActionSuccess) ();
@interface BaseViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIViewController *rootTmpViewController;
@property (nonatomic, strong) AttentionBtnActionSuccess attentionBtnActionSuccess;

- (void)initTableView:(CGRect)frame;
- (void)initGroupedTableView:(CGRect)frame;
- (void)initSearchBar:(CGRect)frame;
- (void)initScrollView:(CGRect)rect;

- (void)showMessageView:(NSArray *)phones title:(NSString *)title;

#pragma mark - 自定义导航栏（白底）
- (UILabel*)createCustomNavigationBar:(NSString*)title;
- (void)customNavBackButtonClicked;

#pragma mark ------ 关注(取消)他
- (void)attentionBtnAction:(NSString*)useID other:(NSString *)otherID type:(BOOL)type;

- (void)setNavigationBar_white;
- (void)setNavigationBar_kdefaultColor;

#pragma mark - 群组成员信息
- (void)updateAllGroupUsersDB;
- (void)updateGroupUsersDB:(EMGroup*)group occupants:(NSArray*)occupants handler:(void(^)(BOOL result, NSMutableArray *dataArray))handler;

@end
