//
//  ActivityAboutreadCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/10.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ActivityAboutreadCellDelegate <NSObject>

- (void)likeTapActionBtn;
- (void)searchTagActovity:(NSInteger)index;

@end

@interface ActivityAboutreadCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *activityPushView;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIImageView *covewImageView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewTimeLabel;
@property (nonatomic,strong)FinanaceDetailModel *model;
@property (nonatomic ,weak) id<ActivityAboutreadCellDelegate>activityAboutreadCellDelegate;
- (void)tranferActivityAboutreadCellModel:(FinanaceDetailModel *)model;
@end
