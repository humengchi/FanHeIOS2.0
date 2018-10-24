//
//  VisitPhoneBookView.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/11/8.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^VisitPhoneBookViewResult)(BOOL result);

@interface VisitPhoneBookView : UIView

@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *clickedBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;

@property (nonatomic, strong) VisitPhoneBookViewResult visitPhoneBookViewResult;

@end
