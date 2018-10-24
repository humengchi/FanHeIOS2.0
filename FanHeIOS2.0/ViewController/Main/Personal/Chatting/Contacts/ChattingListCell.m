//
//  ChattingListCell.m
//  JinMai
//
//  Created by renhao on 16/5/18.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "ChattingListCell.h"
#import "EMGroup+Category.h"

@interface ChattingListCell ()
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *unReadLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *msgLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLayoutConstraint;

@end

@implementation ChattingListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.coverImageView.layer.cornerRadius = 22;
    self.coverImageView.layer.masksToBounds = YES;
    self.coverImageView.layer.borderWidth = 1;
    self.coverImageView.layer.borderColor = WHITE_COLOR.CGColor;
    
    self.unReadLabel.layer.cornerRadius = 8;
    self.unReadLabel.layer.masksToBounds = YES;
    // Initialization code
}

- (void)traderCharttingMessage{
    self.nameLabel.text = self.name;
    if (_unreadCount > 0) {
        if (_unreadCount < 9) {
            self.unReadLabel.font = [UIFont systemFontOfSize:13];
        }else if(_unreadCount > 9 && _unreadCount < 99){
            self.unReadLabel.font = [UIFont systemFontOfSize:12];
        }else{
            self.unReadLabel.font = [UIFont systemFontOfSize:10];
        }
        [self.unReadLabel setHidden:NO];
        [self.contentView bringSubviewToFront:self.nameLabel];
        self.unReadLabel.text = [NSString stringWithFormat:@"%ld",(long)_unreadCount];
    }else{
        [self.unReadLabel setHidden:YES];
    }
    [self.coverImageView sd_setImageWithURL:self.imageURL placeholderImage:self.placeholderImage];
    self.timeLabel.text = self.time;
    if (self.str.length > 0) {
        self.lastMessageLabel.attributedText = self.str;
    }else{
        self.lastMessageLabel.text = self.detailMsg;
    }
}

- (void)traderCharttingMessageGroupSpace:(NSString*)groupId{
    self.nameLabel.text = self.name;
    if (_unreadCount > 0) {
        if (_unreadCount < 9) {
            self.unReadLabel.font = [UIFont systemFontOfSize:13];
        }else if(_unreadCount > 9 && _unreadCount < 99){
            self.unReadLabel.font = [UIFont systemFontOfSize:12];
        }else{
            self.unReadLabel.font = [UIFont systemFontOfSize:10];
        }
        [self.unReadLabel setHidden:NO];
        [self.contentView bringSubviewToFront:self.nameLabel];
        self.unReadLabel.text = [NSString stringWithFormat:@"%ld",(long)_unreadCount];
    }else{
        [self.unReadLabel setHidden:YES];
    }
    UIImage *localImage = [UIImage imageWithContentsOfFile:SAVE_GROUP_HEADER_IMAGE(groupId)];
    if(localImage){
        self.placeholderImage = localImage;
    }
    self.coverImageView.image = self.placeholderImage;
    self.timeLabel.text = self.time;
    if (self.str.length > 0) {
        self.lastMessageLabel.attributedText = self.str;
    }else{
        self.lastMessageLabel.text = self.detailMsg;
    }
}

- (void)traderCharttingMessageGroup:(EMGroup *)group{
    self.nameLabel.text = group.subject;
   
    UIImage *localImage = [UIImage imageWithContentsOfFile:SAVE_GROUP_HEADER_IMAGE(group.groupId)];
    if(localImage){
        group.headerImage = localImage;
        group.hasCreated = @(1);
    }else if([CommonMethod paramArrayIsNull:group.occupants].count && group.hasCreated.integerValue==0) {
        [self checkFriendsNameAndHeader:group];
    }
    self.coverImageView.image = group.headerImage;
    self.msgLayoutConstraint.constant = 18;
    self.timeLayoutConstraint.constant = 110;
    if(group.isMyGroupList.integerValue==1){
        self.unReadLabel.hidden = YES;
        self.timeLabel.text = @"";
        self.lastMessageLabel.text = group.description;
        if(group.description.length==0){
            self.msgLayoutConstraint.constant = 29;
            self.lastMessageLabel.hidden = YES;
        }
        self.timeLayoutConstraint.constant = 0;
    }else{
        if (_unreadCount > 0) {
            if (_unreadCount < 9) {
                self.unReadLabel.font = [UIFont systemFontOfSize:13];
            }else if(_unreadCount > 9 && _unreadCount < 99){
                self.unReadLabel.font = [UIFont systemFontOfSize:12];
            }else{
                self.unReadLabel.font = [UIFont systemFontOfSize:10];
            }
            [self.unReadLabel setHidden:NO];
            [self.contentView bringSubviewToFront:self.nameLabel];
            self.unReadLabel.text = [NSString stringWithFormat:@"%ld",(long)_unreadCount];
        }else{
            [self.unReadLabel setHidden:YES];
        }
        
        self.timeLabel.text = self.time;
        if (self.str.length > 0) {
            self.lastMessageLabel.attributedText = self.str;
        }else{
            self.lastMessageLabel.text = self.detailMsg;
        }
    }
   
}

- (void)checkFriendsNameAndHeader:(EMGroup *)group{
    
      [[EMClient sharedClient].groupManager getGroupMemberListFromServerWithId:group.groupId cursor:@"" pageSize:1000 completion:^(EMCursorResult *aResult, EMError *aError) {
          NSArray *array = [CommonMethod paramArrayIsNull:aResult.list];
          if (array.count==0) {
              return;
          }
          [(BaseViewController*)self.viewController updateGroupUsersDB:group occupants:aResult.list handler:^(BOOL result, NSMutableArray *dataArray) {
              if(result){
                  UIImage *localImage = [UIImage imageWithContentsOfFile:SAVE_GROUP_HEADER_IMAGE(group.groupId)];
                  if(localImage){
                      group.headerImage = localImage;
                      group.hasCreated = @(1);
                      dispatch_async(dispatch_get_main_queue(), ^{
                          self.coverImageView.image = localImage;
                      });
                  }else{
                      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                          UIImage *image = [UIImage createImageWithUserModelArray:dataArray];
                          NSData *imageData = UIImagePNGRepresentation(image);
                          [imageData writeToFile:SAVE_GROUP_HEADER_IMAGE(group.groupId) atomically:YES];
                          group.headerImage = image;
                          group.hasCreated = @(1);
                          dispatch_async(dispatch_get_main_queue(), ^{
                              self.coverImageView.image = image;
                          });
                      });
                  }
              }
          }];
      }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
