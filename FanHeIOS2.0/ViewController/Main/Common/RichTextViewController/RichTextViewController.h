//
//  RichTextViewController.h
//  RichTextView
//
//  Created by     songguolin on 16/1/7.
//  Copyright © 2016年 innos-campus. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ReplyMessageSuccess)();
typedef void(^SavePersonalRemark)(NSString *remark);

typedef void(^ScaningCofferSucceedRestule)(BOOL isSucceed);

@interface RichTextViewController : UIViewController
//提示字
//完成
//编辑富文本，设置内容
@property (nonatomic,strong) NSString* content;

@property (nonatomic, strong) ReplyMessageSuccess replyMessageSuccess;

@property (nonatomic, strong) SavePersonalRemark savePersonalRemark;
@property (nonatomic, strong)ScaningCofferSucceedRestule scaningCofferSucceedRestule;

@property (nonatomic, assign) BOOL  isPersonalRemark;
@property (nonatomic, assign) BOOL  isPersonalDynamic;
@property (nonatomic, assign) BOOL  isCoffer;
@property (nonatomic, strong) NSNumber  *cofferId;
@property (nonatomic, strong) NSNumber  *msgId;

//话题中的发表评论  1.发表 2.回复
@property (nonatomic, assign) NSInteger  commentType;
@property (nonatomic, strong) NSNumber  *reviewId;
@property (nonatomic, strong) NSString  *replyName;

//活动回答
@property (nonatomic, assign) BOOL  isActivity;
@property (nonatomic, strong) UserModel *model;

//名片详情添加备注
@property (nonatomic, assign) BOOL  isCard;
@property (nonatomic, strong) CardScanModel *cardModel;



@end
