//
//  ChangeInformationViewGuid.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/7/20.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ChangeInformationViewGuid.h"
#import "ChangeMessageNotController.h"
@implementation ChangeInformationViewGuid
- (void)tranferString:(NSString *)side name:(NSArray *)nameArray{
    NSString *nameStr = [nameArray componentsJoinedByString:@","];
    CGFloat wideth = [NSHelper widthOfString:nameStr font:[UIFont systemFontOfSize:17] height:17];
    self.nameLabel.text = nameStr;
    self.nameLabel.textColor = [UIColor colorWithHexString:@"3498DB"];

    if (wideth > (WIDTH - 160 - 16)) {
        wideth = WIDTH - 160 - 16;
        side = [NSString stringWithFormat:@"等%ld人%@",nameArray.count,side];
    }
    self.nameLabel.frame = CGRectMake(16, 15, wideth, 19);
    self.sideLabel.frame = CGRectMake(16+wideth, 16, 130, 17);
    self.sideLabel.text = side;
    self.sideLabel.font = [UIFont systemFontOfSize:17];
    self.nameLabel.font = [UIFont systemFontOfSize:17];
    
}
- (IBAction)gotoTaMainPageChangeAction:(id)sender {
    ChangeMessageNotController *vc = [[ChangeMessageNotController alloc] init];
    [[self viewController].navigationController pushViewController:vc animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(self.clickedChangeInfoViewGuid){
            self.clickedChangeInfoViewGuid();
        }
        [self removeFromSuperview];
    });
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
