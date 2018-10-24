//
//  GuestSettingViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "GuestSettingViewController.h"
#import "GuestSettingCell.h"

@interface GuestSettingViewController ()

@end

@implementation GuestSettingViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self removeViewTapGesture];
    if(self.guestsArray==nil || self.guestsArray.count==0){
        self.guestsArray = [NSMutableArray array];
        NSMutableDictionary *dict =
        [NSMutableDictionary dictionaryWithDictionary:@{@"name":@"",@"image":@"",@"intro":@""}];
        [self.guestsArray addObject:dict];
    }
    [self createCustomNavigationBar:@"活动嘉宾"];
    UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    finishBtn.frame = CGRectMake(WIDTH-64, 20, 64, 44);
    [finishBtn setTitle:@"确定" forState:UIControlStateNormal];
    [finishBtn setTitleColor:HEX_COLOR(@"e24943") forState:UIControlStateNormal];
    finishBtn.titleLabel.font = FONT_SYSTEM_SIZE(16);
    [finishBtn addTarget:self action:@selector(finishButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finishBtn];
    
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 190)];
    footerView.backgroundColor = kTableViewBgColor;
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(62, 16, WIDTH-124, 40);
    [addBtn setBackgroundColor:HEX_COLOR(@"1abc9c")];
    [addBtn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
    [addBtn setTitle:@"+ 添加嘉宾" forState:UIControlStateNormal];
    addBtn.titleLabel.font = FONT_SYSTEM_SIZE(17);
    addBtn.layer.masksToBounds = YES;
    addBtn.layer.cornerRadius = 5;
    [addBtn addTarget:self action:@selector(addTicketButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:addBtn];
    self.tableView.tableFooterView = footerView;
}

#pragma mark - 按钮方法
- (void)finishButtonClicked:(UIButton*)sender{
    [self.view endEditing:YES];
    if(self.guestsArray.count){
        for(NSMutableDictionary *dict in self.guestsArray){
            if([CommonMethod paramStringIsNull:dict[@"name"]].length==0){
                [self.view showToastMessage:@"请输入嘉宾姓名"];
                return;
            }else if([CommonMethod paramStringIsNull:dict[@"intro"]].length==0){
                [self.view showToastMessage:@"请输入嘉宾介绍"];
                return;
            }else if([CommonMethod paramStringIsNull:dict[@"intro"]].length<10){
                [self.view showToastMessage:@"嘉宾介绍不能少于10个字"];
                return;
            }
        }
    }
    if(self.guestSetting){
        self.guestSetting(self.guestsArray);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addTicketButtonClicked:(UIButton*)sender{
    NSMutableDictionary *dict =
    [NSMutableDictionary dictionaryWithDictionary:@{@"name":@"",@"image":@"",@"intro":@""}];
    [self.guestsArray addObject:dict];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate/datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.guestsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 169;//190;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"GuestSettingCell";
    GuestSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [CommonMethod getViewFromNib:@"GuestSettingCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.tag = indexPath.row;
    __weak typeof(self) weakSelf = self;
    cell.guestParamEdit = ^(NSMutableDictionary *dictChange, GuestSettingCell *changeCell){
        weakSelf.guestsArray[changeCell.tag] = dictChange;
    };
    if(indexPath.row == self.guestsArray.count-1){
        cell.lineLabel.hidden = YES;
    }else{
        cell.lineLabel.hidden = NO;
    }
    cell.deleteGuest = ^(GuestSettingCell *delCell){
        [weakSelf.guestsArray removeObjectAtIndex:delCell.tag];
        [weakSelf.tableView beginUpdates];
        [weakSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:delCell.tag inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [weakSelf.tableView endUpdates];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    };
    NSMutableDictionary *dict = self.guestsArray[indexPath.row];
    [cell updateDisply:dict];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}

#pragma mark - Keyboard status
- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardEnd.size.height;
    [UIView animateWithDuration:duration animations:^{
        if([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
            self.tableView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64-keyboardHeight);
        }else{
            self.tableView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64);
        }
    }];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    [self.view endEditing:YES];
}

@end
