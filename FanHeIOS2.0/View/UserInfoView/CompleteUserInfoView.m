//
//  CompleteUserInfoView.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/23.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "CompleteUserInfoView.h"

#import <QuartzCore/QuartzCore.h>

@interface HMCCircularProgressView : UIView


@end

@implementation HMCCircularProgressView

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
    CGContextSetLineWidth(context, 15.0);
    CGContextAddArc(context, rect.size.width/2, rect.size.width/2, rect.size.width/2-7.5, 0, 2*M_PI, 0);
    CGContextDrawPath(context, kCGPathStroke);
    
    CGContextSetStrokeColorWithColor(context, circleColor.CGColor);
    CGContextSetLineWidth(context, 15.0);
    CGContextAddArc(context, rect.size.width/2, rect.size.width/2, rect.size.width/2-7.5, -M_PI/2, 2*M_PI*rate/100.0-M_PI/2, 0);
    CGContextDrawPath(context, kCGPathStroke);
    
    NSString *str = [NSString stringWithFormat:@"%ld%%", rate];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    [str drawInRect:CGRectMake(0, rect.size.width/2-25, rect.size.width, 40) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:circleColor,NSForegroundColorAttributeName,FONT_BOLD_SYSTEM_SIZE(36),NSFontAttributeName, paragraph, NSParagraphStyleAttributeName, nil]];
    [@"资料完善度" drawInRect:CGRectMake(0, rect.size.width/2+20, rect.size.width, 15) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:HEX_COLOR(@"AFB6C1"),NSForegroundColorAttributeName,FONT_SYSTEM_SIZE(12),NSFontAttributeName, paragraph, NSParagraphStyleAttributeName, nil]];
}

@end

@interface CompleteUserInfoView ()

@property (nonatomic, weak) IBOutlet UIView *circleView;
@property (nonatomic, weak) IBOutlet UIButton *userNameBtn;
@property (nonatomic, weak) IBOutlet UIButton *companyBtn;
@property (nonatomic, weak) IBOutlet UIButton *positionBtn;
@property (nonatomic, weak) IBOutlet UIButton *headerImageBtn;
@property (nonatomic, weak) IBOutlet UIButton *goodJobs;

@end

@implementation CompleteUserInfoView


- (id)initWithType:(CompleteUserInfoViewType)type{
    NSString *nib;
    switch (type) {
        case CompleteUserInfoViewType_FirstLogin:
            nib = @"CompleteUserInfoViewFirstLogin";
            break;
        case CompleteUserInfoViewType_AddFriend:
            nib = @"CompleteUserInfoViewAddFriend";
            break;
        case CompleteUserInfoViewType_WorkHistory:
            nib = @"CompleteUserInfoViewWorkHistory";
            break;
        case CompleteUserInfoViewType_Identify:
            nib = @"CompleteUserInfoViewIdentify";
            break;
        case CompleteUserInfoViewType_UploadImage:
            nib = @"CompleteUserInfoViewUploadImage";
            break;
        case CompleteUserInfoViewType_HangCoffee:
            nib = @"CompleteUserInfoViewHangCoff";
            
            
        default:
            break;
    }
    if((self=[[[NSBundle mainBundle] loadNibNamed:nib owner:nil options:nil] objectAtIndex:0])){
        self.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
        if(type == CompleteUserInfoViewType_FirstLogin){
            HMCCircularProgressView *progressView = [[HMCCircularProgressView alloc] initWithFrame:CGRectMake(0, 0, 155, 155)];
            [self.circleView addSubview:progressView];
        }
        [self updateUserInfo];
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    return self;
}

#pragma mark -判断显示，姓名、公司、职位、头像、擅长业务是否完善
- (void)updateUserInfo{
    UserModel *model = [DataModelInstance shareInstance].userModel;
    self.userNameBtn.selected = model.realname.length>0;
    self.companyBtn.selected = model.company.length>0;
    self.positionBtn.selected = model.position.length>0;
    self.headerImageBtn.selected = model.image.length>0;
    self.goodJobs.selected = model.goodjobs.count>0;
}

#pragma mark -关闭视图
- (IBAction)removeCoverView:(UIButton *)sender{
    if(self.completeUserInfoViewCancle){
        self.completeUserInfoViewCancle();
    }
    [self removeFromSuperview];
}

#pragma mark--完善资料
- (IBAction)editInfoAction:(UIButton *)sender {
    if(self.completeUserInfoViewEditInfo){
        self.completeUserInfoViewEditInfo();
    }
    [self removeFromSuperview];
}

#pragma mark ------- 拍照
- (IBAction)upHeaderImageAction:(UIButton *)sender {
    self.hidden = YES;
    [self tapUploadImage];
}

- (void)tapUploadImage{
    __weak typeof(self) weakSelf = self;
    UploadImageTypeView *view = [CommonMethod getViewFromNib:@"UploadImageTypeView"];
    view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    [view setUploadImageTypeViewType:UploadImageTypeViewType_UploadHeaderImage];
    view.uploadHeaderImageViewResult = ^(BOOL success){
        if(weakSelf.completeUserInfoViewUploadImage){
            weakSelf.completeUserInfoViewUploadImage();
        }
        [weakSelf removeFromSuperview];
    };
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view showShareNormalView];
}

@end
