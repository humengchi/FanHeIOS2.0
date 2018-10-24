//
//  DynamicModel.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/24.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "DynamicModel.h"

@implementation DynamicSaveModel

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.image = [NSMutableArray arrayWithArray:[coder decodeObjectForKey:@"image"]];
        self.content = [coder decodeObjectForKey:@"content"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.image forKey:@"image"];
    [coder encodeObject:self.content forKey:@"content"];
}

@end

@implementation DynamicCommentModel

- (void)parseDict:(NSDictionary *)dict{
    self.senderModel = [[UserModel alloc] initWithDict:dict];
    self.replytoModel = [[UserModel alloc] initWithDict:[CommonMethod paramDictIsNull:dict[@"replyto"]]];
    self.content = [CommonMethod paramStringIsNull:dict[@"content"]];
    self.content = [self.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.reviewid = [CommonMethod paramNumberIsNull:dict[@"reviewid"]];
    
    if([CommonMethod paramStringIsNull:self.replytoModel.realname].length>0){
        self.showContent = [NSString stringWithFormat:@"%@回复%@：%@", self.senderModel.realname, [CommonMethod paramStringIsNull:self.replytoModel.realname],self.content];
    }else{
        self.showContent = [NSString stringWithFormat:@"%@：%@", self.senderModel.realname,self.content];
    }
}

@end

@implementation DynamicUserModel

- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

@end

@implementation HomeRCMModel

- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
    
    if([CommonMethod paramStringIsNull:self.image].length){
        NSInteger titleHeight = [NSHelper heightOfString:self.title font:FONT_SYSTEM_SIZE(17) width:WIDTH-32 defaultHeight:FONT_SYSTEM_SIZE(17).lineHeight];
        if(titleHeight>(NSInteger)FONT_SYSTEM_SIZE(17).lineHeight*2){
            titleHeight = (NSInteger)FONT_SYSTEM_SIZE(17).lineHeight*2;
            self.titleRow = 2;
            titleHeight += 9;
        }else{
            self.titleRow = 1;
        }
        
        self.cellHeight = titleHeight+117+192*(WIDTH-32)/343.0 + 7;
    }else{
        NSInteger titleHeight = [NSHelper heightOfString:self.title font:FONT_SYSTEM_SIZE(17) width:WIDTH-32 defaultHeight:FONT_SYSTEM_SIZE(17).lineHeight];
        if(titleHeight>(NSInteger)FONT_SYSTEM_SIZE(17).lineHeight*2){
            titleHeight = (NSInteger)FONT_SYSTEM_SIZE(17).lineHeight*2;
            self.titleRow = 2;
            titleHeight += 9;
        }else{
            self.titleRow = 1;
        }
        
        NSInteger contentHeight = [NSHelper heightOfString:self.content font:FONT_SYSTEM_SIZE(14) width:WIDTH-32];
        if(contentHeight>(NSInteger)FONT_SYSTEM_SIZE(14).lineHeight*2){
            contentHeight = (NSInteger)FONT_SYSTEM_SIZE(14).lineHeight*2;
            self.contentRow = 2;
            contentHeight += 7;
        }else{
            self.contentRow = 1;
        }
        if(self.content.length>0){
            self.cellHeight = 116+titleHeight+contentHeight;
        }else{
            self.cellHeight = 104+titleHeight;
        }
    }
    if(self.type.integerValue == 18){
        self.cellHeight = 138;
    }else if(self.type.integerValue == 19){
        self.cellHeight = 204;
        self.rcmdIndustryModel = [NSMutableArray array];
        for(NSDictionary *modelDict in self.rcmdindustry){
            SubjectlistModel *model = [[SubjectlistModel alloc] initWithDict:modelDict];
            [self.rcmdIndustryModel addObject:model];
        }
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

@end

@implementation DynamicModel

- (id)initWithDict:(NSDictionary *)dict cellTag:(NSInteger)cellTag{
    if (self = [super init]) {
        [self parseDict:[CommonMethod paramDictIsNull:dict]];
        self.cellTag = cellTag;
    }
    return self;
}

- (void)parseDict:(NSDictionary *)dict{
    [self setValuesForKeysWithDictionary:dict];
    self.enabledHeaderBtnClicked = YES;
    self.userModel = [[DynamicUserModel alloc] initWithDict:dict];
    self.dynamic_reviewlist = [NSMutableArray array];
    for(NSDictionary *dataDict in [CommonMethod paramArrayIsNull:dict[@"dynamic_reviewlist"]]){
        DynamicCommentModel *model = [[DynamicCommentModel alloc] initWithDict:dataDict];
        //去除掉首尾的空白字符和换行字符
        model.showContent = [model.showContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self.dynamic_reviewlist addObject:model];
    }
    
    if(![CommonMethod paramStringIsNull:self.content].length){
        if(self.type.integerValue<=2){
            if(self.content.length){
                self.content = @"发布了一条动态";
            }
        }else if(self.type.integerValue==8){
            self.content = @"发起了一个话题";
        }else if(self.type.integerValue==9){
            self.content = @"发布了一个活动";
        }else if(self.type.integerValue==10){
            self.content = @"发布了一篇文章";
        }else if(self.type.integerValue==11){
            self.content = @"发布了一个观点";
        }else if(self.type.integerValue==12){
            self.content = @"发表了一个评论";
        }else{
            self.content = @"分享";
        }
    }
    
    self.content = [self.content stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
    self.content = [self.content stringByReplacingOccurrencesOfString:@"</p>" withString:@"<br />"];
    
    self.content = [self.content stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
    self.content = [self.content stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    
    if (self.isDynamicDetail.integerValue == 1) {
        self.contentHeight = [self rectHeightWithStr:[CommonMethod paramStringIsNull:self.content] font:17 space:9 width:WIDTH-32 maxNum:1000];
    }else{
        self.contentHeight = [self rectHeightWithStr:[CommonMethod paramStringIsNull:[self.content filterHTMLNeedBreak]] font:17 space:9 width:WIDTH-32 maxNum:6];
    }
    
    if((self.type.integerValue==13 && self.exttype.integerValue==17) || self.type.integerValue==17){
        [self getNeedOrSupplyContentHeight];
        return;
    }
    
    if([CommonMethod paramStringIsNull:self.image].length){
        NSArray *array = [[CommonMethod paramStringIsNull:self.image] componentsSeparatedByString:@","];
        if(array.count==1){
            self.imageHeight = (WIDTH-90)/3.0+5;
            self.imageSize = CGSizeMake(self.imageHeight, self.imageHeight);
            NSString *imageUrl = array[0];
            if([imageUrl hasPrefix:@"http://"]){
                /*[[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                    if(image){
                        CGSize size = image.size;
                        self.imageSize = image.size;
                        if(size.width>size.height || size.height < (WIDTH-90)/3.0){
                            self.imageHeight = (WIDTH-90)/3.0+5;
                        }else if(size.height>(WIDTH-90)/3.0*2+5){
                            self.imageHeight = (WIDTH-90)/3.0*2+10;
                        }
                        [self resetModelAllHeight];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableView" object:@(self.cellTag)];
                        });
                    }
                }];*/
            }else{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSString *DocumentsPath = [NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/dynamic"], imageUrl];
                    UIImage *image = [UIImage imageWithContentsOfFile:DocumentsPath];
                    if(image){
                        CGSize size = image.size;
                        self.imageSize = image.size;
                        if(size.width>size.height || size.height < (WIDTH-90)/3.0){
                            self.imageHeight = (WIDTH-90)/3.0+5;
                        }else if(size.height>(WIDTH-90)/3.0*2+5){
                            self.imageHeight = (WIDTH-90)/3.0*2+10;
                        }
                        [self resetModelAllHeight];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableView" object:@(self.cellTag)];
                        });
                    }
                });
            }
        }else{
            NSInteger row = array.count/3+(array.count%3>0?1:0);
            self.imageHeight = (row>3?3:row)*((WIDTH-90)/3.0+5);
        }
    }
    //未被删除
    if([CommonMethod paramNumberIsNull:self.parent_status].integerValue<4){
        [self getShareViewHeight];
    }
    [self getCommentsHeight];
    
    self.cellHeight = 72+self.contentHeight+(self.contentHeight?3:0)+self.imageHeight+(self.imageHeight?12:0)+self.shareViewHeight+(self.shareViewHeight?12:0)+self.commentHeight+self.shareViewOnlyHeight+50;
    if([CommonMethod paramNumberIsNull:self.parent_status].integerValue>=4){
        self.cellHeight += 58;
    }
}

//供需高度
- (void)getNeedOrSupplyContentHeight{
    if(self.type.integerValue==17){
        self.content = [self.content filterHTMLNeedBreak];
        self.cellHeight = 10+72+12+34+40-24;
        [self getCommentsHeight];
        self.tagsStr = [NSString stringWithFormat:@"#%@#", [self.tags stringByReplacingOccurrencesOfString:@"," withString:@"#  #"]];
        if(self.isDynamicDetail.integerValue==0){
            self.needTitleHeight = 21;
        }else{
            CGFloat height = [NSHelper heightOfString:[NSString stringWithFormat:@"3号圈 %@",self.title] font:FONT_SYSTEM_SIZE(17) width:WIDTH-32];
            if(height > FONT_SYSTEM_SIZE(17).lineHeight){
                height += (height/FONT_SYSTEM_SIZE(17).lineHeight*9-1)+1;
            }
            self.needTitleHeight = height<21?21:height;
            self.cellHeight -= 62;
            
            height = [NSHelper heightOfString:self.tagsStr font:FONT_SYSTEM_SIZE(12) width:WIDTH-32];
            if(height > FONT_SYSTEM_SIZE(12).lineHeight){
                height += (height/FONT_SYSTEM_SIZE(12).lineHeight-1)*5+1;
            }
            self.tagsHeight = height;
            self.cellHeight += self.tagsHeight+12;
        }
        self.cellHeight += self.needTitleHeight;
        CGFloat height = [NSHelper heightOfString:self.content font:FONT_SYSTEM_SIZE(17) width:WIDTH-32];
        if(self.isDynamicDetail.integerValue==0 && height>FONT_SYSTEM_SIZE(17).lineHeight*3){
            height = FONT_SYSTEM_SIZE(17).lineHeight*3;
        }
        if(height > FONT_SYSTEM_SIZE(17).lineHeight){
            height += (height/FONT_SYSTEM_SIZE(17).lineHeight-1)*9+1;
        }
        self.needContentHeight = height;
        self.cellHeight += self.needContentHeight;
        
        if([CommonMethod paramStringIsNull:self.image].length){
            NSArray *array = [[CommonMethod paramStringIsNull:self.image] componentsSeparatedByString:@","];
            if(array.count==1){
                self.imageHeight = (WIDTH-90)/3.0+5;
                self.imageSize = CGSizeMake(self.imageHeight, self.imageHeight);
                self.cellHeight += self.imageHeight+7;
                NSString *imageUrl = array[0];
                /*[[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                    if(image){
                        CGSize size = image.size;
                        self.imageSize = image.size;
                        if(size.width>size.height || size.height < (WIDTH-90)/3.0){
                            self.imageHeight = (WIDTH-90)/3.0+5;
                        }else if(size.height>(WIDTH-90)/3.0*2+5){
                            self.imageHeight = (WIDTH-90)/3.0*2+10;
                        }
                        self.cellHeight = self.imageHeight+7+self.needContentHeight+self.needTitleHeight+10+72+12+34+40-24+(self.isDynamicDetail.integerValue?-62:0)+self.commentHeight+(self.commentHeight?5:0);
                        if(self.isDynamicDetail.integerValue==1){
                            self.cellHeight += self.tagsHeight;
                        }
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableView" object:@(self.cellTag)];
                        });
                    }
                }];*/
            }else{
                NSInteger row = array.count/3+(array.count%3>0?1:0);
                self.imageHeight = (row>3?3:row)*((WIDTH-90)/3.0+5);
                self.cellHeight += self.imageHeight+7;
            }
        }
        self.cellHeight += self.commentHeight+(self.commentHeight?5:0);
    }else if(self.type.integerValue==13 && self.exttype.integerValue==17){
        self.cellHeight = 134+self.contentHeight;
        self.shareViewHeight = 78-24;
        [self getCommentsHeight];
        self.tagsStr = [NSString stringWithFormat:@"#%@#", [self.parent_tags stringByReplacingOccurrencesOfString:@"," withString:@"#  #"]];
        if(self.isDynamicDetail.integerValue==0){
            self.needTitleHeight = 21;
        }else{
            CGFloat height = [NSHelper heightOfString:[NSString stringWithFormat:@"  %@",self.parent_title] font:FONT_SYSTEM_SIZE(16) width:WIDTH-56];
            if(height > FONT_SYSTEM_SIZE(16).lineHeight){
                height += (height/FONT_SYSTEM_SIZE(16).lineHeight-1)*7+1;
            }
            self.needTitleHeight = height<21?21:height;
            self.cellHeight -= 62;
            
            height = [NSHelper heightOfString:self.tagsStr font:FONT_SYSTEM_SIZE(12) width:WIDTH-56];
            if(height > FONT_SYSTEM_SIZE(12).lineHeight){
                height += (height/FONT_SYSTEM_SIZE(12).lineHeight-1)*5+1;
            }
            self.tagsHeight = height;
            self.shareViewHeight += self.tagsHeight+12;
        }
        self.shareViewHeight += self.needTitleHeight;
        
        self.parent_content = [self.parent_content filterHTMLNeedBreak];
        CGFloat height = [NSHelper heightOfString:self.parent_content font:FONT_SYSTEM_SIZE(16) width:WIDTH-56];
        if(self.isDynamicDetail.integerValue==0 && height>FONT_SYSTEM_SIZE(16).lineHeight*3){
            height = FONT_SYSTEM_SIZE(16).lineHeight*3;
        }
        if(height > FONT_SYSTEM_SIZE(16).lineHeight){
            height += (height/FONT_SYSTEM_SIZE(16).lineHeight-1)*7+1;
        }
        self.needContentHeight = height;
        self.shareViewHeight += self.needContentHeight;
        
        if([CommonMethod paramStringIsNull:self.parent_image].length){
            NSArray *array = [[CommonMethod paramStringIsNull:self.parent_image] componentsSeparatedByString:@","];
            if(array.count==1){
                /*[[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:array[0]] options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                    if(image){
                        CGSize size = image.size;
                        self.imageSize = image.size;
                        if(size.width>size.height || size.height < (WIDTH-90)/3.0){
                            self.shareSubViewHeight = (WIDTH-90)/3.0+5;
                        }else if(size.height>(WIDTH-90)/3.0*2+5){
                            self.shareSubViewHeight = (WIDTH-90)/3.0*2+10;
                        }else{
                            self.shareSubViewHeight = (WIDTH-90)/3.0+5;
                        }
                        self.shareViewHeight += self.shareSubViewHeight+7;
                        
                        self.cellHeight = self.shareViewHeight+self.commentHeight+(self.commentHeight?5:0)+134+self.contentHeight+(self.isDynamicDetail.integerValue?-62:0);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableView" object:nil];
                        });
                    }
                }];*/
            }else{
                NSInteger row = array.count/3+(array.count%3>0?1:0);
                self.shareSubViewHeight = (row>3?3:row)*((WIDTH-90)/3.0+5);
                self.shareViewHeight += self.shareSubViewHeight+12;
            }
        }
        self.cellHeight += self.shareViewHeight+self.commentHeight+(self.commentHeight?5:0);
    }
}

- (void)resetModelAllHeight{
    if((self.type.integerValue==13 && self.exttype.integerValue==17) || self.type.integerValue==17){
        [self getNeedOrSupplyContentHeight];
        return;
    }
    
    //未被删除
    if([CommonMethod paramNumberIsNull:self.parent_status].integerValue<4){
        [self getShareViewHeight];
    }
    
    [self getCommentsHeight];
    self.cellHeight = 72+self.contentHeight+(self.contentHeight?3:0)+self.imageHeight+(self.imageHeight?12:0)+self.shareViewHeight+(self.shareViewHeight?12:0)+self.commentHeight+self.shareViewOnlyHeight+50;
    if([CommonMethod paramNumberIsNull:self.parent_status].integerValue>=4){
        self.cellHeight += 58;
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

- (CGFloat)rectHeightWithStr:(NSString *)htmlString font:(CGFloat)font space:(CGFloat)space width:(CGFloat)width maxNum:(NSInteger)maxNum{
    if([CommonMethod paramStringIsNull:htmlString].length==0){
        return 0;
    }
    NSString *str = [htmlString filterHTMLNeedBreak];
    CGFloat lineHeight = [FONT_SYSTEM_SIZE(font) lineHeight];
    CGFloat height = [NSHelper heightOfString:str font:FONT_SYSTEM_SIZE(font) width:width];
    height += ((NSInteger)(height/lineHeight))*space;
    if(height>(lineHeight+space)*maxNum){
        return (lineHeight+space)*maxNum;
    }else{
        return height;
    }
}

//评论
- (void)getCommentsHeight{
    NSInteger num = 0;
    NSInteger row = 0;
    for(DynamicCommentModel *model in self.dynamic_reviewlist){
        row ++;
        NSInteger height = [NSHelper heightOfString:model.showContent font:FONT_SYSTEM_SIZE(14) width:WIDTH-48 defaultHeight:FONT_SYSTEM_SIZE(14).lineHeight];
        if(num+(NSInteger)(height/(NSInteger)FONT_SYSTEM_SIZE(14).lineHeight)>=4){
            num = 4;
            break;
        }else{
            num += (NSInteger)(height/(NSInteger)(FONT_SYSTEM_SIZE(14).lineHeight));
        }
    }
    if(num){
        if(num==4 || num<self.reviewcount.integerValue){
            self.commentHeight = ((NSInteger)FONT_SYSTEM_SIZE(14).lineHeight+7)*4+25;
        }else{
            self.commentHeight = ((NSInteger)FONT_SYSTEM_SIZE(14).lineHeight+7)*num;
        }
        self.commentRows = row>4?4:row;
        self.commentContentRows = num;
    }
}

//分享
- (void)getShareViewHeight{
    self.shareViewHeight = 0;
    if([CommonMethod paramNumberIsNull:self.parent_review_id].integerValue){
        self.shareNameHeight = 16;
        self.shareViewHeight += self.shareNameHeight+6;
    }else if([CommonMethod paramNumberIsNull:self.review_id].integerValue){
        if(self.type.integerValue == 12 || self.type.integerValue == 11){
            self.shareNameHeight = 0;
        }else{
            self.shareNameHeight = 16;
            self.shareViewHeight += self.shareNameHeight+6;
        }
        self.shareSubViewHeight = 60;
        self.shareViewHeight += self.shareSubViewHeight+12;
        self.shareSubViewTitle = self.review_content;
        self.parent_content = self.review_content;
    }else if([CommonMethod paramStringIsNull:self.parent_content].length||[CommonMethod paramStringIsNull:self.parent_image].length){
        self.shareNameHeight = 16;
        self.shareViewHeight += self.shareNameHeight+6;
    }else{
        if([CommonMethod paramNumberIsNull:self.parent_post_id].integerValue||
           [CommonMethod paramNumberIsNull:self.parent_subject_id].integerValue||
           [CommonMethod paramNumberIsNull:self.parent_activity_id].integerValue||
           [CommonMethod paramNumberIsNull:self.post_id].integerValue||
           [CommonMethod paramNumberIsNull:self.subject_id].integerValue||
           [CommonMethod paramNumberIsNull:self.activity_id].integerValue){
            self.shareViewOnlyHeight = 72;
        }
        return;
    }
    
    if([CommonMethod paramStringIsNull:self.parent_review_content].length){
        if (self.isDynamicDetail.integerValue == 1) {
            self.shareContentHeight = [self rectHeightWithStr:self.parent_review_content font:16 space:7 width:WIDTH-56 maxNum:1000];
        }else{
            self.shareContentHeight = [self rectHeightWithStr:self.parent_review_content font:16 space:7 width:WIDTH-56 maxNum:4];
        }
        self.shareViewHeight += self.shareContentHeight+10;
    }else if([CommonMethod paramStringIsNull:self.parent_content].length){
        if (self.isDynamicDetail.integerValue == 1) {
            self.shareContentHeight = [self rectHeightWithStr:self.parent_content font:16 space:7 width:WIDTH-56 maxNum:1000]+5;
        }else{
            self.shareContentHeight = [self rectHeightWithStr:self.parent_content font:16 space:7 width:WIDTH-56 maxNum:4]+5;
        }
        self.shareViewHeight += self.shareContentHeight;
    }
    if([CommonMethod paramNumberIsNull:self.parent_activity_id].integerValue){
        self.shareSubViewHeight = 60;
        self.shareViewHeight += self.shareSubViewHeight+12;
        self.shareSubViewTitle = self.parent_activity_title;
    }else if([CommonMethod paramNumberIsNull:self.parent_subject_id].integerValue){
        self.shareSubViewHeight = 60;
        self.shareViewHeight += self.shareSubViewHeight+12;
        self.shareSubViewTitle = self.parent_subject_title;
    }else if([CommonMethod paramNumberIsNull:self.parent_post_id].integerValue){
        self.shareSubViewHeight = 60;
        self.shareViewHeight += self.shareSubViewHeight+12;
        self.shareSubViewTitle = self.parent_post_title;
    }else if([CommonMethod paramStringIsNull:self.parent_image].length){
        if([CommonMethod paramStringIsNull:self.parent_image].length){
            NSArray *array = [[CommonMethod paramStringIsNull:self.parent_image] componentsSeparatedByString:@","];
            if(array.count==1){
                /*[[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:array[0]] options:SDWebImageDownloaderHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                    if(image){
                        CGSize size = image.size;
                        self.imageSize = image.size;
                        if(size.width>size.height || size.height < (WIDTH-90)/3.0){
                            self.shareSubViewHeight = (WIDTH-90)/3.0+5;
                        }else if(size.height>(WIDTH-90)/3.0*2+5){
                            self.shareSubViewHeight = (WIDTH-90)/3.0*2+10;
                        }else{
                            self.shareSubViewHeight = (WIDTH-90)/3.0+5;
                        }
                        self.shareViewHeight += self.shareSubViewHeight+12;
                        [self getCommentsHeight];
                        self.cellHeight = 72+self.contentHeight+(self.contentHeight?3:0)+self.imageHeight+(self.imageHeight?12:0)+self.shareViewHeight+(self.shareViewHeight?12:0)+self.commentHeight+self.shareViewOnlyHeight+50;
                        if([CommonMethod paramNumberIsNull:self.parent_status].integerValue>=4){
                            self.cellHeight += 58;
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTableView" object:nil];
                        });
                    }
                }];*/
            }else{
                NSInteger row = array.count/3+(array.count%3>0?1:0);
                self.shareSubViewHeight = (row>3?3:row)*((WIDTH-90)/3.0+5);
                self.shareViewHeight += self.shareSubViewHeight+12;
            }
        }
    }
    if(self.shareViewHeight){
        self.shareViewHeight += 12;
    }
}

@end

