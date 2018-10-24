//
//  ConversationsManager.h
//  EaseDemo
//
//  Created by 杜洁鹏 on 2017/5/24.
//  Copyright © 2017年 杜洁鹏. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMConversation;
@interface ConversationModel : NSObject
@property (nonatomic, strong) EMConversation *conversation;

- (NSString *)nick;
- (NSString *)avatarPath;
- (NSString *)unreadCountStr;
- (NSString *)latestMsgTimeStr;
- (NSString *)msgInfo;

- (BOOL)isTop;
- (void)setIsTop:(BOOL)isTop;
- (void)removeComplation:(void(^)())aComplation;

@end

@interface ConversationsManager : NSObject
+ (NSArray *)conversationModelsWithConversations:(NSArray *)conversations;
@end

