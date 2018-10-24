//
//  ZSSRichTextEditorViewController.m
//  ZSSRichTextEditor
//
//  Created by Nicholas Hubbard on 11/30/13.
//  Copyright (c) 2013 Zed Said Studio. All rights reserved.
//

#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "ZSSRichTextEditor.h"
#import "ZSSBarButtonItem.h"
#import "HRColorUtil.h"
#import "ZSSTextView.h"
#import "InviteAnswerViewController.h"
#import "CreateTopicTagsViewController.h"
#import "ChoiceResultView.h"

#define Start_X 13.0
#define Start_Y 73.0

#define GIF_LOADING_IMAGE @"http://image.51jinmai.com/loadloading.gif"//@"http://jwc.scu.edu.cn/jwc/images/loading39.gif"

@interface ZSSRichTextEditor () <UIWebViewDelegate, HRColorPickerViewControllerDelegate, UITextViewDelegate, UITextFieldDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    NSInteger _limitNum;
    NSInteger _switchResult;
}
@property (nonatomic, strong) UIScrollView *toolBarScroll;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIView *toolbarHolder;
@property (nonatomic, strong) NSString *htmlString;
@property (nonatomic, strong) UIWebView *editorView;
@property (nonatomic, strong) ZSSTextView *sourceView;
@property (nonatomic) CGRect editorViewFrame;
@property (nonatomic) BOOL resourcesLoaded;
@property (nonatomic, strong) NSArray *editorItemsEnabled;
@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) NSString *selectedLinkURL;
@property (nonatomic, strong) NSString *selectedLinkTitle;
@property (nonatomic, strong) NSString *selectedImageURL;
@property (nonatomic, strong) NSString *selectedImageAlt;
@property (nonatomic, strong) UIBarButtonItem *keyboardItem;
@property (nonatomic, strong) NSMutableArray *customBarButtonItems;
@property (nonatomic, strong) NSMutableArray *customZSSBarButtonItems;
@property (nonatomic, strong) NSString *internalHTML;
@property (nonatomic) BOOL editorLoaded;
- (NSString *)removeQuotesFromHTML:(NSString *)html;
- (NSString *)tidyHTML:(NSString *)html;
- (void)enableToolbarItems:(BOOL)enable;
- (BOOL)isIpad;

/*自定义后添加*/
@property (nonatomic, strong) UIView        *linesView;

@property (nonatomic, strong) UIView        *fontView;

@property (nonatomic, strong) UIView        *defaultInputView;
@property (nonatomic, strong) UIButton      *selectedLineBtn;
@property (nonatomic, strong) UIButton      *selectedBoldBtn;
@property (nonatomic, strong) UIButton      *selectedFontBtn;

@property (nonatomic, strong) UILabel       *placeHolderContentLabel;

@property (nonatomic, strong) NSMutableDictionary *requestDict;

@property (nonatomic, strong) IBOutlet UIButton *nextBtn;

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) NSString *limitHtmlString;//允许输入的字数
@property (nonatomic, strong) UILabel *limitNumLabel;//允许输入的字数

@end

@implementation ZSSRichTextEditor

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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = WHITE_COLOR;

    if(self.type == EditotType_Topic){
        if(self.tdModel.subjectid.integerValue){
            self.titleLabel.text = @"编辑话题";
        }else{
            self.titleLabel.text = @"发起话题";
        }
        self.nextBtn.enabled = YES;
        [self.nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [self.nextBtn setTitleColor:HEX_COLOR(@"e24943") forState:UIControlStateNormal];
        _limitNum = 250;
    }else if(self.type == EditotType_Activity){
        self.nextBtn.enabled = NO;
        self.titleLabel.text = @"活动简介";
        [self.nextBtn setTitle:@"确定" forState:UIControlStateDisabled];
        [self.nextBtn setTitle:@"确定" forState:UIControlStateNormal];
        [self.nextBtn setTitleColor:HEX_COLOR(@"e24943") forState:UIControlStateNormal];
    }else if(self.type == EditotType_Viewpoint){
        self.titleLabel.text = @"发表观点";
        [self.nextBtn setTitle:@"发表" forState:UIControlStateNormal];
        [self.nextBtn setTitleColor:HEX_COLOR(@"e24943") forState:UIControlStateNormal];
    }
    
    self.editorLoaded = NO;
    self.shouldShowKeyboard = NO;
    self.formatHTML = YES;
    self.baseURL = [NSURL URLWithString:@"http://www.zedsaid.com"];
    
    self.enabledToolbarItems = [[NSArray alloc] init];
    // Source View
    CGRect frame = CGRectMake(Start_X, Start_Y, WIDTH-Start_X*2, HEIGHT-Start_Y);
    self.sourceView = [[ZSSTextView alloc] initWithFrame:frame];
    self.sourceView.hidden = YES;
    self.sourceView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.sourceView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.sourceView.font = [UIFont fontWithName:@"Courier" size:15.0];//13.0
    self.sourceView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.sourceView.autoresizesSubviews = YES;
    self.sourceView.delegate = self;
    [self.view addSubview:self.sourceView];
    
    // Editor View
    self.editorView = [[UIWebView alloc] initWithFrame:frame];
    self.editorView.delegate = self;
    self.editorView.keyboardDisplayRequiresUserAction = NO;
    self.editorView.scalesPageToFit = YES;
    self.editorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.editorView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.editorView.scrollView.bounces = NO;
    self.editorView.backgroundColor = [UIColor clearColor];
    self.editorView.opaque = NO;
    [self.view addSubview:self.editorView];
    [self hideGradientBackground:self.editorView];
    
//    禁用拖拽时的反弹效果
  //  [(UIScrollView *)[[self.editorView subviews] objectAtIndex:0] setBounces:NO];
    
    self.placeHolderContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 10, WIDTH-50, 20)];
    self.placeHolderContentLabel.userInteractionEnabled = NO;
    if(self.type == EditotType_Topic){
        self.placeHolderContentLabel.text = @"请填写关于话题的描述（选填）";
    }else if(self.type == EditotType_Activity){
        self.placeHolderContentLabel.text = @"填写活动简介，填写越详细越能吸引更多人报名哦";
        if([NSHelper heightOfString:self.placeHolderContentLabel.text font:FONT_SYSTEM_SIZE(15) width:WIDTH-50]>20){
            self.placeHolderContentLabel.frame = CGRectMake(13, 10, WIDTH-50, 40);
            self.placeHolderContentLabel.numberOfLines = 2;
        }
    }else if(self.type == EditotType_Viewpoint){
        self.placeHolderContentLabel.text = @"请输入您的观点...(不少于10个字)";
    }
    self.placeHolderContentLabel.font = FONT_SYSTEM_SIZE(15);
    self.placeHolderContentLabel.textColor = HEX_COLOR(@"afb6c1");
    [self.editorView addSubview:self.placeHolderContentLabel];
    
    if (!self.resourcesLoaded) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"editor" ofType:@"html"];
        NSData *htmlData = [NSData dataWithContentsOfFile:filePath];
        NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
        NSString *source = [[NSBundle mainBundle] pathForResource:@"ZSSRichTextEditor" ofType:@"js"];
        NSString *jsString = [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:source] encoding:NSUTF8StringEncoding];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"<!--editor-->" withString:jsString];
        
        [self.editorView loadHTMLString:htmlString baseURL:self.baseURL];
        self.resourcesLoaded = YES;
    }
    [self initToolBar];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self initDefaultPostsModel];
    });
    
    __weak typeof(self) weakSelf = self;
    self.atPerson = ^(ContactsModel *model){
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf focusTextEditor];
            [weakSelf insertHTML:[NSString stringWithFormat:@"<a href=\"%@%@\" id=\"%@\">@%@</a>",ShareHomePageURL, model.userid, model.userid, model.realname]];
            [weakSelf focusTextEditor];
        });
    };
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.sourceView.frame = CGRectMake(Start_X, Start_Y, WIDTH-Start_X*2, HEIGHT-Start_Y);
        weakSelf.editorView.frame = CGRectMake(Start_X, Start_Y, WIDTH-Start_X*2, HEIGHT-Start_Y);
    });
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //[self focusTextEditor];
}

//隐藏上下滚动时出边界的后面的黑色的阴影
- (void) hideGradientBackground:(UIView*)theView{
    for(UIView * subview in theView.subviews){
        if([subview isKindOfClass:[UIImageView class]]){
            subview.hidden = YES;
        }
        [self hideGradientBackground:subview];
    }
}

#pragma mark- 如果有历史记录则显示
- (void)initDefaultPostsModel{
    if(self.type == EditotType_Topic){
        if([CommonMethod paramStringIsNull:self.tdModel.content].length){
            [self setHTML:self.tdModel.content];
        }
        return;
    }else if(self.type == EditotType_Activity){
        if([CommonMethod paramStringIsNull:self.activityIntroStr].length){
            [self setHTML:self.activityIntroStr];
        }
        return;
    }else if(self.type == EditotType_Viewpoint){
        if(self.vpdModel){
            [self setHTML:self.vpdModel.content];
            return;
        }
        NSString *htmlStr = [[NSUserDefaults standardUserDefaults] objectForKey:SAVE_TEMP_POSTS_MODEL(self.tdModel.subjectid)];
        NSString *tmpContent = [CommonMethod paramStringIsNull:htmlStr];
        if(tmpContent.length){
            self.placeHolderContentLabel.hidden = YES;
            self.nextBtn.enabled = tmpContent.length!=0;
            [self setHTML:tmpContent];
        }
    }
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.sourceView.frame = CGRectMake(Start_X, Start_Y, WIDTH-Start_X*2, HEIGHT-Start_Y);
        weakSelf.editorView.frame = CGRectMake(Start_X, Start_Y, WIDTH-Start_X*2, HEIGHT-Start_Y);
    });
}

#pragma mark - 返回、下一步按钮操作
- (IBAction)leftButtonClicked:(UIButton*)sender{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    [self newThreadForAvoidButtonRepeatClick:sender];
    if(self.type == EditotType_Topic || self.type == EditotType_Activity){
        if(([[self getText] length] > 0 || [[self getHTML] containsString:@"<img"] || [[self getHTML] containsString:@"<hr />"])){
                [self cleanTemporaryDirectory];
                [self.navigationController popViewControllerAnimated:YES];
                
        }else{
            [self cleanTemporaryDirectory];
            [self.navigationController popViewControllerAnimated:YES];
        }
      }else if(self.type == EditotType_Viewpoint){
        if(self.vpdModel){
           
                [self cleanTemporaryDirectory];
                [self.navigationController popViewControllerAnimated:YES];
           
            return;
        }
        
        if(([[self getText] length] == 0 && ![[self getHTML] containsString:@"<img"] && ![[self getHTML] containsString:@"<hr />"])){
            [self cleanTemporaryDirectory];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            
        }];
        
        UIAlertAction* saveAction = [UIAlertAction actionWithTitle:@"保存内容" style:UIAlertActionStyleDefault                                                                 handler:^(UIAlertAction * action) {
            [self saveTmpPostsModel];
            [self cleanTemporaryDirectory];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        UIAlertAction* backAction = [UIAlertAction actionWithTitle:@"清空内容" style:UIAlertActionStyleDefault                                                             handler:^(UIAlertAction * action) {
            [self notSaveTmpPostsModel];
            [self cleanTemporaryDirectory];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
        if([UIDevice currentDevice].systemVersion.intValue > 8){
            [cancelAction setValue:HEX_COLOR(@"040000") forKey:@"_titleTextColor"];
            [saveAction setValue:HEX_COLOR(@"040000") forKey:@"_titleTextColor"];
            [backAction setValue:HEX_COLOR(@"e23000") forKey:@"_titleTextColor"];
        }
        [alertController addAction:cancelAction];
        [alertController addAction:saveAction];
        [alertController addAction:backAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - 保存观点
- (void)saveTmpPostsModel{
    NSString *value = [CommonMethod paramStringIsNull:[self getHTML]];
    NSString *key = SAVE_TEMP_POSTS_MODEL(self.tdModel.subjectid);
    if(value.length){
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)notSaveTmpPostsModel{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SAVE_TEMP_POSTS_MODEL(self.tdModel.subjectid)];
}

- (NSString *)filterHTML{
    NSString *htmlStr = [self getHTML];
    //span标签
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"</span>" withString:@""];
    NSScanner * scanner = [NSScanner scannerWithString:htmlStr];
    NSString * text = nil;
    while([scanner isAtEnd]==NO){
        //找到标签的起始位置
        [scanner scanUpToString:@"<span" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    //div标签
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"</div>" withString:@"</p>"];
    NSScanner *scannerDiv = [NSScanner scannerWithString:htmlStr];
    NSString *textDiv = nil;
    while([scannerDiv isAtEnd]==NO){
        //找到标签的起始位置
        [scannerDiv scanUpToString:@"<div" intoString:nil];
        //找到标签的结束位置
        [scannerDiv scanUpToString:@">" intoString:&textDiv];
        //替换字符
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",textDiv] withString:@"<p>"];
    }
    
    //去掉多余的行数
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"<p><br />" withString:@"<p>"];
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"<br /></p>" withString:@"</p>"];
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"<p>\n" withString:@"<p>"];
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"\n</p>" withString:@"</p>"];
    
    return htmlStr;
}

#pragma mark - 发表，下一步
- (IBAction)rightButtonClicked:(id)sender {
    //[self newThreadForAvoidButtonRepeatClick:sender];
    [self.view endEditing:YES];
    if([[self getHTML] containsString:GIF_LOADING_IMAGE]){
        [self.view showToastMessage:@"图片还未上传成功"];
        [self uploadImageInTemporaryDirectory];
        return;
    }
    NSString *htmlStr = [self filterHTML];
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    htmlStr = [htmlStr stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    if(self.type == EditotType_Topic){
        if([self getHTML].length){
            self.tdModel.content = htmlStr;
        }
        CreateTopicTagsViewController *vc = [CommonMethod getVCFromNib:[CreateTopicTagsViewController class]];
        vc.tdModel = self.tdModel;
        [self.navigationController pushViewController:vc animated:YES];
    }else if(self.type == EditotType_Activity){
        if(self.activityIntroduction){
            self.activityIntroduction(htmlStr);
        }
        [self cleanTemporaryDirectory];
        [self.navigationController popViewControllerAnimated:YES];
    }else if(self.type == EditotType_Viewpoint){
        if(([[self getText] length] < 10 && ![[self getHTML] containsString:@"<img"] && ![[self getHTML] containsString:@"<hr />"])){
            [self.view showToastMessage:@"最少输入10个字"];
            return;
        }
        [self publishViewpoint:htmlStr];
    }
}

//发表、修改观点
- (void)publishViewpoint:(NSString*)htmlStr{
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"发表中..." toView:self.view];
    if(self.requestDict == nil){
        self.requestDict = [[NSMutableDictionary alloc] init];
    }
    [self.requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [self.requestDict setObject:htmlStr forKey:@"content"];
    [self.requestDict setObject:self.tdModel.subjectid forKey:@"subjectid"];
    [self.requestDict setObject:[CommonMethod paramNumberIsNull:self.vpdModel.reviewid] forKey:@"reviewid"];
    if(_switchResult==0){
        [self.requestDict setObject:@(1) forKey:@"adddynamic"];
    }
    if(_switchResult==2){
        [self.requestDict setObject:@(1) forKey:@"ishidden"];
    }else{
        [self.requestDict setObject:@(0) forKey:@"ishidden"];
    }
    __weak typeof(self) weakSelf = self;
    [self requstType:RequestType_Post apiName:API_NAME_POST_ADD_VIEWPOINT paramDict:self.requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [[AppDelegate shareInstance] setZhugeTrack:@"发观点" properties:@{ @"subjectId":[CommonMethod paramNumberIsNull:self.tdModel.subjectid], @"subjectTitle":[CommonMethod paramStringIsNull:self.tdModel.title], @"subjectTags":[CommonMethod paramStringIsNull:[self.tdModel.tags componentsJoinedByString:@","]], @"subjectStatus":[CommonMethod paramNumberIsNull:self.tdModel.status]}];
            [MBProgressHUD showSuccess:@"发表成功" toView:weakSelf.view];
            if(weakSelf.publushViewpointSuccess){
                weakSelf.publushViewpointSuccess();
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:SAVE_TEMP_POSTS_MODEL(self.tdModel.subjectid)];
            });
        }else{
            [MBProgressHUD showError:@"发表失败" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"发表失败" toView:weakSelf.view];
    }];
}

- (void)initToolBar{
    CGFloat start_Y = 0;
    if(_limitNum){
        start_Y = 30;
    }
    // Parent holding view
    self.toolbarHolder = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT, WIDTH, 44+start_Y)];
    self.toolbarHolder.backgroundColor = HEX_COLOR(@"f8f8f8");
    [self.view addSubview:self.toolbarHolder];
    if(_limitNum){
        UIView *limitView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 30)];
        limitView.backgroundColor = WHITE_COLOR;
        [self.toolbarHolder addSubview:limitView];
        self.limitNumLabel = [UILabel createrLabelframe:CGRectMake(25, 0, WIDTH-50, 13) backColor:WHITE_COLOR textColor:HEX_COLOR(@"afb6c1") test:@"" font:12 number:1 nstextLocat:NSTextAlignmentRight];
        [limitView addSubview:self.limitNumLabel];
    }
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, start_Y, WIDTH, 0.5)];
    lineLabel.backgroundColor = kCellLineColor;
    [self.toolbarHolder addSubview:lineLabel];
    if(self.type == EditotType_Activity || self.type == EditotType_Topic){
        //完成
        UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneBtn setImage:kImageWithName(@"btn_viewpoint_arrow") forState:UIControlStateNormal];
        [doneBtn setImage:kImageWithName(@"btn_viewpoint_arrow") forState:UIControlStateHighlighted];
        [doneBtn setImage:kImageWithName(@"btn_viewpoint_arrow") forState:UIControlStateSelected];
        doneBtn.frame = CGRectMake(WIDTH-50, start_Y, 40, 44);
        doneBtn.tag = 201;
        [doneBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolbarHolder addSubview:doneBtn];
        //图片
        UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [imageBtn setImage:kImageWithName(@"btn_viewpoint_image") forState:UIControlStateNormal];
        [imageBtn setImage:kImageWithName(@"btn_viewpoint_image") forState:UIControlStateSelected];
        imageBtn.frame = CGRectMake(WIDTH-90, start_Y, 40, 44);
        imageBtn.tag = 203;
        [imageBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolbarHolder addSubview:imageBtn];
    }else if(self.type == EditotType_Viewpoint){
        //完成
        UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneBtn setImage:kImageWithName(@"btn_viewpoint_arrow") forState:UIControlStateNormal];
        [doneBtn setImage:kImageWithName(@"btn_viewpoint_arrow") forState:UIControlStateHighlighted];
        [doneBtn setImage:kImageWithName(@"btn_viewpoint_arrow") forState:UIControlStateSelected];
        doneBtn.frame = CGRectMake(WIDTH-50, start_Y, 40, 44);
        doneBtn.tag = 201;
        [doneBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolbarHolder addSubview:doneBtn];
        
        //@
        UIButton *atBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [atBtn setImage:kImageWithName(@"btn_viewpoint_@") forState:UIControlStateNormal];
        [atBtn setImage:kImageWithName(@"btn_viewpoint_@") forState:UIControlStateSelected];
        atBtn.frame = CGRectMake(WIDTH-90, start_Y, 40, 44);
        atBtn.tag = 202;
        [atBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolbarHolder addSubview:atBtn];
        
        //图片
        UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [imageBtn setImage:kImageWithName(@"btn_viewpoint_image") forState:UIControlStateNormal];
        [imageBtn setImage:kImageWithName(@"btn_viewpoint_image") forState:UIControlStateSelected];
        imageBtn.frame = CGRectMake(WIDTH-130, start_Y, 40, 44);
        imageBtn.tag = 203;
        [imageBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolbarHolder addSubview:imageBtn];
        
        //匿名
        UIButton *switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        switchBtn.frame = CGRectMake(16, 8, 97, 28);
        [switchBtn setImage:kImageWithName(@"btn_switch_rnd") forState:UIControlStateNormal];
        [switchBtn addTarget:self action:@selector(choiseResultButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolbarHolder addSubview:switchBtn];
    }
}

- (void)choiseResultButtonClicked:(UIButton*)sender{
    UIWindow * window=[[[UIApplication sharedApplication] delegate] window];
    CGRect rect = [sender convertRect: sender.bounds toView:window];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [[UIApplication sharedApplication].keyWindow addSubview:bgView];
    [CommonMethod viewAddGuestureRecognizer:bgView tapsNumber:1 withTarget:self withSEL:@selector(removeMenuView:)];
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(removeMenuView:)];
    swipe.direction = UISwipeGestureRecognizerDirectionUp|UISwipeGestureRecognizerDirectionDown;
    [bgView addGestureRecognizer:swipe];
    ChoiceResultView *choiceView = [CommonMethod getViewFromNib:@"ChoiceResultView"];
    choiceView.frame = CGRectMake(16, rect.origin.y-123, 168, 115);
    choiceView.ChoiceResultViewType = ^(NSInteger tag){
        _switchResult = tag;
        NSString *imageStr;
        if(tag==0){
            imageStr = @"btn_switch_rnd";
        }else if(tag==1){
            imageStr = @"btn_switch_rnv";
        }else{
            imageStr = @"btn_switch_anv";
        }
        [sender setImage:kImageWithName(imageStr) forState:UIControlStateNormal];
    };
    [bgView addSubview:choiceView];
    [[UIApplication sharedApplication].keyWindow addSubview:bgView];
}

- (void)removeMenuView:(UIGestureRecognizer*)tap{
    [tap.view removeFromSuperview];
}

#pragma mark - Method
//tool中按钮点击操作
- (void)buttonClicked:(UIButton*)sender{
    switch (sender.tag) {
        case 201:{
            [self dismissKeyboard];
        }
            break;
        case 202:{
            InviteAnswerViewController *vc = [[InviteAnswerViewController alloc] init];
            vc.tdModel = self.tdModel;
            vc.isAt = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 203:{
            [self dismissKeyboard];
            [self openPhoto];
        }
            break;
        case 204:{
            [self initFontView];
        }
            break;
        default:
            break;
    }
}

- (void)choiceImageOrCamera{
    if([UIDevice currentDevice].systemVersion.intValue >= 8){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
            
        }];
        [cancelAction setValue:HEX_COLOR(@"040000") forKey:@"_titleTextColor"];
        UIAlertAction* imageAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault                                                                 handler:^(UIAlertAction * action) {
            [self openPhoto];
        }];
        [imageAction setValue:HEX_COLOR(@"040000") forKey:@"_titleTextColor"];
        
        UIAlertAction* cameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault                                                             handler:^(UIAlertAction * action) {
            [self openCamera];
        }];
        [cameraAction setValue:HEX_COLOR(@"040000") forKey:@"_titleTextColor"];
        [alertController addAction:cancelAction];
        [alertController addAction:imageAction];
        [alertController addAction:cameraAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else{
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相册",@"相机", nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        actionSheet.delegate = self;
        actionSheet.tag = 301;
        [actionSheet showInView:self.view];
    }
}

- (void)openPhoto{
    ALAuthorizationStatus author =[ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied)
    {
        //无权限
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        });
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"请在iPhone的“设置>隐私>相机”选项中，允许3号圈访问你的相册" cancelButtonTitle:@"取消" otherButtonTitle:@"设置" cancle:^{
        } confirm:^{
            if(IOS_X >= 10){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
            }
        }];
        return;

    }
//    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//        if(granted){
//        }else{
//                   }
//    }];
    UIImagePickerController *ctrl = [[UIImagePickerController alloc] init];
    ctrl.delegate = self;
//    ctrl.allowsEditing = YES;
    [self setNavigationBar_white];
    ctrl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    }
    [self presentViewController:ctrl animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

#pragma mark -- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self setNavigationBar_kdefaultColor];
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    
    NSString *imageName = [NSString stringWithFormat:@"%@.png", [NSDate stringFromDate:[NSDate date] format:kTimeFormatSmallLong3]];
    NSString *imagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:imageName];
    [self focusTextEditor];
    [self insertHTML:@"<br /><br />"];
    [self insertImage:GIF_LOADING_IMAGE alt:imagePath];
    [self focusTextEditor];
    [self filterImageHTML];
    
    [self saveImage:image withName:imageName];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self uploadImageHttp:imagePath];
}

//通过本地图片路径上传图片
- (void)uploadImageHttp:(NSString *)imagePath{
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    [requestDict setObject:imageData forKey:@"pphoto"];
    [self requstType:RequestType_UPLOAD_IMG apiName:API_NAME_UPLOAD_IMAGE paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            NSString *urlStr = [responseObject objectForKey:@"msg"];
            if(urlStr && urlStr.length){
                self.internalHTML = [[self getHTML] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"src=\"%@\" alt=\"%@\"", GIF_LOADING_IMAGE, imagePath] withString:[NSString stringWithFormat:@"src=\"%@\"",urlStr]];
                [self updateHTML];
                [self filterImageHTML];
                [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

//保存到临时文件夹
- (void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName{
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 1);
    NSString *fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:imageName];
    [imageData writeToFile:fullPath atomically:NO];
}

//遍历临时文件夹
- (void)uploadImageInTemporaryDirectory{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *tempFiles = [fm subpathsAtPath:NSTemporaryDirectory()];
    for (NSString *subFolder in tempFiles) {
        if([subFolder hasSuffix:@".png"]){
            NSString *imagePath = [NSString stringWithFormat:@"%@/%@", NSTemporaryDirectory(), subFolder];
            [self uploadImageHttp:imagePath];
        }
    }
}

//清空临时文件夹
- (void)cleanTemporaryDirectory{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *tempFiles = [fm subpathsAtPath:NSTemporaryDirectory()];
    for (NSString *subFolder in tempFiles) {
        if([subFolder hasSuffix:@".png"]){
            NSString *imagePath = [NSString stringWithFormat:@"%@/%@", NSTemporaryDirectory(), subFolder];
            [fm removeItemAtPath:imagePath error:nil];
        }
    }
}

- (void)filterImageHTML{
    NSString *htmlStr = [self getHTML];
    NSLog(@"%@", htmlStr);
    NSScanner *scanner = [NSScanner scannerWithString:htmlStr];
    NSString *text = nil;
    NSString *style = @"style=\"max-width: 100%; height: auto; object-fit:scale-down;\"";
    while([scanner isAtEnd]==NO){
        //找到标签的起始位置
        [scanner scanUpToString:@"<img" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        if(![text containsString:style]){
            htmlStr = [htmlStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:[NSString stringWithFormat:@" <img %@%@>",style,[text substringFromIndex:4]]];
        }
    }
    NSLog(@"%@", htmlStr);
    [self setHTML:htmlStr];
}

//点击cancel 调用的方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self setNavigationBar_kdefaultColor];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)setNavigationBar_kdefaultColor{
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setTintColor:WHITE_COLOR];
    [[UINavigationBar appearance] setBarTintColor:kDefaultColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:WHITE_COLOR,NSFontAttributeName:FONT_SYSTEM_SIZE(17)}];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)setNavigationBar_white{
    [[UINavigationBar appearance] setBackgroundImage:kImageWithColor(WHITE_COLOR, CGRectMake(0, 0, WIDTH, 1)) forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:kImageWithColor(WHITE_COLOR, CGRectMake(0, 0, WIDTH, 1))];
    [[UINavigationBar appearance] setTintColor:HEX_COLOR(@"383838")];
    [[UINavigationBar appearance] setBarTintColor:WHITE_COLOR];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:HEX_COLOR(@"383838"),NSFontAttributeName:FONT_SYSTEM_SIZE(17)}];
}

- (void)openCamera{
    NSArray *mediatypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] || [mediatypes count]<=0){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"错误信息!" message:@"当前设备不支持拍摄功能" delegate:self cancelButtonTitle:@"确认" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        //判断相机是否能够使用
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(status == AVAuthorizationStatusAuthorized) {
            // authorized
            [self presentViewController:imagePicker animated:YES completion:NULL];
        } else if(status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied){
            // restricted
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"无法使用相机" message:@"请在“设置-隐私-相机”选项中允许访问你的相机" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
            });
        } else if(status == AVAuthorizationStatusNotDetermined){
            // not determined
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){//用户尚未做出选择这个应用程序的问候
                    UIImagePickerController* imagePickerTmp = [[UIImagePickerController alloc] init];
                    imagePickerTmp.delegate = self;
                    imagePickerTmp.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [self presentViewController:imagePickerTmp animated:YES completion:NULL];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[UIAlertView alloc] initWithTitle:@"无法使用相机" message:@"请在“设置-隐私-相机”选项中允许访问你的相机" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
                    });
                }
            }];
        }
    }
}


#pragma mark-初始化分割线键盘
- (void)initLinesView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 300)];//[self findKeyboard];
    CGRect frame = CGRectMake(0, HEIGHT-view.frame.size.height-45, WIDTH, view.frame.size.height+45);
    self.linesView = [[UIView alloc] initWithFrame:frame];
    self.linesView.backgroundColor = [UIColor whiteColor];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 45)];
    [self.linesView addSubview:toolBar];
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneBtn setTitle:@"取消" forState:UIControlStateNormal];
    doneBtn.frame = CGRectMake(0, 5, 60, 35);
    [doneBtn setTitleColor:kDefaultColor forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(doneLineViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *doneBtnItem = [[UIBarButtonItem alloc]initWithCustomView:doneBtn];
    
    UIBarButtonItem *spaceBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    NSArray * buttonsArray = [NSArray arrayWithObjects: spaceBtnItem, doneBtnItem,nil];
    [toolBar setItems:buttonsArray];
    
    for(int i=0; i < 1; i++){//4
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *imageName = [NSString stringWithFormat:@"splitline_0%d",i+1];
        [btn setImage:kImageWithName(imageName) forState:UIControlStateNormal];
        [btn setImage:[kImageWithName(imageName) imageWithColor:kDefaultColor] forState:UIControlStateSelected];
        btn.frame = CGRectMake(0, 45+i*view.frame.size.height/4, WIDTH, view.frame.size.height/4);
        btn.tag = i+201;
        [btn addTarget:self action:@selector(addSpliteLine:) forControlEvents:UIControlEventTouchUpInside];
        if(self.selectedLineBtn && self.selectedLineBtn.tag == btn.tag){
            self.selectedLineBtn = btn;
            [btn setSelected:YES];
        }
        [self.linesView addSubview:btn];
    }
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    [window addSubview:self.linesView];
}

//添加分割线
- (void)addSpliteLine:(UIButton*)sender{
    [self setHR];
    [self.linesView removeFromSuperview];
    return;
    if(sender == self.selectedLineBtn){
        [self.selectedLineBtn setSelected:NO];
        self.selectedLineBtn = nil;
    }else{
        if(self.selectedLineBtn){
            [self.selectedLineBtn setSelected:NO];
        }
        self.selectedLineBtn = sender;
        [self.selectedLineBtn setSelected:YES];
    }
}


#pragma mark-初始化字体大小键盘
- (void)initFontView{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 300)];//[self findKeyboard];
    CGRect frame = CGRectMake(0, HEIGHT-view.frame.size.height-45, WIDTH, view.frame.size.height+45);
    self.fontView = [[UIView alloc] initWithFrame:frame];
    self.fontView.backgroundColor = [UIColor whiteColor];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 45)];
    [self.fontView addSubview:toolBar];
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    doneBtn.frame = CGRectMake(0, 5, 60, 35);
    [doneBtn setTitleColor:kDefaultColor forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(doneFontViewClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *doneBtnItem = [[UIBarButtonItem alloc]initWithCustomView:doneBtn];
    
    UIBarButtonItem *spaceBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    NSArray * buttonsArray = [NSArray arrayWithObjects: spaceBtnItem, doneBtnItem,nil];
    [toolBar setItems:buttonsArray];
    
    NSString *titleKey = @"title";
    NSString *fontKey = @"font";
    NSString *colorKey = @"color";
    NSArray *titleArray = @[@{titleKey:@"大标题", fontKey:@(20), colorKey:@"040000"},@{titleKey:@"小标题", fontKey:@(19), colorKey:@"040000"},@{titleKey:@"正文", fontKey:@(18), colorKey:@"040000"},@{titleKey:@"引用", fontKey:@(15), colorKey:@"666666"}];
    for(int i=0; i < 4; i++){
        NSDictionary *dict = titleArray[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:dict[titleKey] forState:UIControlStateNormal];
        [btn setTitleColor:HEX_COLOR(dict[colorKey]) forState:UIControlStateNormal];
        [btn setTitleColor:kDefaultColor forState:UIControlStateSelected];
        [btn setImage:[kImageWithName(@"gouHao") imageWithColor:WHITE_COLOR] forState:UIControlStateNormal];
        [btn setImage:[kImageWithName(@"gouHao") imageWithColor:kDefaultColor] forState:UIControlStateSelected];
        UIImage *imgArrow = [UIImage imageNamed:@"gouHao"];
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -imgArrow.size.width, 0, imgArrow.size.width)];
        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, [NSHelper widthOfString:btn.titleLabel.text font:btn.titleLabel.font height:btn.frame.size.height]+23, 0, -([NSHelper widthOfString:btn.titleLabel.text font:btn.titleLabel.font height:btn.frame.size.height]+23))];
        if(i<2){
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:[dict[fontKey] integerValue]];
        }else{
            btn.titleLabel.font = [UIFont systemFontOfSize:[dict[fontKey] integerValue]];
        }
        btn.frame = CGRectMake(0, 45+i*view.frame.size.height/4, WIDTH, view.frame.size.height/4);
        btn.tag = i+201;
        [btn addTarget:self action:@selector(modifyFont:) forControlEvents:UIControlEventTouchUpInside];
        if(self.selectedFontBtn && self.selectedFontBtn.tag == btn.tag){
            [btn setSelected:YES];
            self.selectedFontBtn = btn;
        }
        [self.fontView addSubview:btn];
    }
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    [window addSubview:self.fontView];
}

- (void)modifyFont:(UIButton*)sender{
    if(sender == self.selectedFontBtn){
        [self.selectedFontBtn setSelected:NO];
        self.selectedFontBtn = nil;
    }else{
        if(self.selectedFontBtn){
            [self.selectedFontBtn setSelected:NO];
        }
        self.selectedFontBtn = sender;
        [self.selectedFontBtn setSelected:YES];
    }
}

- (void)doneFontViewClicked:(UIButton*)sender{
    if(self.selectedFontBtn){
        switch (self.selectedFontBtn.tag-201) {
            case 0:
                [self heading2];
                break;
            case 1:
                [self heading3];
                break;
            case 2:
                [self paragraph];
                break;
            case 3:
                [self heading6];
                break;
                
            default:
                break;
        }
    }
    [self.fontView removeFromSuperview];
}

- (UIView *)findKeyboard{
    UIView *keyboardView = nil;
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in [windows reverseObjectEnumerator]){
        keyboardView = [self findKeyboardInView:window];
        if (keyboardView){
            return keyboardView;
        }
    }
    return nil;
}

- (UIView *)findKeyboardInView:(UIView *)view{
    for (UIView *subView in [view subviews]){
        if (strstr(object_getClassName(subView), "UIKeyboard")){
            return subView;
        }else{
            UIView *tempView = [self findKeyboardInView:subView];
            if (tempView){
                return tempView;
            }
        }
    }
    return nil;
}

- (void)setEnabledToolbarItems:(NSArray *)enabledToolbarItems {
    _enabledToolbarItems = enabledToolbarItems;
    [self buildToolbar];
}


- (void)setToolbarItemTintColor:(UIColor *)toolbarItemTintColor {
    
    _toolbarItemTintColor = toolbarItemTintColor;
    
    // Update the color
    for (ZSSBarButtonItem *item in self.toolbar.items) {
        item.tintColor = [self barButtonItemDefaultColor];
    }
    self.keyboardItem.tintColor = toolbarItemTintColor;
    
}


- (void)setToolbarItemSelectedTintColor:(UIColor *)toolbarItemSelectedTintColor {
    
    _toolbarItemSelectedTintColor = toolbarItemSelectedTintColor;
    
}


- (void)setPlaceholderText {
    
    NSString *js = [NSString stringWithFormat:@"zss_editor.setPlaceholder(\"%@\");", self.placeholder];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
    
}

- (void)setFooterHeight:(float)footerHeight {
    
    NSString *js = [NSString stringWithFormat:@"zss_editor.setFooterHeight(\"%f\");", footerHeight];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
}

- (void)setContentHeight:(float)contentHeight {
    
    NSString *js = [NSString stringWithFormat:@"zss_editor.contentHeight = %f;", contentHeight];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
}


- (NSArray *)itemsForToolbar {
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    // None
    if(_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarNone])
    {
        return items;
    }
    
    // Bold
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarBold]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *bold = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSbold.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setBold)];
        bold.label = @"bold";
        [items addObject:bold];
    }
    
    // Italic
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarItalic]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *italic = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSitalic.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setItalic)];
        italic.label = @"italic";
        [items addObject:italic];
    }
    
    // Subscript
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarSubscript]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *subscript = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSsubscript.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setSubscript)];
        subscript.label = @"subscript";
        [items addObject:subscript];
    }
    
    // Superscript
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarSuperscript]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *superscript = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSsuperscript.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setSuperscript)];
        superscript.label = @"superscript";
        [items addObject:superscript];
    }
    
    // Strike Through
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarStrikeThrough]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *strikeThrough = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSstrikethrough.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setStrikethrough)];
        strikeThrough.label = @"strikeThrough";
        [items addObject:strikeThrough];
    }
    
    // Underline
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarUnderline]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *underline = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSunderline.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setUnderline)];
        underline.label = @"underline";
        [items addObject:underline];
    }
    
    // Remove Format
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarRemoveFormat]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *removeFormat = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSclearstyle.png"] style:UIBarButtonItemStylePlain target:self action:@selector(removeFormat)];
        removeFormat.label = @"removeFormat";
        [items addObject:removeFormat];
    }
    
    // Undo
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarUndo]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *undoButton = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSundo.png"] style:UIBarButtonItemStylePlain target:self action:@selector(undo:)];
        undoButton.label = @"undo";
        [items addObject:undoButton];
    }
    
    // Redo
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarRedo]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *redoButton = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSredo.png"] style:UIBarButtonItemStylePlain target:self action:@selector(redo:)];
        redoButton.label = @"redo";
        [items addObject:redoButton];
    }
    
    // Align Left
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarJustifyLeft]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *alignLeft = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSleftjustify.png"] style:UIBarButtonItemStylePlain target:self action:@selector(alignLeft)];
        alignLeft.label = @"justifyLeft";
        [items addObject:alignLeft];
    }
    
    // Align Center
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarJustifyCenter]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *alignCenter = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSScenterjustify.png"] style:UIBarButtonItemStylePlain target:self action:@selector(alignCenter)];
        alignCenter.label = @"justifyCenter";
        [items addObject:alignCenter];
    }
    
    // Align Right
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarJustifyRight]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *alignRight = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSrightjustify.png"] style:UIBarButtonItemStylePlain target:self action:@selector(alignRight)];
        alignRight.label = @"justifyRight";
        [items addObject:alignRight];
    }
    
    // Align Justify
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarJustifyFull]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *alignFull = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSforcejustify.png"] style:UIBarButtonItemStylePlain target:self action:@selector(alignFull)];
        alignFull.label = @"justifyFull";
        [items addObject:alignFull];
    }
    
    // Paragraph
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarParagraph]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *paragraph = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSparagraph.png"] style:UIBarButtonItemStylePlain target:self action:@selector(paragraph)];
        paragraph.label = @"p";
        [items addObject:paragraph];
    }
    
    // Header 1
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH1]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h1 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh1.png"] style:UIBarButtonItemStylePlain target:self action:@selector(heading1)];
        h1.label = @"h1";
        [items addObject:h1];
    }
    
    // Header 2
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH2]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h2 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh2.png"] style:UIBarButtonItemStylePlain target:self action:@selector(heading2)];
        h2.label = @"h2";
        [items addObject:h2];
    }
    
    // Header 3
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH3]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h3 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh3.png"] style:UIBarButtonItemStylePlain target:self action:@selector(heading3)];
        h3.label = @"h3";
        [items addObject:h3];
    }
    
    // Heading 4
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH4]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h4 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh4.png"] style:UIBarButtonItemStylePlain target:self action:@selector(heading4)];
        h4.label = @"h4";
        [items addObject:h4];
    }
    
    // Header 5
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH5]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h5 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh5.png"] style:UIBarButtonItemStylePlain target:self action:@selector(heading5)];
        h5.label = @"h5";
        [items addObject:h5];
    }
    
    // Heading 6
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarH6]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *h6 = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSh6.png"] style:UIBarButtonItemStylePlain target:self action:@selector(heading6)];
        h6.label = @"h6";
        [items addObject:h6];
    }
    
    // Text Color
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarTextColor]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *textColor = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSStextcolor.png"] style:UIBarButtonItemStylePlain target:self action:@selector(textColor)];
        textColor.label = @"textColor";
        [items addObject:textColor];
    }
    
    // Background Color
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarBackgroundColor]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *bgColor = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSbgcolor.png"] style:UIBarButtonItemStylePlain target:self action:@selector(bgColor)];
        bgColor.label = @"backgroundColor";
        [items addObject:bgColor];
    }
    
    // Unordered List
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarUnorderedList]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *ul = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSunorderedlist.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setUnorderedList)];
        ul.label = @"unorderedList";
        [items addObject:ul];
    }
    
    // Ordered List
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarOrderedList]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *ol = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSorderedlist.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setOrderedList)];
        ol.label = @"orderedList";
        [items addObject:ol];
    }
    
    // Horizontal Rule
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarHorizontalRule]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *hr = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSShorizontalrule.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setHR)];
        hr.label = @"horizontalRule";
        [items addObject:hr];
    }
    
    // Indent
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarIndent]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *indent = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSindent.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setIndent)];
        indent.label = @"indent";
        [items addObject:indent];
    }
    
    // Outdent
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarOutdent]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *outdent = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSoutdent.png"] style:UIBarButtonItemStylePlain target:self action:@selector(setOutdent)];
        outdent.label = @"outdent";
        [items addObject:outdent];
    }
    
    // Image
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarInsertImage]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *insertImage = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSimage.png"] style:UIBarButtonItemStylePlain target:self action:@selector(insertImage)];
        insertImage.label = @"image";
        [items addObject:insertImage];
    }
    
    // Insert Link
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarInsertLink]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *insertLink = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSlink.png"] style:UIBarButtonItemStylePlain target:self action:@selector(insertLink)];
        insertLink.label = @"link";
        [items addObject:insertLink];
    }
    
    // Remove Link
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarRemoveLink]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *removeLink = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSunlink.png"] style:UIBarButtonItemStylePlain target:self action:@selector(removeLink)];
        removeLink.label = @"removeLink";
        [items addObject:removeLink];
    }
    
    // Quick Link
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarQuickLink]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *quickLink = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSquicklink.png"] style:UIBarButtonItemStylePlain target:self action:@selector(quickLink)];
        quickLink.label = @"quickLink";
        [items addObject:quickLink];
    }
    
    // Show Source
    if ((_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarViewSource]) || (_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarAll])) {
        ZSSBarButtonItem *showSource = [[ZSSBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ZSSviewsource.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showHTMLSource:)];
        showSource.label = @"source";
        [items addObject:showSource];
    }
    
    return [NSArray arrayWithArray:items];
    
}


- (void)buildToolbar {
    
    // Check to see if we have any toolbar items, if not, add them all
    NSArray *items = [self itemsForToolbar];
    if (items.count == 0 && !(_enabledToolbarItems && [_enabledToolbarItems containsObject:ZSSRichTextEditorToolbarNone])) {
        _enabledToolbarItems = @[ZSSRichTextEditorToolbarAll];
        items = [self itemsForToolbar];
    }
    
    if (self.customZSSBarButtonItems != nil) {
        items = [items arrayByAddingObjectsFromArray:self.customZSSBarButtonItems];
    }
    
    // get the width before we add custom buttons
    CGFloat toolbarWidth = items.count == 0 ? 0.0f : (CGFloat)(items.count * 39) - 10;
    
    if(self.customBarButtonItems != nil)
    {
        items = [items arrayByAddingObjectsFromArray:self.customBarButtonItems];
        for(ZSSBarButtonItem *buttonItem in self.customBarButtonItems)
        {
            toolbarWidth += buttonItem.customView.frame.size.width + 11.0f;
        }
    }
    
    self.toolbar.items = items;
    for (ZSSBarButtonItem *item in items) {
        item.tintColor = [self barButtonItemDefaultColor];
    }
    
    self.toolbar.frame = CGRectMake(0, 0, toolbarWidth, 44);
    self.toolBarScroll.contentSize = CGSizeMake(self.toolbar.frame.size.width, 44);
}

#pragma mark - Editor Interaction

- (void)focusTextEditor {
    self.editorView.keyboardDisplayRequiresUserAction = NO;
    NSString *js = [NSString stringWithFormat:@"zss_editor.focusEditor();"];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
}

- (void)blurTextEditor {
    NSString *js = [NSString stringWithFormat:@"zss_editor.blurEditor();"];
    [self.editorView stringByEvaluatingJavaScriptFromString:js];
}

- (void)setHTML:(NSString *)html {
    
    self.internalHTML = html;
    
    if (self.editorLoaded) {
        [self updateHTML];
    }
    
}

- (void)updateHTML {
    
    NSString *html = self.internalHTML;
    self.sourceView.text = html;
    NSString *cleanedHTML = [self removeQuotesFromHTML:self.sourceView.text];
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.setHTML(\"%@\");", cleanedHTML];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    [self hideOrShowPlaceHolderContentLabel];
}

- (NSString *)getHTML {
    NSString *html = [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.getHTML();"];
    html = [self removeQuotesFromHTML:html];
    html = [self tidyHTML:html];
    return html;
}


- (void)insertHTML:(NSString *)html {
    NSString *cleanedHTML = [self removeQuotesFromHTML:html];
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertHTML(\"%@\");", cleanedHTML];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (NSString *)getText {
    return [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.getText();"];
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)showHTMLSource:(ZSSBarButtonItem *)barButtonItem {
    if (self.sourceView.hidden) {
        self.sourceView.text = [self getHTML];
        self.sourceView.hidden = NO;
        barButtonItem.tintColor = [UIColor blackColor];
        self.editorView.hidden = YES;
        [self enableToolbarItems:NO];
    } else {
        [self setHTML:self.sourceView.text];
        barButtonItem.tintColor = [self barButtonItemDefaultColor];
        self.sourceView.hidden = YES;
        self.editorView.hidden = NO;
        [self enableToolbarItems:YES];
    }
}

- (void)removeFormat {
    NSString *trigger = @"zss_editor.removeFormating();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)alignLeft {
    NSString *trigger = @"zss_editor.setJustifyLeft();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)alignCenter {
    NSString *trigger = @"zss_editor.setJustifyCenter();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)alignRight {
    NSString *trigger = @"zss_editor.setJustifyRight();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)alignFull {
    NSString *trigger = @"zss_editor.setJustifyFull();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setBold {
    NSString *trigger = @"zss_editor.setBold();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setItalic {
    NSString *trigger = @"zss_editor.setItalic();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setSubscript {
    NSString *trigger = @"zss_editor.setSubscript();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setUnderline {
    NSString *trigger = @"zss_editor.setUnderline();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setSuperscript {
    NSString *trigger = @"zss_editor.setSuperscript();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setStrikethrough {
    NSString *trigger = @"zss_editor.setStrikeThrough();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setUnorderedList {
    NSString *trigger = @"zss_editor.setUnorderedList();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setOrderedList {
    NSString *trigger = @"zss_editor.setOrderedList();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setHR {
    NSString *trigger = @"zss_editor.setHorizontalRule();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setIndent {
    NSString *trigger = @"zss_editor.setIndent();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)setOutdent {
    NSString *trigger = @"zss_editor.setOutdent();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading1 {
    NSString *trigger = @"zss_editor.setHeading('h1');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading2 {
    NSString *trigger = @"zss_editor.setHeading('h2');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading3 {
    NSString *trigger = @"zss_editor.setHeading('h3');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading4 {
    NSString *trigger = @"zss_editor.setHeading('h4');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading5 {
    NSString *trigger = @"zss_editor.setHeading('h5');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)heading6 {
    NSString *trigger = @"zss_editor.setHeading('h6');";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)paragraph {
    NSString *trigger = @"zss_editor.setParagraph();";
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)textColor {
    
    // Save the selection location
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.prepareInsert();"];
    
    // Call the picker
    HRColorPickerViewController *colorPicker = [HRColorPickerViewController cancelableFullColorPickerViewControllerWithColor:[UIColor whiteColor]];
    colorPicker.delegate = self;
    colorPicker.tag = 1;
    colorPicker.title = NSLocalizedString(@"Text Color", nil);
    [self.navigationController pushViewController:colorPicker animated:YES];
    
}

- (void)bgColor {
    
    // Save the selection location
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.prepareInsert();"];
    
    // Call the picker
    HRColorPickerViewController *colorPicker = [HRColorPickerViewController cancelableFullColorPickerViewControllerWithColor:[UIColor whiteColor]];
    colorPicker.delegate = self;
    colorPicker.tag = 2;
    colorPicker.title = NSLocalizedString(@"BG Color", nil);
    [self.navigationController pushViewController:colorPicker animated:YES];
    
}

- (void)setSelectedColor:(UIColor*)color tag:(int)tag {
    
    NSString *hex = [NSString stringWithFormat:@"#%06x",HexColorFromUIColor(color)];
    NSString *trigger;
    if (tag == 1) {
        trigger = [NSString stringWithFormat:@"zss_editor.setTextColor(\"%@\");", hex];
    } else if (tag == 2) {
        trigger = [NSString stringWithFormat:@"zss_editor.setBackgroundColor(\"%@\");", hex];
    }
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    
}

- (void)undo:(ZSSBarButtonItem *)barButtonItem {
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.undo();"];
}

- (void)redo:(ZSSBarButtonItem *)barButtonItem {
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.redo();"];
}

- (void)insertLink {
    
    // Save the selection location
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.prepareInsert();"];
    
    // Show the dialog for inserting or editing a link
    [self showInsertLinkDialogWithLink:self.selectedLinkURL title:self.selectedLinkTitle];
    
}


- (void)showInsertLinkDialogWithLink:(NSString *)url title:(NSString *)title {
    
    // Insert Button Title
    NSString *insertButtonTitle = !self.selectedLinkURL ? NSLocalizedString(@"Insert", nil) : NSLocalizedString(@"Update", nil);
    
    // Picker Button
    UIButton *am = [UIButton buttonWithType:UIButtonTypeCustom];
    am.frame = CGRectMake(0, 0, 25, 25);
    [am setImage:[UIImage imageNamed:@"ZSSpicker.png"] forState:UIControlStateNormal];
    [am addTarget:self action:@selector(showInsertURLAlternatePicker) forControlEvents:UIControlEventTouchUpInside];
    
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Insert Link", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"URL (required)", nil);
            if (url) {
                textField.text = url;
            }
            textField.rightView = am;
            textField.rightViewMode = UITextFieldViewModeAlways;
            textField.clearButtonMode = UITextFieldViewModeAlways;
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"Title", nil);
            textField.clearButtonMode = UITextFieldViewModeAlways;
            textField.secureTextEntry = NO;
            if (title) {
                textField.text = title;
            }
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self focusTextEditor];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:insertButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            UITextField *linkURL = [alertController.textFields objectAtIndex:0];
            UITextField *title = [alertController.textFields objectAtIndex:1];
            if (!self.selectedLinkURL) {
                [self insertLink:linkURL.text title:title.text];
            } else {
                [self updateLink:linkURL.text title:title.text];
            }
            [self focusTextEditor];
        }]];
        [self presentViewController:alertController animated:YES completion:NULL];
        
    } else {
        
        self.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Insert Link", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:insertButtonTitle, nil];
        self.alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        self.alertView.tag = 2;
        UITextField *linkURL = [self.alertView textFieldAtIndex:0];
        linkURL.placeholder = NSLocalizedString(@"URL (required)", nil);
        if (url) {
            linkURL.text = url;
        }
        
        linkURL.rightView = am;
        linkURL.rightViewMode = UITextFieldViewModeAlways;
        
        UITextField *alt = [self.alertView textFieldAtIndex:1];
        alt.secureTextEntry = NO;
        alt.placeholder = NSLocalizedString(@"Title", nil);
        if (title) {
            alt.text = title;
        }
        
        [self.alertView show];
    }
    
}


- (void)insertLink:(NSString *)url title:(NSString *)title {
    
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertLink(\"%@\", \"%@\");", url, title];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
    
}


- (void)updateLink:(NSString *)url title:(NSString *)title {
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.updateLink(\"%@\", \"%@\");", url, title];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}


- (void)dismissAlertView {
    [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:YES];
}

- (void)addCustomToolbarItemWithButton:(UIButton *)button
{
    if(self.customBarButtonItems == nil)
    {
        self.customBarButtonItems = [NSMutableArray array];
    }
    
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:28.5f];
    [button setTitleColor:[self barButtonItemDefaultColor] forState:UIControlStateNormal];
    [button setTitleColor:[self barButtonItemSelectedDefaultColor] forState:UIControlStateHighlighted];
    
    ZSSBarButtonItem *barButtonItem = [[ZSSBarButtonItem alloc] initWithCustomView:button];
    
    [self.customBarButtonItems addObject:barButtonItem];
    
    [self buildToolbar];
}

- (void)addCustomToolbarItem:(ZSSBarButtonItem *)item {
    
    if(self.customZSSBarButtonItems == nil)
    {
        self.customZSSBarButtonItems = [NSMutableArray array];
    }
    [self.customZSSBarButtonItems addObject:item];
    
    [self buildToolbar];
}


- (void)removeLink {
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.unlink();"];
}//end

- (void)quickLink {
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.quickLink();"];
}

- (void)insertImage {
    
    // Save the selection location
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.prepareInsert();"];
    
    [self showInsertImageDialogWithLink:self.selectedImageURL alt:self.selectedImageAlt];
    
}

- (void)showInsertImageDialogWithLink:(NSString *)url alt:(NSString *)alt {
    
    // Insert Button Title
    NSString *insertButtonTitle = !self.selectedImageURL ? NSLocalizedString(@"Insert", nil) : NSLocalizedString(@"Update", nil);
    
    // Picker Button
    UIButton *am = [UIButton buttonWithType:UIButtonTypeCustom];
    am.frame = CGRectMake(0, 0, 25, 25);
    [am setImage:[UIImage imageNamed:@"ZSSpicker.png"] forState:UIControlStateNormal];
    [am addTarget:self action:@selector(showInsertImageAlternatePicker) forControlEvents:UIControlEventTouchUpInside];
    
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)]) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Insert Image", nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"URL (required)", nil);
            if (url) {
                textField.text = url;
            }
            textField.rightView = am;
            textField.rightViewMode = UITextFieldViewModeAlways;
            textField.clearButtonMode = UITextFieldViewModeAlways;
        }];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"Alt", nil);
            textField.clearButtonMode = UITextFieldViewModeAlways;
            textField.secureTextEntry = NO;
            if (alt) {
                textField.text = alt;
            }
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [self focusTextEditor];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:insertButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            UITextField *imageURL = [alertController.textFields objectAtIndex:0];
            UITextField *alt = [alertController.textFields objectAtIndex:1];
            if (!self.selectedImageURL) {
                [self insertImage:imageURL.text alt:alt.text];
            } else {
                [self updateImage:imageURL.text alt:alt.text];
            }
            [self focusTextEditor];
        }]];
        [self presentViewController:alertController animated:YES completion:NULL];
        
    } else {
        
        self.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Insert Image", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:insertButtonTitle, nil];
        self.alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        self.alertView.tag = 1;
        UITextField *imageURL = [self.alertView textFieldAtIndex:0];
        imageURL.placeholder = NSLocalizedString(@"URL (required)", nil);
        if (url) {
            imageURL.text = url;
        }
        
        imageURL.rightView = am;
        imageURL.rightViewMode = UITextFieldViewModeAlways;
        imageURL.clearButtonMode = UITextFieldViewModeAlways;
        
        UITextField *alt1 = [self.alertView textFieldAtIndex:1];
        alt1.secureTextEntry = NO;
        alt1.placeholder = NSLocalizedString(@"Alt", nil);
        alt1.clearButtonMode = UITextFieldViewModeAlways;
        if (alt) {
            alt1.text = alt;
        }
        
        [self.alertView show];
    }
}

- (void)insertImage:(NSString *)url alt:(NSString *)alt {
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.prepareInsert();"];
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.insertImage(\"%@\", \"%@\");", url, alt];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)updateImage:(NSString *)url alt:(NSString *)alt {
    [self.editorView stringByEvaluatingJavaScriptFromString:@"zss_editor.prepareInsert();"];
    NSString *trigger = [NSString stringWithFormat:@"zss_editor.updateImage(\"%@\", \"%@\");", url, alt];
    [self.editorView stringByEvaluatingJavaScriptFromString:trigger];
}

- (void)updateToolBarWithButtonName:(NSString *)name {
    // Items that are enabled
    NSArray *itemNames = [name componentsSeparatedByString:@","];
    // Special case for link
    NSMutableArray *itemsModified = [[NSMutableArray alloc] init];
    for (NSString *linkItem in itemNames) {
        NSString *updatedItem = linkItem;
        if ([linkItem hasPrefix:@"link:"]) {
            updatedItem = @"link";
            self.selectedLinkURL = [linkItem stringByReplacingOccurrencesOfString:@"link:" withString:@""];
        } else if ([linkItem hasPrefix:@"link-title:"]) {
            self.selectedLinkTitle = [self stringByDecodingURLFormat:[linkItem stringByReplacingOccurrencesOfString:@"link-title:" withString:@""]];
        } else if ([linkItem hasPrefix:@"image:"]) {
            updatedItem = @"image";
            self.selectedImageURL = [linkItem stringByReplacingOccurrencesOfString:@"image:" withString:@""];
        } else if ([linkItem hasPrefix:@"image-alt:"]) {
            self.selectedImageAlt = [self stringByDecodingURLFormat:[linkItem stringByReplacingOccurrencesOfString:@"image-alt:" withString:@""]];
        } else {
            self.selectedImageURL = nil;
            self.selectedImageAlt = nil;
            self.selectedLinkURL = nil;
            self.selectedLinkTitle = nil;
        }
        [itemsModified addObject:updatedItem];
    }
    itemNames = [NSArray arrayWithArray:itemsModified];
    
    self.editorItemsEnabled = itemNames;
    
    // Highlight items
    NSArray *items = self.toolbar.items;
    for (ZSSBarButtonItem *item in items) {
        if ([itemNames containsObject:item.label]) {
            item.tintColor = [self barButtonItemSelectedDefaultColor];
        } else {
            item.tintColor = [self barButtonItemDefaultColor];
        }
    }//end
    
}

//判断是否隐藏默认提示输入，按钮是否可点击
- (void)hideOrShowPlaceHolderContentLabel{
    BOOL hide;
    if([[self getText] length] == 0 && ![[self getHTML] containsString:@"<img"] && ![[self getHTML] containsString:@"<hr />"]){
        self.placeHolderContentLabel.hidden = NO;
        hide = NO;
    }else{
        self.placeHolderContentLabel.hidden = YES;
        hide = YES;
    }
    if(self.type == EditotType_Topic){
        self.nextBtn.enabled = YES;
    }else{
        if(hide == NO){
            self.nextBtn.enabled = NO;
        }else{
            self.nextBtn.enabled = YES;
        }
    }
}

#pragma mark - UIWebView Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"%@", [self getHTML]);
    if(_limitNum){
        if([self getText].length>_limitNum){
            [self setHTML:self.limitHtmlString];
            return NO;
        }else if ([self getText].length > _limitNum-50){
            self.limitNumLabel.text = [NSString stringWithFormat:@"剩余%ld个字", _limitNum - [self getText].length];
            self.limitHtmlString = [self getHTML];
        }else{
            self.limitNumLabel.text = @"";
            self.limitHtmlString = [self getHTML];
        }
        if([self getText].length == _limitNum){
            self.limitNumLabel.textColor = HEX_COLOR(@"e24943");
        }else{
            self.limitNumLabel.textColor = HEX_COLOR(@"afb6c1");
        }
    }
    [self hideOrShowPlaceHolderContentLabel];
    
    NSString *urlString = [[request URL] absoluteString];
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        return NO;
    } else if ([urlString rangeOfString:@"callback://0/"].location != NSNotFound) {
        
        // We recieved the callback
        NSString *className = [urlString stringByReplacingOccurrencesOfString:@"callback://0/" withString:@""];
        [self updateToolBarWithButtonName:className];
        
    } else if ([urlString rangeOfString:@"debug://"].location != NSNotFound) {
    //内存泄漏
        // We recieved the callback
        NSString *debug  = [urlString stringByReplacingOccurrencesOfString:@"debug://" withString:@""];
        debug = [debug stringByReplacingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy];
    } else if ([urlString rangeOfString:@"scroll://"].location != NSNotFound) {
        
        NSInteger position = [[urlString stringByReplacingOccurrencesOfString:@"scroll://" withString:@""] integerValue];
        [self editorDidScrollWithPosition:position];
        
    }else if ([urlString rangeOfString:@"applewebdata://"].location != NSNotFound){
//        [self focusTextEditor];
//        [self.sourceView becomeFirstResponder];
    }
    
    return YES;
    
}//end


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [self hideOrShowPlaceHolderContentLabel];
    
    self.editorLoaded = YES;
//    [self setPlaceholderText];
    if (!self.internalHTML) {
        self.internalHTML = @"";
    }
    [self updateHTML];
    if (self.shouldShowKeyboard) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self focusTextEditor];
        });
    }
}


#pragma mark - Callbacks
// Blank implementation
- (void)editorDidScrollWithPosition:(NSInteger)position {
    
    
}

#pragma mark - AlertView

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    
    if (alertView.tag == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        UITextField *textField2 = [alertView textFieldAtIndex:1];
        if ([textField.text length] == 0 || [textField2.text length] == 0) {
            return NO;
        }
    } else if (alertView.tag == 2) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        if ([textField.text length] == 0) {
            return NO;
        }
    }
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            UITextField *imageURL = [alertView textFieldAtIndex:0];
            UITextField *alt = [alertView textFieldAtIndex:1];
            if (!self.selectedImageURL) {
                [self insertImage:imageURL.text alt:alt.text];
            } else {
                [self updateImage:imageURL.text alt:alt.text];
            }
        }
    } else if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            UITextField *linkURL = [alertView textFieldAtIndex:0];
            UITextField *title = [alertView textFieldAtIndex:1];
            if (!self.selectedLinkURL) {
                [self insertLink:linkURL.text title:title.text];
            } else {
                [self updateLink:linkURL.text title:title.text];
            }
        }
    }
    
}


#pragma mark - Asset Picker

- (void)showInsertURLAlternatePicker {
    // Blank method. User should implement this in their subclass
}


- (void)showInsertImageAlternatePicker {
    // Blank method. User should implement this in their subclass
}


#pragma mark - Keyboard status
- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    [self hideOrShowPlaceHolderContentLabel];
    
    // Orientation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    // User Info
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    int curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    
    // Keyboard Size
    //Checks if IOS8, gets correct keyboard height
    CGFloat keyboardHeight = UIInterfaceOrientationIsLandscape(orientation) ? ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.000000) ? keyboardEnd.size.height : keyboardEnd.size.width : keyboardEnd.size.height;
    
    // Correct Curve
    UIViewAnimationOptions animationOptions = curve << 16;
    
    const int extraHeight = 10;
    
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        
        [UIView animateWithDuration:duration delay:0 options:animationOptions animations:^{
            // Toolbar
            if(_limitNum){
                self.toolbarHolder.frame = CGRectMake(0, HEIGHT-keyboardHeight-74, WIDTH, 74);
            }else{
                self.toolbarHolder.frame = CGRectMake(0, HEIGHT-keyboardHeight-44, WIDTH, 44);
            }
            // Toolbar Sizes
            CGFloat sizeOfToolbar = self.toolbarHolder.frame.size.height;
            
            // Editor View
            CGRect frame = CGRectMake(Start_X, Start_Y, WIDTH-Start_X*2, HEIGHT-keyboardHeight-sizeOfToolbar-Start_Y);
            self.editorView.frame = frame;
            self.editorViewFrame = self.editorView.frame;
            self.editorView.scrollView.contentInset = UIEdgeInsetsZero;
            self.editorView.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
            
            // Source View
            self.sourceView.frame = frame;
            
            // Provide editor with keyboard height and editor view height
            [self setFooterHeight:0];//(keyboardHeight - 8)];
            [self setContentHeight: self.editorViewFrame.size.height];
        } completion:nil];
    } else {
        [UIView animateWithDuration:duration delay:0 options:animationOptions animations:^{
            CGRect frame = self.toolbarHolder.frame;
            frame.origin.y = HEIGHT;
            self.toolbarHolder.frame = frame;
            
            frame = CGRectMake(Start_X, Start_Y, WIDTH-Start_X*2, HEIGHT-Start_Y);
            // Editor View
            self.editorView.frame = frame;//editorFrame;
            self.editorViewFrame = self.editorView.frame;
            self.editorView.scrollView.contentInset = UIEdgeInsetsZero;
            self.editorView.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
            
            // Source View
            self.sourceView.frame = frame;
        } completion:nil];
    }//end
}

#pragma mark - Utilities

- (NSString *)removeQuotesFromHTML:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    html = [html stringByReplacingOccurrencesOfString:@"“" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"”" withString:@"&quot;"];
    html = [html stringByReplacingOccurrencesOfString:@"\r"  withString:@"\\r"];
    html = [html stringByReplacingOccurrencesOfString:@"\n"  withString:@"\\n"];
    return html;
}//end


- (NSString *)tidyHTML:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"<br>" withString:@"<br />"];
    html = [html stringByReplacingOccurrencesOfString:@"<hr>" withString:@"<hr />"];
    if (self.formatHTML) {
        html = [self.editorView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"style_html(\"%@\");", html]];
    }
    return html;
}//end


- (UIColor *)barButtonItemDefaultColor {
    
    if (self.toolbarItemTintColor) {
        return self.toolbarItemTintColor;
    }
    
    return [UIColor colorWithRed:0.0f/255.0f green:122.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
}


- (UIColor *)barButtonItemSelectedDefaultColor {
    
    if (self.toolbarItemSelectedTintColor) {
        return self.toolbarItemSelectedTintColor;
    }
    
    return [UIColor blackColor];
}


- (BOOL)isIpad {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}//end


- (NSString *)stringByDecodingURLFormat:(NSString *)string {
    NSString *result = [string stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return result;
}


- (void)enableToolbarItems:(BOOL)enable {
    NSArray *items = self.toolbar.items;
    for (ZSSBarButtonItem *item in items) {
        if (![item.label isEqualToString:@"source"]) {
            item.enabled = enable;
        }
    }
}


@end
