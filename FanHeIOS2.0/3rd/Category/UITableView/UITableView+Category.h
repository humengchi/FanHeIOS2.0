//
//  UITableView+Category.h
//  JinMai
//
//  Created by 胡梦驰 on 16/5/12.
//  Copyright © 2016年 51jinmai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITableView(Category)

//下拉刷新
- (void)tableViewAddDownLoadRefreshing:(MJRefreshComponentRefreshingBlock)refreshingBlock;

//上拉加载
- (void)tableViewAddUpLoadRefreshing:(MJRefreshComponentRefreshingBlock)refreshingBlock;

- (void)endRefresh;
- (void)endRefreshNoData;

@end
