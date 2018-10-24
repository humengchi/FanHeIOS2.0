//
//  NewUserNoticeView.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/10/28.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "NewUserNoticeView.h"
#import "NewFriendsController.h"
#import "VistorsListViewController.h"

@interface NewUserNoticeView ()

@property (nonatomic, strong) HomeDataModel *model;

@property (nonatomic, assign) NewUserNoticeViewType type;

@end

@implementation NewUserNoticeView

- (id)initWithFrame:(CGRect)frame model:(HomeDataModel*)model{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = WHITE_COLOR;
        self.model = model;
        [CommonMethod viewAddGuestureRecognizer:self tapsNumber:1 withTarget:self withSEL:@selector(clickedView)];
        [self creatSubView];
    }
    return self;
}

- (void)creatSubView{
    CGRect frame = self.frame;
    NSMutableArray *array = [NSMutableArray array];
    if(self.model.hopeme.count){
        self.type = NewUserNoticeViewType_NewApplyFriend;
        array = self.model.hopeme;
    }else if(self.model.seeme.count){
        self.type = NewUserNoticeViewType_NewVisitor;
        array = self.model.seeme;
    }else{
        self.type = NewUserNoticeViewType_None;
        if(self.newUserNoticeViewRemoveView){
            self.newUserNoticeViewRemoveView();
        }
        return;
    }
    for(UIView *view in self.subviews){
        [view removeFromSuperview];
    }
    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-25, (frame.size.height-15)/2, 9, 15)];
    arrowImageView.image = kImageWithName(@"icon_next_gray");
    [self addSubview:arrowImageView];
    
    CGFloat start_x = 16;
    for(int i=0; i<array.count; i++){
        start_x = 16+i*27;
        if(i==2){
            UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(start_x, (frame.size.height-34)/2, 34, 34)];
            headImageView.image = kImageWithName(@"icon_index_rmgd");
            [CALayer updateControlLayer:headImageView.layer radius:17 borderWidth:1 borderColor:WHITE_COLOR.CGColor];
            [self addSubview:headImageView];
            break;
        }else{
            UserModel *model = array[i];
            UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(start_x, (frame.size.height-34)/2, 34, 34)];
            [headImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:KHeadImageDefaultName(model.realname)];
            [CALayer updateControlLayer:headImageView.layer radius:17 borderWidth:1 borderColor:WHITE_COLOR.CGColor];
            [self addSubview:headImageView];
        }
    }
    NSString *titleStr;
    if(self.type == NewUserNoticeViewType_NewVisitor){
        if(array.count > 1){
            titleStr = [NSString stringWithFormat:@"%ld个新朋友看过我", (unsigned long)array.count];
        }else{
            UserModel *model = array[0];
            titleStr = [NSString stringWithFormat:@"%@看过我", [CommonMethod paramStringIsNull:model.realname]];
        }
    }else{
        titleStr = [NSString stringWithFormat:@"%ld个新朋友希望认识我", (unsigned long)array.count];
    }
    UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(42+start_x, 0, WIDTH-25-start_x-42, frame.size.height) backColor:WHITE_COLOR textColor:HEX_COLOR(@"AFB6C1") test:titleStr font:14 number:1 nstextLocat:NSTextAlignmentLeft];
    [self addSubview:titleLabel];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, WIDTH-32, 0.3)];
    lineLabel.backgroundColor = kCellLineColor;
    [self addSubview:lineLabel];
}

#pragma mark - 点击视图
- (void)clickedView{
    if(self.type == NewUserNoticeViewType_NewApplyFriend){
        NewFriendsController *vc = [[NewFriendsController alloc] init];
        [[self viewController].navigationController pushViewController:vc animated:YES];
        [self.model.hopeme removeAllObjects];
        [self creatSubView];
    }else if(self.type == NewUserNoticeViewType_NewVisitor){
//        if(self.model.seeme.count == 1){
//            UserModel *model = self.model.seeme[0];
//            MyHomepageController *vc = [[MyHomepageController alloc] init];
//            vc.userID = model.userId;
//            [[self viewController].navigationController pushViewController:vc animated:YES];
//        }else{
            VistorsListViewController *vc = [[VistorsListViewController alloc] init];
            [[self viewController].navigationController pushViewController:vc animated:YES];
//        }
        [self.model.seeme removeAllObjects];
        [self creatSubView];
    }else{//NewUserNoticeViewType_None
        
    }
}

@end
