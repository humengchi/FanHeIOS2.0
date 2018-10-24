//
//  MyTopicModel.m
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/20.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "MyTopicModel.h"

@implementation MyTopicModel
- (void)parseDict:(NSDictionary *)dict{
    self.subjectid = [CommonMethod paramNumberIsNull:[dict objectForKey:@"subjectid"]];
    self.replycount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"replycount"]];
    self.reviewcount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"reviewcount"]];
    self.attentcount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"attentcount"]];
    self.srcnt = [CommonMethod paramNumberIsNull:[dict objectForKey:@"srcnt"]];
    self.reviewid = [CommonMethod paramNumberIsNull:[dict objectForKey:@"reviewid"]];
    self.activityid = [CommonMethod paramNumberIsNull:[dict objectForKey:@"activityid"]];
    
    
    
    self.realname = [CommonMethod paramStringIsNull:[dict objectForKey:@"realname"]];
    self.createtime = [CommonMethod paramStringIsNull:[dict objectForKey:@"createtime"]];
    self.content = [CommonMethod paramStringIsNull:[dict objectForKey:@"content"]];
    self.image = [CommonMethod paramStringIsNull:[dict objectForKey:@"image"]];
    self.status = [CommonMethod paramNumberIsNull:[dict objectForKey:@"status"]];
    self.userid = [CommonMethod paramNumberIsNull:[dict objectForKey:@"userid"]];
    self.usertype = [CommonMethod paramNumberIsNull:[dict objectForKey:@"usertype"]];
    
    self.sreplycount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"sreplycount"]];
    self.sattentcount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"sattentcount"]];
    self.sreviewcount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"sreviewcount"]];
    self.sid = [CommonMethod paramNumberIsNull:[dict objectForKey:@"sid"]];
    self.srid = [CommonMethod paramNumberIsNull:[dict objectForKey:@"srid"]];
    self.srpraisecount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"srpraisecount"]];
    self.srreviewcount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"srreviewcount"]];
    
    
    self.title = [CommonMethod paramStringIsNull:[dict objectForKey:@"title"]];
    self.mycontent = [CommonMethod paramStringIsNull:[dict objectForKey:@"mycontent"]];
    
    self.created_at = [CommonMethod paramStringIsNull:[dict objectForKey:@"created_at"]];
    
    self.readcount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"readcount"]];
    self.gid = [CommonMethod paramNumberIsNull:[dict objectForKey:@"gid"]];
    self.type = [CommonMethod paramNumberIsNull:[dict objectForKey:@"type"]];
    self.review_id = [CommonMethod paramNumberIsNull:[dict objectForKey:@"review_id"]];
    self.parent = [CommonMethod paramNumberIsNull:[dict objectForKey:@"parent"]];
    self.parentrevid = [CommonMethod paramNumberIsNull:[dict objectForKey:@"parentrevid"]];
    self.post_id = [CommonMethod paramNumberIsNull:[dict objectForKey:@"post_id"]];
    
    self.mypraisecount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"mypraisecount"]];
    self.myreviewcount = [CommonMethod paramNumberIsNull:[dict objectForKey:@"myreviewcount"]];
    
    self.subject_id = [CommonMethod paramNumberIsNull:[dict objectForKey:@"subject_id"]];
    self.subject_review_id = [CommonMethod paramNumberIsNull:[dict objectForKey:@"subject_review_id"]];
    self.lasttime = [CommonMethod paramNumberIsNull:[dict objectForKey:@"lasttime"]];
    self.ishidden = [CommonMethod paramNumberIsNull:[dict objectForKey:@"ishidden"]];
    
    
    
    CGFloat heigth1 = [NSHelper rectHeightWithStrHtml:self.content];
    if (heigth1 > 0) {
        if (heigth1 > 55) {
            heigth1 = heigth1 + 12;
        }
        if (heigth1 > 45 && heigth1 < 60) {
            heigth1 = heigth1 + 10;
        }
        if (heigth1 > 30 && heigth1 < 40) {
            heigth1 = heigth1 + 6;
        }
        heigth1 =  heigth1 + 12;
    }
    if (self.content.length <= 0) {
        heigth1 = 0;
    }
    if(self.status.integerValue == 2 && (self.type.integerValue == 8||self.type.integerValue == 3)){
        CGFloat height = 0;
        height = [NSHelper heightOfString:self.mycontent font:FONT_SYSTEM_SIZE(14) width:WIDTH-56];
        if(height>FONT_SYSTEM_SIZE(14).lineHeight*4){
            height = FONT_SYSTEM_SIZE(14).lineHeight*4;
        }
        height += 190;
        self.cellHeight = height;
    }else{
        self.cellHeight = heigth1 + 170 - 14 - 6;
    }
}

@end
