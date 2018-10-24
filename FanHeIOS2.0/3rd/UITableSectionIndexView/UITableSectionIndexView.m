//
//  UITableSectionIndexView.m
//  ChannelPlus
//
//  Created by HuMengChi on 15/12/24.
//  Copyright © 2015年 Peter. All rights reserved.
//

#import "UITableSectionIndexView.h"


@interface UITableSectionIndexView (){
    UIButton *_selectedBtn;
    NSInteger tag;
    UISwipeGestureRecognizer *swipe;
}

@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation UITableSectionIndexView


- (id)initWithFrame:(CGRect)frame sectionArray:(NSMutableArray*)sectionArray{
    if(self = [super initWithFrame:frame]){
        [self loadView:sectionArray];
        tag = 0;
    }

    return self;
}

- (void)loadView:(NSMutableArray*)sectionArray{
    for(UIView *view in self.subviews){
        [view removeFromSuperview];
    }
    swipe = [[UISwipeGestureRecognizer  alloc]initWithTarget:self action:@selector(tapSelect:)];
    [self addGestureRecognizer:swipe];
    self.array = sectionArray;
    if(sectionArray.count == 0){
        return;
    }
    
    float IndexSectionHeight = 16;
    float start_Y = 0;
    if(self.frame.size.height>self.array.count*IndexSectionHeight){
        start_Y = (self.frame.size.height-self.array.count*IndexSectionHeight)/2.0;
    }else{
        start_Y = 0;
        IndexSectionHeight = self.frame.size.height/self.array.count;
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = 200;
    btn.frame = CGRectMake(0, start_Y, self.frame.size.width, IndexSectionHeight);
    [btn addTarget:self action:@selector(changeToRect:) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"icon_connection_searchblue"] forState:UIControlStateNormal];
    [self addSubview:btn];
    
   
    for (int i = 0 ; i<self.array.count; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i+200;
      
        btn.frame = CGRectMake(0, start_Y+(i+1)*IndexSectionHeight, self.frame.size.width, IndexSectionHeight);
        [btn addTarget:self action:@selector(changeToRect:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
      
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        NSDictionary *dict = self.array[i];
        if([dict.allKeys[0] isEqualToString:@"未交换"]){
            [btn setTitle:@"未" forState:UIControlStateNormal];
        }else{
            [btn setTitle:[dict.allKeys[0] uppercaseString] forState:UIControlStateNormal];
        }
        [self addSubview:btn];
        if(tag == i){
            btn.selected = YES;
            _selectedBtn = btn;
        }
    }
}
- (void)tapSelect:(UISwipeGestureRecognizer *)g{
    NSInteger index = g.view.tag;
       tag = index - 200;
    if ([self.delegate respondsToSelector:@selector(indexViewChangeToIndex:)]) {
        [self.delegate indexViewChangeToIndex:index-200];
    }
    
    
}
- (void)changeToRect:(UIButton *)btn{
    //记录上次的按钮，然后取消背景颜色
    _selectedBtn.selected = NO;
    _selectedBtn = btn;
    _selectedBtn.selected = YES;
    tag = btn.tag - 200;
    if ([self.delegate respondsToSelector:@selector(indexViewChangeToIndex:)]) {
        [self.delegate indexViewChangeToIndex:btn.tag-200];
    }
}

- (void)changeBtnIndex:(NSInteger)index{
    tag = index;
    _selectedBtn.selected = NO;
    _selectedBtn = (UIButton*)[self viewWithTag:index+200];
    _selectedBtn.selected = YES;
}
@end
