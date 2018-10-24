//
//  ActivityTalkCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/5.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ActivityTalkCell.h"

@interface ActivityTalkCell ()

@property (nonatomic, weak) IBOutlet UILabel *askLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *questionLabel;
@property (nonatomic, weak) IBOutlet UILabel *answerLabel;

@property (nonatomic, weak) IBOutlet UIButton *replyBtn;

@property (nonatomic, strong) UserModel *model;

@end

@implementation ActivityTalkCell

- (void)awakeFromNib {
    [super awakeFromNib];
   
    [CALayer updateControlLayer:self.replyBtn.layer radius:5 borderWidth:0 borderColor:nil];
    
    [CommonMethod viewAddGuestureRecognizer:self.nameLabel tapsNumber:1 withTarget:self withSEL:@selector(gotoHomePage)];
    // Initialization code
}

- (void)gotoHomePage{
    if (self.model.userId.integerValue > 0) {
        NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
        vc.userId = self.model.userId;
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)getCellHeight:(UserModel*)model{
    CGFloat height = [NSHelper heightOfString:model.ask font:FONT_SYSTEM_SIZE(14) width:WIDTH-32 defaultHeight:16];
    height += ((NSInteger)(height/FONT_SYSTEM_SIZE(14).lineHeight))*6;
    if(model.answer.length){
        CGFloat answerHeight = [NSHelper heightOfString:model.answer font:FONT_SYSTEM_SIZE(14) width:WIDTH-32 defaultHeight:16];
        answerHeight += ((NSInteger)(answerHeight/FONT_SYSTEM_SIZE(14).lineHeight))*6;
        height += 117 + answerHeight;
    }else{
        height += 103;
    }
    return height - 4;
}

- (void)updateDisplyCell:(UserModel *)model{
    [CALayer updateControlLayer:self.askLabel.layer radius:2 borderWidth:0.3 borderColor:HEX_COLOR(@"1abc9c").CGColor];
    self.model = model;
    self.nameLabel.text = model.realname;
    [self.questionLabel setParagraphText:model.ask lineSpace:6];
    [self.answerLabel setParagraphText:model.answer lineSpace:6];
}

- (IBAction)replyButtonClicked:(id)sender{
    if(self.selectedCell){
        self.selectedCell(self);
    }
}

@end
