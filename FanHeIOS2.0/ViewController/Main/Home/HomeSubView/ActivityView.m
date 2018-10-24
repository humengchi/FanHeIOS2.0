//
//  ActivityView.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/10/28.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ActivityView.h"
#import "ActivityDetailController.h"

@interface ActivityView ()

@property (nonatomic, weak) IBOutlet UIScrollView   *scrollView;
@property (nonatomic, weak) IBOutlet UIImageView   *postImageView;
@property (nonatomic, weak) IBOutlet UIImageView   *nextArrowImageView;
@property (nonatomic, weak) IBOutlet UILabel   *companyLabel;
@property (nonatomic, weak) IBOutlet UILabel   *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel   *timeLabel;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ActivityView

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (void)updateDisplayArray:(NSMutableArray *)array{
    self.dataArray = array;
    for(int i=0; i<array.count; i++){
        ActivityModel *model = array[i];
        if(i==0){
            self.postImageView.tag = 200;
            [CommonMethod viewAddGuestureRecognizer:self.postImageView tapsNumber:1 withTarget:self withSEL:@selector(gotoDetail:)];
            self.nameLabel.tag = 200;
            [CommonMethod viewAddGuestureRecognizer:self.nameLabel tapsNumber:1 withTarget:self withSEL:@selector(gotoDetail:)];
            self.companyLabel.tag = 200;
            [CommonMethod viewAddGuestureRecognizer:self.companyLabel tapsNumber:1 withTarget:self withSEL:@selector(gotoDetail:)];
            self.timeLabel.text = model.starttime;
            [self.postImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KWidthImageDefault];
            self.nameLabel.text = model.name;
            self.companyLabel.text = model.organizer;
            self.nextArrowImageView.hidden = YES;
        }else{
            self.nextArrowImageView.hidden = NO;
            UIView *postView = [[UIView alloc] initWithFrame:CGRectMake(0, (i-1)*66, WIDTH-25, 66)];
            postView.backgroundColor = WHITE_COLOR;
            postView.tag = i+200;
            [self.scrollView addSubview:postView];
            [CommonMethod viewAddGuestureRecognizer:postView tapsNumber:1 withTarget:self withSEL:@selector(gotoDetail:)];
            
            UIImageView *timeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 18, 32, 32)];
            timeImageView.image = kImageWithName(@"icon_index_rl");
            [postView addSubview:timeImageView];
            UILabel *monthLabel = [UILabel createrLabelframe:CGRectMake(0, 0, 32, 13) backColor:[UIColor clearColor] textColor:WHITE_COLOR test:[NSString stringWithFormat:@"%@月",model.startmonth] font:7 number:1 nstextLocat:NSTextAlignmentCenter];
            [timeImageView addSubview:monthLabel];
            UILabel *dayLabel = [UILabel createrLabelframe:CGRectMake(0, 14, 32, 18) backColor:[UIColor clearColor] textColor:HEX_COLOR(@"41464E") test:[NSString stringWithFormat:@"%@日",model.startday]  font:11 number:1 nstextLocat:NSTextAlignmentCenter];
            dayLabel.font = FONT_BOLD_SYSTEM_SIZE(11);
            [timeImageView addSubview:dayLabel];
            UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(55, 25, WIDTH-88, 21) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464E") test:model.name font:14 number:1 nstextLocat:NSTextAlignmentLeft];
            [postView addSubview:titleLabel];
        }
    }
    self.scrollView.contentSize = CGSizeMake(WIDTH-25, 66*(array.count-1));
    if(array.count>1){
        self.scrollView.hidden = NO;
        [self startTimer];
    }else{
        self.scrollView.hidden = YES;
    }
}

- (void)startTimer{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(timerSelector) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)timerSelector{
    NSInteger currentPage = self.scrollView.contentOffset.y/66;
    NSInteger allPage = self.scrollView.contentSize.height/66;
    if(currentPage == allPage-1){
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    }else{
        [self.scrollView setContentOffset:CGPointMake(0, 66*((currentPage+1)%allPage)) animated:YES];
    }
}

#pragma mark - web详情界面
- (void)gotoDetail:(UITapGestureRecognizer*)tap{
    ActivityModel *model = self.dataArray[tap.view.tag-200];
    ActivityDetailController *vc = [[ActivityDetailController alloc] init];
    vc.activityid = model.activityid;
    [[self viewController].navigationController pushViewController:vc animated:YES];

}

@end
