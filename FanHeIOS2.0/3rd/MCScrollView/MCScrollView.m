//
//  MCScrollView.m
//  Promotion
//
//  Created by HuMengChi on 15/6/24.
//  Copyright (c) 2015年 hmc. All rights reserved.
//

#import "MCScrollView.h"
#import "UIButton+WebCache.h"
#import "CoffeeIntroduceViewController.h"

#define ScrollSec 5

@interface MCScrollView()<UIScrollViewDelegate>{
    int _sum;
}
@property (nonatomic, strong) UIScrollView      *scrollView;
@property (nonatomic, strong) UIPageControl     *pageControl;
@property (nonatomic, strong) NSTimer           *timer;
@property (nonatomic, strong) NSArray           *array;

@end

@implementation MCScrollView

- (id)initWithFrame:(CGRect)frame ParameterArray:(NSArray*)array{
    if(self = [super initWithFrame:frame]){
        _array = [[NSArray alloc] initWithArray:array];
        [self initControl:frame];
    }
    return self;
}

- (void)updateDisplay:(NSArray*)array{
    _array = array;
    [self initControl:self.frame];
    [self endTimer];
    if(_array.count>1){
        [self startTimer];
    }
}

- (void)initControl:(CGRect)frame {
    frame.origin.y = 0;
    _scrollView = [[UIScrollView alloc] initWithFrame:frame];
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = YES;
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.userInteractionEnabled = YES;
    [_scrollView setContentOffset:CGPointMake(0, 0)];
    [_scrollView scrollRectToVisible:CGRectMake(WIDTH,0,WIDTH,frame.size.height) animated:NO];
    _scrollView.backgroundColor = [UIColor blackColor];
    [self addSubview:_scrollView];
    
    if(_array.count>1){
        _sum = (int)_array.count+2;
        [_scrollView setContentSize:CGSizeMake(WIDTH*_sum, frame.size.height)];
        
        //添加视图到scrollview
        for(int i = 0; i<_sum; i++){
            BannerModel *model;
            int tag;
            if(i == 0){
                model = _array[_sum-3];
                tag = _sum-3+1;
            }else if(i == _sum-1){
                model = _array[0];
                tag = 1;
            }else{
                model = _array[i-1];
                tag = i;
            }
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn sd_setBackgroundImageWithURL:[NSURL URLWithString:model.image] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"banner_index_cf"]];
            btn.frame = CGRectMake(WIDTH*i, 0, WIDTH, frame.size.height);
            btn.tag = i;
            [btn addTarget:self action:@selector(clickAdvertisment:) forControlEvents:UIControlEventTouchUpInside];
            [_scrollView addSubview:btn];
        }
        [_scrollView setContentOffset:CGPointMake(WIDTH, 0) animated:NO];
        
        //初始化UIPageControl
        _pageControl = [[UIPageControl alloc] init];
        CGRect frames = _scrollView.frame;
        CGSize size = [_pageControl sizeForNumberOfPages:_sum-2];
        frames.origin.y = frames.size.height-size.height+20;
        frames.size = size;
        _pageControl.frame = frames;
        _pageControl.center = CGPointMake(WIDTH/2, frames.origin.y);
        [_pageControl setCurrentPageIndicatorTintColor:[UIColor whiteColor]];
        [_pageControl setPageIndicatorTintColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.5]];
        _pageControl.numberOfPages = _sum-2;
        _pageControl.currentPage = 0;
        [_pageControl addTarget:self action:@selector(turnPage) forControlEvents:UIControlEventValueChanged];
        if(_array.count>1){
            _pageControl.hidden = NO;
            _scrollView.scrollEnabled = YES;
        }else{
            _pageControl.hidden = YES;
            _scrollView.scrollEnabled = NO;
        }
        [self addSubview:_pageControl];
    }else{
        [_scrollView setContentSize:CGSizeMake(WIDTH, frame.size.height)];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if(_array.count==0){
            [btn setBackgroundImage:
         kImageWithName(@"banner_index_cf") forState:UIControlStateNormal];
        }else{
            BannerModel *model = _array[0];
            [btn sd_setBackgroundImageWithURL:[NSURL URLWithString:model.image] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"banner_index_cf"]];
        }
        btn.tag = 1;
        [btn addTarget:self action:@selector(clickAdvertisment:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(0, 0, WIDTH, frame.size.height);
        [_scrollView addSubview:btn];
    }
}

#pragma mark-Method
- (void)turnPage{
    
}

- (void)clickAdvertisment:(UIButton*)sender{
    if(self.scrollViewClickIndex && _array.count){
        self.scrollViewClickIndex(sender.tag-1);
    }else{
        [[self viewController].navigationController pushViewController:[[CoffeeIntroduceViewController alloc] init] animated:YES];
    }
}

- (void)startTimer{
    if(_array.count > 1){
        if(_timer){
            [self endTimer];
        }
        _timer = [NSTimer scheduledTimerWithTimeInterval:ScrollSec target:self selector:@selector(runLoop) userInfo:nil repeats:YES];
    }
}

- (void)endTimer{
    [_timer invalidate];
    _timer = nil;
}

#pragma mark-初始化scrollview自动循环
- (void)runLoop{
    int currentPage = _scrollView.contentOffset.x/WIDTH;
    if(currentPage == 0){
        [_scrollView setContentOffset:CGPointMake(WIDTH*_array.count, 0) animated:NO];
    }else if(currentPage == _array.count){
        [_scrollView setContentOffset:CGPointMake(WIDTH*0, 0) animated:NO];
        [_scrollView setContentOffset:CGPointMake(WIDTH*1, 0) animated:YES];
    }else{
        [_scrollView setContentOffset:CGPointMake(WIDTH+currentPage*WIDTH, 0) animated:YES];
    }
    _pageControl.currentPage = currentPage%_array.count;
    [_pageControl updateCurrentPageDisplay];
}

#pragma mark-UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int currentPage = scrollView.contentOffset.x/WIDTH;
    if(currentPage == 0){
        [_scrollView setContentOffset:CGPointMake(WIDTH*_array.count, 0) animated:NO];
    }else if(currentPage == _sum-1){
        [_scrollView setContentOffset:CGPointMake(WIDTH*1, 0) animated:NO];
    }
    currentPage = scrollView.contentOffset.x/WIDTH;
    _pageControl.currentPage = currentPage-1;
    [_pageControl updateCurrentPageDisplay];
    if(_array.count>1){
        [self startTimer];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    [self endTimer];
}

@end
