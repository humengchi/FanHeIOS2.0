//
//  TopicTableViewCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/15.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "TopicTableViewCell.h"
#import "ReportViewController.h"

@interface TopicTableViewCell ()<UIGestureRecognizerDelegate, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *vipImageView;
@property (weak, nonatomic) IBOutlet UILabel *noNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *realNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *zfImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (nonatomic, strong) UIMenuController *menu;

@property (nonatomic, strong) IBOutlet UITextView *contentTextView;

@property (nonatomic, strong) ViewpointModel *model;

@end

@implementation TopicTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [CALayer updateControlLayer:self.headerImageView.layer radius:22 borderWidth:0 borderColor:nil];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingle:)];
    singleTap.delegate= self;
    singleTap.cancelsTouchesInView = NO;
    self.contentTextView.userInteractionEnabled = YES;
    [self.contentTextView addGestureRecognizer:singleTap];
    
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
//    longPress.minimumPressDuration = 0.5;
//    longPress.cancelsTouchesInView = NO;
//    longPress.delegate = self;
//    self.contentTextView.userInteractionEnabled = YES;
//    [self.contentTextView addGestureRecognizer:longPress];
}

- (void)handleSingle:(UITapGestureRecognizer *)sender{
    if(self.selectCell){
        self.selectCell(sender);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    [self.menu setMenuVisible:NO animated:YES];
    // Configure the view for the selected state
}

#pragma mark - ContentView
- (void)createContentWebView{
    self.contentTextView.delegate = self;
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[self.model.content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSFontAttributeName: FONT_SYSTEM_SIZE(14)} documentAttributes:nil error:nil];
    if([self.model.content filterHTML].length){
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyle setLineSpacing:4];
        [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attrStr.string.length)];
    }
    self.contentTextView.attributedText = attrStr;
    self.contentTextView.font = FONT_SYSTEM_SIZE(14);
    self.contentTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentTextView setTextContainerInset:UIEdgeInsetsZero];
    self.contentTextView.textContainer.lineFragmentPadding = 0;
    [self.contentTextView setContentInset:UIEdgeInsetsMake(0, 0, 0, 1)];
    [self.contentTextView setTextAlignment:NSTextAlignmentLeft];//并设置左对齐
}

#pragma mark -UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    if(URL.absoluteString && [URL.absoluteString hasPrefix:ShareHomePageURL]){
        NSNumber *userId = [NSNumber numberWithInteger:[[URL.absoluteString stringByReplacingOccurrencesOfString:ShareHomePageURL withString:@""] integerValue]];
        [self.menu setMenuVisible:NO animated:YES];
        NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
        vc.userId = userId;
        [[self viewController].navigationController pushViewController:vc animated:YES];
        return NO;
    }
    return YES;
}

- (IBAction)gotoHomePageClicked:(id)sender{
    [self.menu setMenuVisible:NO animated:YES];
    if(self.model.ishidden.integerValue == 0){
        NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
        vc.userId = self.model.userid;
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
}

- (void)updateDisplay:(ViewpointModel *)model{
    self.model = model;
    self.vipImageView.hidden = model.usertype.integerValue != 9;
    if(model.ishidden.integerValue == 1){
        self.headerImageView.image = KHeadImageDefaultName(@"匿名");
        self.noNameLabel.hidden = NO;
        self.vipImageView.hidden = YES;
    }else{
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
        self.noNameLabel.hidden = YES;
        self.realNameLabel.text = model.realname;
        self.companyLabel.text = [NSString stringWithFormat:@"%@%@",model.company, model.position];
    }
    self.zfImageView.hidden = model.othericon.integerValue !=1;
    
    self.numLabel.text = [NSString stringWithFormat:@"赞 %@  评论 %@", [NSString getNumStr:model.praisecount], [NSString getNumStr:model.reviewcount]];
    self.timeLabel.text = model.created_at;
    [self createContentWebView];
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        if(self.menu==nil){
            self.menu = [UIMenuController sharedMenuController];
            UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyMenuAction)];
            UIMenuItem *report = [[UIMenuItem alloc] initWithTitle:@"举报" action:@selector(reportMenuAction)];
            if(self.model.userid.integerValue == [DataModelInstance shareInstance].userModel.userId.integerValue){
                [self.menu setMenuItems:[NSArray arrayWithObjects:copy,nil]];
            }else{
                [self.menu setMenuItems:[NSArray arrayWithObjects:copy, report, nil]];
            }
        }
        [self.menu setTargetRect:self.contentTextView.frame inView:self.contentTextView.superview];
        [self.menu setMenuVisible:YES animated:YES];
    }
}

- (void)copyMenuAction{
    UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
    [generalPasteBoard setString:self.model.content];
    [MBProgressHUD showSuccess:@"复制成功" toView:[self viewController].view];
}

- (void)reportMenuAction{
    ReportViewController *vc = [CommonMethod getVCFromNib:[ReportViewController class]];
    vc.reportType = ReportType_Viewpoint;
    vc.reportId = self.model.reviewid;
    [[self viewController].navigationController pushViewController:vc animated:YES];
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action ==@selector(copyMenuAction) || action ==@selector(reportMenuAction)){
        return YES;
    }
    return NO;//隐藏系统默认的菜单项
}

@end
