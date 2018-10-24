//
//  UITableView+Category.m
//  JinMai
//
//  Created by 胡梦驰 on 16/5/12.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import "UITableView+Category.h"

@implementation UITableView(Category)

- (void)tableViewAddDownLoadRefreshing:(MJRefreshComponentRefreshingBlock)refreshingBlock{
    if(self.mj_footer){
        [self.mj_footer resetNoMoreData];
    }
    //下拉刷新控制
    MJRefreshGifHeader *gitHeader = [MJRefreshGifHeader headerWithRefreshingBlock:refreshingBlock];
    [gitHeader setImages:@[kImageWithName(@"loading_toutiao_p1"), kImageWithName(@"loading_toutiao_p2"), kImageWithName(@"loading_toutiao_p3")] duration:1.f forState:MJRefreshStateRefreshing];
    [gitHeader setImages:@[kImageWithName(@"loading_toutiao_p1")] forState:MJRefreshStateIdle];
    [gitHeader setImages:@[kImageWithName(@"loading_toutiao_p1")] forState:MJRefreshStatePulling];
    [gitHeader setImages:@[kImageWithName(@"loading_toutiao_p1")] forState:MJRefreshStateWillRefresh];
    self.mj_header = gitHeader;
}

- (void)tableViewAddUpLoadRefreshing:(MJRefreshComponentRefreshingBlock)refreshingBlock{
    //上拉加载控制
    MJRefreshBackGifFooter *gitFooter = [MJRefreshBackGifFooter footerWithRefreshingBlock:refreshingBlock];
    [gitFooter setImages:@[kImageWithName(@"loading_toutiao_p1"), kImageWithName(@"loading_toutiao_p2"), kImageWithName(@"loading_toutiao_p3")] duration:2.f forState:MJRefreshStateRefreshing];
    [gitFooter setImages:@[kImageWithName(@"loading_toutiao_p1")] forState:MJRefreshStateIdle];
    [gitFooter setImages:@[kImageWithName(@"loading_toutiao_p1")] forState:MJRefreshStatePulling];
    [gitFooter setImages:@[kImageWithName(@"loading_toutiao_p1")] forState:MJRefreshStateWillRefresh];
    self.mj_footer = gitFooter;
}

- (void)endRefresh{
    if(self.mj_footer.isRefreshing){
        [self.mj_footer endRefreshing];
    }
    if(self.mj_header.isRefreshing){
        [self.mj_header endRefreshing];
    }
}

- (void)endRefreshNoData{
    [self.mj_footer endRefreshingWithNoMoreData];
}

@end
