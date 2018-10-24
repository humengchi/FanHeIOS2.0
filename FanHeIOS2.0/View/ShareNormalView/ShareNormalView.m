//
//  ShareNormalView.m
//  JinMai
//
//  Created by 胡梦驰 on 16/5/13.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "ShareNormalView.h"

@interface ShareNormalView ()
@property (nonatomic, weak) IBOutlet UIView *bgView;
@property (nonatomic, weak) IBOutlet UILabel *thirdLabel;
@property (nonatomic, weak) IBOutlet UIImageView *thirdImageView;
@end

@implementation ShareNormalView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)awakeFromNib{
    [super awakeFromNib];
    self.bgView.userInteractionEnabled = YES;
    [CommonMethod viewAddGuestureRecognizer:self.bgView tapsNumber:1 withTarget:self withSEL:@selector(quitButtonClicked:)];
}

- (void)showShareNormalView{
    __weak typeof(self) weakSelf = self;
    self.bgView.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.frame = CGRectMake(0, -180, WIDTH, HEIGHT+180);
        weakSelf.bgView.alpha = 0.5;
    } completion:nil];
}

- (IBAction)quitButtonClicked:(id)sender{
    [[self viewController] newThreadForAvoidButtonRepeatClick:sender];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.frame = CGRectMake(0, 0, WIDTH, HEIGHT+180);
        weakSelf.bgView.alpha = 0.1;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

- (IBAction)shareButtonClicked:(UIButton*)sender{
    [[self viewController] newThreadForAvoidButtonRepeatClick:sender];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.frame = CGRectMake(0, 0, WIDTH, HEIGHT+180);
        weakSelf.bgView.alpha = 0.1;
    } completion:^(BOOL finished) {
        weakSelf.shareIndex(sender.tag-201);
        [weakSelf removeFromSuperview];
    }];
}

- (void)setCopylink{
    self.thirdLabel.text = @"复制链接";
    self.thirdImageView.image = kImageWithName(@"btn_pop_copylink");
}

@end
