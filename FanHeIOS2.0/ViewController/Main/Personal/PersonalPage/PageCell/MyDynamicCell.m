//
//  MyDynamicCell.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/3/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "MyDynamicCell.h"

#import "ContentView.h"
#import "DynamicImageView.h"
#import "CommentsView.h"
#import "CreateTAAView.h"
#import "ShareDynamicView.h"
#import "MyDynamicView.h"
#import "CheckMoreDynamic.h"
@implementation MyDynamicCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (id)initWithDataDict:(DynamicModel*)model isHome:(BOOL)isHome{
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DynamicCell"]){
        
        [self createView_13_12:model isHome:isHome];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)createView_13_12:(DynamicModel*)model isHome:(BOOL)isHome {
    CGFloat start_Y = 0;
    
    MyDynamicView *headerView = [CommonMethod getViewFromNib:@"MyDynamicView"];
    headerView.frame = CGRectMake(0, 0, WIDTH, 50);
    [headerView updateDisplay:isHome];
    [self addSubview:headerView];
    start_Y += 50;
    
    if(model.contentHeight){
        ContentView *contentView = [CommonMethod getViewFromNib:@"ContentView"];
        contentView.frame = CGRectMake(16, start_Y, WIDTH-32, model.contentHeight);
        [contentView updateDisplay:model.content isShare:NO dynamicId:@(0) dynamicModel:model];
        [self addSubview:contentView];
        start_Y += model.contentHeight+3;
    }
    if(model.imageHeight){
        NSArray *imageArray = [[CommonMethod paramStringIsNull:model.image] componentsSeparatedByString:@","];
        DynamicImageView *dynamicImageView = [[DynamicImageView alloc] initWithFrame:CGRectMake(16, start_Y,  WIDTH-80, model.imageHeight) imageArray:imageArray model:model isShare:NO];
        dynamicImageView.backgroundColor = WHITE_COLOR;
        [self addSubview:dynamicImageView];
        start_Y += model.imageHeight+12;
    }
    if([CommonMethod paramNumberIsNull:model.parent_status].integerValue>=4){
        UILabel *deleteLabel = [UILabel createrLabelframe:CGRectMake(16, start_Y, WIDTH-32, 46) backColor:HEX_COLOR(@"f8f8fa") textColor:HEX_COLOR(@"818c9e") test:@"   抱歉，分享内容已被删除" font:14 number:1 nstextLocat:NSTextAlignmentLeft];
        [self addSubview:deleteLabel];
        start_Y += 58;
    }

    if(model.shareViewOnlyHeight){
        CreateTAAView *createTAAView = [CommonMethod getViewFromNib:@"CreateTAAView"];
        createTAAView.frame = CGRectMake(16, start_Y, WIDTH-32, 60);
        [createTAAView updateDisplay:model];
        [self addSubview:createTAAView];
        start_Y += model.shareViewOnlyHeight;
    }
    
    if(model.shareViewHeight){
        ShareDynamicView *shareDynamicView = [[ShareDynamicView alloc] initWithFrame:CGRectMake(0, start_Y, WIDTH, model.shareViewHeight) model:model];
        [self addSubview:shareDynamicView];
        start_Y += model.shareViewHeight+12;
    }
    
    CheckMoreDynamic * checkView = [CommonMethod getViewFromNib:@"CheckMoreDynamic"];
    checkView.frame = CGRectMake(0, start_Y, WIDTH, 50);
    [self addSubview:checkView];

}

@end
