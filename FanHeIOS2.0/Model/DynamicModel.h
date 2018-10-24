//
//  DynamicModel.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/24.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "BaseModel.h"


@interface DynamicSaveModel : BaseModel

@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSArray *image;

@end

@interface DynamicCommentModel : BaseModel

@property (nonatomic, strong) UserModel *senderModel;
@property (nonatomic, strong) UserModel *replytoModel;
@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *showContent;

@property (nonatomic, strong) NSNumber *reviewid;

@end

@interface DynamicUserModel : BaseModel
@property (nonatomic, strong) NSNumber *isattention;
@property (nonatomic, strong) NSNumber *user_id;
@property (nonatomic, strong) NSNumber *user_usertype;
@property (nonatomic, strong) NSNumber *user_othericon;
@property (nonatomic, strong) NSNumber *samefriend;
@property (nonatomic, copy) NSString *user_realname;
@property (nonatomic, copy) NSString *user_image;
@property (nonatomic, copy) NSString *user_company;
@property (nonatomic, copy) NSString *user_position;
@property (nonatomic, copy) NSString *relationship;

@end

@interface HomeRCMModel : BaseModel
@property (nonatomic, strong) NSNumber *rfid;
@property (nonatomic, strong) NSNumber *replycount;
@property (nonatomic, strong) NSNumber *reviewcount;
@property (nonatomic, strong) NSNumber *attentcount;
@property (nonatomic, strong) NSNumber *readcount;
@property (nonatomic, strong) NSNumber *contentid;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, strong) NSNumber *extype;
@property (nonatomic, strong) NSNumber *addresstype;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSNumber *userid;
@property (nonatomic, strong) NSNumber *friendcount;
@property (nonatomic, strong) NSArray *hisfriends;
@property (nonatomic, copy) NSString *realname;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *position;

@property (nonatomic, strong) NSArray *rcmdindustry;
@property (nonatomic, strong) NSMutableArray *rcmdIndustryModel;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *tag;

@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) NSInteger titleRow;
@property (nonatomic, assign) NSInteger contentRow;

@end

@interface DynamicModel : BaseModel

@property (nonatomic, strong)   DynamicUserModel *userModel;
@property (nonatomic, strong)   NSArray *praiselist;
@property (nonatomic, copy)     NSString *content;
@property (nonatomic, copy)     NSString *image;
@property (nonatomic, copy)     NSString *created_at;
@property (nonatomic, strong)   NSNumber *dynamic_id;
@property (nonatomic, strong)   NSMutableArray *dynamic_reviewlist;

@property (nonatomic, strong)   NSNumber *type;
@property (nonatomic, strong)   NSNumber *exttype;
@property (nonatomic, strong)   NSNumber *parent_status;//>=4已被删除
@property (nonatomic, strong)   NSNumber *ispraise;//是否点赞

//供需 17
@property (nonatomic, copy)     NSString *title;
@property (nonatomic, copy)     NSString *tags;
@property (nonatomic, strong)   NSNumber *status;
@property (nonatomic, copy)     NSString *relationship;
@property (nonatomic, strong)   NSNumber *gx_type;

//供需分享 13-17
@property (nonatomic, copy)     NSString *parent_title;
@property (nonatomic, copy)     NSString *parent_tags;
@property (nonatomic, strong)   NSNumber *parent_gx_type;
@property (nonatomic, assign)   CGFloat needTitleHeight;
@property (nonatomic, assign)   CGFloat needContentHeight;
@property (nonatomic, assign)   CGFloat tagsHeight;
@property (nonatomic, copy)     NSString *tagsStr;

//发起人
@property (nonatomic, strong)   NSNumber *parent_user_id;
@property (nonatomic, copy)     NSString *parent_user_realname;
@property (nonatomic, copy)     NSString *parent_user_company;
@property (nonatomic, copy)     NSString *parent_user_position;
@property (nonatomic, copy)     NSString *parent_user_image;
//动态
@property (nonatomic, strong)   NSNumber *parent;
@property (nonatomic, copy)     NSString *parent_image;
@property (nonatomic, copy)     NSString *parent_content;
//观点
@property (nonatomic, copy)     NSNumber *review_id;
@property (nonatomic, copy)     NSString *review_content;
@property (nonatomic, copy)     NSNumber *review_user_id;
@property (nonatomic, copy)     NSString *review_user_realname;
@property (nonatomic, copy)     NSString *review_user_position;
@property (nonatomic, copy)     NSString *review_user_company;
//评论
@property (nonatomic, strong)   NSNumber *parent_review_id;
@property (nonatomic, copy)     NSString *parent_review_content;
@property (nonatomic, strong)   NSNumber *parent_review_user_id;
@property (nonatomic, copy)     NSString *parent_review_user_realname;
@property (nonatomic, copy)     NSString *parent_review_user_company;
@property (nonatomic, copy)     NSString *parent_review_user_position;
@property (nonatomic, copy)     NSString *parent_review_user_image;
//资讯
@property (nonatomic, strong)   NSNumber *parent_post_id;
@property (nonatomic, copy)     NSString *parent_post_title;
@property (nonatomic, copy)     NSString *parent_post_image;
@property (nonatomic, strong)   NSNumber *post_id;
@property (nonatomic, copy)     NSString *post_title;
@property (nonatomic, copy)     NSString *post_subcontent;
@property (nonatomic, copy)     NSString *post_image;
//话题
@property (nonatomic, strong)   NSNumber *parent_subject_id;
@property (nonatomic, copy)     NSString *parent_subject_title;
@property (nonatomic, copy)     NSString *parent_subject_photo;
@property (nonatomic, strong)   NSNumber *subject_id;
@property (nonatomic, copy)     NSString *subject_title;
@property (nonatomic, copy)     NSString *subject_photo;
//活动
@property (nonatomic, strong)   NSNumber *parent_activity_id;
@property (nonatomic, copy)     NSString *parent_activity_title;
@property (nonatomic, copy)     NSString *parent_activity_image;
@property (nonatomic, copy)     NSString *parent_activity_starttime;
@property (nonatomic, copy)     NSString *parent_activity_endtime;
@property (nonatomic, copy)     NSString *parent_activity_timestr;
@property (nonatomic, strong)   NSNumber *activity_id;
@property (nonatomic, copy)     NSString *activity_title;
@property (nonatomic, copy)     NSString *activity_image;
@property (nonatomic, copy)     NSString *activity_starttime;
@property (nonatomic, copy)     NSString *activity_endtime;
@property (nonatomic, copy)     NSString *activity_timestr;
@property (nonatomic, copy)     NSString *isDynamicDetail;

@property (nonatomic, strong)   NSNumber *praisecount;
@property (nonatomic, strong)   NSNumber *reviewcount;
@property (nonatomic, strong)   NSNumber *sharecount;


/***********************临时需要的字段**********************/
@property (nonatomic, assign)   CGFloat cellHeight;

@property (nonatomic, assign)   CGFloat contentHeight;//内容
@property (nonatomic, assign)   CGFloat imageHeight;//九宫格图片
@property (nonatomic, assign)   CGSize imageSize;//只有一张图片的

@property (nonatomic, assign)   CGFloat shareViewHeight;//分享,有文字内容，评论
@property (nonatomic, assign)   CGFloat shareNameHeight;
@property (nonatomic, assign)   CGFloat shareContentHeight;
@property (nonatomic, assign)   CGFloat shareSubViewHeight;

@property (nonatomic, assign)   CGFloat shareViewOnlyHeight;//分享、创建活动，话题，文章

@property (nonatomic, assign)   CGFloat commentRows;//评论个数
@property (nonatomic, assign)   CGFloat commentHeight;//评论
@property (nonatomic, assign)   CGFloat commentContentRows;//评论内容的行数

@property (nonatomic, copy)     NSString *shareSubViewTitle;//

@property (nonatomic, assign)   BOOL uploadFailure;//动态是否上传成功，假上传
//@property (nonatomic, assign)   BOOL isDynamicDetail;

@property (nonatomic, assign)   BOOL isTaDynamicList;//他的动态列表隐藏头部的删除按钮
@property (nonatomic, assign)   NSInteger cellTag;//当前model在列表中cell的index

@property (nonatomic, assign)   BOOL enabledHeaderBtnClicked;//头部的按钮是否可点击

- (void)resetModelAllHeight;

- (id)initWithDict:(NSDictionary*)dict cellTag:(NSInteger)cellTag;

@end
