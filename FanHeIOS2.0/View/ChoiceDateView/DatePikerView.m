//
//  DataPikerView.m
//  TestChoice
//
//  Created by huxianchen on 15/1/13.
//  Copyright (c) 2015年 SAIC. All rights reserved.
//

#import "DatePikerView.h"

#define currentMonth [currentMonthString integerValue]

@interface DatePikerView()<UIPickerViewDelegate, UIPickerViewDataSource>{
    BOOL _first;
}


@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSDateComponents *selectedDateComponets;
@property (weak, nonatomic) IBOutlet UIView *bkView;

@end

@implementation DatePikerView{
    NSMutableArray *yearArray;
    NSMutableArray *monthArray;
    NSMutableArray *DaysArray;
    NSArray *amPmArray;
    NSMutableArray *hoursArray;
    NSMutableArray *minutesArray;
    
    NSString *currentMonthString;
    
    int selectedYearRow;
    int selectedMonthRow;
    int selectedDayRow;
    
    BOOL firstTimeLoad;
    
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.customPicker.delegate = self;
    self.customPicker.dataSource = self;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    
    
    self.startDate= [dateFormatter dateFromString:@"1960-01-01"];
    self.endDate = [NSDate date];//[dateFormatter dateFromString:@"2099-01-01"];
    
    self.selectedDate = [NSDate date];
    self.calendar = [NSCalendar currentCalendar];
    
    [CALayer updateControlLayer:self.bgLabel.layer radius:0 borderWidth:1 borderColor:[UIColor lightGrayColor].CGColor];
    self.bgLabel.hidden = YES;

    [CommonMethod viewAddGuestureRecognizer:self.bkView tapsNumber:1 withTarget:self withSEL:@selector(dealBackViewDoubleClicked:)];
}

- (void)dealBackViewDoubleClicked:(UITapGestureRecognizer *)tap {
    [self removeView];
}

- (IBAction)cancleButtonClicked:(id)sender{
    [self removeView];
}

- (void)showShareNormalView{
    __weak typeof(self) weakSelf = self;
    self.bkView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.frame = CGRectMake(0, -260, WIDTH, HEIGHT+260);
        weakSelf.bkView.alpha = 0.25;
    } completion:nil];
}

- (void)removeView{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.frame = CGRectMake(0, 0, WIDTH, HEIGHT+260);
        weakSelf.bkView.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

- (IBAction)choiceButtonClicked:(id)sender{
    [self actionDone:sender];
    [self removeView];
}

- (IBAction)clearButtonClicked:(id)sender{
    if (self.pickerSelectBlock) {
        self.pickerSelectBlock(self, @"");
    }
    [self removeView];
}

- (void)updateSelectRow:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if(self.sceneType == SceneType_Activity){
        [dateFormatter setDateFormat: @"yyyy-MM-dd"];
        self.startDate = [NSDate date];
        self.endDate = [dateFormatter dateFromString:@"2099-01-01"];
    }
    BOOL dateIsNull = NO;
    if(date==nil){
        date = [NSDate date];
        dateIsNull = YES;
        _first = YES;
    }
    self.selectedDate = date;

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:date];
    NSDateComponents *startDateComponent = [calendar components:unitFlags fromDate:self.startDate];
    
    long yearIndex = [dateComponent year]-[startDateComponent year]+((self.isShow&&dateIsNull)?1:0);
    long monthIndex = [dateComponent month]-1;
    long dayIndex = [dateComponent day]-1;
    long hourIndex = [dateComponent hour];
    long minuteIndex = [dateComponent minute];
    //long secondIndex = [dateComponent second];
    if (self.type == kDatePikerViewTypeDay) {
        [self.customPicker selectRow:yearIndex inComponent:0 animated:NO];
        [self.customPicker selectRow:monthIndex inComponent:1 animated:NO];
        [self.customPicker selectRow:dayIndex inComponent:2 animated:NO];
    }else if (self.type == kDatePikerViewTypeSecond) {
        [self.customPicker selectRow:yearIndex inComponent:0 animated:NO];
        [self.customPicker selectRow:monthIndex inComponent:1 animated:NO];
        [self.customPicker selectRow:dayIndex inComponent:2 animated:NO];
        [self.customPicker selectRow:hourIndex inComponent:3 animated:NO];
        [self.customPicker selectRow:minuteIndex inComponent:4 animated:NO];
        //[self.customPicker selectRow:secondIndex inComponent:5 animated:NO];
    }else if (self.type == kDatePikerViewTypeHHMM) {
        [self.customPicker selectRow:hourIndex inComponent:0 animated:NO];
        [self.customPicker selectRow:minuteIndex inComponent:1 animated:NO];
    }else if (self.type == kDatePikerViewTypeMonth) {
        [self.customPicker selectRow:yearIndex inComponent:0 animated:NO];
        [self.customPicker selectRow:monthIndex inComponent:1 animated:NO];
    }
}

#pragma mark - UIPickerViewDatasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (self.type == kDatePikerViewTypeDay) {
        return 3;
    }else if (self.type == kDatePikerViewTypeSecond) {
        return 5;
    }else if (self.type == kDatePikerViewTypeHHMM) {
        return 2;
    }else if (self.type == kDatePikerViewTypeMonth) {
        return 2;
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.type == kDatePikerViewTypeDay ||
        self.type == kDatePikerViewTypeSecond || self.type == kDatePikerViewTypeMonth) {
        
        switch (component) { // component是栏目index，从0开始，后面的row也一样是从0开始
            case 0: { // 第一栏为年，这里startDate和endDate为起始时间和截止时间，请自行指定
                NSDateComponents *startCpts = [self.calendar components:NSCalendarUnitYear
                                                               fromDate:self.startDate];
                NSDateComponents *endCpts = [self.calendar components:NSCalendarUnitYear
                                                             fromDate:self.endDate];
                if (self.isShow) {
                    return [endCpts year] - [startCpts year] + 2;
                }
                return [endCpts year] - [startCpts year] + 1;
            }
            case 1: // 第二栏为月份
            {
                if(([pickerView selectedRowInComponent:0] == [pickerView numberOfRowsInComponent:0]-1 && self.isShow)||(self.isShow&&_first)){
                    return 0;
                }else{
                    return 12;
                }
            }
            case 2: { // 第三栏为对应月份的天数
                NSRange dayRange = [self.calendar rangeOfUnit:NSCalendarUnitDay
                                                       inUnit:NSCalendarUnitMonth
                                                      forDate:self.selectedDate];
                return dayRange.length;
            case 3://小时
                return 24;
            case 4://分钟
                return 60;
            case 5://秒
                return 60;
            }
            default:
                return 0;
        }
    }else if (self.type == kDatePikerViewTypeHHMM){
        switch (component) {
            case 0:
                return 24;//时
            case 1:
                return 60;//分
                
            default:
                return 0;
        }
    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view
{
    UILabel *dateLabel = (UILabel *)view;
    if (!dateLabel) {
        dateLabel = [[UILabel alloc] init];
        [dateLabel setFont:[UIFont systemFontOfSize:17]];
        [dateLabel setTextColor:HEX_COLOR(@"41464E")];
        [dateLabel setBackgroundColor:[UIColor clearColor]];
    }
    
    if (self.type == kDatePikerViewTypeDay || self.type == kDatePikerViewTypeSecond || self.type == kDatePikerViewTypeMonth) {
        
        switch (component) {
            case 0: {
                NSDateComponents *components = [self.calendar components:NSCalendarUnitYear fromDate:self.startDate];
                if([pickerView numberOfRowsInComponent:0]-1 == row && self.isShow){
                    [dateLabel setText:@"至今"];
                }else{
                    NSString *currentYear = [NSString stringWithFormat:@"%ld年",(long)([components year] + row)];
                    [dateLabel setText:currentYear];
                }
                dateLabel.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case 1: { // 返回月份可以用DateFormatter，这样可以支持本地化
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh-Hans"];
//                NSArray *monthSymbols = [formatter monthSymbols];
//                [dateLabel setText:[monthSymbols objectAtIndex:row]];
                [dateLabel setText:[NSString stringWithFormat:@"%ld月",(long)(row+1)]];
                dateLabel.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case 2: {
                NSRange dateRange = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self.selectedDate];
                NSString *currentDay = [NSString stringWithFormat:@"%02ld日", ((row + 1) % (long)(dateRange.length + 1))];
                [dateLabel setText:currentDay];
                dateLabel.textAlignment = NSTextAlignmentLeft;
                break;
            }
            case 3:{
                NSRange dateRange = [self.calendar rangeOfUnit:NSCalendarUnitHour inUnit:NSCalendarUnitDay forDate:self.selectedDate];
                NSString *currentDay = [NSString stringWithFormat:@"%02ld", (row) % (long)(dateRange.length)];
                [dateLabel setText:currentDay];
                dateLabel.textAlignment = NSTextAlignmentLeft;
                break;
            }
            case 4:{
                NSRange dateRange = [self.calendar rangeOfUnit:NSCalendarUnitMinute inUnit:NSCalendarUnitHour forDate:self.selectedDate];
                NSString *currentDay = [NSString stringWithFormat:@"%02ld", (row) % (long)(dateRange.length)];
                [dateLabel setText:currentDay];
                dateLabel.textAlignment = NSTextAlignmentLeft;
                break;
            }
            case 5:{
                NSRange dateRange = [self.calendar rangeOfUnit:NSCalendarUnitSecond inUnit:NSCalendarUnitMinute forDate:self.selectedDate];
                NSString *currentDay = [NSString stringWithFormat:@"%02ld", (row) % (long)(dateRange.length)];
                [dateLabel setText:currentDay];
                dateLabel.textAlignment = NSTextAlignmentLeft;
                break;
            }
            default:
                break;
        }
    }else if (self.type == kDatePikerViewTypeHHMM){
        switch (component) {
            case 0:{
                NSRange dateRange = [self.calendar rangeOfUnit:NSCalendarUnitHour inUnit:NSCalendarUnitDay forDate:self.selectedDate];
                NSString *currentDay = [NSString stringWithFormat:@"%02ld", (row) % (long)(dateRange.length)];
                [dateLabel setText:currentDay];
                dateLabel.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case 1:{
                NSRange dateRange = [self.calendar rangeOfUnit:NSCalendarUnitMinute inUnit:NSCalendarUnitHour forDate:self.selectedDate];
                NSString *currentDay = [NSString stringWithFormat:@"%02ld", (row) % (long)(dateRange.length)];
                [dateLabel setText:currentDay];
                dateLabel.textAlignment = NSTextAlignmentCenter;
                break;
            }
            default:
                break;
        }
    }
    return dateLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _first = NO;
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    if (self.type == kDatePikerViewTypeDay || self.type == kDatePikerViewTypeSecond || self.type == kDatePikerViewTypeMonth){
        switch (component) {
            case 0: {
                NSDateComponents *indicatorComponents = [self.calendar components:NSCalendarUnitYear fromDate:self.startDate];
                NSInteger year = [indicatorComponents year] + row;
                NSDateComponents *targetComponents = [self.calendar components:unitFlags fromDate:self.selectedDate];
                [targetComponents setYear:year];
                [targetComponents setMonth:1];
                [targetComponents setDay:1];
                self.selectedDateComponets = targetComponents;
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat: @"yyyy-MM-dd"];
                self.selectedDate =  [dateFormatter dateFromString:[NSString stringWithFormat:@"%ld-%ld-%ld", (long)targetComponents.year, (long)targetComponents.month, (long)targetComponents.day]];
                [pickerView selectRow:0 inComponent:1 animated:YES];
                if(self.type != kDatePikerViewTypeMonth){
                    [pickerView selectRow:0 inComponent:2 animated:YES];
                    [pickerView reloadComponent:2];
                }
                break;
            }
            case 1: {
                NSDateComponents *targetComponents = [self.calendar components:unitFlags fromDate:self.selectedDate];
                [targetComponents setMonth:row + 1];
                [targetComponents setDay:1];
                self.selectedDateComponets = targetComponents;
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    
                self.selectedDate =  [dateFormatter dateFromString:[NSString stringWithFormat:@"%ld-%ld-%ld", (long)targetComponents.year, targetComponents.month, (long)targetComponents.day]];
                
                if(self.type != kDatePikerViewTypeMonth){
                    [pickerView selectRow:0 inComponent:2 animated:NO];//YES:days位置错位
                    [pickerView reloadComponent:2];
                }
                break;
            }
            case 2:
            case 3:
            case 4:{
                NSDateComponents *targetComponents = [self.calendar components:unitFlags fromDate:self.selectedDate];
                [targetComponents setDay:row];
                self.selectedDateComponets = targetComponents;
                break;
            }
            default:
                break;
        }
    }else if(self.type == kDatePikerViewTypeHHMM){
        switch (component) {
            case 0: {
                NSDateComponents *targetComponents = [self.calendar components:unitFlags fromDate:self.selectedDate];
                [targetComponents setDay:row + 1];
                self.selectedDateComponets = targetComponents;
                break;
            }
            default:
                break;
        }
    }
    [pickerView reloadAllComponents];
}

- (IBAction)actionCancel:(id)sender{
       if (self.pickerCancelBlock) {
        self.pickerCancelBlock(self);
    }
}

- (IBAction)actionDone:(id)sender{
    NSInteger rows = [self numberOfComponentsInPickerView:self.customPicker];
    NSMutableString *dateStr = [[NSMutableString alloc] init];

    if (self.type == kDatePikerViewTypeDay ||
        self.type == kDatePikerViewTypeSecond || self.type == kDatePikerViewTypeMonth){
        for (int i = 0; i < rows; i++) {
            NSInteger row=[self.customPicker selectedRowInComponent:i];
            if (i ==0) {//年
                if([self.customPicker numberOfRowsInComponent:0]== row+1 && self.isShow){
                    dateStr = nil;
                }else{
                    NSDateComponents *startCpts = [self.calendar components:NSCalendarUnitYear fromDate:self.startDate];
                    [dateStr appendString:[NSString stringWithFormat:@"%ld",[startCpts year] + row]];
                }
            }else if(i ==1){//月
                if(dateStr!=nil){
                    [dateStr appendString:[NSString stringWithFormat:@"-%02ld",row+1]];
                }
            }else if (i == 2){//日
                [dateStr appendString:[NSString stringWithFormat:@"-%02ld",1 + row]];
            } else if (i == 3){//时
                [dateStr appendString:[NSString stringWithFormat:@" %02ld",row]];
            }else if(i == 4){//分
                [dateStr appendString:[NSString stringWithFormat:@":%02ld",row]];
            }else if(i == 5){//秒
                [dateStr appendString:[NSString stringWithFormat:@":%02ld",row]];
            }
        }
    }else if (self.type == kDatePikerViewTypeHHMM){
        for (int i = 0; i < rows; i++) {
            NSInteger row=[self.customPicker selectedRowInComponent:i];
            if (i == 0){
                NSDateComponents *startCpts = [self.calendar components:NSCalendarUnitHour fromDate:self.startDate];
                [dateStr appendString:[NSString stringWithFormat:@"%02ld",[startCpts hour] + row]];
            }else if(i == 1){
                NSDateComponents *startCpts = [self.calendar components:NSCalendarUnitMinute fromDate:self.startDate];
                [dateStr appendString:[NSString stringWithFormat:@":%02ld",[startCpts minute] + row]];
            }
        }
    }
    
    if (self.pickerSelectBlock) {
        self.pickerSelectBlock(self, dateStr);
    }
}

- (void)pickerViewLoaded:(NSInteger)component{
    NSUInteger max = 16384;
    NSUInteger rows = [self pickerView:self.customPicker numberOfRowsInComponent:component];
    
    NSUInteger base10 = (max/2)-(max/2)%rows;
    [self.customPicker selectRow:[self.customPicker selectedRowInComponent:component]%rows+base10 inComponent:component animated:false];
}



@end
