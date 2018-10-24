//
//  ContactsCollectionView.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 16/10/25.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "HomeTableViewCell.h"
#import "ContactsCollectionViewCell.h"

#import "InformationDetailController.h"

@interface HomeTableViewCell ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) HomeTableDataModel    *model;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation HomeTableViewCell

- (id)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        UILabel *lineLabelTop = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.5)];
        lineLabelTop.backgroundColor = kCellLineColor;
        [self addSubview:lineLabelTop];
        
        self.titleLabel = [UILabel createLabel:CGRectMake(36, 16, WIDTH-72, 18) font:FONT_SYSTEM_SIZE(17) bkColor:WHITE_COLOR textColor:HEX_COLOR(@"41464E")];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
        
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height-10, WIDTH, 10)];
        lineLabel.backgroundColor = kTableViewBgColor;
        [self addSubview:lineLabel];
        
        UILabel *lineLabelBottom = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height-9.5, WIDTH, 0.5)];
        lineLabelBottom.backgroundColor = kCellLineColor;
        [self addSubview:lineLabelBottom];
        
        //确定是水平滚动，还是垂直滚动
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:
         UICollectionViewScrollDirectionHorizontal];
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 49, WIDTH, frame.size.height-84) collectionViewLayout:flowLayout];
        self.collectionView.dataSource=self;
        self.collectionView.delegate=self;
        [self.collectionView setBackgroundColor:[UIColor whiteColor]];
        self.collectionView.bounces = YES;
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        //注册Cell，必须要有
        [self.collectionView registerClass:[ContactsCollectionViewCell class] forCellWithReuseIdentifier:@"ContactsCollectionViewCell"];
        [self addSubview:self.collectionView];
    }
    return self;
}

- (void)updateDisplay:(HomeTableDataModel*)model{
    self.model = model;
    self.titleLabel.text = @"人脉推荐";
    [self.collectionView reloadData];
}

#pragma mark -- UICollectionViewDataSource
//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(self.model.type.integerValue == 1){
        return self.model.array.count;//+1
    }else if(self.model.type.integerValue == 2){
        return 1;
    }else{
        return self.model.array.count;
    }
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.model.type.integerValue == 2){
        UINib *nib = [UINib nibWithNibName:@"ContactsCollectionViewCellTalk" bundle: [NSBundle mainBundle]];
        [collectionView registerNib:nib forCellWithReuseIdentifier:@"ContactsCollectionViewCellTalk"];
        ContactsCollectionViewCell *cell = [[ContactsCollectionViewCell alloc]init];
        cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"ContactsCollectionViewCellTalk"forIndexPath:indexPath];
        DJTalkModel *model = self.model.array[indexPath.row];
        [cell updateDisplayDJTalkModel:model];
        return cell;
    }else{
        UINib *nib = [UINib nibWithNibName:@"ContactsCollectionViewCell" bundle: [NSBundle mainBundle]];
        [collectionView registerNib:nib forCellWithReuseIdentifier:@"ContactsCollectionViewCell"];
        ContactsCollectionViewCell *cell = [[ContactsCollectionViewCell alloc]init];
        cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"ContactsCollectionViewCell"forIndexPath:indexPath];
        if(indexPath.row == self.model.array.count){
            [cell updateDisplayUserModel:nil];
        }else{
            UserModel *model = self.model.array[indexPath.row];
            [cell updateDisplayUserModel:model];
        }
        cell.tag = indexPath.row;
        __weak typeof(self) weakSelf = self;
        cell.deleteCell = ^(ContactsCollectionViewCell *delCell) {
            [weakSelf.model.array removeObjectAtIndex:delCell.tag];
            [weakSelf.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:delCell.tag inSection:0]]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.collectionView reloadData];
            });
            
            if(weakSelf.model.array.count==0 && weakSelf.deleteAllUserModel){
                weakSelf.deleteAllUserModel();
                [weakSelf removeFromSuperview];
            }
        };
        [CALayer updateControlLayer:cell.layer radius:0 borderWidth:0.3 borderColor:kCellLineColor.CGColor];
        return cell;
    }
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.model.type.integerValue == 2){
        DJTalkModel *model = self.model.array[indexPath.row];
        CGFloat height = [NSHelper heightOfString:model.title font:FONT_SYSTEM_SIZE(17) width:WIDTH-32];
        CGFloat imageHeight=(WIDTH-32)*167/343.0;
        if(height > 25){
            return CGSizeMake(WIDTH, 50+imageHeight);
        }else{
            return CGSizeMake(WIDTH, 33+imageHeight);
        }
    }else{
        return CGSizeMake(128, 183);
    }
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if(self.model.type.integerValue == 2){
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }else{
        return UIEdgeInsetsMake(0, 12, 0, 12);
    }
}

#pragma mark --UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.model.type.integerValue != 2){
        if(indexPath.row == self.model.array.count){
            [[AppDelegate shareInstance].tabBarController setSelectedIndex:1];
        }else{
            UserModel *model = self.model.array[indexPath.row];
            NewMyHomePageController *vc = [[NewMyHomePageController alloc] init];
            vc.userId = model.userId;
            [[self viewController].navigationController pushViewController:vc animated:YES];
        }
    }else{
        DJTalkModel *model = self.model.array[indexPath.row];
        InformationDetailController *vc = [[InformationDetailController alloc] init];
        vc.postID = model.postid;
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
}

@end
