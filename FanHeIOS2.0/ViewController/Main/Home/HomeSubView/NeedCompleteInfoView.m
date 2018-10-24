//
//  NeedCompleteInfoView.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/10/28.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "NeedCompleteInfoView.h"
#import "CompleteUserInfoView.h"
#import "EditPersonalInfoViewController.h"
#import "IdentityController.h"
#import "InterestBusinessController.h"

@interface HMCSmallCircularProgressView : UIView


@end

@implementation HMCSmallCircularProgressView

- (void)drawRect:(CGRect)rect{
    NSInteger rate = [CommonMethod getUserInfoCompletionRate];
    UIColor *circleColor;
    if(rate >= 80){
        circleColor = HEX_COLOR(@"1ABC9C");
    }else if(rate >= 60){
        circleColor = HEX_COLOR(@"F76B1C");
    }else{
        circleColor = HEX_COLOR(@"E24943");
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor whiteColor] set];
    UIRectFill(CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    CGContextSetStrokeColorWithColor(context, HEX_COLOR(@"E6E8EB").CGColor);
    CGContextSetLineWidth(context, 5.0);
    CGContextAddArc(context, rect.size.width/2, rect.size.width/2, rect.size.width/2-2.5, 0, 2*M_PI, 0);
    CGContextDrawPath(context, kCGPathStroke);
    
    CGContextSetStrokeColorWithColor(context, circleColor.CGColor);
    CGContextSetLineWidth(context, 5.0);
    CGContextAddArc(context, rect.size.width/2, rect.size.width/2, rect.size.width/2-2.5, -M_PI/2, 2*M_PI*rate/100.0-M_PI/2, 0);
    CGContextDrawPath(context, kCGPathStroke);
    
    NSString *str = [NSString stringWithFormat:@"%ld%%", rate];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    [str drawInRect:CGRectMake(0, rect.size.width/2-10, rect.size.width, 12) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:circleColor,NSForegroundColorAttributeName,FONT_BOLD_SYSTEM_SIZE(10),NSFontAttributeName, paragraph, NSParagraphStyleAttributeName, nil]];
    [@"资料完善度" drawInRect:CGRectMake(0, rect.size.width/2+5, rect.size.width, 10) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:HEX_COLOR(@"AFB6C1"),NSForegroundColorAttributeName,FONT_SYSTEM_SIZE(5),NSFontAttributeName, paragraph, NSParagraphStyleAttributeName, nil]];
}

@end

@interface NeedCompleteInfoView ()<IdentityControllerDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *subTitleLabel;
@end

@implementation NeedCompleteInfoView

- (void)awakeFromNib{
    [super awakeFromNib];
    [CommonMethod viewAddGuestureRecognizer:self tapsNumber:1 withTarget:self withSEL:@selector(clickedNeedCompleteInfoView)];
    [self updateDisplay];
}

- (void)updateDisplay{
    for(UIView *view in self.iconImageView.subviews){
        [view removeFromSuperview];
    }
    UserModel *model = [DataModelInstance shareInstance].userModel;
    if([CommonMethod paramArrayIsNull:model.intersted_industrys].count == 0){
        self.type = NeedCompleteInfoViewType_SetInterestIndutry;
        self.titleLabel.text = @"设置你感兴趣的行业";
        self.subTitleLabel.text = @"3号圈会为您推荐相关内容哦";
        self.iconImageView.image = kImageWithName(@"icon_index_sgxqhy");
    }else if([CommonMethod getUserInfoCompletionRate] == 100){
        self.type = NeedCompleteInfoViewType_None;
    }else if(model.image.length == 0){
        self.type = NeedCompleteInfoViewType_UploadImage;
        self.titleLabel.text = @"上传头像";
        self.subTitleLabel.text = @"上传真实头像，做一个有头有脸的人！";
        self.iconImageView.image = kImageWithName(@"icon_index_stx");
    }else if(![CommonMethod getUserCanIdentify]){
        self.type = NeedCompleteInfoViewType_CompleteInfo;
        self.titleLabel.text = @"完善个人资料";
        self.subTitleLabel.text = @"据说资料详细程度和人脉质量成正比哦！";
        HMCSmallCircularProgressView *progressView = [[HMCSmallCircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [self.iconImageView addSubview:progressView];
    }else if(model.hasValidUser.integerValue != 1 && model.hasValidUser.integerValue != 2){
        self.type = NeedCompleteInfoViewType_Identify;
        self.titleLabel.text = @"认证名片";
        self.subTitleLabel.text = @"用户更愿意和靠谱的人建立关系！";
        self.iconImageView.image = kImageWithName(@"icon_index_qrz");
    }else if([CommonMethod getUserInfoCompletionRate] <= 80){
        self.type = NeedCompleteInfoViewType_CompleteInfo;
        self.titleLabel.text = @"完善个人资料";
        self.subTitleLabel.text = @"据说资料详细程度和人脉质量成正比哦！";
    
        HMCSmallCircularProgressView *progressView = [[HMCSmallCircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [self.iconImageView addSubview:progressView];
    }else if([CommonMethod getUserInfoCompletionRate] != 100){
        self.type = NeedCompleteInfoViewType_CompleteInfo;
        self.titleLabel.text = @"完善个人资料";
        self.subTitleLabel.text = @"据说资料详细程度和人脉质量成正比哦！";
        HMCSmallCircularProgressView *progressView = [[HMCSmallCircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [self.iconImageView addSubview:progressView];
    }else{
        self.type = NeedCompleteInfoViewType_None;
    }
    if(self.needCompleteInfoViewClicked){
        self.needCompleteInfoViewClicked(self.type);
    }
}

- (void)clickedNeedCompleteInfoView{
    switch (self.type) {
        case NeedCompleteInfoViewType_SetInterestIndutry:{
            InterestBusinessController *vc = [CommonMethod getVCFromNib:[InterestBusinessController class]];
            vc.saveInterestBusiness = ^(){
                [self updateDisplay];
            };
            vc.isShowBack = YES;
            [[self viewController].navigationController pushViewController:vc animated:YES];
        }
            break;
        case NeedCompleteInfoViewType_UploadImage:{
            __weak UploadImageTypeView *view = [CommonMethod getViewFromNib:@"UploadImageTypeView"];
            view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
            [view setUploadImageTypeViewType:UploadImageTypeViewType_UploadHeaderImage];
            view.uploadHeaderImageViewResult = ^(BOOL success){
                [self updateDisplay];
            };
            [[UIApplication sharedApplication].keyWindow addSubview:view];
            [view showShareNormalView];
        }
            break;
        case NeedCompleteInfoViewType_CompleteInfo:{
            EditPersonalInfoViewController *vc = [[EditPersonalInfoViewController alloc] init];
            vc.savePersonalInfoSuccess = ^(){
                [self updateDisplay];
            };
            [[self viewController].navigationController pushViewController:vc animated:YES];
        }
            break;
        case NeedCompleteInfoViewType_Identify:{
            IdentityController *vc = [[IdentityController alloc] init];
            vc.idDelegate = self;
            vc.rootTmpViewController = [self viewController];
            [[self viewController].navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - IdentityControllerDelegate
- (void)referImageView:(UIImage *)image{
    [self updateDisplay];
}

@end
