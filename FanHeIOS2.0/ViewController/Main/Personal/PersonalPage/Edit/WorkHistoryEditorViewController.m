//
//  WorkHistoryEditorViewController.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/10/26.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "WorkHistoryEditorViewController.h"
#import "RegisterJobInputViewController.h"
#import "RegisterJobSelectBusinessViewController.h"
#import "DatePikerView.h"
#import "AddUrlController.h"
#import "UrlShowView.h"
#import "UrlDetailController.h"

@interface WorkHistoryEditorViewController ()<RegisterJobInputViewControllerDelegate,UITextViewDelegate,UrlShowViewDelegate,AddUrlControllerDelegate,MWPhotoBrowserDelegate>
@property (nonatomic,strong)NSArray *dataArray;
@property (nonatomic,strong)UILabel *detailLabel;

@property (nonatomic,strong) UITextView *textView;
@property (nonatomic,strong) UILabel *labelTextPL;
@property (nonatomic,strong) NSString *position;
@property (nonatomic,strong) NSString *company;
@property (nonatomic,strong) NSString *endtime;
@property (nonatomic,strong) NSString *begintime;
@property (nonatomic,strong) NSString *jobintro;
@property (nonatomic,strong) UIButton *editBtn;
@property (nonatomic ,strong) NSMutableArray *imageArray;
@property (nonatomic,strong) NSMutableArray *bigImage;
@property (nonatomic,strong) NSMutableArray *upImageArray;
@property (nonatomic,strong) NSMutableArray *urlArray;
@property (nonatomic ,strong) UrlShowView *urlView;

@end

@implementation WorkHistoryEditorViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.workModel==nil){
        self.workModel = [[workHistryModel alloc] init];
    }
    self.imageArray = [NSMutableArray arrayWithArray:self.workModel.image];
    self.urlArray =  [NSMutableArray arrayWithArray:self.workModel.url];
    self.upImageArray = [NSMutableArray arrayWithArray:self.workModel.image];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didClickKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didKboardDisappear:) name:UIKeyboardWillHideNotification object:nil];
    [self createCustomNavigationBar:@"我的工作经历"];
    self.editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.editBtn.frame = CGRectMake(WIDTH-60, 20, 50, 44);
    [self.editBtn setTitle:@"保存" forState:UIControlStateNormal];
    [self.editBtn setTitleColor:HEX_COLOR(@"E6E8EB") forState:UIControlStateNormal];
    self.editBtn.titleLabel.font = FONT_SYSTEM_SIZE(16);
    [self.editBtn addTarget:self action:@selector(saveEditInfoButtoAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.editBtn];
    self.dataArray = [NSMutableArray arrayWithObjects:
                      @{@"company":@"公司"},
                      @{@"position":@"职位"},
                      @{@"begintime":@"从业时间"},
                      @{@"endtime":@"结束时间"},
                      nil];
    
    self.company = self.workModel.company;
    self.position = self.workModel.position;
    self.begintime = self.workModel.begintime;
    self.endtime = self.workModel.endtime;
    self.jobintro = self.workModel.jobintro;
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT -64)];
    /*
     if (self.index == 2) {
     UIView *footView = [NSHelper createrViewFrame:CGRectMake(0, HEIGHT - 55, WIDTH, 55) backColor:@"F7F7F7"];
     CGFloat wideth = (WIDTH - 55)/2.0;
     
     UIButton *delectBtn = [NSHelper createButton:CGRectMake(16, 7, wideth, 40) title:@"删除" unSelectImage:nil selectImage:nil target:self selector:@selector(delectWorkHistory)];
     [delectBtn setBackgroundImage:[UIImage imageNamed:@"btn_delete_bg"] forState:UIControlStateNormal];
     [delectBtn setTitleColor:[UIColor colorWithHexString:@"E24943"] forState:UIControlStateNormal];
     
     [footView addSubview:delectBtn];
     
     UIButton *saveBtn = [NSHelper createButton:CGRectMake(16 + 13 + wideth, 7 , wideth, 40) title:@"保存" unSelectImage:nil selectImage:nil target:self selector:@selector(saveEditInfoButtoAction:)];
     [saveBtn setBackgroundImage:[UIImage imageNamed:@"btn_rm_off_red"] forState:UIControlStateNormal];
     
     [footView addSubview:saveBtn];
     [self.view addSubview:footView];
     
     }else{
     UIView *footView = [NSHelper createrViewFrame:CGRectMake(0, HEIGHT - 55, WIDTH, 55) backColor:@"F7F7F7"];
     [self.view addSubview:footView];
     
     UIButton *saveBtn = [NSHelper createButton:CGRectMake(16, 7, WIDTH - 32, 40) title:@"保存" unSelectImage:nil selectImage:nil target:self selector:@selector(saveEditInfoButtoAction:)];
     [saveBtn setBackgroundImage:[UIImage imageNamed:@"btn_rm_off_red"] forState:UIControlStateNormal];
     [footView addSubview:saveBtn];
     }*/
}

-(void)customNavBackButtonClicked{
    [self.textView resignFirstResponder];
    if (self.index == 2) {
        if ([self.company isEqualToString:self.workModel.company] && [self.position isEqualToString:self.workModel.position] && [self.begintime isEqualToString:self.workModel.begintime] && [self.endtime isEqualToString:self.workModel.endtime] && [self.jobintro isEqualToString:self.workModel.jobintro]) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否放弃编辑资料？" cancelButtonTitle:@"放弃" otherButtonTitle:@"继续编辑" cancle:^{
                [self.navigationController popViewControllerAnimated:YES];            } confirm:^{
                }];
        }
    }else{
        if(self.workModel.position.length > 0 ||self.workModel.position.length > 0 || self.workModel.begintime.length > 0 || self.workModel.endtime.length > 0 ||self.workModel.jobintro.length > 0) {
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否放弃编辑资料？" cancelButtonTitle:@"放弃" otherButtonTitle:@"继续编辑" cancle:^{
                [self.navigationController popViewControllerAnimated:YES];
            } confirm:^{
            }];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)delectWorkHistory{
    [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"是否确定删除本条工经历" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
    } confirm:^{
        __weak typeof(self) weakSelf = self;
        __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"删除中..." toView:self.view];
        NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
        [requestDict setObject:[NSString stringWithFormat:@"/%@/%@", [DataModelInstance shareInstance].userModel.userId,self.workModel.careerid] forKey:@"param"];
        
        [self requstType:RequestType_Delete apiName:API_NAME_USER_DELECT_MYCAREER paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
            [hud hideAnimated:YES];
            if([CommonMethod isHttpResponseSuccess:responseObject]){
                self.workModel.careerid = responseObject[@"data"];
                if (self.workDelegate && [self.workDelegate respondsToSelector:@selector(changeWorkHistory:delect:)]) {
                    [self.workDelegate changeWorkHistory:self.workModel delect:YES];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
            [hud hideAnimated:YES];
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }];
    }];
}

#pragma mark - 键盘即将跳出
-(void)didClickKeyboard:(NSNotification *)sender{
//    CGFloat durition = [sender.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
//    CGRect keyboardRect = [sender.userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
//    CGFloat keyboardHeight = keyboardRect.size.height;
//    [self.tableView setContentOffset:CGPointMake(0,230)animated:NO];
//     NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
//    [self.tableView scrollToRowAtIndexPath:selectIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
//    [UIView animateWithDuration:durition animations:^{
//        self.view.transform = CGAffineTransformMakeTranslation(0, -keyboardHeight);
//    }];
}

#pragma mark - 当键盘即将消失
-(void)didKboardDisappear:(NSNotification *)sender{
//    CGFloat duration = [sender.userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
//    [UIView animateWithDuration:duration animations:^{
//        self.view.transform = CGAffineTransformIdentity;
//    }];
}

- (void)saveEditInfoButtoAction:(UIButton *)btn{
    self.workModel.jobintro = self.textView.text;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    if (self.workModel.company.length > 0) {
        [requestDict setObject:self.workModel.company forKey:@"company"];
    }else{
        [self showError:@"请填写公司"];
        return;
    }
    if (self.workModel.position > 0 ) {
        [requestDict setObject:self.workModel.position forKey:@"position"];
    }else{
        [self showError:@"请填写职位"];
        return;
    }
    if (self.workModel.begintime > 0) {
        [requestDict setObject:[self.workModel.begintime stringByReplacingOccurrencesOfString:@"." withString:@"-"] forKey:@"begintime"];
    }else{
        [self showError:@"请选择开始时间"];
        return;
    }
    if (self.workModel.endtime  > 0) {
        if ([self.workModel.endtime isEqualToString:@"至今"]) {
            [requestDict setObject:@"" forKey:@"endtime"];
        }else{
            [requestDict setObject:[self.workModel.endtime stringByReplacingOccurrencesOfString:@"." withString:@"-"] forKey:@"endtime"];
        }
    }else{
        [self showError:@"请选择结束时间"];
        return;
    }
    if (self.textView.text.length > 0) {
        [requestDict setObject:self.textView.text forKey:@"jobintro"];
    }else{
        [requestDict setObject:@"" forKey:@"jobintro"];
    }
    if (self.index == 1) {
        [requestDict setObject:@"0" forKey:@"careerid"];
    }else if (self.index == 2){
        [requestDict setObject:self.workModel.careerid forKey:@"careerid"];
    }
    NSString *imageStr = [self.upImageArray componentsJoinedByString:@","];
    [requestDict setObject:imageStr forKey:@"image"];
    NSMutableString *urlStr;
    if ( self.urlArray.count > 0) {
        for (NSInteger i = 0; i < self.urlArray.count ; i++) {
            if (i == 0) {
                urlStr = self.urlArray[i][@"url"];
            }else{
                urlStr = [NSMutableString stringWithFormat:@"%@,%@",urlStr,self.urlArray[i][@"url"]];
            }
        }
        [requestDict setObject:urlStr forKey:@"url"];
    }
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"保存中..." toView:self.view];
    [self requstType:RequestType_Post apiName:API_NAME_USER_SAVE_MYCAREER paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            weakSelf.workModel.careerid = responseObject[@"data"];
            if (weakSelf.workDelegate && [weakSelf.workDelegate respondsToSelector:@selector(changeWorkHistory:delect:)]) {
                [weakSelf.textView resignFirstResponder];
                weakSelf.workModel.image = self.upImageArray;
                weakSelf.workModel.url = self.urlArray;
                weakSelf.workModel.begintime = [weakSelf.workModel.begintime stringByReplacingOccurrencesOfString:@"-" withString:@"."];
                weakSelf.workModel.endtime = [weakSelf.workModel.endtime stringByReplacingOccurrencesOfString:@"-" withString:@"."];
                [weakSelf.workDelegate changeWorkHistory:weakSelf.workModel delect:NO];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

- (void)showError:(NSString*)error{
    [MBProgressHUD showError:error toView:self.view];
}

#pragma mark - UITableViewDelegate/Data
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.dataArray.count;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 49;
    }else  if (indexPath.section == 1){
        return 232;
        //        if (self.index == 2) {
        //            return HEIGHT - 260 - 64 - 49;
        //        }
        //        return HEIGHT - 64 - 64;
    }else{
        CGFloat heigth = 48;
        CGFloat wideth = (WIDTH - 44)/3.0;
        CGFloat imageHeigth = wideth *61/110.0;
        if (self.workModel.image > 0) {
            heigth = heigth + imageHeigth;
        }else{
            heigth = heigth + 54;
        }
        if (self.urlArray.count > 0) {
            heigth = heigth +52*self.urlArray.count;
            if (self.urlArray.count < 3) {
                heigth = heigth +52*self.urlArray.count + 16 + 54;
            }
        }else{
            heigth = heigth + 24+54 +22;
        }
        return heigth;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 32;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSString *str = @"";
    switch (section) {
        case 0:
            str = @"工作详情";
            break;
        case 1:
            str = @"经历描述";
            break;
        case 2:
            str = @"补充信息(选填)";
            break;
        default:
            break;
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 32)];
    headerView.userInteractionEnabled = YES;
    headerView.backgroundColor = kTableViewBgColor;
    UILabel *textLabel = [UILabel createrLabelframe:CGRectMake(16, 0, WIDTH-16, 32) backColor:kTableViewBgColor textColor:HEX_COLOR(@"818C9E") test:str font:14 number:1 nstextLocat:NSTextAlignmentLeft];
    [headerView addSubview:textLabel];
    
    return headerView;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"";
    UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    
    if (indexPath.section == 0) {
        NSDictionary *dict = self.dataArray[indexPath.row];
        NSString *keyStr = dict.allKeys[0];
        cell.textLabel.text = dict[keyStr];
        cell.textLabel.textColor = HEX_COLOR(@"AFB6C1");
        UIImageView *nextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-25, 18, 8, 15)];
        nextImageView.image = kImageWithName(@"icon_next_gray");
        [cell.contentView addSubview:nextImageView];
        self.detailLabel = [UILabel createLabel:CGRectMake(97, 16, WIDTH - 97 - 42, 18) font:[UIFont systemFontOfSize:17] bkColor:WHITE_COLOR textColor:HEX_COLOR(@"41464E")];
        self.detailLabel.textAlignment = NSTextAlignmentRight;
        self.detailLabel.tag = indexPath.row;
        
        if ([self.workModel valueForKey:keyStr]) {
            self.detailLabel.text = [self.workModel valueForKey:keyStr];
        }else{
            self.detailLabel.textColor = HEX_COLOR(@"E6E8EB");
            if (indexPath.row == 0) {
                self.detailLabel.text = @"请输入公司";
            }else if (indexPath.row == 1){
                self.detailLabel.text = @"请选择职位";
            }else if (indexPath.row == 2){
                self.detailLabel.text = @"请选择时间";
            }else if (indexPath.row == 3){
                self.detailLabel.text = @"请选择时间";
            }
        }
        [cell.contentView addSubview:self.detailLabel];
    }else if (indexPath.section == 1) {
        self.textView = [[UITextView alloc]initWithFrame:CGRectMake(16, 21, WIDTH - 32, 200)];
        self.labelTextPL = [UILabel createLabel:CGRectMake(10, 6, WIDTH -  16, 144) font:[UIFont systemFontOfSize:17] bkColor:WHITE_COLOR textColor:HEX_COLOR(@"E6E8EB")];
        //        self.textView.backgroundColor = [UIColor redColor];
        self.labelTextPL.numberOfLines = 0;
        self.textView.font = [UIFont systemFontOfSize:17];
        self.textView.delegate = self;
        if (self.workModel.jobintro.length > 0) {
            self.textView.text = self.workModel.jobintro;
        }else{
            self.labelTextPL.text = @"可参考如下格式：\n【工作职责】\n简要描述您在岗职位的工作内容或职责范围等\n\n\n【项目经历及业绩】\n简要描述您工作期间负责的任务及业绩。";
            self.textView.font = [UIFont systemFontOfSize:17];
            [self.textView addSubview:self.labelTextPL];
        }
        [cell.contentView addSubview:self.textView];
    }else{
        if (self.imageArray.count > 0) {
            if ([self.imageArray containsObject:[UIImage imageNamed:@"btn_work_picadd"]]) {
                [self.imageArray removeObject:[UIImage imageNamed:@"btn_work_picadd"]];
            }
            if (self.imageArray.count != 3) {
                [self.imageArray addObject:[UIImage imageNamed:@"btn_work_picadd"]];
            }
            if (self.imageArray.count == 1) {
                UIButton *photoBtn = [NSHelper createButton:CGRectMake(16, 24, WIDTH - 32, 54) title:nil unSelectImage:[UIImage imageNamed:@"btn_work_pic"] selectImage:nil target:self selector:@selector(addPhotoAttion)];
                [cell.contentView addSubview:photoBtn];
            }else{
                for (NSInteger i = 0; i < self.imageArray.count; i++) {
                    CGFloat wideth = (WIDTH - 44)/3.0;
                    CGFloat imageHeigth = wideth *61/110.0;
                    float x = 16+(wideth+6)*i;
                    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(x, 24, wideth, imageHeigth)];
                    imageView.userInteractionEnabled = YES;
                    if([self.imageArray[i] isKindOfClass:[UIImage class]]) {
                        imageView.image = self.imageArray[i];
                    }else{
                        [imageView sd_setImageWithURL:[NSURL URLWithString:self.imageArray[i]] placeholderImage:KWidthImageDefault];
                    }
                    imageView.clipsToBounds = YES;
                    imageView.contentMode = UIViewContentModeScaleAspectFill;
                    imageView.tag = i;
                    UITapGestureRecognizer *bigTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(magnifyImageAction:)];
                    [imageView addGestureRecognizer:bigTap];
                    if (i < 3 && self.imageArray.count > 0) {
                        if (self.imageArray.count-1 == i) {
                            if (![self.imageArray containsObject:[UIImage imageNamed:@"btn_work_picadd"]]) {
                                UIButton *delectBtn = [NSHelper createButton:CGRectMake(imageView.frame.size.width - 25, 3, 21, 21) title:nil unSelectImage:[UIImage imageNamed:@"btn_work_dele"] selectImage:nil target:self selector:@selector(delectImage:)];
                                delectBtn.tag = i;
                                [imageView addSubview:delectBtn];
                                
                            }else{
                                UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addPhotoAttion)];
                                [imageView addGestureRecognizer:g];
                            }
                        }else{
                            UIButton *delectBtn = [NSHelper createButton:CGRectMake(imageView.frame.size.width - 25, 3, 21, 21) title:nil unSelectImage:[UIImage imageNamed:@"btn_work_dele"] selectImage:nil target:self selector:@selector(delectImage:)];
                            delectBtn.tag = i;
                            [imageView addSubview:delectBtn];
                        }
                        [cell.contentView addSubview:imageView];
                    }
                }
            }
            
        }else{
            UIButton *photoBtn = [NSHelper createButton:CGRectMake(16, 24, WIDTH - 32, 54) title:nil unSelectImage:[UIImage imageNamed:@"btn_work_pic"] selectImage:nil target:self selector:@selector(addPhotoAttion)];
            [cell.contentView addSubview:photoBtn];
            
        }
        if (self.urlArray.count > 0 ) {
            self.urlView = [[UrlShowView alloc]initWithFrame:CGRectMake(0, 102, WIDTH, 52*self.urlArray.count)];
            self.urlView.showImage = [UIImage imageNamed:@"btn_work_dele"];
            [self.urlView createrUrlView:self.urlArray];
            self.urlView.urlShowViewDelegate = self;
            
            [cell.contentView addSubview:self.urlView];
            if (self.urlArray.count < 3) {
                UIButton *addUrlBtn = [NSHelper createButton:CGRectMake(16, 52*self.urlArray.count + 16 + 102 , WIDTH - 32, 54) title:nil unSelectImage:[UIImage imageNamed:@"btn_work_link"] selectImage:nil target:self selector:@selector(addUrlBtnAttion:)];
                [cell.contentView addSubview:addUrlBtn];
            }
            
        }else{
            UIButton *addUrlBtn = [NSHelper createButton:CGRectMake(16, 102, WIDTH - 32, 54) title:nil unSelectImage:[UIImage imageNamed:@"btn_work_link"] selectImage:nil target:self selector:@selector(addUrlBtnAttion:)];
            [cell.contentView addSubview:addUrlBtn];
        }
        
    }
    if ([self changeSavaColor]) {
        [self.editBtn setTitleColor:HEX_COLOR(@"E24943") forState:UIControlStateNormal];
    }else{
        [self.editBtn setTitleColor:HEX_COLOR(@"E6E8EB") forState:UIControlStateNormal];
        
    }
    return cell;
}
- (void)magnifyImageAction:(UITapGestureRecognizer *)g{
    NSInteger index = g.view.tag;
    
    // Create browser
    self.bigImage = [NSMutableArray new];
    for (NSInteger i =0; i <self.upImageArray.count; i++){
        MWPhoto *po = [MWPhoto photoWithURL:[NSURL URLWithString:self.upImageArray[i]]];
        [self.bigImage addObject:po];
    }
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = YES;
    browser.displayNavArrows = YES;
    browser.displaySelectionButtons = NO;
    browser.alwaysShowControls = NO;
    //        _photoBrowser.wantsFullScreenLayout = YES;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = NO;
    browser.startOnGrid = NO;
    [browser setCurrentPhotoIndex:index];
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.bigImage.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.bigImage.count)
        return [self.bigImage objectAtIndex:index];
    return nil;
}
- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ------ 删除照片
- (void)delectImage:(UIButton *)btn{
    NSInteger index = btn.tag;
    if(self.imageArray.count>index){
        [self.imageArray removeObjectAtIndex:index];
    }
    if(self.upImageArray.count>index){
        [self.upImageArray removeObjectAtIndex:index];
    }
    //一个cell刷新
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:2];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark ------- add图片and网址
- (void)addPhotoAttion{
    __weak typeof(self) weakSelf = self;
    UploadImageTypeView *view = [CommonMethod getViewFromNib:@"UploadImageTypeView"];
    view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    [view setUploadImageTypeViewType:UploadImageTypeViewType_UploadNormalImage];
    view.uploadImageViewImage = ^(UIImage *image){
        [weakSelf upPhoneImage:image];
    };
    view.cancleLoadImageViewType = ^(){
    };
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view showShareNormalView];
}

- (void)upPhoneImage:(UIImage *)image{
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"图片上传中..." toView:self.view];
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    UIImage *newImage = image;//
    NSData *imageData =  UIImageJPEGRepresentation(newImage, 0.5);
    [requestDict setObject:imageData forKey:@"pphoto"];
    [self requstType:RequestType_UPLOAD_IMG apiName:API_NAME_UPLOAD_IMAGE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        NSString *str = [NSString stringWithFormat:@"%@",responseObject[@"status"]];
        if([str isEqualToString:@"1"]){
            [self.imageArray addObject:[responseObject objectForKey:@"msg"]];
            
            [self.upImageArray addObject:[responseObject objectForKey:@"msg"]];
            //一个cell刷新
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:2];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        }else{
            [MBProgressHUD showError:@"图片上传失败" toView:self.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
    }];
}

#pragma mark ------urlShowViewDelegate
#pragma mark ----- 删除链接
- (void)delectUrlAction:(NSInteger)index{
    [self.urlArray removeObjectAtIndex:index];
    //一个cell刷新
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:2];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)gotoMakeUrl:(NSInteger)index{
    NSMutableDictionary *dic =  self.urlArray[index];
    UrlDetailController *url = [[UrlDetailController alloc]init];
    url.title = dic[@"title"];
    url.url = dic[@"url"];
    [self.navigationController pushViewController:url animated:YES];
}

#pragma mark ------addUrlControllerDelegate;
- (void)backAddUrlControllerDic:(NSMutableDictionary *)dic{
    [self.urlArray addObject:dic];
    //一个cell刷新
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:2];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)addUrlBtnAttion:(UIButton *)btn{
    AddUrlController *add = [[AddUrlController alloc]init];
    add.addUrlControllerDelegate = self;
    [self.navigationController pushViewController:add animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        [self.view endEditing:YES];
        if (indexPath.row == 0||indexPath.row == 1) {
            [self choiceJobType:indexPath.row];
        }else if(indexPath.row == 2 || indexPath.row == 3){
            [self choiceTime:indexPath.row];
        }
    }
}

#pragma mark - 公司、职位、行业
- (void)choiceJobType:(NSInteger)tag{
    if(tag == 0){
        RegisterJobInputViewController *vc = [CommonMethod getVCFromNib:[RegisterJobInputViewController class]];
        vc.isWorkHistory = YES;
        vc.delegate = self;
        vc.jobParamType = JOB_PARAM_ADDBUSINESS;
        [self presentViewController:vc animated:YES completion:nil];
    }else{
        RegisterJobInputViewController *vc = [CommonMethod getVCFromNib:[RegisterJobInputViewController class]];
        vc.isWorkHistory = YES;
        vc.delegate = self;
        vc.jobParamType = JOB_PARAM_POSITION;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark - RegisterJobInputViewControllerDelegate
- (void)RegisterJobInputViewControllerDelegateChoiceParam:(NSString *)param isCompany:(JOB_PARAM)jobParam{
    if(jobParam == JOB_PARAM_ADDBUSINESS){
        self.workModel.company = param;
    }else if (jobParam == JOB_PARAM_POSITION){
        self.workModel.position = param;
    }
    if([self changeSavaColor]) {
        [self.editBtn setTitleColor:HEX_COLOR(@"E24943") forState:UIControlStateNormal];
    }else{
        [self.editBtn setTitleColor:HEX_COLOR(@"818C9E") forState:UIControlStateNormal];
    }
    [self.tableView reloadData];
}

#pragma mark - 工作时间
- (void)choiceTime:(NSInteger)tag{
    DatePikerView *view = [CommonMethod getViewFromNib:NSStringFromClass([DatePikerView class])];
    view.type = kDatePikerViewTypeMonth;
    if (tag == 3){
        view.isShow = YES;
    }
    view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    if (tag == 2) {
        if(self.workModel.begintime.length){
            [view updateSelectRow:[NSDate dateFromString:self.workModel.begintime format:kTimeFormatMonth]];
        }else{
            [view updateSelectRow:nil];
        }
    }
    if (tag == 3) {
        if(self.workModel.endtime.length){
            [view updateSelectRow:[NSDate dateFromString:self.workModel.endtime format:kTimeFormatMonth]];
        }else{
            [view updateSelectRow:nil];
        }
    }
    view.pickerSelectBlock = ^(id param, NSString *value){
        if (value == nil ) {
            if (tag == 3) {
                self.workModel.endtime  = @"至今";
                [self.tableView reloadData];
            }
        }else if (tag == 2) {
            self.workModel.begintime = value;
            if (self.workModel.begintime.length > 0) {
                NSString *bagTime = [self.workModel.begintime stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];//该方法是去掉指定符号
                bagTime = [bagTime stringByReplacingOccurrencesOfString:@"" withString:@"-"];
                NSString *cuurenTime = [[NSDate currentTimeString:kTimeFormatMonth] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
                cuurenTime = [cuurenTime stringByReplacingOccurrencesOfString:@"" withString:@"-"];
                if(bagTime.integerValue > cuurenTime.integerValue){
                    self.workModel.begintime = nil;
                    [self showError:@"工作开始时间不得超过今日"];
                }
            }
            if (self.workModel.begintime.length > 0 && self.workModel.endtime.length > 0 && ![self.workModel.endtime isEqualToString:@"至今"]) {
                NSString *bagTime = [self.workModel.begintime stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];//该方法是去掉指定符号
                NSString *endTime = [self.workModel.endtime stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
                NSString *cuurenTime = [[NSDate currentTimeString:kTimeFormatMonth] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
                if (bagTime.integerValue > endTime.integerValue) {
                    self.workModel.endtime = nil;
                    [self showError:@"工作开始时间不得大于结束时间"];
                }else if(bagTime.integerValue > cuurenTime.integerValue){
                    [self showError:@"工作开始时间不得超过今日"];
                }
            }
        }else if(tag == 3) {
            if(value==nil){
                self.workModel.endtime = nil;
            }else{
                self.workModel.endtime = value;
                if (self.workModel.begintime.length > 0 && self.workModel.endtime.length > 0 && ![self.workModel.endtime isEqualToString:@"至今"]) {
                    NSString *bagTime = [self.workModel.begintime stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];//该方法是去掉指定符号
                    NSString *endTime = [self.workModel.endtime stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
                    NSString *cuurenTime = [[NSDate currentTimeString:kTimeFormatMonth] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
                    if (bagTime.integerValue > endTime.integerValue) {
                        self.workModel.endtime = nil;
                        [self showError:@"工作开始时间不得大于结束时间"];
                    }else if(endTime.integerValue > cuurenTime.integerValue){
                        [self showError:@"工作结束时间不得超过今日"];
                    }
                }
                if ([self changeSavaColor]) {
                    [self.editBtn setTitleColor:HEX_COLOR(@"E24943") forState:UIControlStateNormal];
                }else{
                    [self.editBtn setTitleColor:HEX_COLOR(@"818C9E") forState:UIControlStateNormal];
                }
            }
        }
        [self.tableView reloadData];
    };
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view showShareNormalView];
}

#pragma mark -UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (self.textView) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    if (self.workModel.endtime.length <= 0) {
        self.workModel.endtime = @"至今";
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:3 inSection:0];
        
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        if ([self changeSavaColor]) {
            [self.editBtn setTitleColor:HEX_COLOR(@"E24943") forState:UIControlStateNormal];
        }else{
            [self.editBtn setTitleColor:HEX_COLOR(@"818C9E") forState:UIControlStateNormal];
        }
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if (textView.text.length <= 0 ) {
        [self.textView addSubview:self.labelTextPL];
    }else{
        self.workModel.jobintro = self.textView.text;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if (self.textView) {
        if (self.textView.text.length <= 0) {
            [self.textView addSubview:self.labelTextPL];
        }
        if (text.length > 0) {
            [self.labelTextPL removeFromSuperview];
        }
        
    }
    if (textView.text.length == 0) {
        NSString *tem = [[text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]componentsJoinedByString:@""];
        if (![text isEqualToString:tem]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    NSString *tem = [[textView.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]componentsJoinedByString:@""];
    if (![textView.text isEqualToString:tem]) {
        return NO;
    }
    
    if (textView.text.length > 500) {
        textView.text = [textView.text substringToIndex:500];
    }
    self.workModel.jobintro = self.textView.text;
    return YES;
}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //    [self.tableView setContentOffset:CGPointMake(0,0)animated:NO];
    [self.view endEditing:YES];
}

- (BOOL)changeSavaColor{
    if (self.workModel.company.length > 0 &&  self.workModel.position > 0 && self.workModel.begintime > 0 && self.workModel.endtime  > 0) {
        return YES;
    }
    return NO;
}

@end
