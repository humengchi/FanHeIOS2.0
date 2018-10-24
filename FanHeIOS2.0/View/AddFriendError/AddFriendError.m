//
//  AddFriendError
//  FanHeIOS2.0
//
//  Created by renhao on 2017/7/21.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "AddFriendError.h"

@interface AddFriendError ()

@property (nonatomic, weak) IBOutlet UIImageView *coverImageView;
@property (nonatomic, weak) IBOutlet UILabel *showLabel;
@property (nonatomic, weak) IBOutlet UILabel *mainLabel;
@property (nonatomic, weak) IBOutlet UIButton *btn;

@end

@implementation AddFriendError

- (IBAction)clearViewFormeSupper:(UIButton*)sender {
    if(self.buttonClicked){
        self.buttonClicked();
    }
    [self removeFromSuperview];
}

- (void)setCoffeeBeans:(NSNumber *)coffeeBeans{
    self.coverImageView.image = kImageWithName(@"icon_zf_cg");
    self.mainLabel.text = @"成功充值";
    self.showLabel.text = [NSString stringWithFormat:@"+%@咖啡豆", coffeeBeans];
    [self.btn setTitle:@"返回" forState:UIControlStateNormal];
}

@end
