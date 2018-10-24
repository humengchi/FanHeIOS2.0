//
//  PositionSearch.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/16.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "PositionSearch.h"

@implementation PositionSearch
- (void)createrTagSearchViewCity:(NSArray *)cityArray tag:(NSInteger)tag{
    UIScrollView *scrooleView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 48)];
    self.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    [self addSubview:scrooleView];
    CGFloat tagHeigt = 0;
    //1 活动 2，话题
    if (tag == 1 ) {
        tagHeigt = 21;
        UIImageView *fanHeImageView = [UIImageView drawImageViewLine:CGRectMake(25, tagHeigt, 200, 28) bgColor:[UIColor clearColor]];
        fanHeImageView.image = [UIImage imageNamed:@"icon_lives_event_fh"];
        fanHeImageView.tag = 1;
        fanHeImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *fanHeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(fanHeTapAction:)];
        [fanHeImageView addGestureRecognizer:fanHeTap];
        [self addSubview:fanHeImageView];
        tagHeigt += 28;
//        tagHeigt = 21+28+12;
//        UIImageView *otherImageView = [UIImageView drawImageViewLine:CGRectMake(25, tagHeigt, 200, 28) bgColor:[UIColor clearColor]];
//        otherImageView.tag = 2;
//        otherImageView.userInteractionEnabled = YES;
//        UITapGestureRecognizer *other = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(fanHeTapAction:)];
//        [otherImageView addGestureRecognizer:other];
//        otherImageView.image = [UIImage imageNamed:@"icon_lives_event_bt"];
//        [self addSubview:otherImageView];
//        tagHeigt += 28;
    }
    if (tagHeigt == 2) {
        tagHeigt = 22;
    }
    tagHeigt = tagHeigt  + 21;
    if (cityArray.count > 0) {
        UILabel *addLabel = [UILabel createLabel:CGRectMake(25, tagHeigt, WIDTH - 50, 17) font:[UIFont systemFontOfSize:14] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"818C9E"]];
        addLabel.text = @"大家都在搜";
        [scrooleView addSubview:addLabel];
        
        CGFloat start_X = 25;
        CGFloat start_Y = tagHeigt+30;
        CGRect btnFrame = CGRectMake(0, 0, 100, 29);
        for(int i = 0; i < cityArray.count; i++){
            NSString *str = [NSString stringWithFormat:@"%@", cityArray[i]];
            CGFloat strWidth = [NSHelper widthOfString:str font:[UIFont systemFontOfSize:13] height:13]+16;
    
            if(start_X+strWidth > WIDTH-35){
                start_X = 25;
                start_Y += 41;
            }
            btnFrame.size.width = strWidth;
            btnFrame.origin.x = start_X;
            btnFrame.origin.y = start_Y;
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            [btn setTitle:str forState:UIControlStateNormal];
            btn.backgroundColor = [UIColor whiteColor];
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = 2.0;
            btn.layer.borderWidth = 0.5;
            btn.layer.borderColor = [UIColor colorWithHexString:@"AFB6C1"].CGColor;
            [btn setTitleColor:HEX_COLOR(@"41464E") forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(choseCityTagSearch:) forControlEvents:UIControlEventTouchUpInside];
            btn.frame = btnFrame;
            [scrooleView addSubview:btn];
            
            start_X = strWidth +8 + start_X;
            tagHeigt = start_Y+29+24;
        }
    }
    CGFloat start_Y = tagHeigt+32;
    scrooleView.contentSize = CGSizeMake(0, start_Y + 50);
}

- (void)choseCityTagSearch:(UIButton *)btn{
    NSString *title = btn.titleLabel.text;
    if ([self.positionSearchDelegate respondsToSelector:@selector(gotoMakeSurePositionSearch:)]) {
        [self.positionSearchDelegate gotoMakeSurePositionSearch:title];
    }
}

- (void)fanHeTapAction:(UITapGestureRecognizer *)g{
    NSInteger tag = g.view.tag;
    if ([self.positionSearchDelegate respondsToSelector:@selector(gotoAddressSearch:)]) {
        [self.positionSearchDelegate gotoAddressSearch:tag];
    }
    
}

@end
