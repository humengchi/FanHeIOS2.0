//
//  PublishCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/4.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "PublishCell.h"
#import "ApplyManagerViewController.h"
#import "ActivityTalkViewController.h"

@interface PublishCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *applyNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *askNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *readNumLabel;

@property (weak, nonatomic) IBOutlet UIImageView *applyNumNewImageView;
@property (weak, nonatomic) IBOutlet UIImageView *askNumNewImageView;

@property (nonatomic, strong) MyActivityModel *model;

@end

@implementation PublishCell

- (void)tranferMyActivityCellModel:(MyActivityModel *)model{
    self.model = model;
    self.titleLabel.text = model.name;
    self.timeLabel.text = [NSString stringWithFormat:@"%@ 发布",model.edittime];
    self.startLabel.text = model.price;
    if ([model.price isEqualToString:@"已取消"]) {
        self.startLabel.layer.borderColor = [[UIColor colorWithHexString:@"D8D8D8"] CGColor];
        self.startLabel.textColor = [UIColor colorWithHexString:@"D8D8D8"];
    }else if ([model.price isEqualToString:@"已结束"]){
        self.startLabel.layer.borderColor = [[UIColor colorWithHexString:@"41464E"] CGColor];
        self.startLabel.textColor = [UIColor colorWithHexString:@"41464E"];
    }else if ([model.price isEqualToString:@"已截止"]){
        self.startLabel.layer.borderColor = [[UIColor colorWithHexString:@"F76B1C"] CGColor];
        self.startLabel.textColor = [UIColor colorWithHexString:@"F76B1C"];
    }else if ([model.price isEqualToString:@"未通过"]){
        self.startLabel.layer.borderColor = [[UIColor colorWithHexString:@"E24943"] CGColor];
        self.startLabel.textColor = [UIColor colorWithHexString:@"E24943"];
    }else{
        self.startLabel.layer.borderColor = [[UIColor colorWithHexString:@"1ABC9C"] CGColor];
    }
    self.applyNumLabel.text = [NSString stringWithFormat:@"报名 %@", model.applynum];
    self.askNumLabel.text = [NSString stringWithFormat:@"讨论 %@", model.asknum];
    self.readNumLabel.text = [NSString stringWithFormat:@"浏览 %@", model.readcount];
    self.applyNumNewImageView.hidden = model.newapplynum.integerValue==0;
    self.askNumNewImageView.hidden = model.newasknum.integerValue==0;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.startLabel.layer.borderWidth = 0.3;
    self.startLabel.layer.masksToBounds = YES;
    self.startLabel.layer.cornerRadius = 2;
    
    self.applyNumNewImageView.layer.masksToBounds = YES;
    self.applyNumNewImageView.layer.cornerRadius = 3.5;
    
    self.askNumNewImageView.layer.masksToBounds = YES;
    self.askNumNewImageView.layer.cornerRadius = 3.5;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)applyButtonClicked:(id)sender{
    ApplyManagerViewController *vc = [[ApplyManagerViewController alloc] init];
    vc.activityid = self.model.activityid;
    [[self viewController].navigationController pushViewController:vc animated:YES];
}

- (IBAction)talkButtonClicked:(id)sender{
    ActivityTalkViewController *vc = [[ActivityTalkViewController alloc] init];
    vc.activityid = self.model.activityid;
    [[self viewController].navigationController pushViewController:vc animated:YES];
}

@end
