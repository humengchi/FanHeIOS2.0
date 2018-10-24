//
//  DataPikerView.h
//  TestChoice
//
//  Created by huxianchen on 15/1/13.
//  Copyright (c) 2015年 SAIC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, kDatePikerViewType) {
    kDatePikerViewTypeDay,      //2013年4月03日
    kDatePikerViewTypeSecond,      //2013年4月03日12时13分
    kDatePikerViewTypeHHMM,     //12时13分
    kDatePikerViewTypeMonth   //2013年4月
};

typedef NS_ENUM(NSInteger, SceneType) {
    SceneType_Activity = 1,      //发布活动
};


typedef void(^DatePickerSelectBlock)(id param, NSString *value);
typedef void(^DatePickerCancelBlock)(id param);

@interface DatePikerView : UIView

@property (weak, nonatomic) IBOutlet UIPickerView *customPicker;
@property (weak, nonatomic) IBOutlet UILabel *bgLabel;
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, assign) kDatePikerViewType type;

@property (nonatomic, strong) DatePickerSelectBlock pickerSelectBlock;
@property (nonatomic, strong) DatePickerCancelBlock pickerCancelBlock;

@property (nonatomic, assign) SceneType sceneType;

- (void)updateSelectRow:(NSDate *)date;
- (void)showShareNormalView;
@end
