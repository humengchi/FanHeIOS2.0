//
//  NewWorkHistoryCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/14.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "NewWorkHistoryCell.h"
#import "CompanyViewController.h"

@interface NewWorkHistoryCell ()
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;

@property (weak, nonatomic) IBOutlet UILabel *workYearLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UIView *rzView;

@property (nonatomic, strong) workHistryModel *model;
@end

@implementation NewWorkHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (CGFloat)getCellHeight:(workHistryModel*)model{
    CGFloat height = [NSHelper heightOfString:[model.jobintro stringByReplacingOccurrencesOfString:@"\n" withString:@""] font:FONT_SYSTEM_SIZE(14) width:WIDTH-32 defaultHeight:FONT_SYSTEM_SIZE(14).lineHeight];
    if(height > FONT_SYSTEM_SIZE(14).lineHeight*3){
        height = FONT_SYSTEM_SIZE(14).lineHeight*3;
    }
    height += (height/FONT_SYSTEM_SIZE(14).lineHeight-1)*7;
    if(model.attestationlist.count){
        height += 43;
    }
    height += 81;
    return height;
}

- (void)updateDisplayModel:(workHistryModel*)model{
    self.model = model;
    [self.logoImageView sd_setImageWithURL:[NSURL URLWithString:[CommonMethod paramStringIsNull:model.logo]] placeholderImage:kImageWithName(@"icon_work_company")];
    self.companyLabel.text = model.company;
    self.positionLabel.text = model.position;
    self.workYearLabel.text = [NSString stringWithFormat:@"%@-%@", model.begintime, model.endtime];
    
    model.jobintro = [CommonMethod paramStringIsNull:model.jobintro].length?model.jobintro:@"描述";
    CGFloat height = [NSHelper heightOfString:[model.jobintro stringByReplacingOccurrencesOfString:@"\n" withString:@""] font:FONT_SYSTEM_SIZE(14) width:WIDTH-32 defaultHeight:FONT_SYSTEM_SIZE(14).lineHeight];
    if(height>FONT_SYSTEM_SIZE(14).lineHeight){
        [self.introLabel setParagraphText:[model.jobintro stringByReplacingOccurrencesOfString:@"\n" withString:@""] lineSpace:7];
    }else{
        self.introLabel.text = [model.jobintro stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    self.rzView.hidden = model.attestationlist.count==0;
    for(UIView *view in self.rzView.subviews){
        [view removeFromSuperview];
    }
    if(model.attestationlist.count){
        NSString *str = [NSString stringWithFormat:@"%@人为Ta认证", model.attestationtotal];
        CGFloat strWidth = [NSHelper widthOfString:str font:FONT_SYSTEM_SIZE(14) height:50];
        CGFloat start_X = 0;
        for (int i=0; i < model.attestationlist.count+1; i++) {
            if(WIDTH-40-strWidth<27*(i+1)+7){
                break;
            }
            start_X = 27*i;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(start_X, 0, 34, 34)];
            if(i==0){
                imageView.image = kImageWithName(@"icon_work_rz");
            }else{
                UserModel *userModel = [[UserModel alloc] initWithDict:model.attestationlist[i-1]];
                if(WIDTH-40-strWidth<27*(i+2)+7){
                    imageView.image = kImageWithName(@"icon_index_rmgd");
                }else{
                    [imageView sd_setImageWithURL:[NSURL URLWithString:userModel.image] placeholderImage:KHeadImageDefaultName(userModel.realname)];
                }
            }
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [self.rzView addSubview:imageView];
            [CALayer updateControlLayer:imageView.layer radius:17 borderWidth:1 borderColor:WHITE_COLOR.CGColor];
        }
        UILabel *numLabel = [UILabel createrLabelframe:CGRectMake(start_X+34+10, 0, strWidth, 34) backColor:WHITE_COLOR textColor:HEX_COLOR(@"AFB6C1") test:str font:14 number:1 nstextLocat:NSTextAlignmentRight];
        [self.rzView addSubview:numLabel];
    }
}

- (IBAction)gotoCompanyDetail:(UITapGestureRecognizer*)tap{
    CompanyViewController *vc = [[CompanyViewController alloc] init];
    vc.companyId = self.model.companyid;
    vc.company = self.model.company;
    [[self viewController].navigationController pushViewController:vc animated:YES];
}

@end
