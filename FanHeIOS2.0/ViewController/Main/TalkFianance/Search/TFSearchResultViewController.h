//
//  TFSearchResultViewController.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/12/20.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, TFSearchResult) {
    TFSearchResult_Topic,
    TFSearchResult_Information,
    TFSearchResult_Activity,
    TFSearchResult_Report
    
};

@interface TFSearchResultViewController : BaseViewController

@property (nonatomic, strong) NSString *tagStr;

@property (nonatomic, assign) TFSearchResult type;

@end
