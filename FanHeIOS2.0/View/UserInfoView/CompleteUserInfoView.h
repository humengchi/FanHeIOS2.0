//
//  CompleteUserInfoView.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/23.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CompleteUserInfoViewType) {
    CompleteUserInfoViewType_FirstLogin,
    CompleteUserInfoViewType_AddFriend,
    CompleteUserInfoViewType_Identify,
    CompleteUserInfoViewType_UploadImage,
    CompleteUserInfoViewType_HangCoffee,
     CompleteUserInfoViewType_WorkHistory,
};

typedef void(^CompleteUserInfoViewUploadImage) ();
typedef void(^CompleteUserInfoViewEditInfo) ();
typedef void(^CompleteUserInfoViewCancle) ();

@interface CompleteUserInfoView : UIView

@property (nonatomic, strong) CompleteUserInfoViewUploadImage completeUserInfoViewUploadImage;

@property (nonatomic, strong) CompleteUserInfoViewEditInfo completeUserInfoViewEditInfo;

@property (nonatomic, strong) CompleteUserInfoViewCancle completeUserInfoViewCancle;

- (id)initWithType:(CompleteUserInfoViewType)type;

@end
