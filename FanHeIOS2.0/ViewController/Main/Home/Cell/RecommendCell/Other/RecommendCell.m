//
//  RecommendCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/2/28.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "RecommendCell.h"

@interface RecommendCell ()

@property (nonatomic, weak) IBOutlet UILabel *tagLabel;
@property (nonatomic, weak) IBOutlet UILabel *friendsLabel;
@property (nonatomic, weak) IBOutlet UILabel *friendsSubLabel;
@property (nonatomic, weak) IBOutlet UIImageView *coverImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *contentLabel;
@property (nonatomic, weak) IBOutlet UILabel *addressLabel;
@property (nonatomic, weak) IBOutlet UILabel *numberLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *friendLayoutConstraint;

//感兴趣的行业
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

//好友A认识了X个新好友
@property (nonatomic, weak) IBOutlet UIImageView *headerImageView;
@property (nonatomic, weak) IBOutlet UIImageView *vipImageView;
@property (nonatomic, weak) IBOutlet UIImageView *headerImageView1;
@property (nonatomic, weak) IBOutlet UIImageView *vipImageView1;
@property (nonatomic, weak) IBOutlet UIImageView *headerImageView2;
@property (nonatomic, weak) IBOutlet UIImageView *vipImageView2;
@property (nonatomic, weak) IBOutlet UIImageView *headerImageView3;
@property (nonatomic, weak) IBOutlet UIImageView *vipImageView3;

@property (nonatomic, strong) HomeRCMModel *model;

@end

@implementation RecommendCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateDisplay:(HomeRCMModel*)model{
    self.model = model;
    if([CommonMethod paramStringIsNull:model.image].length){
        [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KWidthImageDefault];
    }else{
        if(model.contentRow==2){
            [self.contentLabel setParagraphText:[[CommonMethod paramStringIsNull:model.content] filterHTML] lineSpace:7];
        }else{
            self.contentLabel.text = [CommonMethod paramStringIsNull:model.content];
        }
        self.contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    if(model.titleRow==2){
        [self.titleLabel setParagraphText:[CommonMethod paramStringIsNull:model.title] lineSpace:9];
    }else{
        self.titleLabel.text = [CommonMethod paramStringIsNull:model.title];
    }
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    NSString *tagStr = @"";
    if([CommonMethod paramStringIsNull:model.tag].length){
        tagStr = [model.tag stringByReplacingOccurrencesOfString:@"," withString:@"#"];
        tagStr = [NSString stringWithFormat:@"#%@# ", tagStr];
    }
    switch (model.type.integerValue) {
        case RecommendType_Topic:
            self.addressLabel.hidden = YES;
            self.numberLabel.hidden = NO;
            self.numberLabel.text = [NSString stringWithFormat:@"关注 %@   观点 %@   评论 %@", model.attentcount, model.replycount, model.reviewcount];
            self.tagLabel.text = [NSString stringWithFormat:@"%@热门话题讨论",tagStr];
            self.friendsSubLabel.text = @"等人正在参与话题讨论";
            break;
        case RecommendType_Activity:{
            self.addressLabel.hidden = NO;
            self.numberLabel.hidden = YES;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", model.address]];
                if(model.addresstype.integerValue==1){
                    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil] ;
                    textAttachment.image = [UIImage imageNamed:@"btn_cd_fh"];
                    textAttachment.bounds = CGRectMake(0, -5, 102, 20);
                    NSAttributedString *textAttachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
                    [attr appendAttributedString:textAttachmentString];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.addressLabel.attributedText = attr;
                    self.tagLabel.text = [NSString stringWithFormat:@"%@热门活动",tagStr];
                    self.friendsSubLabel.text = @"等人报名了活动";
                });
            });
        }
            break;
        case RecommendType_Post:
            self.addressLabel.hidden = YES;
            self.numberLabel.hidden = NO;
            self.numberLabel.text = [NSString stringWithFormat:@"阅读 %@   评论 %@", model.readcount, model.reviewcount];
            self.tagLabel.text = [NSString stringWithFormat:@"%@金融头条",tagStr];
            break;
            
        default:
            break;
    }
    if([CommonMethod paramArrayIsNull:model.friends].count && model.extype.integerValue==2){
        self.friendsLabel.text = [model.friends componentsJoinedByString:@"、"];
        self.friendsLabel.hidden = NO;
        self.friendsSubLabel.hidden = NO;
        self.tagLabel.text = @"";
        self.friendLayoutConstraint.constant = WIDTH-154;
//        if(model.friends.count==1){
//            self.friendsSubLabel.text = [self.friendsSubLabel.text stringByReplacingOccurrencesOfString:@"等人" withString:@""];
//        }
    }else{
        self.friendsLabel.text = @"";
        self.friendsLabel.hidden = YES;
        self.friendsSubLabel.hidden = YES;
    }
}

- (IBAction)deleteButtonClicked:(id)sender{
    if(self.deleteRecommendCell){
        self.deleteRecommendCell(self);
    }
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[CommonMethod paramNumberIsNull:self.model.type] forKey:@"type"];
    [requestDict setObject:[CommonMethod paramNumberIsNull:self.model.extype] forKey:@"extype"];
    [requestDict setObject:[CommonMethod paramNumberIsNull:self.model.contentid] forKey:@"contentid"];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [[self viewController] requstType:RequestType_Post apiName:API_NAME_POST_DYNAMIC_DELRCMD paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

- (void)updateDisplayMayInterestIndustry:(HomeRCMModel*)model{
    self.model = model;
    for(UIView *view in self.scrollView.subviews){
        [view removeFromSuperview];
    }
    for(int i=0; i<[CommonMethod paramArrayIsNull:model.rcmdIndustryModel].count; i++){
        SubjectlistModel *slmodel = model.rcmdIndustryModel[i];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(16+118*i, 0, 110, 120)];
        view.backgroundColor = HEX_COLOR(@"fafafb");
        [self.scrollView addSubview:view];
        [CALayer updateControlLayer:view.layer radius:4 borderWidth:0.5 borderColor:kCellLineColor.CGColor];
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(39, 12, 32, 32)];
        iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        [iconImageView sd_setImageWithURL:[NSURL URLWithString:slmodel.ios_icon] placeholderImage:KSquareImageDefault];
        [view addSubview:iconImageView];
        UILabel *label = [UILabel createrLabelframe:CGRectMake(0, 53, 110, 16) backColor:HEX_COLOR(@"fafafb") textColor:HEX_COLOR(@"41464e") test:slmodel.name font:14 number:1 nstextLocat:NSTextAlignmentCenter];
        [view addSubview:label];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(23, 80, 64, 28);
        [btn setBackgroundImage:kImageWithName(@"btn_bg_red") forState:UIControlStateNormal];
        btn.titleLabel.font = FONT_SYSTEM_SIZE(12);
        [btn setTitle:@"关注" forState:UIControlStateNormal];
        [btn setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
        [btn setBackgroundImage:kImageWithName(@"btn_bg_gray") forState:UIControlStateDisabled];
        [btn setTitle:@"已关注" forState:UIControlStateDisabled];
        [btn setTitleColor:HEX_COLOR(@"afb6c1") forState:UIControlStateDisabled];
        [btn addTarget:self action:@selector(attentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        btn.enabled = slmodel.isAttent.integerValue!=1;
        [view addSubview:btn];
    }
    [self.scrollView setContentSize:CGSizeMake(16+118*[CommonMethod paramArrayIsNull:model.rcmdindustry].count, 120)];
}

- (void)attentButtonClicked:(UIButton*)sender{
    sender.enabled = NO;
    SubjectlistModel *slmodel = self.model.rcmdIndustryModel[sender.tag];
    slmodel.isAttent = @(1);
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    [requestDict setObject:[CommonMethod paramStringIsNull:slmodel.name] forKey:@"industry"];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [[self viewController] requstType:RequestType_Post apiName:API_NAME_USER_POST_USER_ATTENTINDUSTRY paramDict:requestDict hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}

//好友加了几个好友
- (void)updateDisplayFAF:(HomeRCMModel*)model{
    self.model = model;
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    self.vipImageView.hidden = NO;
    self.headerImageView1.hidden = YES;
    self.vipImageView1.hidden = YES;
    self.headerImageView2.hidden = YES;
    self.vipImageView2.hidden = YES;
    self.headerImageView3.hidden = YES;
    self.vipImageView3.hidden = YES;
    self.numberLabel.text = [NSString stringWithFormat:@"认识了%@个好友", model.friendcount];
    
    NSMutableArray *infoArray = [NSMutableArray array];
    if([CommonMethod paramStringIsNull:model.realname].length){
        [infoArray addObject:model.realname];
    }
    NSString *companyStr = [NSString stringWithFormat:@"%@%@", [CommonMethod paramStringIsNull:model.company],[CommonMethod paramStringIsNull:model.position]];
    if(companyStr.length){
        [infoArray addObject:companyStr];
    }
    self.titleLabel.text = [infoArray componentsJoinedByString:@" | "];
    NSArray *array = model.hisfriends;
    if(array.count>=1){
        UserModel *model = [[UserModel alloc] initWithDict:array[0]];
        [self.headerImageView1 sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
        self.headerImageView1.hidden = NO;
        self.vipImageView1.hidden = model.usertype.integerValue!=9;
    }
    if(array.count>=2){
        UserModel *model = [[UserModel alloc] initWithDict:array[1]];
        [self.headerImageView2 sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
        self.headerImageView2.hidden = NO;
        self.vipImageView2.hidden = model.usertype.integerValue!=9;
    }
    if(array.count>=3){
        UserModel *model = [[UserModel alloc] initWithDict:array[2]];
        [self.headerImageView3 sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
        self.headerImageView3.hidden = NO;
        self.vipImageView3.hidden = model.usertype.integerValue!=9;
    }
}

@end
