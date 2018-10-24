//
//  ChoiceAddressView.m
//  JinMai
//
//  Created by 胡梦驰 on 16/5/11.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "ChoiceAddressView.h"

@interface ChoiceAddressView ()<UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, weak) IBOutlet UIPickerView   *pickerView;
@property (nonatomic, weak) IBOutlet UIView *bgView;

@property (nonatomic, strong) NSMutableArray    *provincesArray;

@property (nonatomic, strong) NSMutableArray    *citysArray;

@property (nonatomic, strong) NSMutableArray    *districtsArray;

@end

@implementation ChoiceAddressView

- (void)awakeFromNib{
    [super awakeFromNib];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    [self.pickerView reloadAllComponents];
    
    self.provincesArray = [NSMutableArray array];
    self.citysArray = [NSMutableArray array];
    self.districtsArray = [NSMutableArray array];
    
    [CommonMethod viewAddGuestureRecognizer:self.bgView tapsNumber:1 withTarget:self withSEL:@selector(dealBackViewDoubleClicked:)];
}

- (void)showShareNormalView{
    __weak typeof(self) weakSelf = self;
    self.bgView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.frame = CGRectMake(0, -260, WIDTH, HEIGHT+260);
        weakSelf.bgView.alpha = 0.25;
    } completion:nil];
}

- (void)removeView{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.frame = CGRectMake(0, 0, WIDTH, HEIGHT+260);
        weakSelf.bgView.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

- (void)dealBackViewDoubleClicked:(UITapGestureRecognizer *)tap {
    [self removeView];
}

- (IBAction)cancleButtonClicked:(id)sender{
    [self removeView];
}

- (IBAction)choiceButtonClicked:(id)sender{
    if(self.selectAddress){
        NSString *provinceId = [self.provincesArray[[self.pickerView selectedRowInComponent:0]] citysId];
        NSString *cityId;
        if(self.citysArray.count){
            cityId = [self.citysArray[[self.pickerView selectedRowInComponent:1]] citysId];
        }
        
        NSString *districtId;
        if(self.districtsArray.count){
            districtId = [self.districtsArray[[self.pickerView selectedRowInComponent:2]] citysId];
        }
        self.selectAddress(provinceId, cityId, districtId);
    }
    [self removeView];
}

- (void)updateDisplay:(NSString*)provinceId cityId:(NSString*)cityId districtId:(NSString*)districtId{
    if(provinceId.length == 0){
        self.provincesArray = [[DBInstance shareInstance] getAllCitysModel:@"1" ParentId:@""];
        CitysModel* model = self.provincesArray[0];
        self.citysArray = [[DBInstance shareInstance] getAllCitysModel:@"2" ParentId:model.citysId];
        CitysModel* model1 = self.citysArray[0];
        self.districtsArray = [[DBInstance shareInstance] getAllCitysModel:@"3" ParentId:model1.citysId];
        [self.pickerView reloadAllComponents];
    }else{
        self.provincesArray = [[DBInstance shareInstance] getAllCitysModel:@"1" ParentId:@""];
        NSInteger provinceIndex = [self getIndexAtArray:self.provincesArray citysId:provinceId];
        self.citysArray = [[DBInstance shareInstance] getAllCitysModel:@"2" ParentId:provinceId];
        if(self.citysArray.count == 0){
            CitysModel* model = self.provincesArray[(provinceIndex != -1?provinceIndex:0)];
            self.citysArray = [[DBInstance shareInstance] getAllCitysModel:@"2" ParentId:model.citysId];
                
        }
        self.districtsArray = [[DBInstance shareInstance] getAllCitysModel:@"3" ParentId:cityId];
        if(self.districtsArray.count == 0){
            CitysModel* model1 = self.citysArray[0];
            self.districtsArray = [[DBInstance shareInstance] getAllCitysModel:@"3" ParentId:model1.citysId];
        }
        [self.pickerView reloadAllComponents];
        NSInteger cityIndex = [self getIndexAtArray:self.citysArray citysId:cityId];
        NSInteger districtIndex = [self getIndexAtArray:self.districtsArray citysId:districtId];
        if(provinceIndex != -1){
            [self.pickerView selectRow:provinceIndex inComponent:0 animated:YES];
        }
        if(cityIndex != -1){
            [self.pickerView selectRow:cityIndex inComponent:1 animated:YES];
        }
        if(districtIndex != -1){
            [self.pickerView selectRow:districtIndex inComponent:2 animated:YES];
        }
    }
}

- (NSInteger)getIndexAtArray:(NSMutableArray*)array citysId:(NSString*)citysId{
    NSInteger i = 0;
    for(CitysModel *model in array){
        if([citysId isEqualToString:model.citysId]){
            return i;
        }else{
            i++;
        }
    }
    return -1;
}

#pragma markUIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if(component == 0){
        return [self.provincesArray count];
    }else if(component == 1){
        return [self.citysArray count];
    }else{
        return [self.districtsArray count];
    }
}

//设置组件的宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return WIDTH/3;
}
//设置组件中每行的高度
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 60;
}

//设置组件中每行的标题row:行
//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
//    CitysModel *model;
//    if (component == 0) {
//        model = self.provincesArray[row];
//    }else if (component == 1) {
//        model = self.citysArray[row];
//    }else{
//        model = self.districtsArray[row];
//    }
//    return model.ShortName;
//}

- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *addressLabel = (UILabel *)view;
    if (!addressLabel) {
        addressLabel = [[UILabel alloc] init];
        [addressLabel setFont:[UIFont systemFontOfSize:17]];
        [addressLabel setTextColor:HEX_COLOR(@"41464E")];
        [addressLabel setBackgroundColor:[UIColor clearColor]];
    }
    CitysModel *model;
    if (component == 0) {
        model = self.provincesArray[row];
    }else if (component == 1) {
        model = self.citysArray[row];
    }else{
        model = self.districtsArray[row];
    }
    addressLabel.text = model.ShortName;
    addressLabel.textAlignment = NSTextAlignmentCenter;
    return addressLabel;
}

//选中行的事件处理
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if (component == 0) {
        CitysModel* model = self.provincesArray[row];
        self.citysArray = [[DBInstance shareInstance] getAllCitysModel:@"2" ParentId:model.citysId];
        if(self.citysArray.count){
            CitysModel* model1 = self.citysArray[0];
            self.districtsArray = [[DBInstance shareInstance] getAllCitysModel:@"3" ParentId:model1.citysId];
        }else{
            [self removeView];
        }
        [self.pickerView reloadComponent:1];
        [self.pickerView reloadComponent:2];
    }else if (component == 1) {
        CitysModel* model1 = self.citysArray[row];
        self.districtsArray = [[DBInstance shareInstance] getAllCitysModel:@"3" ParentId:model1.citysId];
        [self.pickerView reloadComponent:2];
    }
}


@end
