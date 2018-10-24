//
//  MycofferCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/10.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactsModel.h"
@interface MycofferCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *describeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
- (void)myRelationFriendContactsModel:(ContactsModel*)model;
+ (CGFloat)tableFrameBackCellHeigthContactsModel:(ContactsModel*)model;
@end
