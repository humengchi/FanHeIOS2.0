//
//  TagSearchView.m
//  FanHeIOS2.0
//
//  Created by renhao on 2017/1/9.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "TagSearchView.h"

@interface TagSearchView ()
//时间
@property (nonatomic ,assign) NSInteger col;
//费用
@property (nonatomic ,assign) NSInteger row;
@property (nonatomic, strong) UIButton *sureBtn;
@property (nonatomic ,strong) NSMutableArray *timeArray;
@property (nonatomic ,strong) NSMutableArray *moneyArray;


@end

@implementation TagSearchView

- (void)createrTagSearchViewCity:(NSArray *)cityArray tagArray:(NSArray *)tagArray{
    self.timeArray = [NSMutableArray new];
    self.moneyArray = [NSMutableArray new];
    UserModel *model = [DataModelInstance shareInstance].userModel;
    self.timeArray = [NSMutableArray arrayWithArray:model.cityData];
    self.moneyArray = [NSMutableArray arrayWithArray:model.tagData];
    UIScrollView *scrooleView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 48)];
    scrooleView.scrollEnabled = NO;
    [self addSubview:scrooleView];
    self.backgroundColor = [UIColor whiteColor];
     CGFloat wideth = (WIDTH - 32 - 33)/4;
    if (cityArray.count > 0) {
        UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 32)];
        backView.backgroundColor = [UIColor colorWithHexString:@"F5F5F7"];
        UIButton *addBtn = [NSHelper createButton:CGRectMake(16, 8, 36,14) title:@"时间" unSelectImage:nil selectImage:nil target:self selector:nil];
         addBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [addBtn setTitleColor:[UIColor colorWithHexString:@"818C9E"] forState:UIControlStateNormal];
          [backView addSubview:addBtn];
        [scrooleView addSubview:backView];
        
        self.timeBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 32, WIDTH, 60)];
        self.timeBackView.backgroundColor = [UIColor whiteColor];
        self.timeBackView.userInteractionEnabled = YES;
        [scrooleView addSubview:self.timeBackView];

        CGFloat start_X = 16;
        for(int i = 0; i < cityArray.count; i++){
            NSString *str = [NSString stringWithFormat:@"%@", cityArray[i]];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            [btn setTitle:str forState:UIControlStateNormal];
            UserModel *model = [DataModelInstance shareInstance].userModel;
             btn.tag = i + 1;
            for (NSString *title in model.cityData) {
                if ([title isEqualToString:str]) {
                    btn.selected = YES;
                }
            }
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_hd_sxws"]forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_hd_sxxz"]forState:UIControlStateSelected];
            [btn setTitleColor:HEX_COLOR(@"1ABC9C") forState:UIControlStateSelected];
            [btn setTitleColor:HEX_COLOR(@"41464E") forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(choseCityTagSearch:) forControlEvents:UIControlEventTouchUpInside];
            btn.frame = CGRectMake((11 + wideth)*i + start_X, 16, wideth, 29);
            [self.timeBackView addSubview:btn];

        }
        
    }
    CGFloat start_Y = 94;
    if (tagArray.count > 0) {
        UIView *backView = [[UIView alloc]initWithFrame:CGRectMake(0, start_Y, WIDTH, 32)];
        backView.backgroundColor = [UIColor colorWithHexString:@"F5F5F7"];
        UIButton *tagBtn = [NSHelper createButton:CGRectMake(16, 8, 36,14) title:@"费用" unSelectImage:nil selectImage:nil target:self selector:nil];
        tagBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [tagBtn setTitleColor:[UIColor colorWithHexString:@"818C9E"] forState:UIControlStateNormal];
        [backView addSubview:tagBtn];
        [scrooleView addSubview:backView];
        CGFloat start_X = 16;
       
        self.moneyBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 126, WIDTH, 60)];
        self.moneyBackView.backgroundColor = [UIColor whiteColor];
        self.moneyBackView.userInteractionEnabled = YES;
        [scrooleView addSubview:self.moneyBackView];
        for(int i = 0; i < tagArray.count; i++){
            NSString *str = [NSString stringWithFormat:@"%@", tagArray[i]];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            UserModel *model = [DataModelInstance shareInstance].userModel;
            btn.tag = i + 1;
            for (NSString *title in model.tagData) {
                if ([title isEqualToString:str]) {
                    btn.selected = YES;
                }
            }
                [btn setTitleColor:HEX_COLOR(@"1ABC9C") forState:UIControlStateSelected];
                [btn setTitleColor:HEX_COLOR(@"41464E") forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_hd_sxws"]forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_hd_sxxz"]forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(choseTagSearch:) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            [btn setTitle:str forState:UIControlStateNormal];
            btn.frame = CGRectMake((11 + wideth)*i + start_X, 16, wideth, 29);
            [self.moneyBackView addSubview:btn];
        }
    }
    UIView *lineView  = [NSHelper createrViewFrame:CGRectMake(0, 186, WIDTH, 0.5) backColor:@"D9D9D9"];
    [self addSubview:lineView];
                         
   
    CGFloat wideth1 = (self.frame.size.width - 50)/2.0;
    UIButton *clearBtn = [NSHelper createButton:CGRectMake(16, 203, wideth1,29) title:@"清除筛选" unSelectImage:nil selectImage:nil target:self selector:@selector(claerBtnAction)];
    [clearBtn setBackgroundImage:[UIImage imageNamed:@"btn_hd_sxws"] forState:UIControlStateNormal];
    [clearBtn setTitleColor:[UIColor colorWithHexString:@"818C9E"] forState:UIControlStateNormal];
    [self addSubview:clearBtn];
    self.sureBtn = [NSHelper createButton:CGRectMake(34+wideth1,203, wideth1,29) title:@"完成" unSelectImage:nil selectImage:nil target:self selector:@selector(sureBtnAction)];
    self.sureBtn.layer.masksToBounds = YES;
    self.sureBtn.layer.cornerRadius = 2.0;
    [self.sureBtn setBackgroundImage:kImageWithName(@"btn_hd_qd") forState:UIControlStateNormal];
    [self.sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addSubview:self.sureBtn];
    
}

- (void)claerBtnAction{
    for (UIView *view in self.timeBackView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            btn.selected = NO;
        }
    }
    for (UIView *view in self.moneyBackView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)view;
            btn.selected = NO;
        }
    }
    [self.timeArray removeAllObjects];
    [self.moneyArray removeAllObjects];
    UserModel *model = [DataModelInstance shareInstance].userModel;
    model.cityData = self.timeArray;
    model.tagData = self.moneyArray;
    [DataModelInstance shareInstance].userModel = model;
}

- (void)sureBtnAction{
     UserModel *model = [DataModelInstance shareInstance].userModel;
    model.cityData =  self.timeArray;
    model.tagData = self.moneyArray;
    [DataModelInstance shareInstance].userModel = model;
    if(self.timeArray.count+self.moneyArray.count == 0){
                self.col = 0;
                self.row = 0;
    }
    if ([self.tagSearchViewDelegate respondsToSelector:@selector(gotoMakeSureTagSearchTime:feerMoney:)]) {
        [self.tagSearchViewDelegate gotoMakeSureTagSearchTime:self.col feerMoney:self.row];
    }
}

- (void)choseCityTagSearch:(UIButton *)btn{
    [self.timeArray removeAllObjects];
    [self.timeArray addObject:btn.titleLabel.text];
    btn.selected = !btn.selected;
    if (btn.selected == NO) {
           [self.timeArray removeObject:btn.titleLabel.text];
        self.col = 0;
    }else{
        self.col = btn.tag;
    }

    for (UIView *view in self.timeBackView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton*)view;
            if(button.tag != btn.tag){
                button.selected = NO;
            }
        }
    }
    self.col = btn.tag;
}

- (void)choseTagSearch:(UIButton *)btn{
    [self.moneyArray removeAllObjects];
    [self.moneyArray addObject:btn.titleLabel.text];
    btn.selected = !btn.selected;
    if (btn.selected == NO) {
        [self.moneyArray removeObject:btn.titleLabel.text];
         self.row = 0;
    }else{
         self.row = btn.tag;
    }
    for (UIView *view in self.moneyBackView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton*)view;
            if(button.tag != btn.tag){
                button.selected = NO;
            }
        }
    }
   
}

@end
