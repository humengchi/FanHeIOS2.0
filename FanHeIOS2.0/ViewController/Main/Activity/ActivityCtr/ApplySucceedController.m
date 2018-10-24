//
//  ApplySucceedController.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/11.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ApplySucceedController.h"
#import "ChoiceFriendViewController.h"
#import "ActivityDetailController.h"
#import "MyActivityOrderController.h"

@interface ApplySucceedController ()
@property (weak, nonatomic) IBOutlet UIImageView *wexinImageView;
@property (weak, nonatomic) IBOutlet UIImageView *friendsQuan;
@property (weak, nonatomic) IBOutlet UIImageView *JinMaiImageView;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;

@end

@implementation ApplySucceedController

// 作用：拦截手势触发
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kTableViewBgColor;
    self.wexinImageView.userInteractionEnabled = YES;
    self.friendsQuan.userInteractionEnabled = YES;
    self.JinMaiImageView.userInteractionEnabled = YES;
    [self createCustomNavigationBar:@"报名成功"];
    if(self.needcheck.integerValue == 0){
        self.subTitleLabel.text = @"活动报名成功";
    }else{
        self.subTitleLabel.text = @"报名成功，请耐心等待审核";
    }
    // Do any additional setup after loading the view from its nib.
}
- (void)customNavBackButtonClicked{
    NSArray *viewcontrollers = self.navigationController.viewControllers;
    for(UIViewController *vc in viewcontrollers){
        if([vc isKindOfClass:[ActivityDetailController class]]){
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }else if([vc isKindOfClass:[MyActivityOrderController class]]){
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)shareActivity:(UITapGestureRecognizer *)sender {
    NSInteger index = sender.view.tag;
    [self firendClick:index];
}
#pragma mark ----------分享 ---
- (void)firendClick:(NSInteger )index{
    NSString *html = self.actModel.subcontent;
    NSString *title = self.actModel.name;
    
    NSString *content = html.length>100?[html substringToIndex:100]:html;
    NSString *imageUrl = self.actModel.image;
    NSString *contentUrl = [NSString stringWithFormat:@"%@%@",ShareActivityPageURL, self.actModel.activityid];
    UIImage *imageSource;
    if(imageUrl && imageUrl.length){
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        imageSource = [UIImage imageWithData:data];
        
    }else{
        imageSource = kImageWithName(@"icon-60");
    }
    switch (index){
        case 0:{
            [self shareUMengWeiXInTitle:title count:content url:contentUrl image:imageSource index:index];
            break;
        }
        case 1:{
            [self shareUMengWeiXInTitle:title count:content url:contentUrl image:imageSource index:index];
            break;
        }
        case 2:{
            ChoiceFriendViewController *choseCtr = [CommonMethod getVCFromNib:[ChoiceFriendViewController class]];
            choseCtr.actModel = self.actModel;
            [self.navigationController pushViewController:choseCtr animated:YES];
            return;
        }
    }
}
- (void)shareUMengWeiXInTitle:(NSString *)title count:(NSString *)count url:(NSString *)url image:(UIImage *)imageSource index:(NSInteger)index{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMSocialPlatformType shareType;
    if (index == 0) {
        shareType = UMSocialPlatformType_WechatSession;
    }else if (index == 1) {
        shareType = UMSocialPlatformType_WechatTimeLine;
    }
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:count thumImage:imageSource];
    //设置网页地址
    shareObject.webpageUrl = url;
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:shareType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
    }];
}


@end
