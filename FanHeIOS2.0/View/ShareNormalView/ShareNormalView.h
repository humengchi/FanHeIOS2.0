//
//  ShareNormalView.h
//  JinMai
//
//  Created by 胡梦驰 on 16/5/13.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ShareIndex)(NSInteger index);
@interface ShareNormalView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *threeImageVIew;
@property (weak, nonatomic) IBOutlet UILabel *threeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fourImageView;
@property (weak, nonatomic) IBOutlet UILabel *foureLabel;

@property (nonatomic, strong) ShareIndex shareIndex;
@property (nonatomic, weak) IBOutlet UIView *messageView;

- (void)showShareNormalView;
- (void)setCopylink;

@end
