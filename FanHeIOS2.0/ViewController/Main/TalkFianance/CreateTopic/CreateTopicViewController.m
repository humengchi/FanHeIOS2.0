//
//  CreateTopicViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/15.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "CreateTopicViewController.h"
#import "TopicViewController.h"
#import "ZSSRichTextEditor.h"

@interface CreateTopicViewController (){
    BOOL _noNetWork;
}

@property (nonatomic, weak) IBOutlet UIButton *nextBtn;
@property (nonatomic, weak) IBOutlet UITextField *textField;

@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation CreateTopicViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self removeViewTapGesture];
    [self.textField.subviews[0] removeFromSuperview];
    self.view.backgroundColor = kTableViewBgColor;
    [self initTableView:CGRectMake(0, 118, WIDTH, HEIGHT-118)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.nextBtn.enabled = YES;
    __weak typeof(self) weakSelf = self;
    [self.textField.rac_textSignal subscribeNext:^(NSString *text) {
        if(text.length > 50){
            weakSelf.textField.text = [text substringToIndex:50];
        }
        if(weakSelf.textField.text.length){
            [weakSelf loadTipsListHttpData];
        }else{
            [weakSelf.listArray removeAllObjects];
            [weakSelf.tableView reloadData];
        }
    }];
    [self.textField becomeFirstResponder];
    if(!self.tdModel){
        self.tdModel = [[TopicDetailModel alloc] init];
    }else{
        self.textField.text = self.tdModel.title;
    }
    if(self.tdModel.subjectid.integerValue){
        self.titleLabel.text = @"编辑话题";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -取消
- (IBAction)cancleButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -下一步
- (IBAction)nextButtonClicked:(id)sender{
    if(self.textField.text.length < 5){
        [self.view showToastMessage:@"最少输入5个字"];
        return;
    }
    self.tdModel.title = self.textField.text;
    ZSSRichTextEditor *editor = [CommonMethod getVCFromNib:[ZSSRichTextEditor class]];
    editor.tdModel = self.tdModel;
    editor.type = EditotType_Topic;
    [self.navigationController pushViewController:editor animated:YES];
}

#pragma mark - Keyboard status
- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardEnd.size.height;
    [UIView animateWithDuration:duration animations:^{
        if([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
            self.tableView.frame = CGRectMake(0, 118, WIDTH, HEIGHT-118-keyboardHeight);
        }else{
            self.tableView.frame = CGRectMake(0, 118, WIDTH, HEIGHT-118);
        }
    }];
}

#pragma mark - 话题输入提示
- (void)loadTipsListHttpData{
    _noNetWork = NO;
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",self.textField.text] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_POST_SUBJECT_TIP paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if(weakSelf.listArray==nil){
            weakSelf.listArray = [NSMutableArray array];
        }
        [weakSelf.listArray removeAllObjects];
        [weakSelf.tableView reloadData];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            NSArray *array = [CommonMethod paramArrayIsNull:responseObject[@"data"]];
            for(NSDictionary *dict in array){
                TopicDetailModel *model = [[TopicDetailModel alloc] initWithDict:dict];
                [weakSelf.listArray addObject:model];
            }
        }
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        if(weakSelf.listArray==nil){
            weakSelf.listArray = [NSMutableArray array];
        }
        _noNetWork = YES;
        [weakSelf.listArray removeAllObjects];
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark -- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.listArray==nil){
        return 0;
    }else if(self.listArray.count){
        return self.listArray.count;
    }else if(_noNetWork){
        return 1;
    }else if(self.textField.text.length){
        return 1;
    }else{
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.listArray.count){
        TopicDetailModel *model = self.listArray[indexPath.row];
        CGFloat height = [NSHelper heightOfString:model.title font:FONT_SYSTEM_SIZE(16) width:WIDTH-32 defaultHeight:16]+44;
        return height;
    }else{
        return 120;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.listArray.count){
        static NSString *identify = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        
        TopicDetailModel *model = self.listArray[indexPath.row];
        CGFloat height = [NSHelper heightOfString:model.title font:FONT_SYSTEM_SIZE(16) width:WIDTH-32 defaultHeight:16];
        UILabel *titleLabel = [UILabel createLabel:CGRectMake(16, 12, WIDTH-32, height) font:FONT_SYSTEM_SIZE(15) bkColor:nil textColor:HEX_COLOR(@"41464e")];
        titleLabel.text = model.title;
        titleLabel.numberOfLines = 0;
        [cell.contentView addSubview:titleLabel];
        
        UILabel *subTitleLabel = [UILabel createLabel:CGRectMake(16, height+19, WIDTH-32, 13) font:FONT_SYSTEM_SIZE(12) bkColor:nil textColor:HEX_COLOR(@"afb6c1")];
        subTitleLabel.text = [NSString stringWithFormat:@"关注 %@  观点 %@  评论 %@", [NSString getNumStr:model.attentcount], [NSString getNumStr:model.replycount], [NSString getNumStr:model.reviewcount]];
        [cell.contentView addSubview:subTitleLabel];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, height+43.5, WIDTH, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [cell.contentView addSubview:lineLabel];
        
        return cell;
    
    }else{
        static NSString *identify = @"UITableViewCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
        if(!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        }
        for(UIView *view in cell.contentView.subviews){
            [view removeFromSuperview];
        }
        NSString *errorStr = @"";
        if(_noNetWork){
            errorStr = @"无法链接到网络，点击屏幕重试";
        }else{
            errorStr = @"没有相关话题";
        }
        UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake((WIDTH-250)/2, 48, 250, 19) backColor:kTableViewBgColor textColor:HEX_COLOR(@"AFB6C1") test:errorStr font:17 number:1 nstextLocat:NSTextAlignmentCenter];
        [cell.contentView addSubview:contentLabel];
        cell.backgroundColor = kTableViewBgColor;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.listArray.count){
        TopicDetailModel *model = self.listArray[indexPath.row];
        TopicViewController *vc = [CommonMethod getVCFromNib:[TopicViewController class]];
        vc.subjectId = model.subjectid;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        if(_noNetWork){
            [self loadTipsListHttpData];
        }
    }
}


@end
