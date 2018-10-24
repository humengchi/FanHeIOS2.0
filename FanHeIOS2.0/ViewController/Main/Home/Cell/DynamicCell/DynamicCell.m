//
//  DynamicCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/28.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "DynamicCell.h"
#import "HeaderView.h"
#import "ContentView.h"
#import "DynamicImageView.h"
#import "CommentsView.h"
#import "ToolsView.h"
#import "UploadFailureView.h"
#import "CreateTAAView.h"
#import "ShareDynamicView.h"
#import "DymanicRateController.h"

@interface DynamicCell ()<DymanicRateControllerDelegate>


@property (nonatomic, strong) HeaderView *headerView;
@property (nonatomic, strong) ContentView *contentViewTmp;
@property (nonatomic, strong) DynamicImageView *dynamicImageView;
@property (nonatomic, strong) ToolsView *toolsView;

@end

@implementation DynamicCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.clipsToBounds = YES;
}

- (void)updateDisplayEnableEdit:(DynamicModel*)model{
    self.model = model;
    self.headerView.choiceBtn.enabled = YES;
    self.headerView.model = model;
    self.contentViewTmp.userInteractionEnabled = YES;
    self.contentViewTmp.dynamicId = model.dynamic_id;
    self.toolsView.userInteractionEnabled = YES;
    self.toolsView.model = model;
    self.dynamicImageView.model = model;
}

- (id)initWithDataModel:(DynamicModel*)model identifier:(NSString*)identifier{
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier]){
        self.model = model;
//        [self updateDisplay:model];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateDisplay:(DynamicModel*)model{
    NSOperationQueue *queue = [NSOperationQueue currentQueue];
    queue.maxConcurrentOperationCount = 1;
    __block CGFloat start_Y = 0;
    __weak typeof(self) weakSelf = self;
    [queue addOperationWithBlock:^{
        self.headerView = [CommonMethod getViewFromNib:@"HeaderView"];
        self.headerView.frame = CGRectMake(0, 0, WIDTH, 72);
        [self.headerView updateDisplay:model];
        self.headerView.deleteDynamic = ^(){
            [weakSelf deleteDynamicHttp];
        };
        self.headerView.ignoreDynamic = ^(){
            if(weakSelf.deleteDynamicCell){
                weakSelf.deleteDynamicCell(weakSelf);
            }
        };
        self.headerView.deleteUserDynamic = ^(NSNumber *userId){
            if(weakSelf.deleteUserDynamic){
                weakSelf.deleteUserDynamic(userId);
            }
        };
        [self.contentView addSubview:self.headerView];
        start_Y += 72;
    }];
    
    [queue addOperationWithBlock:^{
        if(model.type.integerValue == 17){
            UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, start_Y, 21, 21)];
            if(model.gx_type.integerValue==1){
                iconImageView.image = kImageWithName(@"icon_rm_supply");
            }else{
                iconImageView.image = kImageWithName(@"icon_rm_need");
            }
            [self.contentView addSubview:iconImageView];
            
            UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(45, start_Y, WIDTH-61, (NSInteger)model.needTitleHeight) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:model.title font:17 number:1 nstextLocat:NSTextAlignmentLeft];
            [self.contentView addSubview:titleLabel];
            start_Y += 12+21;
            
            UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(16, start_Y, WIDTH-32, (NSInteger)model.needContentHeight) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e") test:model.content font:17 number:0 nstextLocat:NSTextAlignmentLeft];
            if(model.needContentHeight>FONT_SYSTEM_SIZE(17).lineHeight){
                [contentLabel setParagraphText:model.content lineSpace:9];
            }
            [self.contentView addSubview:contentLabel];
            start_Y += model.needContentHeight+10;
            
            if(model.isDynamicDetail.integerValue==1){
                UILabel *tagsLabel = [UILabel createrLabelframe:CGRectMake(16, start_Y, WIDTH-32, (NSInteger)model.tagsHeight) backColor:WHITE_COLOR textColor:HEX_COLOR(@"1abc9c") test:model.tagsStr font:12 number:0 nstextLocat:NSTextAlignmentLeft];
                if (model.tagsHeight>FONT_SYSTEM_SIZE(12).lineHeight) {
                    [tagsLabel setParagraphText:model.tagsStr lineSpace:5];
                }
                [self.contentView addSubview:tagsLabel];
                start_Y += model.tagsHeight+12;
            }
            
            if(model.imageHeight){
                NSArray *imageArray = [[CommonMethod paramStringIsNull:model.image] componentsSeparatedByString:@","];
                self.dynamicImageView = [[DynamicImageView alloc] initWithFrame:CGRectMake(16, start_Y, WIDTH-80, model.imageHeight) imageArray:imageArray model:model isShare:NO];
                self.dynamicImageView.backgroundColor = WHITE_COLOR;
                [self.contentView addSubview:self.dynamicImageView];
                start_Y += model.imageHeight+12;
            }
            
        }else if(model.type.integerValue==13 && model.exttype.integerValue==17){
            if(model.contentHeight){
                self.contentViewTmp = [CommonMethod getViewFromNib:@"ContentView"];
                self.contentViewTmp.frame = CGRectMake(16, start_Y, WIDTH-32, (NSInteger)model.contentHeight);
                [self.contentViewTmp updateDisplay:model.content isShare:NO dynamicId:model.dynamic_id dynamicModel:model];
                [self.contentView addSubview:self.contentViewTmp];
                start_Y += model.contentHeight+3;
                if(model.dynamic_id.integerValue<0){
                    self.contentViewTmp.userInteractionEnabled = NO;
                }
            }
        }else{
            if(model.contentHeight){
                self.contentViewTmp = [CommonMethod getViewFromNib:@"ContentView"];
                self.contentViewTmp.frame = CGRectMake(16, start_Y, WIDTH-32, (NSInteger)model.contentHeight);
                [self.contentViewTmp updateDisplay:model.content isShare:NO dynamicId:model.dynamic_id dynamicModel:model];
                [self.contentView addSubview:self.contentViewTmp];
                start_Y += model.contentHeight+3;
                if(model.dynamic_id.integerValue<0){
                    self.contentViewTmp.userInteractionEnabled = NO;
                }
            }
            
            if(model.imageHeight){
                NSArray *imageArray = [[CommonMethod paramStringIsNull:model.image] componentsSeparatedByString:@","];
                self.dynamicImageView = [[DynamicImageView alloc] initWithFrame:CGRectMake(16, start_Y, WIDTH-80, model.imageHeight) imageArray:imageArray model:model isShare:NO];
                self.dynamicImageView.backgroundColor = WHITE_COLOR;
                [self.contentView addSubview:self.dynamicImageView];
                start_Y += model.imageHeight+12;
            }
            
            if([CommonMethod paramNumberIsNull:model.parent_status].integerValue>=4){
                UILabel *deleteLabel = [UILabel createrLabelframe:CGRectMake(16, start_Y, WIDTH-32, 46) backColor:HEX_COLOR(@"f8f8fa") textColor:HEX_COLOR(@"818c9e") test:@"   抱歉，分享内容已被删除" font:14 number:1 nstextLocat:NSTextAlignmentLeft];
                [self.contentView addSubview:deleteLabel];
                start_Y += 58;
            }
            
            if(model.shareViewOnlyHeight){
                CreateTAAView *createTAAView = [CommonMethod getViewFromNib:@"CreateTAAView"];
                createTAAView.frame = CGRectMake(16, start_Y, WIDTH-32, 60);
                [createTAAView updateDisplay:model];
                [self.contentView addSubview:createTAAView];
                start_Y += model.shareViewOnlyHeight;
            }
        }
    }];
    
    [queue addOperationWithBlock:^{
        if(model.shareViewHeight){
            ShareDynamicView *shareDynamicView = [[ShareDynamicView alloc] initWithFrame:CGRectMake(0, start_Y, WIDTH, model.shareViewHeight) model:model];
            [self.contentView addSubview:shareDynamicView];
            start_Y += model.shareViewHeight+12;
        }
    }];
    
    [queue addOperationWithBlock:^{
        if(model.commentHeight){
            CommentsView *commentsView = [[CommentsView alloc] initWithFrame:CGRectMake(0, start_Y-3, WIDTH, model.commentHeight) model:model];
            [self.contentView addSubview:commentsView];
            commentsView.replyUserReview = ^(NSInteger row){
                [weakSelf gotoReviewVC:row];
            };
            start_Y += model.commentHeight;
        }
    }];
    
    [queue addOperationWithBlock:^{
        if(!model.uploadFailure){
            self.toolsView = [CommonMethod getViewFromNib:@"ToolsView"];
            self.toolsView.frame = CGRectMake(0, model.cellHeight-50, WIDTH, 40);
            [self.toolsView updateDisplay:model];
            self.toolsView.reviewDynamic = ^(){
                [weakSelf gotoReviewVC:-1];
            };
            [self.contentView addSubview:self.toolsView];
            start_Y += 40;
            if(model.dynamic_id.integerValue<0){
                self.toolsView.userInteractionEnabled = NO;
            }
        }else{
            UploadFailureView *uploadFailueView = [CommonMethod getViewFromNib:@"UploadFailureView"];
            uploadFailueView.frame = CGRectMake(0, start_Y, WIDTH, 40);
            [self.contentView addSubview:uploadFailueView];
            start_Y += 40;
        }
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, model.cellHeight-10, WIDTH, 10)];
        lineLabel.backgroundColor = kTableViewBgColor;
        [self.contentView addSubview:lineLabel];
    }];
}

//删除动态
- (void)deleteDynamicHttp{
    if(self.deleteDynamicCell){
        self.deleteDynamicCell(self);
    }
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[NSString stringWithFormat:@"/%@",self.model.dynamic_id] forKey:@"param"];
    [[self viewController] requstType:RequestType_Delete apiName:API_NAME_DELETE_DYNAMICDETAILRATELIT_DELECTDYNAMIC paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){

        }else{
            weakSelf.model.enabledHeaderBtnClicked = YES;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:[weakSelf viewController].view];
        weakSelf.model.enabledHeaderBtnClicked = YES;
    }];
}

//发表评论
- (void)gotoReviewVC:(NSInteger)row{
    DymanicRateController *vc = [[DymanicRateController alloc] init];
    vc.dymanicRateControllerDelegate = self;
    vc.dynamicModel = self.model;
    if(row>=0){
        DynamicCommentModel *model = self.model.dynamic_reviewlist[row];
        vc.dynamicID = model.reviewid;
        vc.nameStr = model.senderModel.realname;
        vc.fristRate = NO;
    }else{
        vc.dynamicID = self.model.dynamic_id;
        vc.fristRate = YES;
    }
    [[self viewController] presentViewController:vc animated:YES completion:nil];
}

#pragma mark -DymanicRateControllerDelegate
- (void)successDynamicCommentModel:(DynamicCommentModel *)model{
    self.model.reviewcount = @(self.model.reviewcount.integerValue+1);
    [self.model.dynamic_reviewlist insertObject:model atIndex:0];
    [self.model resetModelAllHeight];
    if(self.refreshDynamicCell){
        self.refreshDynamicCell(self);
    }
}

@end
