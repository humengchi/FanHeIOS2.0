//
//  GetWallCoffeeTakeTableViewCell.h
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/11/17.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GetWallCoffeeTakeTableViewCell : UITableViewCell

+ (CGFloat)getCellHeight:(MyGetCoffeeModel*)model isMyGetCodffee:(BOOL)isMyGetCodffee;

- (void)updateDisply:(MyGetCoffeeModel*)model isMyGetCodffee:(BOOL)isMyGetCodffee;

@end
