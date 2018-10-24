//
//  GetCoffeeView.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "GetCoffeeView.h"

@interface  GetCoffeeView ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;

@end

@implementation GetCoffeeView

- (void)awakeFromNib{
    [super awakeFromNib];
    [CommonMethod viewAddGuestureRecognizer:self tapsNumber:1 withTarget:self withSEL:@selector(selectedGetCoffeeView)];
    [CALayer updateControlLayer:self.headerImageView.layer radius:17 borderWidth:0 borderColor:nil
     ];
}

- (void)selectedGetCoffeeView{
    if(self.selectedCoffeeView){
        self.selectedCoffeeView();
    }
}

- (void)updateDisplay:(NSDictionary *)dict{
    NSString *nameStr = [CommonMethod paramStringIsNull:dict[@"realname"]];
    self.nameLabel.text = nameStr;
    self.msgLabel.text = dict[@"takemessage"];
    self.timeLabel.text = dict[@"time"];
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:dict[@"image"]] placeholderImage:KHeadImageDefaultName(dict[@"realname"])];
}

- (IBAction)deleteButtonClicked:(id)sender {
    if(self.deleteCoffeeView){
        self.deleteCoffeeView();
    }
}

- (IBAction)replyButtonClicked:(id)sender {
    if(self.replyCoffeeView){
        self.replyCoffeeView();
    }
}

@end
