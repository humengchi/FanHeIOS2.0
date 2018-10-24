//
//  TransmitDynamicController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/23.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "TransmitDynamicController.h"
#import <objc/runtime.h>
#import "InviteAnswerViewController.h"
#import "AddUrlController.h"
#import "AllFriendsViewController.h"
#import "DynamicKeyWordController.h"

#define Start_X 13.0
#define Start_Y 73.0

#define GIF_LOADING_IMAGE @"http://image.51jinmai.com/loadloading.gif"

@interface TransmitDynamicController () <UIWebViewDelegate, UITextViewDelegate, UITextFieldDelegate,AddUrlControllerDelegate>

@property (nonatomic, strong) UIView *toolbarHolder;

@property (nonatomic, strong) IBOutlet UIButton *nextBtn;

@property (nonatomic, strong) NSString *linkImage;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIImageView *headerImageView;
@property (nonatomic, weak) IBOutlet UILabel *onlyTitleLabel;
@property (nonatomic, weak) IBOutlet UIWebView *editorView;
@property (nonatomic, strong) UILabel *placeHolderContentLabel;

@end

@implementation TransmitDynamicController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillHideNotification object:nil];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = WHITE_COLOR;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSData *data = UIImagePNGRepresentation(kImageWithName(@"icon_dt_link"));
    NSString *str = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    self.linkImage = [NSString stringWithFormat:@"<img src=\"data:image/png;base64,%@\">", str];
    
    self.editorView.scrollView.scrollEnabled = NO;
    self.editorView.scrollView.bounces = NO;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"/CKEditor/demo.html" ofType:nil];
    [self.editorView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
    [self.editorView becomeFirstResponder];
    
    [self initToolBar];
    
    self.placeHolderContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, WIDTH-50, 20)];
    self.placeHolderContentLabel.userInteractionEnabled = NO;
    self.placeHolderContentLabel.text = @"说两句...";
    self.placeHolderContentLabel.font = FONT_SYSTEM_SIZE(15);
    self.placeHolderContentLabel.textColor = HEX_COLOR(@"afb6c1");
    [self.editorView addSubview:self.placeHolderContentLabel];
    
    if(self.model){
        [self updateDisplay:self.model];
    }
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if(navigationType == UIWebViewNavigationTypeLinkClicked){
        return NO;
    }else{
        return YES;
    }
}

- (void)updateDisplay:(DynamicModel*)model{
    //资讯
    if([CommonMethod paramNumberIsNull:model.parent_post_id].integerValue){
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.parent_post_image] placeholderImage:kImageWithName(@"icon_dtfx_wz") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if(image){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *newImage = [self scaleImage:image];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageView.image = newImage;
                    });
                });
            }
        }];
        self.onlyTitleLabel.hidden = YES;
        self.timeLabel.hidden = NO;
        self.titleLabel.hidden = NO;
        self.timeLabel.text = model.parent_post_title;
        self.titleLabel.text = [NSString stringWithFormat:@"%@：%@",model.userModel.user_realname,[model.content filterHTML]];
        NSString *cotent = [NSString stringWithFormat:@"//%@:%@",[NSString stringWithFormat:@"<a href=\"%@%@\" id=\"%@\" extype=\"atname\">@%@</a>",ShareHomePageURL, model.userModel.user_id, model.userModel.user_id, model.userModel.user_realname], model.content];
        [self setHTML:cotent];
    }else if([CommonMethod paramNumberIsNull:model.post_id].integerValue){
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.post_image] placeholderImage:kImageWithName(@"icon_dtfx_wz") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if(image){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *newImage = [self scaleImage:image];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageView.image = newImage;
                    });
                });
            }
        }];
        if(model.review_id.integerValue){//转发资讯评论
            self.onlyTitleLabel.hidden = YES;
            self.timeLabel.hidden = NO;
            self.titleLabel.hidden = NO;
            self.timeLabel.text = model.post_title;
            self.titleLabel.text = [NSString stringWithFormat:@"%@：%@",model.userModel.user_realname,[model.review_content filterHTML]];
        }else{
            if([CommonMethod paramStringIsNull:model.post_subcontent].length){
                self.onlyTitleLabel.hidden = YES;
                self.timeLabel.hidden = NO;
                self.titleLabel.hidden = NO;
                self.titleLabel.text = model.post_title;
                self.timeLabel.text = [model.post_subcontent stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            }else{
                self.onlyTitleLabel.hidden = NO;
                self.timeLabel.hidden = YES;
                self.titleLabel.hidden = YES;
                self.onlyTitleLabel.text = model.post_title;
            }
        }
        if(model.userModel.user_id.integerValue){
            NSString *cotent = [NSString stringWithFormat:@"//%@:%@",[NSString stringWithFormat:@"<a href=\"%@%@\" id=\"%@\" extype=\"atname\">@%@</a>",ShareHomePageURL, model.userModel.user_id, model.userModel.user_id, model.userModel.user_realname], model.content];
            [self setHTML:cotent];
        }
    }
    //活动
    else if([CommonMethod paramNumberIsNull:model.parent_activity_id].integerValue){
        
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.parent_activity_image] placeholderImage:kImageWithName(@"icon_dtfx_hd") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if(image){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *newImage = [self scaleImage:image];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageView.image = newImage;
                    });
                });
            }
        }];
        self.onlyTitleLabel.hidden = YES;
        self.timeLabel.hidden = NO;
        self.titleLabel.hidden = NO;
        self.timeLabel.text = model.parent_activity_timestr;
        self.titleLabel.text = model.parent_activity_title;
        if(model.userModel.user_id.integerValue){
            NSString *cotent = [NSString stringWithFormat:@"//%@:%@",[NSString stringWithFormat:@"<a href=\"%@%@\" id=\"%@\" extype=\"atname\">@%@</a>",ShareHomePageURL, model.userModel.user_id, model.userModel.user_id, model.userModel.user_realname], model.content];
            [self setHTML:cotent];
        }
    }else if([CommonMethod paramNumberIsNull:model.activity_id].integerValue){
      [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.activity_image] placeholderImage:kImageWithName(@"icon_dtfx_hd") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if(image){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *newImage = [self scaleImage:image];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageView.image = newImage;
                    });
                });
            }
        }];
        self.onlyTitleLabel.hidden = YES;
        self.timeLabel.hidden = NO;
        self.titleLabel.hidden = NO;
        self.timeLabel.text = model.activity_timestr;
        self.titleLabel.text = model.activity_title;
        if(model.userModel.user_id.integerValue){
            NSString *cotent = [NSString stringWithFormat:@"//%@:%@",[NSString stringWithFormat:@"<a href=\"%@%@\" id=\"%@\" extype=\"atname\">@%@</a>",ShareHomePageURL, model.userModel.user_id, model.userModel.user_id, model.userModel.user_realname], model.content];
            [self setHTML:cotent];
        }
    }
    //话题
    else if([CommonMethod paramNumberIsNull:model.parent_subject_id].integerValue){
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.parent_subject_photo] placeholderImage:kImageWithName(@"icon_dtfx_ht") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if(image){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *newImage = [self scaleImage:image];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageView.image = newImage;
                    });
                });
            }
        }];
        self.onlyTitleLabel.hidden = YES;
        self.timeLabel.hidden = NO;
        self.titleLabel.hidden = NO;
        self.timeLabel.text = model.parent_subject_title;
        self.titleLabel.text = [NSString stringWithFormat:@"%@：%@",model.userModel.user_realname,[model.content filterHTML]];
        if(model.userModel.user_id.integerValue){
            NSString *cotent = [NSString stringWithFormat:@"//%@:%@",[NSString stringWithFormat:@"<a href=\"%@%@\" id=\"%@\" extype=\"atname\">@%@</a>",ShareHomePageURL, model.userModel.user_id, model.userModel.user_id, model.userModel.user_realname], model.content];
            [self setHTML:cotent];
        }
    }else if([CommonMethod paramNumberIsNull:model.subject_id].integerValue){
        
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.subject_photo] placeholderImage:kImageWithName(@"icon_dtfx_ht") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if(image){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *newImage = [self scaleImage:image];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageView.image = newImage;
                    });
                });
            }
        }];
        if(model.review_id.integerValue){
            self.onlyTitleLabel.hidden = YES;
            self.timeLabel.hidden = NO;
            self.titleLabel.hidden = NO;
            self.titleLabel.text = [NSString stringWithFormat:@"%@：%@",model.userModel.user_realname,[model.review_content filterHTML]];
            self.timeLabel.text = model.subject_title;
        }else{
            self.onlyTitleLabel.hidden = NO;
            self.timeLabel.hidden = YES;
            self.titleLabel.hidden = YES;
            self.onlyTitleLabel.text = model.subject_title;
        }
        if(model.userModel.user_id.integerValue){
            NSString *cotent = [NSString stringWithFormat:@"//%@:%@",[NSString stringWithFormat:@"<a href=\"%@%@\" id=\"%@\" extype=\"atname\">@%@</a>",ShareHomePageURL, model.userModel.user_id, model.userModel.user_id, model.userModel.user_realname], model.content];
            [self setHTML:cotent];
        }
    }
    //动态
    else if([CommonMethod paramNumberIsNull:model.parent].integerValue){
        self.imageView.hidden = YES;
        self.headerImageView.hidden = NO;
        [CALayer updateControlLayer:self.headerImageView.layer radius:22 borderWidth:0 borderColor:nil];
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.parent_review_user_image] placeholderImage:KHeadImageDefaultName(model.parent_review_user_realname)];
        self.onlyTitleLabel.hidden = YES;
        self.timeLabel.hidden = NO;
        self.titleLabel.hidden = NO;
        if(model.type.integerValue == 13 && model.exttype.integerValue == 17){
            self.timeLabel.text = [NSString stringWithFormat:@"%@的供需动态", model.parent_review_user_realname];
            self.titleLabel.text = model.parent_title;
        }else{
            self.timeLabel.text = [NSString stringWithFormat:@"%@的金脉动态", model.parent_review_user_realname];
            NSString *content = model.parent_content.length?model.parent_content:[NSString stringWithFormat:@"分享了%ld张图片",[model.parent_image componentsSeparatedByString:@","].count];
            self.titleLabel.text = [content filterHTML];
        }
        NSString *cotent = [NSString stringWithFormat:@"//%@:%@",[NSString stringWithFormat:@"<a href=\"%@%@\" id=\"%@\" extype=\"atname\">@%@</a>",ShareHomePageURL, model.userModel.user_id, model.userModel.user_id, model.userModel.user_realname], model.content];
        [self setHTML:cotent];
    }else{
        self.imageView.hidden = YES;
        self.headerImageView.hidden = NO;
        [CALayer updateControlLayer:self.headerImageView.layer radius:22 borderWidth:0 borderColor:nil];
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.userModel.user_image] placeholderImage:KHeadImageDefaultName(model.userModel.user_realname)];
        self.onlyTitleLabel.hidden = YES;
        self.timeLabel.hidden = NO;
        self.titleLabel.hidden = NO;
        if(model.type.integerValue == 17){
            self.timeLabel.text = [NSString stringWithFormat:@"%@的供需动态", model.userModel.user_realname];
            self.titleLabel.text = model.title;
        }else{
            self.timeLabel.text = [NSString stringWithFormat:@"%@的金脉动态", model.userModel.user_realname];
            NSString *content = model.content.length?model.content:[NSString stringWithFormat:@"分享了%ld张图片",[model.image componentsSeparatedByString:@","].count];
            self.titleLabel.text = [content filterHTML];
        }
    }
    if([[self getHTML] filterHTML].length==0){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self focusTextEditor];
        });
    }
}

- (void)focusTextEditor{
    self.editorView.keyboardDisplayRequiresUserAction = NO;
    [self.editorView stringByEvaluatingJavaScriptFromString:@"CKEDITOR.instances.editor.focus();"];
    self.editorView.keyboardDisplayRequiresUserAction = YES;
}

#pragma mark -文本内容
- (NSString*)getHTML{
    return [self.editorView stringByEvaluatingJavaScriptFromString:@"CKEDITOR.instances.editor.getData()"];
}

- (void)setHTML:(NSString *)html {
    if([html filterHTML].length){
        self.placeHolderContentLabel.hidden = YES;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self focusTextEditor];
        [self.editorView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"CKEDITOR.instances.editor.insertHtml('%@');",html]];
        [self.editorView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"movetostart()"]];
    });
}

#pragma mark - 返回、下一步按钮操作
- (IBAction)leftButtonClicked:(UIButton*)sender{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)filterHTML{
    NSString *htmlStr = [self getHTML];
    //img
    NSScanner * scannerImg = [NSScanner scannerWithString:htmlStr];
    NSString * textImg = nil;
    while([scannerImg isAtEnd]==NO){
        //找到标签的起始位置
        [scannerImg scanUpToString:@"<img" intoString:nil];
        //找到标签的结束位置
        [scannerImg scanUpToString:@">" intoString:&textImg];
        //替换字符
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",textImg] withString:@""];
    }
    //i@
    NSScanner * scannerAt = [NSScanner scannerWithString:htmlStr];
    NSString * textAt = nil;
    while([scannerAt isAtEnd]==NO){
        //找到标签的起始位置
        [scannerAt scanUpToString:@"<a" intoString:nil];
        //找到标签的结束位置
        [scannerAt scanUpToString:@">" intoString:&textAt];
        NSString *newStr = [NSString stringWithFormat:@"%@",textAt];
        if([newStr hasPrefix:@"<a id="]){
            NSRange startRange = [newStr rangeOfString:@"<a"];
            NSRange endRange = [newStr rangeOfString:@" href"];
            NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
            NSString *result = [newStr substringWithRange:range];
            newStr = [newStr stringByReplacingOccurrencesOfString:result withString:@""];
            newStr = [newStr stringByAppendingString:result];
        }else if([newStr hasPrefix:@"<a extype="]){
            NSRange startRange = [newStr rangeOfString:@"<a"];
            NSRange endRange = [newStr rangeOfString:@" href"];
            NSRange range = NSMakeRange(startRange.location + startRange.length, endRange.location - startRange.location - startRange.length);
            NSString *result = [newStr substringWithRange:range];
            newStr = [newStr stringByReplacingOccurrencesOfString:result withString:@""];
            newStr = [newStr stringByAppendingString:result];
        }
        //替换字符
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",textAt] withString:newStr];
    }
    return htmlStr;
}

#pragma mark - 发表，下一步
- (IBAction)rightButtonClicked:(id)sender {
    [self.view endEditing:YES];
    [self createDynamicHttp:nil];
}

#pragma mark - 创建动态
- (void)createDynamicHttp:(MBProgressHUD*)hud{
    if(hud==nil){
        hud = [MBProgressHUD showMessag:@"发布中" toView:self.view];
    }
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    NSString *content = [CommonMethod paramStringIsNull:[self filterHTML]];
    content = [content stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
    content = [content stringByReplacingOccurrencesOfString:@"</p>" withString:@"\n"];
    content = [content stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
    if([content filterHTML].length>300){
        [hud hideAnimated:YES];
        [self.view showToastMessage:@"最多输入300字"];
        return;
    }
    [requestDict setObject:content forKey:@"content"];
    NSString *apiStr;
    //资讯
    if([CommonMethod paramNumberIsNull:self.model.parent_post_id].integerValue){
        apiStr = API_NAME_POST_DYNAMIC_SHARE_POST_REVIEW;
        [requestDict setObject:self.model.review_id forKey:@"reviewid"];
    }else if([CommonMethod paramNumberIsNull:self.model.post_id].integerValue){
        if(self.model.review_id.integerValue){
            apiStr = API_NAME_POST_DYNAMIC_SHARE_POST_REVIEW;
            [requestDict setObject:self.model.review_id forKey:@"reviewid"];
        }else{
            apiStr = API_NAME_POST_DYNAMIC_SHARE_POST;
            [requestDict setObject:self.model.post_id forKey:@"postid"];
        }
    }
    //活动
    else if([CommonMethod paramNumberIsNull:self.model.parent_activity_id].integerValue){
        apiStr = API_NAME_POST_DYNAMIC_SHARE_ACTIVITY;
        [requestDict setObject:self.model.parent_activity_id forKey:@"activityid"];
    }else if([CommonMethod paramNumberIsNull:self.model.activity_id].integerValue){
        apiStr = API_NAME_POST_DYNAMIC_SHARE_ACTIVITY;
        [requestDict setObject:self.model.activity_id forKey:@"activityid"];
    }
    //话题
    else if([CommonMethod paramNumberIsNull:self.model.parent_subject_id].integerValue){
        if(self.model.exttype.integerValue==3||self.model.exttype.integerValue==8){
            apiStr = API_NAME_POST_DYNAMIC_SHARE_SUBJECT;
            [requestDict setObject:self.model.parent_subject_id forKey:@"subjectid"];
        }else{
            apiStr = API_NAME_POST_DYNAMIC_SHARE_GD;
            if(self.model.exttype.integerValue == 11){
                [requestDict setObject:self.model.parent_review_id forKey:@"reviewid"];
            }else{
                [requestDict setObject:self.model.parent_subject_id forKey:@"reviewid"];
            }
        }
    }else if([CommonMethod paramNumberIsNull:self.model.subject_id].integerValue){
        if(self.model.review_id.integerValue){
            apiStr = API_NAME_POST_DYNAMIC_SHARE_GD;
            [requestDict setObject:self.model.review_id forKey:@"reviewid"];
        }else{
            apiStr = API_NAME_POST_DYNAMIC_SHARE_SUBJECT;
            [requestDict setObject:self.model.subject_id forKey:@"subjectid"];
        }
    }
    //动态
    else if([CommonMethod paramNumberIsNull:self.model.parent].integerValue){
        apiStr = API_NAME_POST_DYNAMIC_SHARE_DYNAMIC;
        [requestDict setObject:self.model.parent forKey:@"dynamicid"];
    }else{
        apiStr = API_NAME_POST_DYNAMIC_SHARE_DYNAMIC;
        [requestDict setObject:self.model.dynamic_id forKey:@"dynamicid"];
    }
    [self requstType:RequestType_Post apiName:apiStr paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            [MBProgressHUD showSuccess:@"转发成功" toView:weakSelf.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication].keyWindow endEditing:YES];
                
                [weakSelf.navigationController popViewControllerAnimated:YES];
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            });
        }else{
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

- (void)initToolBar{
    CGFloat start_Y = 0;
   
    self.toolbarHolder = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT, WIDTH, 44+start_Y)];
    self.toolbarHolder.backgroundColor = HEX_COLOR(@"f8f8f8");
    [self.view addSubview:self.toolbarHolder];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, start_Y, WIDTH, 0.5)];
    lineLabel.backgroundColor = kCellLineColor;
    [self.toolbarHolder addSubview:lineLabel];
    
    //链接
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneBtn setImage:kImageWithName(@"btn_link_b") forState:UIControlStateNormal];
    doneBtn.frame = CGRectMake(WIDTH-130, start_Y, 40, 44);
    doneBtn.tag = 202;
    [doneBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarHolder addSubview:doneBtn];
    
    //@
    UIButton *atBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [atBtn setImage:kImageWithName(@"btn_viewpoint_@") forState:UIControlStateNormal];
    atBtn.frame = CGRectMake(WIDTH-90, start_Y, 40, 44);
    atBtn.tag = 203;
    [atBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarHolder addSubview:atBtn];
    
    //#
    UIButton *relationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [relationBtn setImage:kImageWithName(@"btn_keyb") forState:UIControlStateNormal];
    relationBtn.frame = CGRectMake(WIDTH-50, start_Y, 40, 44);
    relationBtn.tag = 204;
    [relationBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarHolder addSubview:relationBtn];
}

#pragma mark - Method
//tool中按钮点击操作
- (void)buttonClicked:(UIButton*)sender{
    [self.editorView stringByEvaluatingJavaScriptFromString:@"setPosition()"];
    switch (sender.tag) {
        case 201:{
            
        }
            break;
        case 202:{
            AddUrlController *vc = [CommonMethod getVCFromNib:[AddUrlController class]];
            vc.addUrlControllerDelegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 203:{
            AllFriendsViewController *vc = [CommonMethod getVCFromNib:[AllFriendsViewController class]];
            vc.isDynamicAt = YES;
            __weak typeof(self) weakSelf = self;
            vc.dynamicAtUser = ^(ChartModel *model){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.editorView stringByEvaluatingJavaScriptFromString:@"restorePosition()"];
                    NSString *url = [NSString stringWithFormat:@"CKEDITOR.instances.editor.insertHtml('<a href=\"%@%@\" id=\"%@\" extype=\"atname\">@%@</a>');",ShareHomePageURL, model.userid, model.userid, model.realname];
                    [weakSelf.editorView stringByEvaluatingJavaScriptFromString:url];
                    weakSelf.placeHolderContentLabel.hidden = YES;
                });
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 204:{
            DynamicKeyWordController *vc = [CommonMethod getVCFromNib:[DynamicKeyWordController class]];
            __weak typeof(self) weakSelf = self;
            vc.DynamicKeyWord = ^(NSString *keyWord){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.editorView stringByEvaluatingJavaScriptFromString:@"restorePosition()"];
                    [weakSelf.editorView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"CKEDITOR.instances.editor.insertHtml('<a href=\"keyword://%@\" extype=\"keyword\">#%@#</a>');", keyWord, keyWord]];
                    weakSelf.placeHolderContentLabel.hidden = YES;
                });
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - AddUrlControllerDelegate
- (void)backAddUrlControllerDic:(NSMutableDictionary *)dic{
    [self.editorView stringByEvaluatingJavaScriptFromString:@"restorePosition()"];
    NSString *url = [NSString stringWithFormat:@"CKEDITOR.instances.editor.insertHtml('<a href=\"%@\" extype=\"urllink\">%@</a>');",dic[@"url"], [CommonMethod paramStringIsNull:dic[@"title"]].length?dic[@"title"]:dic[@"url"]];
    [self.editorView stringByEvaluatingJavaScriptFromString:url];
    self.placeHolderContentLabel.hidden = YES;
}

#pragma mark - Keyboard status
- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    int curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = UIInterfaceOrientationIsLandscape(orientation) ? ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.000000) ? keyboardEnd.size.height : keyboardEnd.size.width : keyboardEnd.size.height;
    UIViewAnimationOptions animationOptions = curve << 16;
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        [UIView animateWithDuration:duration delay:0 options:animationOptions animations:^{
            self.toolbarHolder.frame = CGRectMake(0, HEIGHT-keyboardHeight-44, WIDTH, 44);
            self.placeHolderContentLabel.hidden = YES;
        } completion:nil];
    } else {
        [UIView animateWithDuration:duration delay:0 options:animationOptions animations:^{
            CGRect frame = self.toolbarHolder.frame;
            frame.origin.y = HEIGHT;
            self.toolbarHolder.frame = frame;
            if([[self getHTML] filterHTML].length == 0){
                self.placeHolderContentLabel.hidden = NO;
            }
        } completion:nil];
    }
}

- (UIImage*)scaleImage:(UIImage*)originImage{
    CGSize retSize = originImage.size;
    CGFloat sizeWidth = MIN(retSize.width, retSize.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([originImage CGImage], CGRectMake(0, 0, sizeWidth, sizeWidth));//获取图片整体部分
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:originImage.scale orientation:UIImageOrientationUp];
    return image;
}

@end

