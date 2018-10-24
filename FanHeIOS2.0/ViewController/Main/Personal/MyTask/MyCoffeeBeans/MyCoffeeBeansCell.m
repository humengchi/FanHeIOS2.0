//
//  MyCoffeeBeansCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/10.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "MyCoffeeBeansCell.h"

@interface MyCoffeeBeansCell ()

@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *limiLabel;
@property (nonatomic, weak) IBOutlet UILabel *cbLabel;

@end

@implementation MyCoffeeBeansCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateDisplay:(NSInteger)row{
    NSArray *array = @[@{@"icon":@"icon_misson_cqy", @"name":@"企业信息查询", @"limit":@"5", @"cb":@"5"}, @{@"icon":@"icon_misson_gx", @"name":@"供需发布", @"limit":@"2", @"cb":@"3"}, @{@"icon":@"icon_misson_smp", @"name":@"扫描用户名片", @"limit":@"5", @"cb":@"5"}];
    NSDictionary *dict = array[row];
    self.iconImageView.image = kImageWithName(dict[@"icon"]);
    self.nameLabel.text = dict[@"name"];
    self.limiLabel.text = [NSString stringWithFormat:@"每日%@次免费查询机会", dict[@"limit"]];
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"超出部分 %@ ／次",dict[@"cb"]]];
    NSTextAttachment *attchImage = [[NSTextAttachment alloc] init];
    attchImage.image = kImageWithName(@"icon_kfd_grey");
    attchImage.bounds = CGRectMake(2, -1, 9, 10);
    NSAttributedString *stringImage = [NSAttributedString attributedStringWithAttachment:attchImage];
    [attriStr insertAttributedString:stringImage atIndex:6];
    self.cbLabel.attributedText = attriStr;
}

@end
