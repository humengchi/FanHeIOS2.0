//
//  NeedAndSupplyCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/14.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "NeedAndSupplyCell.h"
#import "NeedSupplyListController.h"

@interface NeedAndSupplyCell ()

@property (weak, nonatomic) IBOutlet UILabel *titileLabel;

@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *showAllBtn;

@end

@implementation NeedAndSupplyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)getCellHeight:(NeedModel*)model{
    CGFloat height = [NSHelper heightOfString:model.intro font:FONT_SYSTEM_SIZE(14) width:WIDTH-32];
    if(height > FONT_SYSTEM_SIZE(14).lineHeight*3){
        height = FONT_SYSTEM_SIZE(14).lineHeight*3;
    }
    height += (height/FONT_SYSTEM_SIZE(14).lineHeight-1)*7;
    if(model.count.integerValue>1){
        height += 41;
    }
    height += 80;
    return height;
}

- (void)updateDisplayModel:(NeedModel*)model{
    self.titileLabel.text = model.title;
    CGFloat height = [NSHelper heightOfString:model.intro font:FONT_SYSTEM_SIZE(14) width:WIDTH-32];
    if(height>FONT_SYSTEM_SIZE(14).lineHeight){
        [self.introLabel setParagraphText:model.intro lineSpace:7];
    }else{
        self.introLabel.text = model.intro;
    }
    self.tagLabel.text = [CommonMethod paramArrayIsNull:model.tags].count?[NSString stringWithFormat:@"#%@#",[model.tags componentsJoinedByString:@"# #"]]:@"#标签#";
    self.showAllBtn.hidden = model.count.integerValue<=1;
    self.timeLabel.text = model.created_at;
}

- (IBAction)showAllButtonClicked:(id)sender {
    NeedSupplyListController *vc = [CommonMethod getVCFromNib:[NeedSupplyListController class]];
    vc.isNeed = self.isNeed;
    vc.userId = self.userId;
    vc.needOrSupplyChange = ^{
        if(self.needOrSupplyChange){
            self.needOrSupplyChange();
        }
    };
    [[self viewController].navigationController pushViewController:vc animated:YES];
}

@end
