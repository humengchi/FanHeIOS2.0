//
//  ContentView.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/3/1.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ContentView.h"
#import "SearchViewController.h"
#import "WebViewController.h"
#import "VariousDetailController.h"
#import "ViewpointDetailViewController.h"
#import "RateDetailController.h"
#import "DynamicCell.h"

@interface ContentView ()<UIGestureRecognizerDelegate, UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UITextView *contentTextView;

@property (nonatomic, strong) DynamicModel *model;

@end

@implementation ContentView

- (void)drawRect:(CGRect)rect {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingle:)];
    singleTap.delegate= self;
    singleTap.cancelsTouchesInView = NO;
    self.contentTextView.userInteractionEnabled = YES;
    [self.contentTextView addGestureRecognizer:singleTap];
}

- (void)handleSingle:(UITapGestureRecognizer *)sender{
    if(self.dynamicId.integerValue > 0){
        VariousDetailController *vc = [[VariousDetailController alloc] init];
        vc.dynamicid = self.dynamicId;
        vc.deleteDynamicDetail = ^(NSNumber *dynamicid){
            if([self.superview isKindOfClass:[DynamicCell class]]){
                DynamicCell *cell = (DynamicCell*)self.superview;
                if(cell.deleteDynamicCell){
                    cell.deleteDynamicCell(cell);
                }
            }
        };
        vc.attentUser = ^(BOOL isAttent){
            if([self.superview isKindOfClass:[DynamicCell class]]){
                DynamicCell *cell = (DynamicCell*)self.superview;
                if(cell.attentUser){
                    cell.attentUser(isAttent);
                }
            }else if(self.superview.superview.superview && [self.superview.superview.superview isKindOfClass:[DynamicCell class]]){
                DynamicCell *cell = (DynamicCell*)self.superview.superview.superview;
                if(cell.attentUser){
                    cell.attentUser(isAttent);
                }
            }
        };
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }else if(self.dynamicId.integerValue==0){
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
        }else if(self.model.parent_post_id.integerValue){
            RateDetailController *vc = [CommonMethod getVCFromNib:[RateDetailController class]];
            vc.reviewid = self.model.parent_review_id;
            [[self viewController].navigationController pushViewController:vc animated:YES];
        }else if(self.model.parent_subject_id.integerValue){
            ViewpointDetailViewController *vc = [CommonMethod getVCFromNib:[ViewpointDetailViewController class]];
            vc.viewpointId = self.model.parent_review_id;
            TopicDetailModel *topicDetailModel = [[TopicDetailModel alloc] init];
            topicDetailModel.subjectid = self.model.parent_review_id;
            topicDetailModel.title = self.model.parent_review_content;
            vc.topicDetailModel = topicDetailModel;
            [[self viewController].navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - ContentView
- (void)updateDisplay:(NSString*)content isShare:(BOOL)isShare dynamicId:(NSNumber*)dynamicId dynamicModel:(DynamicModel*)model{
    self.dynamicId = dynamicId;
    self.model = model;
    CGFloat spacing;
    CGFloat font;
    if(isShare){
        spacing = 7;
        font = 16;
        self.contentTextView.backgroundColor = HEX_COLOR(@"f8f8fa");
    }else{
        spacing = 9;
        font = 17;
        self.contentTextView.backgroundColor = WHITE_COLOR;
    }
    
    self.contentTextView.delegate = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *contentStr = content;
        if([contentStr containsString:@"extype=\"urllink\">"]){
            NSData *data = UIImagePNGRepresentation(kImageWithName(@"icon_dt_link"));
            NSString *str = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            str = [NSString stringWithFormat:@"extype=\"urllink\"><img src=\"data:image/png;base64,%@\" />", str];
            contentStr = [contentStr stringByReplacingOccurrencesOfString:@"extype=\"urllink\">" withString:str];
        }
        NSString *style = [NSString stringWithFormat:@"%@",@"<head><meta name=\"viewport\" content=\"width=self.view.frame.size.width,initial-scale=1.0,user-scalable=0\"><style> body { margin:0; padding:0rem; border:0; font-size:100%; font-family:\"Helvetica Neue\",Helvetica,\"Hiragino Sans GB\",\"Microsoft YaHei\",Arial,sans-serif; vertical-align:baseline; word-break : normal; } p,div{ margin: 0; font-size: 1rem; line-height: 1rem; color: #41464E; word-break : normal; text-align:justify; text-justify:inter-word; } h1,h2,h3,h4,h5,h6 { margin: 0; font-size: 1rem; line-height: 1rem; color: #41464E; font-weight:bold; word-break : normal; text-align:justify; text-justify:inter-word; } img{ max-width: 100%; height: auto; object-fit:scale-down; } a{ font-size: 1rem; line-height: 1rem; color: #3498db; padding:0 0.3125rem; text-decoration: none; -webkit-tap-highlight-color:rgba(0,0,0,0); }width:100% !important;}</style></head>"];
        contentStr = [contentStr stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
        contentStr = [contentStr stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
        if([[contentStr lowercaseString] hasPrefix:@"<p "] ||[[contentStr lowercaseString] hasPrefix:@"<p>"]){
            contentStr = [NSString stringWithFormat:@"%@%@", style, contentStr];
        }else{
            contentStr = [NSString stringWithFormat:@"%@<p>%@</p>", style, contentStr];
        }
        NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[contentStr dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSFontAttributeName: FONT_SYSTEM_SIZE(font)} documentAttributes:nil error:nil];
        if([contentStr filterHTML].length){
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            [paragraphStyle setLineSpacing:spacing-1];
            [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attrStr.string.length)];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.contentTextView.attributedText = attrStr;
            self.contentTextView.editable = NO;
            self.contentTextView.font = FONT_SYSTEM_SIZE(font);
            self.contentTextView.textColor = HEX_COLOR(@"41464e");
            self.contentTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
            [self.contentTextView setTextContainerInset:UIEdgeInsetsZero];
            self.contentTextView.textContainer.lineFragmentPadding = 0;
            [self.contentTextView setContentInset:UIEdgeInsetsMake(0, 0, 0, 1)];
            [self.contentTextView setTextAlignment:NSTextAlignmentLeft];//并设置左对齐
            self.contentTextView.tintColor = HEX_COLOR(@"3498db");
        });
    });
}

#pragma mark -UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    if(URL.absoluteString && [URL.absoluteString hasPrefix:ShareHomePageURL]){
        NSNumber *userId = [NSNumber numberWithInteger:[[URL.absoluteString stringByReplacingOccurrencesOfString:ShareHomePageURL withString:@""] integerValue]];
        if(userId.integerValue){
            NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
            vc.userId = userId;
            [[self viewController].navigationController pushViewController:vc animated:YES];
        }
    }else if(URL.absoluteString && [URL.absoluteString hasPrefix:@"keyword://"]){
        NSString *keyWord = [URL.absoluteString stringByReplacingOccurrencesOfString:@"keyword://" withString:@""];
        if(textView.text.length > characterRange.location+characterRange.length){
            keyWord = [textView.text substringWithRange:characterRange];
            keyWord = [keyWord stringByReplacingOccurrencesOfString:@"#" withString:@""];
        }
        
        if(keyWord.length){
            SearchViewController *vc = [CommonMethod getVCFromNib:[SearchViewController class]];
            vc.isFrist = YES;
            vc.searchTitle = keyWord;
            vc.view.transform = CGAffineTransformMakeTranslation(0, 64);
            vc.view.alpha = 0.8;
            [UIView animateWithDuration:0.3 animations:^{
                vc.view.alpha = 1;
                vc.view.transform = CGAffineTransformMakeTranslation(0, 0);
            }];
            [[self viewController].navigationController pushViewController:vc animated:NO];
        }
    }else{
        if(URL.absoluteString){
            WebViewController *vc = [[WebViewController alloc] init];
            vc.webUrl = URL.absoluteString;
            [[self viewController].navigationController pushViewController:vc animated:YES];
        }
    }
    return NO;
}

@end
