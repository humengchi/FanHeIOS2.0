//
//  CreateDynamicController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/23.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "CreateDynamicController.h"
#import <objc/runtime.h>
#import "ZLPhoto.h"
#import "InviteAnswerViewController.h"
#import "AddUrlController.h"
#import "AllFriendsViewController.h"
#import "DynamicKeyWordController.h"

#define Start_X 13.0
#define Start_Y 73.0

@interface CreateDynamicController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UIWebViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,AddUrlControllerDelegate, MWPhotoBrowserDelegate, TZImagePickerControllerDelegate>{
    BOOL _isFirstBecome;
}

@property (nonatomic, strong) UIView *toolbarHolder;
@property (nonatomic, strong) IBOutlet UIButton *nextBtn;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSString *linkImage;
@property (nonatomic, weak)   IBOutlet UIWebView *editorView;

@property (nonatomic, strong) UILabel *placeHolderContentLabel;

@end

@implementation CreateDynamicController

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

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(_isFirstBecome){
        [self initDefaultPostsModel];
        _isFirstBecome = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isFirstBecome = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSData *data = UIImagePNGRepresentation(kImageWithName(@"icon_dt_link"));
    NSString *str = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    self.linkImage = [NSString stringWithFormat:@"<img src=\"data:image/png;base64,%@\">", str];
    
    self.view.backgroundColor = WHITE_COLOR;
    
    self.dataArray = [NSMutableArray array];
    [self initCollectionView];
    
    self.editorView.scrollView.scrollEnabled = NO;
    self.editorView.scrollView.bounces = NO;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"/CKEditor/demo.html" ofType:nil];
    [self.editorView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
    [self.editorView becomeFirstResponder];
    
    [self initToolBar];
    
    self.placeHolderContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, WIDTH-50, 20)];
    self.placeHolderContentLabel.userInteractionEnabled = NO;
    self.placeHolderContentLabel.text = @"分享工作动态，让更多金融人看到";
    self.placeHolderContentLabel.font = FONT_SYSTEM_SIZE(15);
    self.placeHolderContentLabel.textColor = HEX_COLOR(@"afb6c1");
    [self.editorView addSubview:self.placeHolderContentLabel];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self initDefaultPostsModel];
    });
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if(navigationType == UIWebViewNavigationTypeLinkClicked){
        return NO;
    }else{
        return YES;
    }
}

//选择的图片展示区
- (void)initCollectionView{
    //确定是水平滚动，还是垂直滚动
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:
     UICollectionViewScrollDirectionVertical];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame: CGRectMake(25, Start_Y+160, WIDTH-50, HEIGHT-Start_Y-160) collectionViewLayout:flowLayout];
    self.collectionView.dataSource=self;
    self.collectionView.delegate=self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    //注册Cell，必须要有
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [self.view addSubview:self.collectionView];
}

#pragma mark -- UICollectionViewDataSource
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(self.dataArray.count==0){
        return 0;
    }else if(self.dataArray.count != 9){
        return self.dataArray.count+1;
    }else{
        return self.dataArray.count;
    }
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"UICollectionViewCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    for(UIGestureRecognizer *gesture in cell.gestureRecognizers){
        [cell removeGestureRecognizer:gesture];
    }
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    CGFloat width = (WIDTH-50)/4.0-9-2;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 9, width, width)];
    [cell.contentView addSubview:imageView];
    if(indexPath.row>self.dataArray.count-1){
        imageView.image = kImageWithName(@"btn_add_img_b");
    }else{
        if([self.dataArray[indexPath.row] isKindOfClass:[UIImage class]]){
            UIImage *image = self.dataArray[indexPath.row];
            CGFloat width = MIN(image.size.width, image.size.height);
            imageView.image = [image scaleToSquareSize:width];
        }else{
            [imageView sd_setImageWithURL:[NSURL URLWithString:self.dataArray[indexPath.row]] placeholderImage:KSquareImageDefault completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if(image){
                    CGFloat width = MIN(image.size.width, image.size.height);
                    imageView.image = [image scaleToSquareSize:width];
                }
            }];
        }
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame = CGRectMake(width-9, 0, 18, 18);
        deleteBtn.tag = indexPath.row;
        [deleteBtn setImage:kImageWithName(@"btn_upl_img_c") forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:deleteBtn];
    }
    return cell;
}

- (void)deleteImage:(UIButton*)sender{
    [self.dataArray removeObjectAtIndex:sender.tag];
    [self.collectionView reloadData];
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((WIDTH-50)/4.0-2, (WIDTH-50)/4.0-2);
}

//定义每个section 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 1, 10, 1);
}

//每个item的间隔
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}

#pragma mark --UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row>self.dataArray.count-1){
        [self openPhoto];
    }else{
        [self photoButtonClicked:indexPath.row];
    }
}

//点击图片
- (void)photoButtonClicked:(NSUInteger)index{
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    photoBrowser.displayActionButton = YES;
    photoBrowser.displayNavArrows = YES;
    photoBrowser.displaySelectionButtons = NO;
    photoBrowser.alwaysShowControls = NO;
    photoBrowser.autoPlayOnAppear = NO;
    photoBrowser.zoomPhotosToFill = YES;
    photoBrowser.enableGrid = NO;
    photoBrowser.startOnGrid = NO;
    photoBrowser.enableSwipeToDismiss = YES;
    [photoBrowser setCurrentPhotoIndex:index];
    [self presentViewController:photoBrowser animated:YES completion:nil];
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.dataArray.count;
}

- (id )photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    MWPhoto *photo;
    if([self.dataArray[index] isKindOfClass:[UIImage class]]){
        photo = [MWPhoto photoWithImage:self.dataArray[index]];
    }else{
        NSURL *url = [NSURL URLWithString:self.dataArray[index]];
        photo = [MWPhoto photoWithURL:url];
    }
    return photo;
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- 如果有历史记录则显示
- (void)initDefaultPostsModel{
    [self focusTextEditor];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:SAVE_DYNAMIC_MODEL];
    if(data){
        DynamicSaveModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSString *tmpContent = [CommonMethod paramStringIsNull:model.content];
        if(tmpContent.length){
            self.placeHolderContentLabel.hidden = YES;
            [self.editorView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"CKEDITOR.instances.editor.insertHtml('%@');",tmpContent]];
        }
        self.dataArray = [[CommonMethod paramArrayIsNull:model.image] mutableCopy];
        if(self.dataArray.count){
            [self.collectionView reloadData];
        }
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

#pragma mark - 返回、下一步按钮操作
- (IBAction)leftButtonClicked:(UIButton*)sender{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    if([[[self getHTML] filterHTML] length] == 0 && self.dataArray.count==0){
        [self notSaveTmpPostsModel];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        
    }];
    
    UIAlertAction* saveAction = [UIAlertAction actionWithTitle:@"保存内容" style:UIAlertActionStyleDefault                                                                 handler:^(UIAlertAction * action) {
        [self saveTmpPostsModel];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    UIAlertAction* backAction = [UIAlertAction actionWithTitle:@"清空内容" style:UIAlertActionStyleDefault                                                             handler:^(UIAlertAction * action) {
        [self notSaveTmpPostsModel];
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

#pragma mark - 保存观点
- (void)saveTmpPostsModel{
    DynamicSaveModel *model = [[DynamicSaveModel alloc] init];
    model.content = [CommonMethod paramStringIsNull:[self getHTML]];
    model.image = self.dataArray;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:SAVE_DYNAMIC_MODEL];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)notSaveTmpPostsModel{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:SAVE_DYNAMIC_MODEL];
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
    if(![[self getHTML] filterHTML].length&&!self.dataArray.count){
        [self.view showToastMessage:@"动态不能为空"];
        return;
    }
    [self.view endEditing:YES];
    MBProgressHUD *hud = [MBProgressHUD showMessag:@"发布中..." toView:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UserModel *userModel = [DataModelInstance shareInstance].userModel;
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:userModel.userId forKey:@"user_id"];
        [dict setObject:userModel.realname forKey:@"user_realname"];
        [dict setObject:userModel.image forKey:@"user_image"];
        [dict setObject:userModel.company forKey:@"user_company"];
        [dict setObject:userModel.position forKey:@"user_position"];
        [dict setObject:userModel.usertype forKey:@"user_usertype"];
        [dict setObject:userModel.othericon forKey:@"user_othericon"];
        [dict setObject:@(0) forKey:@"sharecount"];
        [dict setObject:@(1) forKey:@"type"];
        [dict setObject:@(0) forKey:@"parent"];
        [dict setObject:@(0) forKey:@"praisecount"];
        [dict setObject:@(0) forKey:@"reviewcount"];
        [dict setObject:@(-[NSDate currentTimeString:kTimeFormatSmallLong3].integerValue) forKey:@"dynamic_id"];
        [dict setObject:@(0) forKey:@"ispraise"];
        [dict setObject:@(1) forKey:@"parent_status"];
        [dict setObject:@"" forKey:@"relationship"];
        NSString *content = [self filterHTML];
        content = [content stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
        content = [content stringByReplacingOccurrencesOfString:@"</p>" withString:@"\n"];
        content = [content stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
        content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
        if([content filterHTML].length>300){
            [hud hideAnimated:YES];
            [self.view showToastMessage:@"最多输入300字"];
            return;
        }else if(content.length){
            [dict setObject:content forKey:@"content"];
        }else{
            [dict setObject:@"" forKey:@"content"];
            [self.editorView stringByEvaluatingJavaScriptFromString:@"CKEDITOR.instances.editor.setData('');"];
        }
        NSMutableArray *imagesArray = [NSMutableArray array];
        for(UIImage *image in self.dataArray){
            [imagesArray addObject:[self getImagePath:image]];
        }
        if(imagesArray.count){
            [dict setObject:[imagesArray componentsJoinedByString:@","] forKey:@"image"];
        }else{
            [dict setObject:@"" forKey:@"image"];
        }
        NSMutableArray *dynamicArray = [NSMutableArray arrayWithArray:userModel.noUploadDynamicData];
        [dynamicArray addObject:dict];
        userModel.noUploadDynamicData = dynamicArray;
        userModel.hasPublishDynamic = @1;
        [DataModelInstance shareInstance].userModel = userModel;
        
        DynamicModel *model = [[DynamicModel alloc] initWithDict:dict cellTag:0];
        if(self.createDynamicSuccess){
            self.createDynamicSuccess(model);
        }
        [hud hideAnimated:YES];
        [MBProgressHUD showSuccess:@"发布成功" toView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:SAVE_DYNAMIC_MODEL];
            [self.navigationController popViewControllerAnimated:YES];
        });
    });
}

- (void)initToolBar{
    CGFloat start_Y = 0;
    self.toolbarHolder = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT, WIDTH, 44+start_Y)];
    self.toolbarHolder.backgroundColor = HEX_COLOR(@"f8f8f8");
    [self.view addSubview:self.toolbarHolder];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, start_Y, WIDTH, 0.5)];
    lineLabel.backgroundColor = kCellLineColor;
    [self.toolbarHolder addSubview:lineLabel];
    
    //图片
    UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageBtn setImage:kImageWithName(@"btn_viewpoint_image") forState:UIControlStateNormal];
    imageBtn.frame = CGRectMake(WIDTH-170, start_Y, 40, 44);
    imageBtn.tag = 201;
    [imageBtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarHolder addSubview:imageBtn];
    
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
            if(self.dataArray.count<9){
                [self openPhoto];
            }
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
                    [weakSelf.editorView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"CKEDITOR.instances.editor.insertHtml('<a href=\"%@%@\" id=\"%@\" extype=\"atname\">@%@</a>');",ShareHomePageURL, model.userid, model.userid, model.realname]];
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

- (void)openPhoto{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied){
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"请在iPhone的“设置>隐私>相册”选项中，允许3号圈访问你的相册" cancelButtonTitle:@"取消" otherButtonTitle:@"设置" cancle:^{
        } confirm:^{
            if(IOS_X >= 10){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
            }
        }];
        return;
    }
    if(9-self.dataArray.count <= 0){
        return;
    }
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9-self.dataArray.count delegate:self];
    imagePickerVc.allowTakePicture = NO;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    [[UINavigationBar appearance] setBackgroundImage:kImageWithColor(kDefaultColor, CGRectMake(0, 0, WIDTH, 1)) forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:kImageWithColor(kDefaultColor, CGRectMake(0, 0, WIDTH, 1))];
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray *photos, NSArray *assets, BOOL success) {
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
        for (UIImage *image in photos) {
            UIImage *newImage = image;
            //旋转
            UIImageOrientation imageOrientation=image.imageOrientation;
            if(imageOrientation!=UIImageOrientationUp){
                UIGraphicsBeginImageContext(image.size);
                [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
                newImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            [self.dataArray addObject:newImage];
            [self.collectionView reloadData];
            if(self.dataArray.count){
                self.nextBtn.enabled = YES;
            }
        }
    }];
    [imagePickerVc setImagePickerControllerDidCancelHandle:^{
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
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
              self.placeHolderContentLabel.text = @"分享工作动态，让更多金融人看到";
            self.placeHolderContentLabel.hidden = YES;
        } completion:nil];
    } else {
        [UIView animateWithDuration:duration delay:0 options:animationOptions animations:^{
            CGRect frame = self.toolbarHolder.frame;
            frame.origin.y = HEIGHT;
            self.toolbarHolder.frame = frame;
            if([[self getHTML] filterHTML].length == 0){
                self.placeHolderContentLabel.text = @"";
                self.placeHolderContentLabel.hidden = NO;
            }
        } completion:nil];
        
    }
}


@end

