//
//  GetSucceedCofferView.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/11/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GetSucceedCofferView : UIView
@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *sideLabel;
- (void)createrGetCofferCoverImage:(NSString *)imageUrl isMyGet:(BOOL)isMyGet;
@end
