//
//  FianaceCell.h
//  FanHeIOS2.0
//
//  Created by renhao on 2016/12/15.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FianaceCellDelegate <NSObject>

- (void)gotoIntviewProgramme;

@end
@interface FianaceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *intviewCoverImageView;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendActionBtn;
@property (nonatomic ,weak) id<FianaceCellDelegate>fianaceCellDelegate;
- (void)tranferFianaceCell;
@end
