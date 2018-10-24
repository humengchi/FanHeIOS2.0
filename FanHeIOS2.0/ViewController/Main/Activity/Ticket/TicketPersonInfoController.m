//
//  TicketPersonInfoController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/6/8.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "TicketPersonInfoController.h"
#import "TicketPaymentController.h"
#import "ApplySucceedController.h"

@interface TicketPersonInfoController ()<UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) NSMutableArray *paramArray;

@property (nonatomic, weak) IBOutlet UIButton *nextBtn;
@property (nonatomic, weak) IBOutlet UIView *nextView;

@property (nonatomic, strong) NSString *ordernum;
@property (nonatomic, strong) NSString *remark;
@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation TicketPersonInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.remark = @"";
    [self createCustomNavigationBar:@"参会者信息"];
    self.paramArray = [NSMutableArray array];
    for (int i = 0; i<self.ticketNum; i++) {
        NSMutableArray *array = [NSMutableArray array];
        for(InfoFieldModel *model in self.activityModel.infofields){
            InfoFieldModel *tmpModel = [[InfoFieldModel alloc] init];
            [tmpModel copy:model];
            [array addObject:tmpModel];
        }
        [self.paramArray addObject:array];
    }
    [self initGroupedTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64-49)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 55)];
    headerView.backgroundColor = kTableViewBgColor;
    UILabel *label = [UILabel createrLabelframe:CGRectMake(16, 22, WIDTH-32, 17) backColor:kTableViewBgColor textColor:HEX_COLOR(@"41464e") test:@"*请完善参会者信息，完成报名" font:17 number:1 nstextLocat:NSTextAlignmentLeft];
    [headerView addSubview:label];
    self.tableView.tableHeaderView = headerView;
    
    self.nextView.frame = CGRectMake(0, HEIGHT-49, WIDTH, 49);
    [self.view addSubview:self.nextView];
}

#pragma mark - method
- (IBAction)nextButtonClicked:(id)sender{
    for (int i = 0; i < self.paramArray.count; i++) {
        NSMutableArray *tmpArray = self.paramArray[i];
        for (int j = 0; j<tmpArray.count; j++) {
            InfoFieldModel *tmpModel = tmpArray[j];
            if([CommonMethod paramStringIsNull:tmpModel.infovalue].length==0){
                if(self.paramArray.count>1){
                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                    formatter.numberStyle = kCFNumberFormatterRoundHalfDown;
                    NSString *string = [NSString stringWithFormat:@"第%@位", [formatter stringFromNumber:[NSNumber numberWithInt:i+1]]];
                    [self.view showToastMessage:[NSString stringWithFormat:@"请输入%@的%@", string, tmpModel.infoname]];
                }else{
                    [self.view showToastMessage:[NSString stringWithFormat:@"请输入%@", tmpModel.infoname]];
                }
                return;
            }else if([tmpModel.infoname isEqualToString:@"手机号"] && ![NSHelper justMobile:tmpModel.infovalue]){
                if(self.paramArray.count>1){
                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                    formatter.numberStyle = kCFNumberFormatterRoundHalfDown;
                    NSString *string = [NSString stringWithFormat:@"第%@位", [formatter stringFromNumber:[NSNumber numberWithInt:i+1]]];
                    [self.view showToastMessage:[NSString stringWithFormat:@"%@的手机号格式错误", string]];
                }else{
                    [self.view showToastMessage:@"手机号格式错误"];
                }
                return;
            }
        }
    }
    [self loadHttpData];
}

#pragma mark - 网络请求
- (void)loadHttpData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"%@", [DataModelInstance shareInstance].userModel.userId] forKey:@"userid"];
    [requestDict setObject:self.ticketModel.ticktid forKey:@"ticketid"];
    [requestDict setObject:@(self.ticketNum) forKey:@"ticketnum"];
    [requestDict setObject:self.remark forKey:@"remark"];
    NSMutableArray *strArray = [NSMutableArray array];
    for(NSMutableArray *array in self.paramArray){
        NSMutableArray *valueArray = [NSMutableArray array];
        for(InfoFieldModel *model in array){
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:model.infoid forKey:@"infoid"];
            [dict setObject:model.infovalue forKey:@"value"];
            [valueArray addObject:dict];
        }
        [strArray addObject:valueArray];
    }
    NSError *error;
    NSData * data = [NSJSONSerialization dataWithJSONObject:strArray options:NSJSONWritingPrettyPrinted error:&error];
    NSString *valueStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    valueStr = [valueStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    valueStr = [valueStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    [requestDict setObject:valueStr forKey:@"info"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_ACTIVITY_NEW_APPLY paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            weakSelf.ordernum = [CommonMethod paramStringIsNull:[CommonMethod paramDictIsNull:responseObject[@"data"]][@"ordernum"]];
            if(weakSelf.ticketModel.price.floatValue > 0 && weakSelf.activityModel.feetype.integerValue == 1){
                TicketPaymentController *vc = [CommonMethod getVCFromNib:[TicketPaymentController class]];
                vc.activityModel = weakSelf.activityModel;
                vc.ticketModel = weakSelf.ticketModel;
                vc.ticketNum = weakSelf.ticketNum;
                vc.ordernum = weakSelf.ordernum;
                vc.currentDate = [NSDate date];
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }else{
                ApplySucceedController *vc = [CommonMethod getVCFromNib:[ApplySucceedController class]];
                vc.actModel = weakSelf.activityModel;
                vc.needcheck = weakSelf.ticketModel.needcheck;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
        }else{
            [MBProgressHUD showError:responseObject[@"msg"] toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [MBProgressHUD showError:@"网络请求失败，请检查网络设置" toView:weakSelf.view];
    }];
}

#pragma mark - Keyboard status
- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardEnd.size.height;
    [UIView animateWithDuration:duration animations:^{
        if([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
            self.tableView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64-49-keyboardHeight);
            self.nextView.frame = CGRectMake(0, HEIGHT-49-keyboardHeight, WIDTH, 49);
        }else{
            self.tableView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64-49);
            self.nextView.frame = CGRectMake(0, HEIGHT-49, WIDTH, 49);
        }
    }];
}

#pragma mark - UITableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.ticketNum+1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == self.ticketNum) {
        return 1;
    }else{
        return self.activityModel.infofields.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.ticketNum>1 && section != self.ticketNum){
        return 35;
    }else{
        return 0.00001;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == self.ticketNum) {
        return 106;
    }else{
        return 49.0;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(self.ticketNum>1 && section != self.ticketNum){
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 35)];
        headerView.backgroundColor = HEX_COLOR(@"fafafb");
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = kCFNumberFormatterRoundHalfDown;
        NSString *string = [NSString stringWithFormat:@"第%@位", [formatter stringFromNumber:[NSNumber numberWithInt:section+1]]];
        UILabel *label = [UILabel createrLabelframe:CGRectMake(16, 9, WIDTH-32, 17) backColor:HEX_COLOR(@"fafafb") textColor:HEX_COLOR(@"e24943") test:string font:17 number:1 nstextLocat:NSTextAlignmentLeft];
        [headerView addSubview:label];
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [headerView addSubview:lineLabel];
        UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 34.5, WIDTH, 0.5)];
        lineLabel1.backgroundColor = kCellLineColor;
        [headerView addSubview:lineLabel1];
        return headerView;
    }else{
        return nil;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 5)];
    footerView.backgroundColor = kTableViewBgColor;
    return footerView;
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
    if (indexPath.section == self.ticketNum) {
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(11, 0, WIDTH-22, 106)];
        textView.font = FONT_SYSTEM_SIZE(17);
        textView.textColor = HEX_COLOR(@"41464e");
        textView.delegate = self;
        textView.text = self.remark;
        textView.returnKeyType = UIReturnKeyDone;
        [cell.contentView addSubview:textView];
        
        self.placeholderLabel = [UILabel createrLabelframe:CGRectMake(16, 11, WIDTH-32, 17) backColor:[UIColor clearColor] textColor:HEX_COLOR(@"e6e8eb") test:@"留言（选填）" font:17 number:1 nstextLocat:NSTextAlignmentLeft];
        [cell.contentView addSubview:self.placeholderLabel];
        self.placeholderLabel.hidden = self.remark.length>0;
        
        self.numLabel = [UILabel createrLabelframe:CGRectMake(16, 84, WIDTH-32, 12) backColor:WHITE_COLOR textColor:HEX_COLOR(@"afb6c1") test:[NSString stringWithFormat:@"%lu/40", (unsigned long)self.remark.length] font:12 number:1 nstextLocat:NSTextAlignmentRight];
        [cell.contentView addSubview:self.numLabel];
    }else{
        NSMutableArray *array = self.paramArray[indexPath.section];
        InfoFieldModel *model = array[indexPath.row];
        UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(16, 16, 75, 17) backColor:WHITE_COLOR textColor:HEX_COLOR(@"afb6c1") test:model.infoname font:17 number:1 nstextLocat:NSTextAlignmentLeft];
        [cell.contentView addSubview:titleLabel];
        
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(104, 1, WIDTH-104-16, 47)];
        [textField setValue:HEX_COLOR(@"e6e8eb") forKeyPath:@"_placeholderLabel.textColor"];
        textField.placeholder = @"必填";
        textField.tag = indexPath.section*100+indexPath.row;
        textField.delegate = self;
        textField.textColor = HEX_COLOR(@"41464e");
        textField.text = [CommonMethod paramStringIsNull:model.infovalue];
        if([model.infoname isEqualToString:@"手机号"]){
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }
        textField.returnKeyType = UIReturnKeyDone;
        [cell.contentView addSubview:textField];
        
        CGRect frame = CGRectMake(16, 48.5, WIDTH-32, 0.5);
        if(indexPath.row == self.activityModel.infofields.count-1){
            frame = CGRectMake(0, 48.5, WIDTH, 0.5);
        }
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:frame];
        lineLabel.backgroundColor = kCellLineColor;
        [cell.contentView addSubview:lineLabel];
    }
    
    return cell;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    if(position && (range.length==0 || string.length==0)){
        return YES;
    }else{
        NSString *str = [textField.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:string];
        NSMutableArray *array = self.paramArray[textField.tag/100];
        InfoFieldModel *model = array[textField.tag%100];
        model.infovalue = str;
        BOOL infoFinished = YES;
        for (int i = 0; i < self.paramArray.count; i++) {
            NSMutableArray *tmpArray = self.paramArray[i];
            for (int j = 0; j<tmpArray.count; j++) {
                InfoFieldModel *tmpModel = tmpArray[j];
                if([CommonMethod paramStringIsNull:tmpModel.infovalue].length==0){
                    infoFinished = NO;
                }
            }
        }
        self.nextBtn.selected = infoFinished;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    if(position && (range.length==0 || text.length==0)){
        return YES;
    }else{
        NSString *str = [textView.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:text];
        self.placeholderLabel.hidden = str.length>0;
        if(str.length>40){
            textView.text = [str substringToIndex:40];
            self.remark = [str substringToIndex:40];
            return NO;
        }else{
            self.remark = str;
            self.numLabel.text = [NSString stringWithFormat:@"%ld/40", str.length];
        }
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.ticketNum] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

@end
