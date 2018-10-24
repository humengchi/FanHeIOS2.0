//
//  DynamicTranferView.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DynamicTranferView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *twoLabe;
@property (weak, nonatomic) IBOutlet UILabel *oneLabel;
- (void)tranferDynamicTranferViewimageUrl:(NSString *)url count:(NSString *)count;
@end
