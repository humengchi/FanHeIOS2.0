//
//  AdvertisementViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2016/11/11.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "AdvertisementView.h"
#import "AdvertDetailViewController.h"
#import "ActivityDetailController.h"

@interface AdvertisementView (){
    NSInteger _second;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton    *clickedBtn;
@property (nonatomic, strong) NSTimer   *timer;

@end

@implementation AdvertisementView

- (void)awakeFromNib{
    [super awakeFromNib];
    _second = 5;
    [CALayer updateControlLayer:self.clickedBtn.layer radius:5 borderWidth:0 borderColor:nil];
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_ADVERTISEMENT_DATA];
    NSString *imageUrl = [CommonMethod paramStringIsNull:dict[@"image"]];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:KBlankImageDefault];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerRunLoop) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [CommonMethod viewAddGuestureRecognizer:self.imageView tapsNumber:1 withTarget:self withSEL:@selector(gotoAdvertDetail)];
}

- (void)gotoAdvertDetail{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_ADVERTISEMENT_DATA];
    NSString *url = [CommonMethod paramStringIsNull:dict[@"url"]];
    NSNumber *type = dict[@"type"];
    if (type.integerValue == 0 ) {
        if(url.length > 0){
            [self.timer invalidate];
            [UIView setAnimationsEnabled:YES];
            AdvertDetailViewController *vc = [[AdvertDetailViewController alloc] init];
            vc.url = url;
            [[self viewController].navigationController pushViewController:vc animated:YES];
            [self removeFromSuperview];
        }
    }else if (type.integerValue == 2 ) {
        if(url.length > 0){
            [self.timer invalidate];
            [UIView setAnimationsEnabled:YES];
            if([url hasPrefix:FristAdURL]){
                NSString *activityID = [url substringFromIndex:[FristAdURL length]];
                
                NSNumber *activityNumBerID = [NSNumber numberWithInteger:activityID.integerValue];
                ActivityDetailController *activityDetail = [[ActivityDetailController alloc]init];
               
                activityDetail.activityid = activityNumBerID;
                
                [[self viewController].navigationController pushViewController:activityDetail animated:YES];
                [self removeFromSuperview];
            }
        }
    }

}

- (void)timerRunLoop{
    _second--;
    if(_second==0){
        self.clickedBtn.userInteractionEnabled = NO;
        [self gotoMainVC:nil];
    }else{
        [UIView setAnimationsEnabled:NO];
        [self.clickedBtn setTitle:[NSString stringWithFormat:@"跳过 %ld", (long)_second] forState:UIControlStateNormal];
    }
}

#pragma mark-跳过
- (IBAction)gotoMainVC:(id)sender{
    [self.timer invalidate];
    [UIView setAnimationsEnabled:YES];
    [UIView animateWithDuration:1 animations:^{
        self.imageView.frame = CGRectMake(0, 0, WIDTH*1.5, HEIGHT*1.5);
        self.imageView.center = self.center;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
