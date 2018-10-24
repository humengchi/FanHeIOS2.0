//
//  myView.h
//  crop
//
//  Created by ddapp on 16/4/13.
//  Copyright © 2016年 techinone. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol btnActionDelegate <NSObject>

- (void)btnActionWithTag:(NSInteger) btnTag;

@end
@interface myView : UIView
@property (strong, nonatomic) IBOutlet UIButton *sureBtn;

@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;

@property(nonatomic,weak)id<btnActionDelegate>myViewDelegate;


@end

//@protocol btnActionDelegate <NSObject>
//
//- (void)btnActionWithTag:(NSInteger) btnTag;
//
//@end