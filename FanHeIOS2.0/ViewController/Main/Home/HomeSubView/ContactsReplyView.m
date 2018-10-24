//
//  ContactsReplyView.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/8/16.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "ContactsReplyView.h"
#import "ReplyCollectionViewCell.h"

@interface ContactsReplyView ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView  *collectionView;

@property (nonatomic, strong) NSMutableArray    *dataArray;

@property (nonatomic, strong) UIPageControl     *pageControl;

@end

@implementation ContactsReplyView

- (id)initWithFrame:(CGRect)frame data:(NSArray*)dataArray{
    if(self = [super initWithFrame:frame]){
        self.dataArray = [NSMutableArray arrayWithArray:dataArray];
        //确定是水平滚动，还是垂直滚动
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        [flowLayout setScrollDirection:
         UICollectionViewScrollDirectionHorizontal];
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 152) collectionViewLayout:flowLayout];
        self.collectionView.dataSource=self;
        self.collectionView.delegate=self;
        [self.collectionView setBackgroundColor:[UIColor whiteColor]];
        self.collectionView.pagingEnabled = YES;
        self.collectionView.bounces = NO;
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        //注册Cell，必须要有
        [self.collectionView registerClass:[ReplyCollectionViewCell class] forCellWithReuseIdentifier:@"ReplyCollectionViewCell"];
        [self addSubview:self.collectionView];
        
        [self.collectionView reloadData];
        
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.frame = CGRectMake(WIDTH-37, 9, 30, 30);
        [deleteBtn setImage:kImageWithName(@"btn_close_gray") forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteBtn];
        
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 146, WIDTH, 8)];
        self.pageControl.numberOfPages = self.dataArray.count;
        self.pageControl.currentPage = 0;
        self.pageControl.pageIndicatorTintColor = HEX_COLOR(@"E6E8EB");
        self.pageControl.currentPageIndicatorTintColor = HEX_COLOR(@"AFB6C1");
        if(dataArray.count == 1){
            self.pageControl.hidden = YES;
        }
        [self addSubview:self.pageControl];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height-0.5, WIDTH, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [self addSubview:lineLabel];
        
        self.backgroundColor = WHITE_COLOR;
    }
    return self;
}

- (void)deleteButtonClicked:(id)sender{
    if(self.deleteReplyView){
        self.deleteReplyView();
    }
}

#pragma mark -- UICollectionViewDataSource
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    // Register nib file for the cell
    UINib *nib = [UINib nibWithNibName:@"ReplyCollectionViewCell" bundle: [NSBundle mainBundle]];
    [collectionView registerNib:nib forCellWithReuseIdentifier:@"ReplyCollectionViewCell"];
    ReplyCollectionViewCell *cell = [[ReplyCollectionViewCell alloc]init];
    // Set up the reuse identifier
    cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"ReplyCollectionViewCell"forIndexPath:indexPath];
    [cell updateDisplay:self.dataArray[indexPath.row]];
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(WIDTH, 152);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0.5);
}

#pragma mark --UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.selectReplyView){
        self.selectReplyView(indexPath.row);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger index = scrollView.contentOffset.x/WIDTH;
    [self.pageControl setCurrentPage:index];
}

@end
