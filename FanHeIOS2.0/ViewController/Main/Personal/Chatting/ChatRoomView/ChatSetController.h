//
//  ChatSetController.h
//  JinMai
//
//  Created by renhao on 16/5/22.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ChatSetControllerDelegate <NSObject>

- (void)referViewChat;

@end
@interface ChatSetController : BaseViewController
@property (nonatomic ,strong) NSString *chatId;
@property (nonatomic,strong)UIImageView *coverImageiew;

@property (nonatomic,strong) UILabel *nameLabel;
@property (nonatomic,strong) UILabel *positionLabel;
@property (nonatomic,strong) UILabel *messageLabel;
@property (nonatomic,strong) UILabel *clearLabel;
@property (nonatomic,strong) UISwitch *messageSetSwitch;
@property (strong, nonatomic) EMConversation *conversation;
@property (nonatomic ,weak) id<ChatSetControllerDelegate>setDelegate;
@end
