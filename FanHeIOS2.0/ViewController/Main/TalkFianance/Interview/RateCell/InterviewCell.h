//
//  InterviewCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/19.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InterviewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *ReadCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *CoverImageVIew;
@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *RateCountLabel;
+ (CGFloat)tableFrameInterviewCellHeigthContactsModel:(TalkFianaceModel *)fianaceModel;
- (void)tranferInterviewCellFianaceModel:(TalkFianaceModel *)fianaceModel;
@end
