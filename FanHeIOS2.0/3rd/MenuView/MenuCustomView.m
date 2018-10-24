//
//  MenuCustomView.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/3/6.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "MenuCustomView.h"

@interface MenuCustomView ()<UITableViewDelegate, UITableViewDataSource>{
    BOOL _isAttent;
}

@end

@implementation MenuCustomView

- (id)initWithFrame:(CGRect)frame isTop:(BOOL)isTop isAttent:(BOOL)isAttent{
    if(self=[super initWithFrame:frame]){
        _isAttent = isAttent;
        frame.origin.x = 0;
        frame.origin.y = 0;
        CGRect tableFrame = frame;
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:frame];
        [self addSubview:bgImageView];
        if(!isTop){
            bgImageView.image = kImageWithName(@"bg_pop_up");
            tableFrame.origin.y += 5;
            tableFrame.size.height -= 5;
        }else{
            bgImageView.image = kImageWithName(@"bg_pop_down");
            tableFrame.size.height -= 5;
        }
        UITableView *tableView = [[UITableView alloc] initWithFrame:tableFrame];
        tableView.backgroundColor = WHITE_COLOR;
        tableView.scrollEnabled = NO;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.layer.masksToBounds = YES;
        tableView.layer.cornerRadius = 3;
        [self addSubview:tableView];
    }
    return self;
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 51;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    NSArray *array;
    if(_isAttent){
        array = @[@{@"image":@"icon_pop_notinterest", @"title":@"不感兴趣", @"content":@"不再显示此动态"},@{@"image":@"icon_pop_report", @"title":@"举报", @"content":@"此动态涉及广告、违禁内容等"},@{@"image":@"icon_pop_notfollow", @"title":@"取消关注", @"content":@"不再关注此人"}];
    }else{
        array = @[@{@"image":@"icon_pop_notinterest", @"title":@"不感兴趣", @"content":@"不再显示此动态"},@{@"image":@"icon_pop_report", @"title":@"举报", @"content":@"此动态涉及广告、违禁内容等"},@{@"image":@"icon_pop_black", @"title":@"屏蔽此人", @"content":@"不再显示此人的动态"}];
    }
    NSDictionary *dict = array[indexPath.row];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 17, 17, 17)];
    imageView.image = kImageWithName(dict[@"image"]);
    [cell.contentView addSubview:imageView];
    
    UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(57, 12, 60, 13) backColor:nil textColor:HEX_COLOR(@"41464e") test:dict[@"title"] font:12 number:1 nstextLocat:NSTextAlignmentLeft];
    [cell.contentView addSubview:titleLabel];
    
    UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(57, 29, 150, 11) backColor:nil textColor:HEX_COLOR(@"afb6c1") test:dict[@"content"] font:10 number:1 nstextLocat:NSTextAlignmentLeft];
    [cell.contentView addSubview:contentLabel];
    
    if(indexPath.row==1){
        UILabel *lineLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5)];
        lineLabel1.backgroundColor = kCellLineColor;
        [cell.contentView addSubview:lineLabel1];
        UILabel *lineLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 50.5, self.frame.size.width, 0.5)];
        lineLabel2.backgroundColor = kCellLineColor;
        [cell.contentView addSubview:lineLabel2];
    }

    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH-75, 51)];
    bgView.backgroundColor = HEX_COLOR(@"fafafb");
    cell.selectedBackgroundView = bgView;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.menuSelectedIndex){
        self.menuSelectedIndex(indexPath.row);
    }
    [self.superview removeFromSuperview];
}


@end
