
//
//  CommentsView.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/3/1.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "CommentsView.h"
#import "VariousDetailController.h"

@interface CommentsView ()<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) DynamicModel *model;

@property (nonatomic, strong) NSMutableArray *cellHeightArray;

@end

@implementation CommentsView

- (id)initWithFrame:(CGRect)frame model:(DynamicModel*)model{
    if (self=[super initWithFrame:frame]) {
        self.model = model;
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(18, 2, 11, 11)];
        iconImageView.image = kImageWithName(@"btn_dt_pl");
        [self addSubview:iconImageView];
        
        self.cellHeightArray = [NSMutableArray array];
        NSInteger contentHeight = 0;
        NSInteger cellRow = 0;
        BOOL showMoreView = NO;
        for(int i=0; i< model.commentRows; i++){
            DynamicCommentModel *model = self.model.dynamic_reviewlist[i];
            NSInteger height = [NSHelper heightOfString:model.showContent font:FONT_SYSTEM_SIZE(14) width:WIDTH-48 defaultHeight:FONT_SYSTEM_SIZE(14).lineHeight];
            NSInteger row = height/(NSInteger)FONT_SYSTEM_SIZE(14).lineHeight;
            height += row*7;
            if(cellRow+row>4){
                height = self.model.commentHeight-contentHeight-26;
                showMoreView = YES;
            }else{
                contentHeight += height;
            }
            [self.cellHeightArray addObject:@(height)];
            cellRow += row;
        }
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(32, 0, WIDTH-48, frame.size.height) style:UITableViewStylePlain];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = WHITE_COLOR;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.scrollEnabled = NO;
        self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.tableView];
        
        if(showMoreView||model.commentRows<model.reviewcount.integerValue||model.commentRows==4||model.commentContentRows>=4){
            UILabel *numLabel = [UILabel createLabel:CGRectMake(0, 0, WIDTH-48, 18) font:FONT_SYSTEM_SIZE(14) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"afb6c1")];
            numLabel.text = [NSString stringWithFormat:@"查看%@条评论", self.model.reviewcount];
            self.tableView.tableFooterView = numLabel;
            [CommonMethod viewAddGuestureRecognizer:numLabel tapsNumber:1 withTarget:self withSEL:@selector(gotoDynamicDetail)];
        }
    }
    return self;
}

- (void)gotoDynamicDetail{
    if(self.model.dynamic_id.integerValue){
        VariousDetailController *vc = [[VariousDetailController alloc] init];
        vc.dynamicid = self.model.dynamic_id;
        vc.deleteDynamicDetail = ^(NSNumber *dynamicid) {
            
        };
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UITableViewDelegate/data
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.model.commentRows;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 21;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSNumber *height = self.cellHeightArray[indexPath.row];
    return height.integerValue;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    DynamicCommentModel *model = self.model.dynamic_reviewlist[indexPath.row];
    
    NSNumber *height = self.cellHeightArray[indexPath.row];
    NSString *text = model.showContent;
    UITextView *contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, WIDTH-48, height.integerValue)];
    contentTextView.delegate = self;
    contentTextView.editable = NO;
    contentTextView.scrollEnabled = NO;
    contentTextView.userInteractionEnabled = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
        [attr addAttributes:@{NSForegroundColorAttributeName:HEX_COLOR(@"818c9e")} range:NSMakeRange(0, text.length)];
        //名字
        NSRange range = [text rangeOfString:[NSString stringWithFormat:@"%@：",[CommonMethod paramStringIsNull:model.senderModel.realname]]];
        [attr setAttributes:@{NSForegroundColorAttributeName:HEX_COLOR(@"3498db")} range:range];
        
        NSRange range1 = [text rangeOfString:[CommonMethod paramStringIsNull:model.senderModel.realname]];
        [attr setAttributes:@{NSLinkAttributeName:[NSString stringWithFormat:@"%@",[CommonMethod paramNumberIsNull:model.senderModel.userId]]} range:range1];
        
        NSRange range2 = [text rangeOfString:[NSString stringWithFormat:@"%@：",[CommonMethod paramStringIsNull:model.replytoModel.realname]]];
        [attr setAttributes:@{NSLinkAttributeName:[NSString stringWithFormat:@"%@",[CommonMethod paramNumberIsNull:model.replytoModel.userId]]} range:range2];
        
        //行间距
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyle setLineSpacing:5];//7
        [attr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, text.length)];
        dispatch_async(dispatch_get_main_queue(), ^{
            contentTextView.tintColor = HEX_COLOR(@"3498db");
            contentTextView.attributedText = attr;
            contentTextView.font = FONT_SYSTEM_SIZE(14);
            contentTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
            [contentTextView setTextContainerInset:UIEdgeInsetsZero];
            contentTextView.textContainer.lineFragmentPadding = 0;
            [contentTextView setContentInset:UIEdgeInsetsMake(0, 0, 0, 1)];
            [contentTextView setTextAlignment:NSTextAlignmentJustified];//并设置左对齐
        });
    });
    [cell.contentView addSubview:contentTextView];
    contentTextView.tag = indexPath.row;
    
    [CommonMethod viewAddGuestureRecognizer:contentTextView tapsNumber:1 withTarget:self withSEL:@selector(gotoReview:)];
    
    return cell;
}

- (void)gotoReview:(UITapGestureRecognizer*)gesture{
    if(self.replyUserReview){
        self.replyUserReview(gesture.view.tag);
    }
}


#pragma mark -UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    if([CommonMethod paramStringIsNull:URL.absoluteString].integerValue){
        NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
        vc.userId = [NSNumber numberWithInteger:[CommonMethod paramStringIsNull:URL.absoluteString].integerValue];
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
    return YES;
}

@end
