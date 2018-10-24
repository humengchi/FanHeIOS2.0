//
//  JobTextFile.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/11/4.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol keyInputJobTextFileDelegate <NSObject>

- (void) deleteBackwardJob;

@end
@interface JobTextFile : UITextField
@property (nonatomic,weak) id<keyInputJobTextFileDelegate>keyInputDelegate;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,strong) NSString *strIndex;
@end
