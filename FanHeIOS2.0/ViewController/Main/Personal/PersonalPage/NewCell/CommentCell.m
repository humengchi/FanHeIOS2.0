//
//  CommentCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/14.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "CommentCell.h"

@interface CommentCell ()
@property (weak, nonatomic) IBOutlet UIImageView *rzImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIImageView *vipImageView;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *tagsView;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@property (nonatomic, strong) UserModel *userModel;

@end

@implementation CommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)getCellHeight:(UserModel*)model{
    CGFloat height = [NSHelper heightOfString:model.msg font:FONT_SYSTEM_SIZE(14) width:WIDTH-85];
    height += (height/FONT_SYSTEM_SIZE(14).lineHeight-1)*6;
    height += 81;
    return height;
}

- (void)updateDisplayModel:(UserModel*)model isMyHomePage:(BOOL)isMyHomePage{
    self.userModel = model;
    self.rzImageView.hidden = model.hasValidUser.integerValue != 1;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    self.vipImageView.hidden = model.othericon.integerValue != 1;
    self.companyLabel.text = model.company;
    self.nameLabel.text = model.realname;
    [self.commentLabel setParagraphText:model.msg lineSpace:6];
    self.deleteBtn.hidden = !(model.userId.integerValue==[DataModelInstance shareInstance].userModel.userId.integerValue || isMyHomePage);
    for(UIView *view in self.tagsView.subviews){
        [view removeFromSuperview];
    }
    CGFloat start_X = 0;
    if([CommonMethod paramStringIsNull:model.relation].length){
        CGFloat strWidth = [NSHelper widthOfString:model.relation font:FONT_SYSTEM_SIZE(8) height:11]+15;
        UILabel *realtionLabel = [UILabel createrLabelframe:CGRectMake(start_X, 0, strWidth, 11) backColor:WHITE_COLOR textColor:HEX_COLOR(@"818c9e") test:model.relation font:8 number:1 nstextLocat:NSTextAlignmentCenter];
        [CALayer updateControlLayer:realtionLabel.layer radius:5.5 borderWidth:0.3 borderColor:HEX_COLOR(@"818c9e").CGColor];
        [self.tagsView addSubview:realtionLabel];
        start_X += strWidth+6;
    }
    if([CommonMethod paramNumberIsNull:model.usertype].integerValue == 9){
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(start_X, 0, 31, 11)];
        iconImageView.image = kImageWithName(@"icon_zy_zf");
        [self.tagsView addSubview:iconImageView];
    }
}

- (IBAction)deleteButtonClicked:(id)sender{
    [[[CommonUIAlert alloc] init] showCommonAlertView:self.viewController title:@"" message:@"是否删除该条评论？" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
        
    } confirm:^{
        __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"删除中..." toView:self.viewController.view];
        __weak typeof(self) weakSelf = self;
        NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
        [requestDict setObject:[NSString stringWithFormat:@"/%@/%@",[DataModelInstance shareInstance].userModel.userId, self.userModel.evid] forKey:@"param"];
        [self.viewController requstType:RequestType_Delete apiName:API_NAME_DELETE_USER_EVALUATION paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
            [hud hideAnimated:YES];
            if([CommonMethod isHttpResponseSuccess:responseObject]){
                [MBProgressHUD showSuccess:@"删除成功!" toView:weakSelf.viewController.view];
                if(weakSelf.deleteComment){
                    weakSelf.deleteComment(self);
                }
            }else{
                [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.viewController.view];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
            [hud hideAnimated:YES];
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.viewController.view];
        }];
    }];
}

@end
