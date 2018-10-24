//
//  ContactsReplyView.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DeleteReplyView)();
typedef void(^SelectReplyView)(NSInteger index);

@interface ContactsReplyView : UIView

@property (nonatomic, strong) DeleteReplyView deleteReplyView;
@property (nonatomic, strong) SelectReplyView selectReplyView;

- (id)initWithFrame:(CGRect)frame data:(NSArray*)dataArray;

@end
