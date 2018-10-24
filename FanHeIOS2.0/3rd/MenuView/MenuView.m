//
//  MenuView.m
//  PopMenuTableView
//
//  Created by 孔繁武 on 16/8/1.
//  Copyright © 2016年 孔繁武. All rights reserved.
//

#import "MenuView.h"
#import "MenuModel.h"

@interface MenuView () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) UIView * backView;
@property (nonatomic,strong) UIView * choiceView;

@property (nonatomic,strong) NSArray * dataArray;
@property (nonatomic,strong) UIViewController * target;

@end

@implementation MenuView

- (void)setDataArray:(NSArray *)dataArray{
    
    NSMutableArray *tempMutableArr = [NSMutableArray array];
    for (NSDictionary *dict in dataArray) {
        MenuModel *model = [MenuModel MenuModelWithDict:dict];
        [tempMutableArr addObject:model];
    }
    _dataArray = tempMutableArr;
}

- (void)setUpUIWithFrame:(CGRect)frame{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT-64)];
    backView.backgroundColor = [UIColor blackColor];
    backView.alpha = 0.0;
    backView.userInteractionEnabled = YES;
    backView.tag = 5000;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [backView addGestureRecognizer:tap];
    self.backView = backView;
    
    [self addSubview:backView];
    
    self.choiceView = [[UIView alloc] initWithFrame:CGRectMake(WIDTH-frame.size.width-6, 10, frame.size.width, frame.size.height)];
    [self addSubview:self.choiceView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -7, frame.size.width, frame.size.height+7)];
    UIImage *bgImage = [UIImage imageNamed:@"menu_add_bg"];
    CGFloat top = 15; // 顶端盖高度
    CGFloat bottom = 15; // 底端盖高度
    CGFloat left = 15; // 左端盖宽度
    CGFloat right = 15; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    bgImage = [bgImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    imageView.image = bgImage;
    [self.choiceView addSubview:imageView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.rowHeight = 40;
    [CALayer updateControlLayer:self.tableView.layer radius:5 borderWidth:0 borderColor:nil];
    [self.choiceView addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    MenuModel *model = self.dataArray[indexPath.row];
    
    UILabel *titleMenLabel = [UILabel createLabel:CGRectMake(0, 0, self.tableView.frame.size.width, 40) font:[UIFont systemFontOfSize:14] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"41464E"]];
    titleMenLabel.text = model.itemName;
    titleMenLabel.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:titleMenLabel];
    
    if([CommonMethod paramStringIsNull:model.imageName].length){
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 11, 17, 17)];
        imageView.image = kImageWithName(model.imageName);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.contentView addSubview:imageView];
        titleMenLabel.textAlignment = NSTextAlignmentLeft;
        titleMenLabel.frame = CGRectMake(42, 0, self.tableView.frame.size.width-58, 40);
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(16, 39.5, self.tableView.frame.size.width-32, 0.5)];
    lineView.backgroundColor = kCellLineColor;
    [cell.contentView addSubview:lineView];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self showMenuWithAnimation:NO];
    MenuModel *model = self.dataArray[indexPath.row];
    if (self.itemsClickBlock) {
        self.itemsClickBlock(model.itemName,indexPath.row);
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)showMenuWithAnimation:(BOOL)isShow{
    [UIView animateWithDuration:0.25 animations:^{
        if (isShow) {
            self.alpha = 1;
            self.backView.alpha = 0.5;
            self.choiceView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }else{
            self.alpha = 0;
            self.backView.alpha = 0;
            self.choiceView.transform = CGAffineTransformMakeScale(0.01, 0.01);
        }
    } completion:^(BOOL finished) {
        if (!isShow) {
            [self.backView removeFromSuperview];
            [self removeFromSuperview];
        }
    }];
}

- (void)tap:(UITapGestureRecognizer *)sender{
    [self showMenuWithAnimation:NO];
    if (self.backViewTapBlock) {
        self.backViewTapBlock();
    }
}


+ (MenuView *)createMenuWithFrame:(CGRect)frame target:(UIViewController *)target dataArray:(NSArray *)dataArray itemsClickBlock:(void (^)(NSString *, NSInteger))itemsClickBlock backViewTap:(void (^)())backViewTapBlock{
    
    MenuView *menuView = [[MenuView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    menuView.target = target;
    menuView.dataArray = dataArray;
    menuView.itemsClickBlock = itemsClickBlock;
    menuView.backViewTapBlock = backViewTapBlock;
    [menuView setUpUIWithFrame:frame];
    menuView.choiceView.layer.anchorPoint = CGPointMake(1, 0);
    menuView.choiceView.layer.position = CGPointMake(WIDTH-6, 10);
    menuView.choiceView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [[UIApplication sharedApplication].keyWindow addSubview:menuView];
    return menuView;
}

@end











