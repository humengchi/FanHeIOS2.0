//
//  DynamicHeaderCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/2.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "DynamicHeaderCell.h"

#import "DymanicHeaderView.h"
#import "ContentView.h"
#import "DynamicImageView.h"
#import "CommentsView.h"
#import "CreateTAAView.h"
#import "ShareDynamicView.h"


@implementation DynamicHeaderCell
- (id)initWithDataDict:(DynamicModel*)model{
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DynamicCell"]){
        
        [self createView:model];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)createView:(DynamicModel*)model{
    CGFloat start_Y = 0;
    
    DymanicHeaderView *headerView = [CommonMethod getViewFromNib:@"DymanicHeaderView"];
    headerView.frame = CGRectMake(0, 0, WIDTH, 72);
    [headerView updateDisplay:model.userModel];
    [self addSubview:headerView];
    start_Y += 72;
    
    if(model.type.integerValue == 17){
        UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(16, start_Y, WIDTH-32, (NSInteger)model.needTitleHeight+2) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:@"" font:17 number:0 nstextLocat:NSTextAlignmentLeft];
        NSMutableAttributedString * attriStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",model.title]];
        NSTextAttachment *attchImage = [[NSTextAttachment alloc] init];
        if(model.gx_type.integerValue==1){
            attchImage.image = kImageWithName(@"icon_rm_supply");
        }else{
            attchImage.image = kImageWithName(@"icon_rm_need");
        }
        attchImage.bounds = CGRectMake(0, -5, 21, 21);
        NSAttributedString *stringImage = [NSAttributedString attributedStringWithAttachment:attchImage];
        [attriStr insertAttributedString:stringImage atIndex:0];
        if(model.needTitleHeight>FONT_SYSTEM_SIZE(17).lineHeight && model.needTitleHeight != 21){
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            [paragraphStyle setLineSpacing:9];
            [attriStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, 1)];
        }
        titleLabel.attributedText = attriStr;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.textAlignment = NSTextAlignmentJustified;
        [self addSubview:titleLabel];
        start_Y += 12+model.needTitleHeight;
        
        UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(16, start_Y, WIDTH-32, (NSInteger)model.needContentHeight) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e") test:model.content font:17 number:0 nstextLocat:NSTextAlignmentLeft];
        if(model.needContentHeight>FONT_SYSTEM_SIZE(17).lineHeight){
            [contentLabel setParagraphText:model.content lineSpace:9];
            contentLabel.textAlignment = NSTextAlignmentJustified;
        }
        [self addSubview:contentLabel];
        start_Y += model.needContentHeight+10;
        if(model.isDynamicDetail.integerValue==1){
            UILabel *tagsLabel = [UILabel createrLabelframe:CGRectMake(16, start_Y, WIDTH-32, (NSInteger)model.tagsHeight+1) backColor:WHITE_COLOR textColor:HEX_COLOR(@"1abc9c") test:model.tagsStr font:12 number:0 nstextLocat:NSTextAlignmentLeft];
            if (model.tagsHeight>FONT_SYSTEM_SIZE(12).lineHeight) {
                [tagsLabel setParagraphText:model.tagsStr lineSpace:5];
            }
            [self addSubview:tagsLabel];
            start_Y += model.tagsHeight+12;
        }
        
        if(model.imageHeight){
            NSArray *imageArray = [[CommonMethod paramStringIsNull:model.image] componentsSeparatedByString:@","];
            DynamicImageView *dynamicImageView = [[DynamicImageView alloc] initWithFrame:CGRectMake(16, start_Y, WIDTH-80, model.imageHeight) imageArray:imageArray model:model isShare:NO];
            dynamicImageView.backgroundColor = WHITE_COLOR;
            [self addSubview:dynamicImageView];
            start_Y += model.imageHeight+12;
        }
        
    }else if(model.type.integerValue==13 && model.exttype.integerValue==17){
        if(model.contentHeight){
            ContentView *contentViewTmp = [CommonMethod getViewFromNib:@"ContentView"];
            contentViewTmp.frame = CGRectMake(16, start_Y, WIDTH-32, model.contentHeight);
            [contentViewTmp updateDisplay:model.content isShare:NO dynamicId:model.dynamic_id dynamicModel:model];
            [self addSubview:contentViewTmp];
            start_Y += model.contentHeight+3;
        }
        if(model.shareViewHeight){
            ShareDynamicView *shareDynamicView = [[ShareDynamicView alloc] initWithFrame:CGRectMake(0, start_Y, WIDTH, model.shareViewHeight) model:model];
            [self addSubview:shareDynamicView];
            start_Y += model.shareViewHeight+12;
        }
    }else{
        if(model.contentHeight){
            ContentView *contentView = [CommonMethod getViewFromNib:@"ContentView"];
            contentView.frame = CGRectMake(16, start_Y, WIDTH-32, model.contentHeight);
            [contentView updateDisplay:model.content isShare:NO dynamicId:@(-1) dynamicModel:model];
            [self addSubview:contentView];
            start_Y += model.contentHeight+3;
        }
        if(model.imageHeight){
            NSArray *imageArray = [[CommonMethod paramStringIsNull:model.image] componentsSeparatedByString:@","];
            DynamicImageView *dynamicImageView = [[DynamicImageView alloc] initWithFrame:CGRectMake(16, start_Y, WIDTH-80,model.imageHeight) imageArray:imageArray model:model isShare:NO];
             dynamicImageView.backgroundColor = WHITE_COLOR;
            [self addSubview:dynamicImageView];
            start_Y += model.imageHeight ;
        }
        
        if([CommonMethod paramNumberIsNull:model.parent_status].integerValue>=4){
            UILabel *deleteLabel = [UILabel createrLabelframe:CGRectMake(16, start_Y, WIDTH-32, 46) backColor:HEX_COLOR(@"f8f8fa") textColor:HEX_COLOR(@"818c9e") test:@"   抱歉，分享内容已被删除" font:14 number:1 nstextLocat:NSTextAlignmentLeft];
            [self addSubview:deleteLabel];
            start_Y += 58;
        }
        if(model.shareViewOnlyHeight){
            CreateTAAView *createTAAView = [CommonMethod getViewFromNib:@"CreateTAAView"];
            createTAAView.frame = CGRectMake(16, start_Y, WIDTH-32, 60);
            [createTAAView updateDisplay:model];
            [self addSubview:createTAAView];
            start_Y += model.shareViewOnlyHeight;
        }
        if(model.shareViewHeight){
            ShareDynamicView *shareDynamicView = [[ShareDynamicView alloc] initWithFrame:CGRectMake(0, start_Y, WIDTH, model.shareViewHeight) model:model];
            [self addSubview:shareDynamicView];
            start_Y += model.shareViewHeight+12;
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}



@end
