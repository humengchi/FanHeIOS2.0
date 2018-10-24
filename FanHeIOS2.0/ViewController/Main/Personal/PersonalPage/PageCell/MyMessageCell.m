//
//  MyMessageCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/3.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "MyMessageCell.h"

@implementation MyMessageCell

- (void)tranferMyMessageTaMessageModel:(TaMessageModel*)model{
    
    NSString *positionStr = [NSString stringWithFormat:@"%@%@",model.company,model.position];
    if (positionStr.length <= 0) {
        positionStr = @"请尽快编辑你的职位信息";
        self.positionLabel.textColor = [UIColor colorWithHexString:@"E6E8EB"];
    }
    CGFloat positioheigth = [NSHelper heightOfString:positionStr font:[UIFont systemFontOfSize:17] width:WIDTH - 56];
    CGRect positioFrame = self.positionLabel.frame;
    positioFrame.size.height = positioheigth;
    self.positionLabel.frame = positioFrame;
    self.positionLabel.text = positionStr;
    
    NSString *nameStr = model.realname;
    if (model.realname.length > 5) {
        nameStr = [NSString stringWithFormat:@"%@...",[model.realname substringToIndex:5]];
    }
    if (model.city.length > 0) {
        nameStr = [NSString stringWithFormat:@"%@ | %@ ",nameStr,model.city];
    }
    if (model.workyearstr.length > 0) {
        nameStr = [NSString stringWithFormat:@"%@ | %@",nameStr,model.workyearstr];
    }
    //加V
    if (model.usertype.integerValue == 9) {
        // 创建一个富文本
        NSMutableAttributedString * attriStr = [[NSMutableAttributedString alloc] initWithString:nameStr];
        /**
         添加图片到指定的位置
         */
        NSTextAttachment *attchImage = [[NSTextAttachment alloc] init];
        // 表情图片
        attchImage.image = [UIImage imageNamed:@"btn_zy_v"];
        // 设置图片大小
        attchImage.bounds = CGRectMake(2, -2, 16, 16);
        NSAttributedString *stringImage = [NSAttributedString attributedStringWithAttachment:attchImage];
        if (model.realname.length > 5) {
            NSString *str = [NSString stringWithFormat:@"%@...",[model.realname substringToIndex:5]];
            [attriStr insertAttributedString:stringImage atIndex:str.length];
        }else{
            [attriStr insertAttributedString:stringImage atIndex:model.realname.length];
        }
        self.nameLabel.attributedText = attriStr;
    }else{
        self.nameLabel.text = nameStr;
    }
    
    if (model.isMyHomePage) {
        NSString *str;
        if (model.mystate.length > 0) {
            str = [NSString stringWithFormat:@"%@ ",model.mystate];
            CGFloat positioheigth = [NSHelper heightOfString:model.mystate font:[UIFont systemFontOfSize:14] width:WIDTH - 66];
            CGRect positioFrame = self.signLabel.frame;
            positioFrame.size.height = positioheigth;
            self.signLabel.frame = positioFrame;
            self.signLabel.textColor = [UIColor colorWithHexString:@"41464E"];
        }else{
            str = @"点击编辑签名 ";
            CGFloat positioheigth = [NSHelper heightOfString:str font:[UIFont systemFontOfSize:14] width:WIDTH - 66];
            CGRect positioFrame = self.signLabel.frame;
            positioFrame.size.height = positioheigth;
            self.signLabel.frame = positioFrame;
           
        }
        // 创建一个富文本
        NSMutableAttributedString * attriStr1 = [[NSMutableAttributedString alloc] initWithString:str];
        /**
         添加图片到指定的位置
         */
        NSTextAttachment *attchImage = [[NSTextAttachment alloc] init];
        // 表情图片
        attchImage.image = [UIImage imageNamed:@"btn_zy_bjs"];
        // 设置图片大小
        attchImage.bounds = CGRectMake(0, 0, 10, 10);
        NSAttributedString *stringImage = [NSAttributedString attributedStringWithAttachment:attchImage];
        [attriStr1 insertAttributedString:stringImage atIndex:str.length];
        self.signLabel.attributedText = attriStr1;
        
    }else{
        if (model.mystate.length > 0) {
            CGFloat positioheigth = [NSHelper heightOfString:model.mystate font:[UIFont systemFontOfSize:14] width:WIDTH - 56];
            CGRect positioFrame = self.signLabel.frame;
            positioFrame.size.height = positioheigth;
            self.signLabel.frame = positioFrame;
            self.signLabel.textColor = [UIColor colorWithHexString:@"41464E"];
            self.signLabel.text = model.mystate;
        }
    }
    if(!model.isMyHomePage){
        if (model.hasValidUser.integerValue != 1) {
            self.cardCertificationImage.image = [UIImage imageNamed:@"btn_zy_wrz"];
        }else{
            self.cardCertificationImage.image = [UIImage imageNamed:@"btn_zy_yrz"];
        }
    }else{
        UserModel *tmpModel = [DataModelInstance shareInstance].userModel;
        tmpModel.hasValidUser = model.hasValidUser;
        [DataModelInstance shareInstance].userModel = tmpModel;
        if (model.hasValidUser.integerValue == 0) {
            self.cardCertificationImage.image = [UIImage imageNamed:@"btn_zy_wrz"];
        }else if (model.hasValidUser.integerValue == 1) {
            self.cardCertificationImage.image = [UIImage imageNamed:@"btn_zy_yrz"];
        }else if (model.hasValidUser.integerValue == 2) {
            self.cardCertificationImage.image = [UIImage imageNamed:@"btn_zy_wrz"];
        }else if (model.hasValidUser.integerValue == 3) {
            self.cardCertificationImage.image = [UIImage imageNamed:@"btn_zy_rzsb"];
        }
    }
    UITapGestureRecognizer *vaildUser = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(vaildUserAction)];
    self.cardCertificationImage.userInteractionEnabled = YES;
       UITapGestureRecognizer *myStart = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mySingAction)];
    self.signLabel.userInteractionEnabled = YES;
    if (model.isMyHomePage) {
        [self.cardCertificationImage addGestureRecognizer:vaildUser];
        [self.signLabel addGestureRecognizer:myStart];
    }

    
}
- (void)mySingAction{
    if([self.attestationDelegate respondsToSelector:@selector(mySingActionChange)]){
        [self.attestationDelegate mySingActionChange];
    }
}

- (void)vaildUserAction{
    if([self.attestationDelegate respondsToSelector:@selector(attestationIdentityMessage)]){
        [self.attestationDelegate attestationIdentityMessage];
    }
}

+ (CGFloat)backHeigthTaMessageModel:(TaMessageModel*)model{
    NSString *nameStr = model.realname;
    if (model.realname.length > 5) {
        nameStr = [NSString stringWithFormat:@"%@...",[model.realname substringToIndex:5]];
    }
    if (model.city.length > 0) {
        nameStr = [NSString stringWithFormat:@"%@ | %@ ",nameStr,model.city];
    }
    if (model.workyearstr.length > 0) {
        nameStr = [NSString stringWithFormat:@"%@ | %@",nameStr,model.workyearstr];
    }

    CGFloat heigth = [NSHelper heightOfString:nameStr font:[UIFont systemFontOfSize:17] width:WIDTH - 56];
    
    //加V
    if (model.usertype.integerValue == 9) {
        heigth = [NSHelper heightOfString:nameStr font:[UIFont systemFontOfSize:17] width:WIDTH - 62-14];
    }
    
    NSString *positionStr = [NSString stringWithFormat:@"%@%@",model.company,model.position];
    CGFloat positioheigth = [NSHelper heightOfString:positionStr font:[UIFont systemFontOfSize:17] width:WIDTH - 56];
    
    CGFloat signheigth = 17;
    if (model.mystate.length > 0) {
     signheigth = [NSHelper heightOfString:model.mystate font:[UIFont systemFontOfSize:14] width:WIDTH - 56];
    }
    
    return signheigth + positioheigth + heigth + 80;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
