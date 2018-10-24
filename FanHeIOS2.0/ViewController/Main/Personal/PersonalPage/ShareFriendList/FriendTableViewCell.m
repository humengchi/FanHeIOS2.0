//
//  FriendTableViewCell.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/18.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "FriendTableViewCell.h"

@interface FriendTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *headerImageVIew;
@property (weak, nonatomic) IBOutlet UIImageView *vipImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel2;

@end

@implementation FriendTableViewCell

- (void)updateDisplyGetCoffee:(MyGetCoffeeModel*)model{
    [self.headerImageVIew sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    NSString *companyStr = [NSString stringWithFormat:@"%@%@", [CommonMethod paramStringIsNull:model.company], [CommonMethod paramStringIsNull:model.position]];
    NSArray *array = @[[CommonMethod paramStringIsNull:model.realname], [CommonMethod paramStringIsNull:model.city], [CommonMethod paramStringIsNull:model.workyearstr]];
    NSString *nameStr = [array componentsJoinedByString:@"｜"];
    if(companyStr.length){
        self.nameLabel.hidden = NO;
        self.companyLabel.hidden = NO;
        self.nameLabel2.hidden = YES;
        self.nameLabel.text = companyStr;
        self.companyLabel.text = nameStr;
    }else{
        self.nameLabel.hidden = YES;
        self.companyLabel.hidden = YES;
        self.nameLabel2.hidden = NO;
        self.nameLabel2.text = nameStr;
    }
}

- (void)updateDisplay:(ChartModel*)model{
    [self.headerImageVIew sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    if(model.company.length){
        self.nameLabel.hidden = NO;
        self.companyLabel.hidden = NO;
        self.nameLabel2.hidden = YES;
        self.nameLabel.text = model.realname;
        self.companyLabel.text = [NSString stringWithFormat:@"%@%@",model.company,[CommonMethod paramStringIsNull:model.position]];
    }else{
        self.nameLabel.hidden = YES;
        self.companyLabel.hidden = YES;
        self.nameLabel2.hidden = NO;
        self.nameLabel2.text = model.realname;
    }
    self.vipImageView.hidden = model.usertype.integerValue != 9;
}

- (void)updateDisplayOnlyName:(ChartModel*)model{
    self.nameLabel.hidden = YES;
    self.companyLabel.hidden = YES;
    self.nameLabel2.hidden = NO;
    [self.headerImageVIew sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
    self.nameLabel2.text = model.realname;
    self.vipImageView.hidden = model.usertype.integerValue != 9;
}

- (void)updateDisplayGroup:(EMGroup *)group{
    self.nameLabel.hidden = YES;
    self.companyLabel.hidden = YES;
    self.nameLabel2.hidden = NO;
    self.nameLabel2.text = group.subject;
    self.vipImageView.hidden = YES;
    UIImage *localImage = [UIImage imageWithContentsOfFile:SAVE_GROUP_HEADER_IMAGE(group.groupId)];
    if(localImage){
        self.headerImageVIew.image = localImage;
    }else{
        [self checkFriendsNameAndHeader:group];
    }
}

- (void)checkFriendsNameAndHeader:(EMGroup *)group{
    NSArray *array = [CommonMethod paramArrayIsNull:group.occupants];
    if (array.count==0) {
        return;
    }
    [(BaseViewController*)self.viewController updateGroupUsersDB:group occupants:group.occupants handler:^(BOOL result, NSMutableArray *dataArray) {
        if(result){
            UIImage *localImage = [UIImage imageWithContentsOfFile:SAVE_GROUP_HEADER_IMAGE(group.groupId)];
            if(localImage){
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.headerImageVIew.image = localImage;
                });
            }else{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *image = [UIImage createImageWithUserModelArray:dataArray];
                    NSData *imageData = UIImagePNGRepresentation(image);
                    [imageData writeToFile:SAVE_GROUP_HEADER_IMAGE(group.groupId) atomically:YES];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.headerImageVIew.image = image;
                    });
                });
            }
        }
    }];
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
