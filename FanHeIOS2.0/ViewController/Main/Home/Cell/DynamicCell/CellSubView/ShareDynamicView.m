//
//  ShareDynamicView.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/3/1.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ShareDynamicView.h"
#import "ContentView.h"
#import "CreateTAAView.h"
#import "DynamicImageView.h"
#import "VariousDetailController.h"
#import "ViewpointDetailViewController.h"
#import "RateDetailController.h"
#import "DynamicCell.h"

@interface ShareDynamicView ()

@property (nonatomic, strong) DynamicModel *model;

@end

@implementation ShareDynamicView

- (id)initWithFrame:(CGRect)frame model:(DynamicModel*)model{
    if(self=[super initWithFrame:frame]){
        self.model = model;
        UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(16, 0, WIDTH-32, frame.size.height)];
        mainView.backgroundColor = HEX_COLOR(@"f8f8fa");
        [self addSubview:mainView];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [mainView addSubview:bgView];
        [CommonMethod viewAddGuestureRecognizer:bgView tapsNumber:1 withTarget:self withSEL:@selector(gotoDetail)];
        
        CGFloat start_Y = 0;
        if(model.type.integerValue==13 && model.exttype.integerValue==17){
            UIButton *nameCompanyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            nameCompanyBtn.frame = CGRectMake(12, 12, WIDTH-56, 16);
            [nameCompanyBtn setTitleColor:HEX_COLOR(@"3498db") forState:UIControlStateNormal];
            [nameCompanyBtn addTarget:self action:@selector(gotoHomePageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            NSString *titleStr;
            if([CommonMethod paramStringIsNull:model.parent_user_company].length){
                titleStr = [NSString stringWithFormat:@"%@·%@%@", [CommonMethod paramStringIsNull:model.parent_user_realname], [CommonMethod paramStringIsNull:model.parent_user_company],[CommonMethod paramStringIsNull:model.parent_user_position]];
            }else{
                titleStr = [CommonMethod paramStringIsNull:model.parent_user_realname];
            }
            CGFloat widthStr = [NSHelper widthOfString:titleStr font:FONT_SYSTEM_SIZE(16) height:16];
            if(widthStr < WIDTH-56){
                nameCompanyBtn.frame = CGRectMake(12, 12, widthStr, 16);
            }
            [nameCompanyBtn setTitle:titleStr forState:UIControlStateNormal];
            nameCompanyBtn.titleLabel.font = FONT_SYSTEM_SIZE(16);
            [nameCompanyBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [mainView addSubview:nameCompanyBtn];
            start_Y += 36;
            if(model.isDynamicDetail.integerValue==1){
                UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(12, start_Y, WIDTH-56, (NSInteger)model.needTitleHeight+2) backColor:HEX_COLOR(@"f8f8fa") textColor:HEX_COLOR(@"41464e") test:@"" font:16 number:1 nstextLocat:NSTextAlignmentLeft];
                [mainView addSubview:titleLabel];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    NSMutableAttributedString * attriStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",model.parent_title]];
                    NSTextAttachment *attchImage = [[NSTextAttachment alloc] init];
                    if(model.parent_gx_type.integerValue==1){
                        attchImage.image = kImageWithName(@"icon_rm_supply");
                    }else{
                        attchImage.image = kImageWithName(@"icon_rm_need");
                    }
                    attchImage.bounds = CGRectMake(0, -5, 21, 21);
                    NSAttributedString *stringImage = [NSAttributedString attributedStringWithAttachment:attchImage];
                    [attriStr insertAttributedString:stringImage atIndex:0];
                    if(model.needTitleHeight>FONT_SYSTEM_SIZE(16).lineHeight && model.needTitleHeight != 21){
                        titleLabel.numberOfLines = 0;
                        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                        [paragraphStyle setLineSpacing:7];
                        [attriStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, 1)];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        titleLabel.attributedText = attriStr;
                        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                        titleLabel.textAlignment = NSTextAlignmentJustified;
                    });
                });
            }else{
                UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, start_Y, 21, 21)];
                if(model.parent_gx_type.integerValue==1){
                    iconImageView.image = kImageWithName(@"icon_rm_supply");
                }else{
                    iconImageView.image = kImageWithName(@"icon_rm_need");
                }
                [mainView addSubview:iconImageView];
                
                UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(40, start_Y, WIDTH-84, (NSInteger)model.needTitleHeight) backColor:HEX_COLOR(@"f8f8fa") textColor:HEX_COLOR(@"41464e") test:model.parent_title font:16 number:1 nstextLocat:NSTextAlignmentLeft];
                [mainView addSubview:titleLabel];
                if(model.needTitleHeight>FONT_SYSTEM_SIZE(16).lineHeight && model.needTitleHeight != 21){
                    titleLabel.numberOfLines = 0;
                    [titleLabel setParagraphText:model.parent_title lineSpace:7];
                    titleLabel.textAlignment = NSTextAlignmentJustified;
                }
            }
            start_Y += 10+model.needTitleHeight;
            
            UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(12, start_Y, WIDTH-56, (NSInteger)model.needContentHeight) backColor:HEX_COLOR(@"f8f8fa") textColor:HEX_COLOR(@"818c9e") test:model.parent_content font:16 number:0 nstextLocat:NSTextAlignmentLeft];
            if(model.needContentHeight>FONT_SYSTEM_SIZE(16).lineHeight){
                [contentLabel setParagraphText:model.parent_content lineSpace:7];
                contentLabel.textAlignment = NSTextAlignmentJustified;
            }
            [mainView addSubview:contentLabel];
            start_Y += model.needContentHeight+10;
            
            if(model.isDynamicDetail.integerValue==1){
                UILabel *tagsLabel = [UILabel createrLabelframe:CGRectMake(12, start_Y, WIDTH-56, (NSInteger)model.tagsHeight+1) backColor:HEX_COLOR(@"f8f8fa") textColor:HEX_COLOR(@"1abc9c") test:model.tagsStr font:12 number:0 nstextLocat:NSTextAlignmentLeft];
                if (model.tagsHeight>FONT_SYSTEM_SIZE(12).lineHeight) {
                    [tagsLabel setParagraphText:model.tagsStr lineSpace:5];
                }
                [mainView addSubview:tagsLabel];
                start_Y += model.tagsHeight+12;
            }
            
            if(model.shareSubViewHeight){
                NSArray *imageArray = [[CommonMethod paramStringIsNull:model.parent_image] componentsSeparatedByString:@","];
                DynamicImageView *dynamicImageView = [[DynamicImageView alloc] initWithFrame:CGRectMake(12, start_Y, WIDTH-80, model.shareSubViewHeight) imageArray:imageArray model:model isShare:YES];
                dynamicImageView.backgroundColor = HEX_COLOR(@"f8f8fa");
                [mainView addSubview:dynamicImageView];
            }
        }else{
            CGFloat width = WIDTH-32-24;
            if(model.shareNameHeight){
                UIButton *nameCompanyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                nameCompanyBtn.frame = CGRectMake(12, 12, width, 16);
                [nameCompanyBtn setTitleColor:HEX_COLOR(@"3498db") forState:UIControlStateNormal];
                [nameCompanyBtn addTarget:self action:@selector(gotoHomePageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                NSString *titleStr;
                if([CommonMethod paramStringIsNull:model.review_user_realname].length){
                    if([CommonMethod paramStringIsNull:model.review_user_company].length){
                        titleStr = [NSString stringWithFormat:@"%@·%@%@", [CommonMethod paramStringIsNull:model.review_user_realname], [CommonMethod paramStringIsNull:model.review_user_company],[CommonMethod paramStringIsNull:model.review_user_position]];
                    }else{
                        titleStr = [CommonMethod paramStringIsNull:model.review_user_realname];
                    }
                }else if([CommonMethod paramStringIsNull:model.parent_review_user_realname].length){
                    if([CommonMethod paramStringIsNull:model.parent_review_user_company].length){
                    titleStr = [NSString stringWithFormat:@"%@·%@%@", [CommonMethod paramStringIsNull:model.parent_review_user_realname], [CommonMethod paramStringIsNull:model.parent_review_user_company],[CommonMethod paramStringIsNull:model.parent_review_user_position]];
                    }else{
                        titleStr = [CommonMethod paramStringIsNull:model.parent_review_user_realname];
                    }
                }else if([CommonMethod paramStringIsNull:model.parent_user_realname].length){
                    if([CommonMethod paramStringIsNull:model.parent_user_company].length){
                        titleStr = [NSString stringWithFormat:@"%@·%@%@", [CommonMethod paramStringIsNull:model.parent_user_realname], [CommonMethod paramStringIsNull:model.parent_user_company],[CommonMethod paramStringIsNull:model.parent_user_position]];
                    }else{
                        titleStr = [CommonMethod paramStringIsNull:model.parent_user_realname];
                    }
                }
                CGFloat widthStr = [NSHelper widthOfString:titleStr font:FONT_SYSTEM_SIZE(16) height:16];
                if(widthStr < width){
                    nameCompanyBtn.frame = CGRectMake(12, 12, widthStr, 16);
                }
                [nameCompanyBtn setTitle:titleStr forState:UIControlStateNormal];
                nameCompanyBtn.titleLabel.font = FONT_SYSTEM_SIZE(16);
                [nameCompanyBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
                [mainView addSubview:nameCompanyBtn];
                start_Y += 35;
            }else{
                start_Y += 12;
            }
            
            if(model.shareContentHeight){
                ContentView *contentView = [CommonMethod getViewFromNib:@"ContentView"];
                contentView.frame = CGRectMake(12, start_Y, width, model.shareContentHeight);
                contentView.backgroundColor = HEX_COLOR(@"f8f8fa");
                if([CommonMethod paramStringIsNull:model.parent_review_content].length){
                    [contentView updateDisplay:[NSString stringWithFormat:@"%@",model.parent_review_content] isShare:YES dynamicId:@(0) dynamicModel:model];//model.dynamic_id
                }else if([CommonMethod paramStringIsNull:model.review_content].length){
                    [contentView updateDisplay:[NSString stringWithFormat:@"%@",model.review_content] isShare:YES dynamicId:@(0) dynamicModel:model];
                }else{
                    [contentView updateDisplay:[NSString stringWithFormat:@"%@",model.parent_content] isShare:YES dynamicId:model.parent dynamicModel:model];
                }
                [mainView addSubview:contentView];
                start_Y += model.shareContentHeight;
            }
            
            if(model.shareSubViewTitle.length){
                CreateTAAView *createTAAView = [CommonMethod getViewFromNib:@"CreateTAAView"];
                createTAAView.frame = CGRectMake(12, start_Y, width, 60);
                createTAAView.backgroundColor = WHITE_COLOR;
                [createTAAView updateDisplay:model];
                [mainView addSubview:createTAAView];
                start_Y += 70;
            }else if(model.shareSubViewHeight){
                NSArray *imageArray = [[CommonMethod paramStringIsNull:model.parent_image] componentsSeparatedByString:@","];
                CGFloat width = WIDTH-80;
                if(imageArray.count==1){
                    if(model.imageSize.width && model.imageSize.height){
                        width = model.imageSize.width*(model.shareSubViewHeight-5.0)/model.imageSize.height;
                        width = width<(WIDTH-90)/3.0?(WIDTH-90)/3.0:width;
                        width = width>(WIDTH-90)/3.0*2+5?(WIDTH-90)/3.0*2+5:width;
                    }
                }
                DynamicImageView *dynamicImageView = [[DynamicImageView alloc] initWithFrame:CGRectMake(12, start_Y, width, model.shareSubViewHeight) imageArray:imageArray model:model isShare:YES];
                dynamicImageView.backgroundColor = HEX_COLOR(@"f8f8fa");
                [mainView addSubview:dynamicImageView];
                start_Y += model.shareSubViewHeight+7;
            }
        }
    }
    return self;
}

- (void)gotoHomePageButtonClicked:(id)sender{
    if([CommonMethod paramNumberIsNull:self.model.parent_review_user_id].integerValue){
        NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
        vc.userId = [CommonMethod paramNumberIsNull:self.model.parent_review_user_id];
        vc.attentUser = ^(BOOL isAttent){
            if([self.superview isKindOfClass:[DynamicCell class]]){
                DynamicCell *cell = (DynamicCell*)self.superview;
                if(cell.attentUser){
                    cell.attentUser(isAttent);
                }
            }
        };
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }else if([CommonMethod paramNumberIsNull:self.model.parent_user_id].integerValue){
        NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
        vc.userId = [CommonMethod paramNumberIsNull:self.model.parent_user_id];
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }else if([CommonMethod paramNumberIsNull:self.model.review_user_id].integerValue){
        NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
        vc.userId = [CommonMethod paramNumberIsNull:self.model.review_user_id];
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
}

- (void)gotoDetail{
    if(self.model.type.integerValue==13&&self.model.exttype.integerValue==17){
        VariousDetailController *vc = [[VariousDetailController alloc] init];
        vc.dynamicid = self.model.parent;
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }else if([CommonMethod paramStringIsNull:self.model.parent_review_content].length){
        VariousDetailController *vc = [[VariousDetailController alloc] init];
        vc.dynamicid = self.model.dynamic_id;
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }else if([CommonMethod paramStringIsNull:self.model.review_content].length){
        if(self.model.subject_id.integerValue){
            ViewpointDetailViewController *vc = [CommonMethod getVCFromNib:[ViewpointDetailViewController class]];
            vc.viewpointId = self.model.review_id;
            TopicDetailModel *topicDetailModel = [[TopicDetailModel alloc] init];
            topicDetailModel.subjectid = self.model.review_id;
            topicDetailModel.title = self.model.review_content;
            vc.topicDetailModel = topicDetailModel;
            [[self viewController].navigationController pushViewController:vc animated:YES];
        }else if(self.model.post_id.integerValue){
            RateDetailController *vc = [CommonMethod getVCFromNib:[RateDetailController class]];
            vc.reviewid = self.model.review_id;
            [[self viewController].navigationController pushViewController:vc animated:YES];
        }
    }else if([CommonMethod paramNumberIsNull:self.model.parent].integerValue){
        VariousDetailController *vc = [[VariousDetailController alloc] init];
        vc.dynamicid = self.model.parent;
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
}

@end
