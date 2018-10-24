//
//  ApplySettingViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ApplySettingViewController.h"
#import "ApplySettingCell.h"
#import "DatePikerView.h"

@interface ApplySettingViewController ()

@end

@implementation ApplySettingViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self removeViewTapGesture];
    if(self.ticketsArray==nil){
        self.ticketsArray = [NSMutableArray array];
    }
    [self createCustomNavigationBar:@"报名设置"];
    
    UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    finishBtn.frame = CGRectMake(WIDTH-64, 20, 64, 44);
    [finishBtn setTitle:@"确定" forState:UIControlStateNormal];
    [finishBtn setTitleColor:HEX_COLOR(@"e24943") forState:UIControlStateNormal];
    finishBtn.titleLabel.font = FONT_SYSTEM_SIZE(16);
    [finishBtn addTarget:self action:@selector(finishButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finishBtn];
    
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 69)];
    headerView.backgroundColor = kTableViewBgColor;
    UILabel *label = [UILabel createrLabelframe:CGRectMake(16, 12, WIDTH-32, 45) backColor:kTableViewBgColor textColor:HEX_COLOR(@"41464e") test:@"您可以通过电话或APP获得报名用户信息\n门票在线购买功能暂不开放" font:14 number:2 nstextLocat:NSTextAlignmentLeft];
    [label setParagraphText:@"您可以通过电话或APP获得报名用户信息\n门票在线购买功能暂不开放" lineSpace:6];
    [headerView addSubview:label];
    self.tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 296)];
    footerView.backgroundColor = kTableViewBgColor;
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(62, 21, WIDTH-124, 40);
    [addBtn setBackgroundColor:HEX_COLOR(@"1abc9c")];
    [addBtn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
    [addBtn setTitle:@"+ 添加门票" forState:UIControlStateNormal];
    addBtn.titleLabel.font = FONT_SYSTEM_SIZE(17);
    addBtn.layer.masksToBounds = YES;
    addBtn.layer.cornerRadius = 5;
    [addBtn addTarget:self action:@selector(addTicketButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:addBtn];
    UILabel *hudLabel = [UILabel createrLabelframe:CGRectMake((WIDTH-300)/2, 73, 300, 14) backColor:kTableViewBgColor textColor:HEX_COLOR(@"41464e") test:@"活动门票：不设置门票默认为免费活动、名额不限制" font:12 number:1 nstextLocat:NSTextAlignmentCenter];
    [footerView addSubview:hudLabel];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"活动门票：不设置门票默认为免费活动、名额不限制"];
    [attr addAttributes:@{NSForegroundColorAttributeName:KTextColor} range:NSMakeRange(0, 5)];
    hudLabel.attributedText = attr;
    self.tableView.tableFooterView = footerView;
}

#pragma mark - 按钮方法
- (void)finishButtonClicked:(UIButton*)sender{
    [self.view endEditing:YES];
    if(self.ticketsArray.count){
        NSMutableArray *tmpArray = [NSMutableArray array];
        for(NSMutableDictionary *dict in self.ticketsArray){
            NSString *name = [CommonMethod paramStringIsNull:dict[@"name"]];
            if(name.length==0){
                [self.view showToastMessage:@"门票名称不能为空"];
                return;
            }
            if([tmpArray containsObject:name]){
                [self.view showToastMessage:@"门票名称不能重复"];
                return;
            }else{
                [tmpArray addObject:name];
            }
        }
    }
    if(self.applySetting){
        self.applySetting(self.ticketsArray, self.phone, self.applyendtime);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addTicketButtonClicked:(UIButton*)sender{
    NSMutableDictionary *dict =
    [NSMutableDictionary dictionaryWithDictionary:@{@"name":@"",@"price":@(0),@"seat":@(0),@"remark":@""}];
    [self.ticketsArray addObject:dict];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate/datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0){
        return 2;
    }else{
        return self.ticketsArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        return 49;
    }else{
        return 237;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        static NSString *identify = @"UITableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(16, 14, 75, 21) backColor:WHITE_COLOR textColor:HEX_COLOR(@"afb6c1") test:(indexPath.row==0?@"咨询电话":@"截止时间") font:17 number:1 nstextLocat:NSTextAlignmentLeft];
        [cell.contentView addSubview:titleLabel];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(104, 5, WIDTH-144, 39)];
        textField.textColor = HEX_COLOR(@"41464e");
        textField.font = FONT_SYSTEM_SIZE(17);
        [cell.contentView addSubview:textField];
        if(indexPath.row==0){
            UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 48.5, WIDTH-32, 0.5)];
            lineLabel.backgroundColor = kCellLineColor;
            [cell.contentView addSubview:lineLabel];
            textField.frame = CGRectMake(104, 5, WIDTH-120, 39);
            textField.placeholder = @"如有分机请使用#隔开（选填）";
            textField.keyboardType = UIKeyboardTypePhonePad;
            textField.text = [CommonMethod paramStringIsNull:self.phone];
            __weak typeof(self) weakSelf = self;
            [textField.rac_textSignal subscribeNext:^(NSString *text) {
                if(text.length>20){
                    textField.text = [text substringToIndex:20];
                }
                weakSelf.phone = text;
            }];
        }else{
            textField.enabled = NO;
            textField.placeholder = @"不填默认为活动开始";
            textField.text = self.applyendtime;
            UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-30, 16, 14, 15)];
            iconImageView.contentMode = UIViewContentModeScaleAspectFit;
            iconImageView.image = kImageWithName(@"icon_calendar_c");
            [cell.contentView addSubview:iconImageView];
        }
        [textField setValue:HEX_COLOR(@"e6e8eb") forKeyPath:@"_placeholderLabel.textColor"];
        return cell;
    }else{
        static NSString *identify = @"ApplySettingCell";
        ApplySettingCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [CommonMethod getViewFromNib:@"ApplySettingCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.tag = indexPath.row;
        __weak typeof(self) weakSelf = self;
        cell.ticketParamEdit = ^(NSMutableDictionary *dictChange, ApplySettingCell *delCell){
            weakSelf.ticketsArray[delCell.tag] = dictChange;
        };
        cell.deleteTicket = ^(ApplySettingCell *delCell){
            [weakSelf.ticketsArray removeObjectAtIndex:delCell.tag];
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:delCell.tag inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
            [weakSelf.tableView endUpdates];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
        };
        NSMutableDictionary *dict = self.ticketsArray[indexPath.row];
        [cell updateDisply:dict];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    if(indexPath.section==0&&indexPath.row==1){
        DatePikerView *view = [CommonMethod getViewFromNib:NSStringFromClass([DatePikerView class])];
        view.type = kDatePikerViewTypeSecond;
        view.sceneType = SceneType_Activity;
        view.clearBtn.hidden = NO;
        view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        if([CommonMethod paramStringIsNull:self.applyendtime].length){
            [view updateSelectRow:[NSDate dateFromString:self.applyendtime format:kTimeFormat1]];
        }else{
            [view updateSelectRow:[NSDate date]];
        }
        [view updateSelectRow:[NSDate date]];
        view.pickerSelectBlock = ^(id param, NSString *value){
            if(value.length && [NSDate secondsAwayFrom:[NSDate dateFromString:value format:kTimeFormat1] dateSecond:[NSDate date]]<=0){
                [self.view showToastMessage:@"截止时间必须大于当前时间"];
                return;
            }
            if(value.length && self.endtime.length && [NSDate secondsAwayFrom:[NSDate dateFromString:self.endtime format:kTimeFormat1] dateSecond:[NSDate dateFromString:value format:kTimeFormat1]]<=0){
                [self.view showToastMessage:@"截止时间必小于结束时间"];
                return;
            }
            self.applyendtime = value;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        };
        [[UIApplication sharedApplication].keyWindow addSubview:view];
        [view showShareNormalView];
    }
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
    [self.view endEditing:YES];
}


@end
