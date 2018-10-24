//
//  MyMessageCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/3.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaMessageModel.h"

@protocol MyMessageCellDelegate <NSObject>
//名片
- (void)attestationIdentityMessage;
//个人签名
- (void)mySingActionChange;

@end


@interface MyMessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cardCertificationImage;

@property (weak, nonatomic) IBOutlet UIImageView *marksImageView;
@property (weak, nonatomic) IBOutlet UILabel *signLabel;
@property (nonatomic ,weak) id<MyMessageCellDelegate >attestationDelegate;
- (void)tranferMyMessageTaMessageModel:(TaMessageModel*)model;
+ (CGFloat)backHeigthTaMessageModel:(TaMessageModel*)model;
@end
