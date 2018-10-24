//
//  ContactsCollectionViewCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/10/25.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsCollectionViewCell : UICollectionViewCell

- (void)updateDisplayUserModel:(UserModel*)model;
- (void)updateDisplayDJTalkModel:(DJTalkModel*)model;
- (void)updateDisplayUserModelIntroduce:(UserModel*)model;

@property (nonatomic, strong) void(^deleteCell)(ContactsCollectionViewCell *delCell);

@end
