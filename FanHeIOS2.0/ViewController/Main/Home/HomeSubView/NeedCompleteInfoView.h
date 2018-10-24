//
//  NeedCompleteInfoView.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/10/28.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, NeedCompleteInfoViewType) {
    NeedCompleteInfoViewType_None,
    NeedCompleteInfoViewType_UploadImage,
    NeedCompleteInfoViewType_CompleteInfo,
    NeedCompleteInfoViewType_Identify,
    NeedCompleteInfoViewType_SetInterestIndutry,
};

typedef void(^NeedCompleteInfoViewClicked)(NeedCompleteInfoViewType type);

@interface NeedCompleteInfoView : UIView

@property (nonatomic, assign) NeedCompleteInfoViewType type;

@property (nonatomic, strong) NeedCompleteInfoViewClicked needCompleteInfoViewClicked;

- (void)updateDisplay;

@end
