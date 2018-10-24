//
//  ConventionTopicCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/15.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ConventionTopicCell.h"
#import "TFSearchResultViewController.h"

@implementation ConventionTopicCell
- (void)createrConventionTip:(FinanaceModel *)model{
    self.fianaceModel = model;
    CGFloat gX = 16;
    for(UIView *view in self.tagLabel.subviews){
        [view removeFromSuperview];
    }
    self.tagLabel.userInteractionEnabled = YES;
    if (model.tags.count > 0) {
        for (NSInteger i = 0; i < model.tags.count; i++) {
            CGFloat wideth = [NSHelper widthOfString:model.tags[i] font:[UIFont systemFontOfSize:12] height:20]+16;
            UILabel *label = [[UILabel alloc]init];
            label.font = [UIFont systemFontOfSize:12];
            label.tag = i;
            label.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(searchTagFianace:)];
            [label addGestureRecognizer:tap];
            label.text = model.tags[i];
            label.textColor = [UIColor colorWithHexString:@"1ABC9C"];
            label.layer.cornerRadius = 2;
            label.layer.borderWidth = 0.5;
            label.layer.borderColor = [UIColor colorWithHexString:@"1ABC9C"].CGColor;
            label.textAlignment = NSTextAlignmentCenter;
            if (gX + 32 < WIDTH) {
                label.frame = CGRectMake(gX, 0, wideth, 21);
                gX = gX + wideth + 8;
            }else{
                break;
            }
            
            [self.tagLabel addSubview:label];
        }
    }
    
    self.titleLabel.text = model.title;
    
    if (model.model.usertype.integerValue != 9) {
        self.memberImageView.hidden = YES;
    }else{
        self.memberImageView.hidden = NO;
    }
    
    //说明
    if (model.model.content.length > 0) {
        NSString * htmlString = [NSString stringWithFormat:@"%@",model.model.content];

      self.sidTextView.text =  [htmlString filterHTML];
//        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//            self.sidTextView.attributedText  =attrStr;
//        self.sidTextView.attributedText = [NSHelper contentStringFromRawString:model.model.content];
        self.sidTextView.userInteractionEnabled = NO;

     
        self.sidTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;

        self.sidTextView.editable = NO;
        self.sidTextView.scrollEnabled = NO;
        self.sidTextView.selectable = YES;
        
        self.sidTextView.textColor = HEX_COLOR(@"818C9E");

        self.sidTextView.font = FONT_SYSTEM_SIZE(14);
        self.sidTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
         [self.sidTextView setTextContainerInset:UIEdgeInsetsZero];
        self.sidTextView.textContainer.lineFragmentPadding = 0;
        [self.sidTextView setContentInset:UIEdgeInsetsMake(0, 0, 0, 1)];
        [self.sidTextView setTextAlignment:NSTextAlignmentLeft];//并设置左对齐

        [self.headerImageView.layer setMasksToBounds:YES];
        [self.headerImageView.layer setCornerRadius:self.headerImageView.frame.size.width/2.0]; //设置矩形四个圆角半径
        
        if(model.model.ishidden.integerValue != 0){
            self.nameLabel.text = @"匿名用户";
            self.headerImageView.image = KHeadImageDefaultName(@"匿名");
            self.memberImageView.hidden = YES;
        }else{
              [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.model.image] placeholderImage:KHeadImageDefaultName(model.model.realname)];
            self.nameLabel.text = model.model.realname;
        }
    }else{
        self.headerImageView.hidden = YES;
        self.nameLabel.hidden = YES;
        self.sidTextView.hidden = YES;
    }
    self.rateLabel.text = [NSString stringWithFormat:@"评论 %ld",(long)model.reviewcount.integerValue];
    self.attentionLabel.text = [NSString stringWithFormat:@"关注 %ld",(long)model.attentcount.integerValue];
    self.viewpiontLabel.text = [NSString stringWithFormat:@"观点 %ld",(long)model.replycount.integerValue];
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    
    //    UITextView *text=(UITextView *)sender;
    [UIMenuController sharedMenuController].menuVisible = NO;  //donot display the menu
    [self.sidTextView resignFirstResponder];                     //do not allow the user to selected anything
    return NO;
    
}

+ (CGFloat)tableFrameBackCellHeigthContactsModel:(FinanaceModel *)finceModel{
    CGFloat heigth = 102;
    NSString *titleStr = finceModel.title;
    CGFloat heigth1 = [NSHelper heightOfString:titleStr font:[UIFont systemFontOfSize:17] width:(WIDTH -32)];
    if (heigth1 > 22) {
        heigth1 = 36;
    }else{
        heigth1 = 17;
    }
    NSString *sideStr = finceModel.model.content;
    if (sideStr.length >  0) {
        CGFloat heigth2 = [NSHelper rectHeightWithStrHtml:sideStr];
        //        CGFloat heigth2 = [NSHelper heightOfString:sideStr font:[UIFont systemFontOfSize:14] width:(WIDTH -32)];
        if (heigth2 > 18) {
            heigth2 = 32;
        }else{
            heigth2 = 14;
        }
        
        heigth += 56;
        return heigth + heigth1 + heigth2;
    }
    return heigth + heigth1;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    [CommonMethod viewAddGuestureRecognizer:self.headerImageView    tapsNumber:1 withTarget:self withSEL:@selector(gotoHomePageClicked)];
    [CommonMethod viewAddGuestureRecognizer:self.nameLabel    tapsNumber:1 withTarget:self withSEL:@selector(gotoHomePageClicked)];
}
- (void)searchTagFianace:(UITapGestureRecognizer *)g{
    NSInteger index = g.view.tag;
    TFSearchResultViewController *tfSearch = [[TFSearchResultViewController alloc]init];
    if(self.fianaceModel.type.integerValue == 1){
        tfSearch.type = TFSearchResult_Topic;
    }else{
        tfSearch.type = TFSearchResult_Information;
    }
    tfSearch.tagStr = self.fianaceModel.tags[index];
    [[self viewController].navigationController pushViewController:tfSearch animated:YES];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (void)gotoHomePageClicked{
    if(self.fianaceModel.model.ishidden.integerValue == 0){
        NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
        vc.userId = self.fianaceModel.model.userid;
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
}

@end
