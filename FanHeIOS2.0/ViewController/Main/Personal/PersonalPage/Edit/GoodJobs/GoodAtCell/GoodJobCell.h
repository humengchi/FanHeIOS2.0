//
//  GoodJobCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 16/11/3.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoodJobCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (nonatomic,strong) NSString *searchOne;
- (void)goodAtlokeJob:(SubjectModel *)model row:(NSUInteger )index section:(NSInteger)section select:(BOOL)select isSearch:(NSString *)isSearch;
@end
