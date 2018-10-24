//
//  ApplySettingCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ApplySettingCell.h"
#import "ApplySettingViewController.h"

@interface ApplySettingCell ()<UITextViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSMutableDictionary *dict;

@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UITextField *priceTextField;
@property (nonatomic, weak) IBOutlet UITextField *seatTextField;
@property (nonatomic, weak) IBOutlet UITextView *remarkTextView;
@property (nonatomic, weak) IBOutlet UILabel *remarkPlaceholder;

@end

@implementation ApplySettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.remarkTextView.delegate = self;
    [self.nameTextField setValue:HEX_COLOR(@"e6e8eb") forKeyPath:@"_placeholderLabel.textColor"];
    [self.priceTextField setValue:HEX_COLOR(@"e6e8eb") forKeyPath:@"_placeholderLabel.textColor"];
    [self.seatTextField setValue:HEX_COLOR(@"e6e8eb") forKeyPath:@"_placeholderLabel.textColor"];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateDisply:(NSMutableDictionary *)dict{
    self.dict = [dict mutableCopy];
    __weak typeof(self) weakSelf = self;
    self.nameTextField.text = self.dict[@"name"];
    if([CommonMethod paramNumberIsNull:self.dict[@"price"]].integerValue){
        self.priceTextField.text = [CommonMethod paramNumberIsNull:self.dict[@"price"]].stringValue;
    }
    if([CommonMethod paramNumberIsNull:self.dict[@"seat"]].integerValue){
        self.seatTextField.text = [CommonMethod paramNumberIsNull:self.dict[@"seat"]].stringValue;
    }
    self.remarkTextView.text = self.dict[@"remark"];
    self.nameTextField.delegate = self;
    [self.priceTextField.rac_textSignal subscribeNext:^(NSString *text) {
        if(text.length>6){
            weakSelf.priceTextField.text = [text substringToIndex:6];
        }
        [weakSelf.dict setObject:[NSNumber numberWithInt:weakSelf.priceTextField.text.integerValue] forKey:@"price"];
        if(weakSelf.ticketParamEdit){
            weakSelf.ticketParamEdit(weakSelf.dict, self);
        }
    }];
    [self.seatTextField.rac_textSignal subscribeNext:^(NSString *text) {
        if(text.length>8){
            weakSelf.seatTextField.text = [text substringToIndex:8];
        }
        [weakSelf.dict setObject:[NSNumber numberWithInt:weakSelf.seatTextField.text.integerValue] forKey:@"seat"];
        if(weakSelf.ticketParamEdit){
            weakSelf.ticketParamEdit(weakSelf.dict, self);
        }
    }];
    [self.remarkTextView.rac_textSignal subscribeNext:^(NSString *text) {
        weakSelf.remarkPlaceholder.hidden = text.length>0;
    }];
}

- (IBAction)deleteTicketButtonClicked:(id)sender{
    [self endEditing:YES];
    if(self.deleteTicket){
        self.deleteTicket(self);
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    
    UITextRange *selectedRange = [textView markedTextRange];
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    if(position && (range.length==0 || text.length==0)){
        return YES;
    }else{
        NSString *str = [textView.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:text];
        if(str.length>40){
            self.remarkTextView.text = [str substringToIndex:40];
            [self.dict setObject:self.remarkTextView.text forKey:@"remark"];
            if(self.ticketParamEdit){
                self.ticketParamEdit(self.dict, self);
            }
            return NO;
        }else{
            [self.dict setObject:str forKey:@"remark"];
            if(self.ticketParamEdit){
                self.ticketParamEdit(self.dict, self);
            }
        }
    }
    return YES;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(textField == self.nameTextField){
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if(position && (range.length==0 || string.length==0)){
            return YES;
        }else{
            NSString *str = [textField.text stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:string];
            if(str.length>10){
                self.nameTextField.text = [str substringToIndex:10];
                [self.dict setObject:self.nameTextField.text forKey:@"name"];
                if(self.ticketParamEdit){
                    self.ticketParamEdit(self.dict, self);
                }
                return NO;
            }else{
                [self.dict setObject:str forKey:@"name"];
                if(self.ticketParamEdit){
                    self.ticketParamEdit(self.dict, self);
                }
            }
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    ApplySettingViewController *vc = (ApplySettingViewController*)[self viewController];
    [vc.tableView scrollRectToVisible:CGRectMake(0, 167+self.tag*237, WIDTH, 237) animated:YES];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    ApplySettingViewController *vc = (ApplySettingViewController*)[self viewController];
    [vc.tableView scrollRectToVisible:CGRectMake(0, 167+self.tag*237, WIDTH, 237) animated:YES];
}

@end
