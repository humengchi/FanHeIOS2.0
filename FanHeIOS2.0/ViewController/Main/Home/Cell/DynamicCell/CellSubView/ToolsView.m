//
//  ToolsView.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/3/1.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ToolsView.h"
#import "TransmitDynamicController.h"
#import "DynamicShareView.h"
#import "ChoiceFriendViewController.h"

@interface ToolsView ()

@property (nonatomic, weak) IBOutlet UIButton *shareBtn;
@property (nonatomic, weak) IBOutlet UIButton *praiseBtn;
@property (nonatomic, weak) IBOutlet UIButton *reviewBtn;

@end

@implementation ToolsView

- (void)updateDisplay:(DynamicModel*)model{
    self.model = model;
    if([CommonMethod paramNumberIsNull:model.sharecount].integerValue){
        [self.shareBtn setTitle:[NSString stringWithFormat:@" %@",[NSString getNumStr:model.sharecount]] forState:UIControlStateNormal];
    }
    
    if([CommonMethod paramNumberIsNull:model.praisecount].integerValue){
        [self.praiseBtn setTitle:[NSString stringWithFormat:@" %@",[NSString getNumStr:model.praisecount]] forState:UIControlStateNormal];
        if([CommonMethod paramNumberIsNull:model.ispraise].integerValue){
            self.praiseBtn.selected = YES;
            [self.praiseBtn setTitle:[NSString stringWithFormat:@" %@",[NSString getNumStr:model.praisecount]] forState:UIControlStateSelected];
            [self.praiseBtn setTitle:[NSString stringWithFormat:@" %@",[NSString getNumStr:model.praisecount]] forState:UIControlStateNormal];
        }
    }else if([CommonMethod paramNumberIsNull:model.ispraise].integerValue){
        self.praiseBtn.selected = YES;
        model.praisecount = @(1);
        [self.praiseBtn setTitle:[NSString stringWithFormat:@" %@",[NSString getNumStr:model.praisecount]] forState:UIControlStateSelected];
        [self.praiseBtn setTitle:[NSString stringWithFormat:@" %@",[NSString getNumStr:model.praisecount]] forState:UIControlStateNormal];
    }
    
    if([CommonMethod paramNumberIsNull:model.reviewcount].integerValue){
        [self.reviewBtn setTitle:[NSString stringWithFormat:@" %@",[NSString getNumStr:model.reviewcount]] forState:UIControlStateNormal];
    }
    if(model.parent_status.integerValue>=4){
        self.shareBtn.enabled = NO;
    }
}

- (IBAction)shareButtonClicked:(id)sender{
    [[self viewController] newThreadForAvoidButtonRepeatClick:sender];
    DynamicShareView *shareView = [[DynamicShareView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [[UIApplication sharedApplication].keyWindow addSubview:shareView];
    [shareView showOrHideView:YES];
    __weak typeof(self) shareSlef = self;
    [shareView setDynamicShareViewIndex:^(NSInteger index) {
        [shareSlef shareFriends:index];
    }];
}

#pragma mark -------- 分享页面
- (void)shareFriends:(NSInteger)index{
    NSString *html;
    if (self.model.type.integerValue == 13) {
        if (self.model.exttype.integerValue == 3 ||self.model.exttype.integerValue == 8) {
            html = self.model.parent_subject_title;
        }
        if (self.model.exttype.integerValue == 4 ||self.model.exttype.integerValue == 9) {
            html = self.model.parent_post_title;
        }
        if (self.model.exttype.integerValue == 5 ||self.model.exttype.integerValue == 10) {
            html = self.model.parent_activity_title;
        }
        if (self.model.exttype.integerValue == 7 ||self.model.exttype.integerValue == 12 || self.model.exttype.integerValue == 6 ||self.model.exttype.integerValue == 11) {
            html =  self.model.parent_review_content;
        }
        if (self.model.exttype.integerValue == 1) {
            //村文本
            html = self.model.parent_content;
        }
        if (self.model.exttype.integerValue == 2) {
            //村文本
            if (self.model.parent_content.length > 0) {
                html = self.model.parent_content;
                
            }else{
                NSArray *imageArray = [self.model.parent_image componentsSeparatedByString:@","];
                html = [NSString stringWithFormat:@"分享了%ld张图片",imageArray.count];
            }
        }
    }else{
        if (self.model.type.integerValue == 3 || self.model.type.integerValue == 8) {
            html = self.model.subject_title;
        }
        if (self.model.type.integerValue == 4 ||self.model.type.integerValue == 9) {
            html = self.model.activity_title;
        }
        if (self.model.type.integerValue == 5 ||self.model.type.integerValue == 10) {
            html =  self.model.post_title;
            
        }
        if (self.model.type.integerValue == 7 ||self.model.type.integerValue == 12 || self.model.type.integerValue == 6 ||self.model.type.integerValue == 11) {
            html =  self.model.review_content;
        }
        if (self.model.type.integerValue == 1) {
            //村文本
            html = self.model.content;
        }
        if (self.model.type.integerValue == 2) {
            //村文本
            if (self.model.content.length > 0) {
                html = self.model.content;
            }else{
                NSArray *imageArray = [self.model.image componentsSeparatedByString:@","];
                html = [NSString stringWithFormat:@"分享了%ld张图片",imageArray.count];
            }
        }
    }
    NSString *imageUrl = self.model.parent_user_image;
    NSString *title = [NSString stringWithFormat:@"%@的金脉动态",self.model.parent_user_realname];
    if (self.model.parent_user_realname.length == 0 || html.length == 0) {
        if (self.model.type.integerValue == 5 || self.model.exttype.integerValue == 5 ) {
            title = [NSString stringWithFormat:@"%@的金脉动态",self.model.userModel.user_realname];
            imageUrl = self.model.userModel.user_image;
            html = @"分享了一篇文章";
        }
        if (self.model.type.integerValue == 4 || self.model.exttype.integerValue == 4 ) {
            title = [NSString stringWithFormat:@"%@的金脉动态",self.model.userModel.user_realname];
            imageUrl = self.model.userModel.user_image;
            html = @"分享了一个活动";
        }
    }
    
    
    html = [html filterHTML];
    NSString *content = html.length>100?[html substringToIndex:100]:html;
    
    NSString *contentUrl = [NSString stringWithFormat:@"%@%@",DYNAMIC_SHARE_URL, self.model.dynamic_id];
    UIImage *imageSource;
    if(imageUrl && imageUrl.length){
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        imageSource = [UIImage imageWithData:data];
    }else{
        imageSource = kImageWithName(@"icon-60");
    }
    if(self.model.type.integerValue == 17){
        title = self.model.title;
        content = self.model.content;
        contentUrl = [NSString stringWithFormat:@"%@%@",DYNAMIC_SHARE_URL, self.model.dynamic_id];
    }else if(self.model.type.integerValue == 13 && self.model.exttype.integerValue == 17){
        title = self.model.parent_title;
        contentUrl = [NSString stringWithFormat:@"%@%@",DYNAMIC_SHARE_URL, self.model.parent];
        content = title;//self.model.parent_content;
    }
    switch (index){
        case 0:{
            TransmitDynamicController *vc = [[TransmitDynamicController alloc]init];
            vc.model = self.model;
            vc.view.transform = CGAffineTransformMakeTranslation(0, 64);
            vc.view.alpha = 0.8;
            [UIView animateWithDuration:0.3 animations:^{
                vc.view.alpha = 1;
                vc.view.transform = CGAffineTransformMakeTranslation(0, 0);
            }];
            [[self viewController].navigationController pushViewController:vc animated:NO];
            break;
        }
        case 1:{
            [self shareUMengWeiXInTitle:title count:content url:contentUrl image:imageSource index:index];
            break;
        }
        case 2:{
            title = content;
            [self shareUMengWeiXInTitle:title count:content url:contentUrl image:imageSource index:index];
            break;
        }
        case 3:{
            ChoiceFriendViewController *choseCtr = [CommonMethod getVCFromNib:[ChoiceFriendViewController class]];
            choseCtr.dymodel = self.model;
            [[self viewController].navigationController pushViewController:choseCtr animated:YES];
            return;
        }
        case 4:{
            [MBProgressHUD showSuccess:@"复制成功" toView:nil];
            UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
            [generalPasteBoard setString:contentUrl];
            return;
        }
    }
}

- (void)shareUMengWeiXInTitle:(NSString *)title count:(NSString *)count url:(NSString *)url image:(UIImage *)imageSource index:(NSInteger)index{
    UserModel *model = [DataModelInstance shareInstance].userModel;
    [[AppDelegate shareInstance] setZhugeTrack:@"分享动态" properties:@{@"industry":[CommonMethod paramStringIsNull:model.industry], @"business":[CommonMethod paramStringIsNull:model.business],@"city":[CommonMethod paramStringIsNull:model.address], @"dynamicId":[CommonMethod paramNumberIsNull:self.model.dynamic_id],@"dynamicType":[CommonMethod paramNumberIsNull:self.model.type],@"dynamicExtype":[CommonMethod paramNumberIsNull:self.model.exttype]}];
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMSocialPlatformType shareType;
    if (index == 1) {
        shareType = UMSocialPlatformType_WechatSession;
    }else {
        shareType = UMSocialPlatformType_WechatTimeLine;
    }
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:count thumImage:imageSource];
    //设置网页地址
    shareObject.webpageUrl = url;
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:shareType messageObject:messageObject currentViewController:[self viewController] completion:^(id data, NSError *error) {
    }];
}

- (IBAction)praiseButtonClicked:(UIButton*)sender{
    if([CommonMethod paramNumberIsNull:self.model.ispraise].integerValue==1){
        [[self viewController].view showToastMessage:@"你已经点过赞啦"];
    }else{
        self.praiseBtn.selected = YES;
        self.model.praisecount = @(self.model.praisecount.integerValue+1);
        self.model.ispraise = @(1);
        [self.praiseBtn setTitle:[NSString stringWithFormat:@" %@",[NSString getNumStr:self.model.praisecount]] forState:UIControlStateSelected];
        [self.praiseBtn setTitle:[NSString stringWithFormat:@" %@",[NSString getNumStr:self.model.praisecount]] forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
        [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
        [requestDict setObject:self.model.dynamic_id forKey:@"dynamicid"];
        [[self viewController] requstType:RequestType_Post apiName:API_NAME_POST_DYNAMICDETAILRATELIT_PARSEDNAMIC paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
            if([CommonMethod isHttpResponseSuccess:responseObject]){
                UserModel *model = [DataModelInstance shareInstance].userModel;
                [[AppDelegate shareInstance] setZhugeTrack:@"点赞动态" properties:@{@"industry":[CommonMethod paramStringIsNull:model.industry], @"business":[CommonMethod paramStringIsNull:model.business],@"city":[CommonMethod paramStringIsNull:model.address], @"dynamicId":[CommonMethod paramNumberIsNull:weakSelf.model.dynamic_id],@"dynamicType":[CommonMethod paramNumberIsNull:weakSelf.model.type],@"dynamicExtype":[CommonMethod paramNumberIsNull:weakSelf.model.exttype]}];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:[weakSelf viewController].view];
        }];
    }
}

- (IBAction)reviewButtonClicked:(id)sender{
    [[self viewController] newThreadForAvoidButtonRepeatClick:sender];
    if(self.reviewDynamic){
        self.reviewDynamic();
    }
}

@end
