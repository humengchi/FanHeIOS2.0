//
//  ViewController.m
//  InputimageExample
//
//  Created by zorro on 15/3/6.
//  Copyright (c) 2015年 tutuge. All rights reserved.
//

#import "RichTextViewController.h"

#define DefaultFont (14)

@interface RichTextViewController ()<UITextViewDelegate>{
    NSInteger _maxCount;
}
@property (weak, nonatomic) IBOutlet UITextView *textView;
//默认提示字
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;


//设置
@property (nonatomic,assign) NSRange newRange;     //记录最新内容的range
@property (nonatomic,strong) NSString * newstr;    //记录最新内容的字符串
@property (nonatomic,assign) BOOL isBold;          //是否加粗
@property (nonatomic,strong) UIColor * fontColor;  //字体颜色
@property (nonatomic,assign) CGFloat  font;        //字体大小
@property (nonatomic,assign) NSUInteger location;  //纪录变化的起始位置
//纪录变化时的内容，即是
@property (nonatomic,strong) NSMutableAttributedString * locationStr;
@property (nonatomic,assign) CGFloat lineSapce;    //行间距
@property (nonatomic,assign) BOOL isDelete;        //是否是回删

@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation RichTextViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _maxCount = 50;
    if (self.isCoffer) {
        self.titleLabel.text = @"给Ta留言";
        self.placeholderLabel.text = @"领Ta的咖啡，跟Ta打个招呼吧.\n\n例如：我是来自XXX的YYY，这杯咖啡我带走啦~~希望可以交个朋友，深度交流一下。";
        [self.sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        
        [self.sendBtn setTitleColor:HEX_COLOR(@"E6E8EB") forState:UIControlStateDisabled];
        [self.sendBtn setTitleColor:kDefaultColor forState:UIControlStateNormal];
        [self.sendBtn setImage:nil forState:UIControlStateNormal];
        [self.sendBtn setImage:nil forState:UIControlStateDisabled];
        //        self.numberLabel.text = @"0/50";
        //        _maxCount = 50;
    }else if(self.isPersonalRemark){
        self.titleLabel.text = @"个人简介";
        self.placeholderLabel.text = @"简单描述自己的职位、工作内容、产品等，让更多金融人能了解你";
        [self.sendBtn setTitle:@"保存" forState:UIControlStateNormal];
        
        [self.sendBtn setTitleColor:HEX_COLOR(@"E6E8EB") forState:UIControlStateDisabled];
        [self.sendBtn setTitleColor:kDefaultColor forState:UIControlStateNormal];
        [self.sendBtn setImage:nil forState:UIControlStateNormal];
        [self.sendBtn setImage:nil forState:UIControlStateDisabled];
        self.numberLabel.text = @"0/140";
        _maxCount = 140;
    }else if(self.isPersonalDynamic){
        self.titleLabel.text = @"发布签名";
        self.placeholderLabel.text = @"分享你此刻的心情、工作、业务";
        [self.sendBtn setTitle:@"发布" forState:UIControlStateNormal];
        
        [self.sendBtn setTitleColor:HEX_COLOR(@"E6E8EB") forState:UIControlStateDisabled];
        [self.sendBtn setTitleColor:kDefaultColor forState:UIControlStateNormal];
        [self.sendBtn setImage:nil forState:UIControlStateNormal];
        [self.sendBtn setImage:nil forState:UIControlStateDisabled];
        self.numberLabel.text = @"0/50";
        _maxCount = 50;
    }else if(self.commentType){
        self.titleLabel.text = @"发表评论";
        if(self.commentType == 1){
            self.placeholderLabel.text = @"说点什么吧……";
        }else{
            self.placeholderLabel.text = [NSString stringWithFormat:@"回复%@",self.replyName];
        }
        [self.sendBtn setTitle:@"发表" forState:UIControlStateNormal];
        
        [self.sendBtn setTitleColor:HEX_COLOR(@"E6E8EB") forState:UIControlStateDisabled];
        [self.sendBtn setTitleColor:kDefaultColor forState:UIControlStateNormal];
        [self.sendBtn setImage:nil forState:UIControlStateNormal];
        [self.sendBtn setImage:nil forState:UIControlStateDisabled];
        self.numberLabel.text = @"0/1000";
        _maxCount = 1000;
    }else if(self.isActivity){
        self.titleLabel.text = @"回答";
        self.placeholderLabel.text = @"回答提问者的问题…";
        [self.sendBtn setTitle:@"发表" forState:UIControlStateNormal];
        [self.sendBtn setTitleColor:HEX_COLOR(@"E6E8EB") forState:UIControlStateDisabled];
        [self.sendBtn setTitleColor:kDefaultColor forState:UIControlStateNormal];
        [self.sendBtn setImage:nil forState:UIControlStateNormal];
        [self.sendBtn setImage:nil forState:UIControlStateDisabled];
        self.numberLabel.text = @"0/40";
        _maxCount = 40;
    }else if(self.isCard){
        self.titleLabel.text = @"添加备注";
        self.placeholderLabel.text = @"添加备注信息…";
        [self.sendBtn setTitle:@"保存" forState:UIControlStateNormal];
        [self.sendBtn setTitleColor:HEX_COLOR(@"E6E8EB") forState:UIControlStateDisabled];
        [self.sendBtn setTitleColor:kDefaultColor forState:UIControlStateNormal];
        [self.sendBtn setImage:nil forState:UIControlStateNormal];
        [self.sendBtn setImage:nil forState:UIControlStateDisabled];
        self.numberLabel.text = @"0/20";
        _maxCount = 20;
        self.content = self.cardModel.remark;
    }
    
    //Init text font
    [self resetTextStyle];
    //Add keyboard notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
    if (self.content!=nil) {
        [self setRichTextViewContent:self.content];
    }
    
    [self.textView becomeFirstResponder];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)CommomInit{
    self.textView.delegate=self;
    //显示链接，电话
    self.textView.dataDetectorTypes = UIDataDetectorTypeAll;
    self.font=DefaultFont;
    self.fontColor=HEX_COLOR(@"41464E");
    self.location=0;
    self.isBold=NO;
    self.lineSapce=7;
    [self setInitLocation];
}

- (void)resetTextStyle {
    //After changing text selection, should reset style.
    [self CommomInit];
    NSRange wholeRange = NSMakeRange(0, _textView.textStorage.length);
    
    [_textView.textStorage removeAttribute:NSFontAttributeName range:wholeRange];
    [_textView.textStorage removeAttribute:NSForegroundColorAttributeName range:wholeRange];
    
    //字体颜色
    [_textView.textStorage addAttribute:NSForegroundColorAttributeName value:self.fontColor range:wholeRange];
    
    //字体加粗
    if (self.isBold) {
        [_textView.textStorage addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:self.font] range:wholeRange];
    }else{//字体大小
        [_textView.textStorage addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:self.font] range:wholeRange];
    }
}

//把最新内容都赋给self.locationStr
-(void)setInitLocation{
    self.locationStr=nil;
    self.locationStr=[[NSMutableAttributedString alloc]initWithAttributedString:self.textView.attributedText];
    if (self.textView.textStorage.length>0) {
        self.placeholderLabel.hidden=YES;
    }
}

//设置样式
-(void)setStyle{
    //把最新的内容进行替换
    [self setInitLocation];
    if (self.isDelete) {
        return;
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = self.lineSapce;// 字体的行间距
    NSDictionary *attributes=nil;
    if (self.isBold) {
        attributes = @{
                       NSFontAttributeName:[UIFont boldSystemFontOfSize:self.font],
                       NSForegroundColorAttributeName:self.fontColor,
                       NSParagraphStyleAttributeName:paragraphStyle
                       };
    }else{
        attributes = @{
                       NSFontAttributeName:[UIFont systemFontOfSize:self.font],
                       NSForegroundColorAttributeName:self.fontColor,
                       NSParagraphStyleAttributeName:paragraphStyle
                       };
    }
    
    [self setRichTextViewContent:self.textView.text];
    //这里需要把光标的位置重新设定
    self.textView.selectedRange=NSMakeRange(self.newRange.location+self.newRange.length, 0);
#warning 原本的文本处理
    //    NSAttributedString * replaceStr=[[NSAttributedString alloc] initWithString:self.newstr attributes:attributes];
    //    [self.locationStr replaceCharactersInRange:self.newRange withAttributedString:replaceStr];
    //    _textView.attributedText =self.locationStr;
    //
    //    //这里需要把光标的位置重新设定
    //    self.textView.selectedRange=NSMakeRange(self.newRange.location+self.newRange.length, 0);
}
#pragma mark textViewDelegate
/**
 点击图片触发代理事件
 **/
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange{
    return NO;
}

/**
 *  点击链接，触发代理事件
 */
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    [[UIApplication sharedApplication] openURL:URL];
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (textView.text.length == 0) {
        NSString *tem = [[text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] componentsJoinedByString:@""];
        if (![text isEqualToString:tem]&&tem.length==0) {
            return NO;
        }
    }
    if([text isEqualToString:@"\n"]){
        [self.textView resignFirstResponder];
        if(self.sendBtn.isEnabled){
            [self sendButtonClicked:self.sendBtn];
        }
        return NO;
    }
    if(textView.text.length == 0 && text.length == 0){
        self.numberLabel.text = [NSString stringWithFormat:@"%ld/%ld", (unsigned long)self.textView.attributedText.length, (long)_maxCount];
        self.placeholderLabel.hidden = NO;
    }
    if (range.length == 1){
        return YES;
    } else{
        // 超过长度限制
        if ([textView.text length] >= _maxCount+3){
            self.numberLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)_maxCount, (long)_maxCount];
            return NO;
        }
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    if (self.textView.attributedText.length>0) {
        self.placeholderLabel.hidden=YES;
        self.sendBtn.enabled = YES;
    }else{
        self.placeholderLabel.hidden=NO;
        self.sendBtn.enabled = NO;
    }
    self.numberLabel.text = [NSString stringWithFormat:@"%ld/%ld", (unsigned long)self.textView.attributedText.length, (long)_maxCount];
    NSInteger len=textView.attributedText.length-self.locationStr.length;
    if (len>0) {
        self.isDelete=NO;
        self.newRange=NSMakeRange(self.textView.selectedRange.location-len, len);
        self.newstr=[textView.text substringWithRange:self.newRange];
    }else{
        self.isDelete=YES;
    }
    
    bool isChinese;//判断当前输入法是否是中文
    if ([[[textView textInputMode] primaryLanguage]  isEqualToString: @"en-US"]) {
        isChinese = false;
    }else{
        isChinese = true;
    }
    NSString *str = [[ self.textView text] stringByReplacingOccurrencesOfString:@"?" withString:@""];
    if (isChinese) { //中文输入法下
        UITextRange *selectedRange = [self.textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [self.textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            //            NSLog(@"汉字");
            [self setStyle];
            if ( str.length>=_maxCount) {
                
                self.numberLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)_maxCount, (long)_maxCount];
                NSString *strNew = [NSString stringWithString:str];
                [ self.textView setText:[strNew substringToIndex:_maxCount]];
            }
        }else{
            //            NSLog(@"没有转化--%@",str);
            if ([str length]>=_maxCount+10) {
                
                self.numberLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)_maxCount, (long)_maxCount];
                NSString *strNew = [NSString stringWithString:str];
                [ self.textView setText:[strNew substringToIndex:_maxCount+10]];
            }
        }
    }else{
        //        NSLog(@"英文");
        [self setStyle];
        if ([str length]>=_maxCount) {
            self.numberLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)_maxCount, (long)_maxCount];
            NSString *strNew = [NSString stringWithString:str];
            [ self.textView setText:[strNew substringToIndex:_maxCount]];
        }
    }
}

#pragma mark - Keyboard notification
- (void)onKeyboardNotification:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardEnd.size.height;
    [UIView animateWithDuration:duration animations:^{
        if([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
            self.view.frame = CGRectMake(0, 0, WIDTH, HEIGHT-keyboardHeight);
        }else{
            self.view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        }
    }];
}

#pragma mark  设置内容，二次编辑
-(void)setRichTextViewContent:(NSString*)content{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 6;// 字体的行间距
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSParagraphStyleAttributeName:paragraphStyle};
    self.textView.attributedText = [[NSAttributedString alloc] initWithString:content attributes:attributes];
    if(content && content.length){
        self.placeholderLabel.hidden = YES;
        self.sendBtn.enabled = YES;
    }
    self.numberLabel.text = [NSString stringWithFormat:@"%ld/%ld", (unsigned long)self.textView.attributedText.length, (long)_maxCount];
}

#pragma mark- method
- (IBAction)backButtonClicked:(id)sender {
    UserModel  * userModel = [DataModelInstance shareInstance].userModel;
    if (self.isCoffer) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if(self.isPersonalRemark){
        if ([userModel.remark isEqualToString:self.textView.text]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否放弃编辑资料？" cancelButtonTitle:@"放弃" otherButtonTitle:@"继续编辑" cancle:^{
                [self dismissViewControllerAnimated:YES completion:nil];
                return ;
            } confirm:^{
                return ;
                
            }];
        }
    }else if(self.isPersonalDynamic){
        if ([userModel.mystate isEqualToString:self.textView.text]) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否放弃编辑资料？" cancelButtonTitle:@"放弃" otherButtonTitle:@"继续编辑" cancle:^{
                [self dismissViewControllerAnimated:YES completion:nil];
                return ;
            } confirm:^{
                return ;
                
            }];
        }
    }else if(self.commentType){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if(self.isActivity){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if(self.isCard){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    [self.view endEditing:YES];
}

//发表
- (IBAction)sendButtonClicked:(id)sender {
    [self.view endEditing:YES];
    if (self.isCoffer) {
        [self getCofferAndEditMessage];
    }else if(self.isPersonalRemark){
        if(self.savePersonalRemark){
            self.savePersonalRemark(self.textView.text);
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }else if(self.isPersonalDynamic){
        [self updateMyStateHttp];
    }else if(self.commentType){
        [self publishReviewHttp];
    }else if(self.isActivity){
        [self activityAnswerHttp];
    }else if(self.isCard){
        [self saveCardRemark];
    }else{
        [self replyInfoHttp];
    }
}

#pragma mark -保存名片备注
- (void)saveCardRemark{
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"保存中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.cardModel.cardId forKey:@"cardid"];
    [requestDict setObject:self.textView.text forKey:@"remark"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_USER_ADDCARDREMARK paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"保存成功" toView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }else{
            [MBProgressHUD showError:@"保存失败，请重试" toView:self.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"保存失败，请重试" toView:self.view];
    }];
}

#pragma mark -活动回答
- (void)activityAnswerHttp{
    if(self.textView.text.length<4){
        [self.view showToastMessage:@"最少输入4个字"];
        return;
    }
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"发表中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.model.askid forKey:@"askid"];
    [requestDict setObject:self.textView.text forKey:@"content"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_ACTIVITY_ANSWER paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"发表成功" toView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if(self.savePersonalRemark){
                    self.savePersonalRemark(self.textView.text);
                }
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }else{
            [MBProgressHUD showError:@"发布失败，请重试" toView:self.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"发布失败，请重试" toView:self.view];
    }];
}

#pragma mark  ---- 领取咖啡并发送消息
- (void)getCofferAndEditMessage{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"领取中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.cofferId forKey:@"coffid"];
    [requestDict setObject:self.textView.text forKey:@"msg"];
    
    [self requstType:RequestType_Post apiName:API_NAME_USER_GET_COFFEE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            self.scaningCofferSucceedRestule(YES);
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            self.scaningCofferSucceedRestule(NO);
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
    
}

#pragma mark -发表动态
- (void)updateMyStateHttp{
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"发布中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.textView.text forKey:@"mystate"];
    [self requstType:RequestType_Post apiName:API_NAME_USER_UPDATE_MYSTATE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if(self.savePersonalRemark){
                self.savePersonalRemark(self.textView.text);
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }else{
            [MBProgressHUD showError:@"发布失败，请重试" toView:self.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"发布失败，请重试" toView:self.view];
    }];
}

#pragma mark － 回复
- (void)replyInfoHttp{
    NSString *msg = self.textView.text;
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"回复中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.msgId forKey:@"msgid"];
    [requestDict setObject:msg forKey:@"msg"];
    [self requstType:RequestType_Post apiName:API_NAME_USER_REPLY_COFF_MSG paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"发送成功" toView:weakSelf.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if(weakSelf.replyMessageSuccess){
                    weakSelf.replyMessageSuccess();
                }
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            });
        }else{
            [MBProgressHUD showError:@"发送失败，请重试" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark -发表评论
- (void)publishReviewHttp{
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"发表中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.reviewId forKey:@"reviewid"];
    [requestDict setObject:self.textView.text forKey:@"content"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_ADD_VP_REVIEW paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            if(self.replyMessageSuccess){
                self.replyMessageSuccess();
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [MBProgressHUD showError:@"发表失败" toView:self.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"发表失败" toView:self.view];
    }];
}
@end
