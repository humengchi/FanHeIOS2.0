//
//  TouTiaoRecomView.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/8/23.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "TouTiaoRecomView.h"
#import "TouTiaoViewController.h"

@interface TouTiaoRecomView ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation TouTiaoRecomView

- (void)updateDispaly:(TalkFianaceModel *)model{
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KWidthImageDefault];
    if([NSHelper heightOfString:model.title font:FONT_SYSTEM_SIZE(16) width:WIDTH-165] > FONT_SYSTEM_SIZE(16).lineHeight){
        [self.titleLabel setParagraphText:model.title lineSpace:9];
    }else{
        self.titleLabel.text = model.title;
    }
}

- (IBAction)buttonClicked:(id)sender{
    TouTiaoViewController *vc = [[TouTiaoViewController alloc] init];
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

@end
