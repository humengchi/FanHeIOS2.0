//
//  DynamicImageView.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/3/1.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "DynamicImageView.h"
#import "VariousDetailController.h"

@interface DynamicImageView ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,MWPhotoBrowserDelegate>{
    CGFloat _cellWidth;
}

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSMutableArray *collectionArray;


@property (nonatomic, assign) BOOL isShare;

@end

@implementation DynamicImageView

- (id)initWithFrame:(CGRect)frame imageArray:(NSArray*)imageArray model:(DynamicModel*)model isShare:(BOOL)isShare{
    if (self=[super initWithFrame:frame]) {
        self.isShare = isShare;
        self.model = model;
        self.imageArray = imageArray;
        self.collectionArray = [NSMutableArray arrayWithArray:imageArray];
        //确定是水平滚动，还是垂直滚动
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:
         UICollectionViewScrollDirectionVertical];
        
        if(imageArray.count==2){
            [self.collectionArray addObject:@""];
        }else if(imageArray.count==4){
            [self.collectionArray insertObject:@"" atIndex:2];
            [self.collectionArray addObject:@""];
        }else if(imageArray.count==5){
            [self.collectionArray addObject:@""];
        }else if(imageArray.count==7){
            [self.collectionArray addObject:@""];
            [self.collectionArray addObject:@""];
        }else if(imageArray.count==8){
            [self.collectionArray addObject:@""];
        }
        CGRect collectionFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        if(imageArray.count==1){
            if(isShare){
                if(model.shareSubViewHeight>5){
                    collectionFrame.size.height = model.shareSubViewHeight;
                }
            }else{
                if(model.imageHeight>5){
                    collectionFrame.size.height = model.imageHeight;
                }
            }
            if(model.imageSize.width && model.imageSize.height){
                CGFloat width = model.imageSize.width*(collectionFrame.size.height-5.0)/model.imageSize.height;
                width = width<(WIDTH-90)/3.0?(WIDTH-90)/3.0:width;
                width = width>(WIDTH-90)/3.0*2+5?(WIDTH-90)/3.0*2+5:width;
                collectionFrame.size.width = width;
            }
        }else{
            _cellWidth = (frame.size.width-10)/3;
        }
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:collectionFrame collectionViewLayout:flowLayout];
        self.collectionView.dataSource=self;
        self.collectionView.delegate=self;
        [self.collectionView setBackgroundColor:self.backgroundColor];
        self.collectionView.bounces = YES;
        self.collectionView.scrollEnabled = NO;
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        //注册Cell，必须要有
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
        [self addSubview:self.collectionView];
    }
    return self;
}

#pragma mark -- UICollectionViewDataSource
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.collectionArray.count>9?9:self.collectionArray.count;
}

- (UIImage*)scaleImage:(UIImage*)originImage{
    CGSize retSize = originImage.size;
    CGFloat sizeWidth = retSize.width;
    CGFloat sizeHeight = retSize.height;
    
    if(retSize.height/retSize.width > 2){
        sizeHeight = sizeWidth*(self.collectionView.frame.size.height-5)/(CGFloat)self.collectionView.frame.size.width;
    }else if(retSize.width/retSize.height > 2){
        sizeWidth = sizeHeight*self.collectionView.frame.size.width/(CGFloat)(self.collectionView.frame.size.height-5);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([originImage CGImage], CGRectMake((retSize.width-sizeWidth)/2,(retSize.height-sizeHeight)/2, sizeWidth, sizeHeight));//获取图片整体部分
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:originImage.scale orientation:UIImageOrientationUp];
    return image;
}

//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"UICollectionViewCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    for(UIGestureRecognizer *gesture in cell.gestureRecognizers){
        [cell removeGestureRecognizer:gesture];
    }
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    NSString *imageUrl = self.collectionArray[indexPath.row];
    /*if(((self.model.type.integerValue==13 && self.model.exttype.integerValue==17) || self.model.type.integerValue==17) && imageUrl.length){
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _cellWidth, _cellWidth)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:KSquareImageDefault];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [cell.contentView addSubview:imageView];
        return cell;
    }*/
    if(imageUrl.length){
        CGRect frame = CGRectMake(0, 0, _cellWidth, _cellWidth);
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        UIImage *defaultImage = KSquareImageDefault;
        if(self.collectionArray.count==1){
            frame.size.height = collectionView.frame.size.height-5;
            frame.size.width = collectionView.frame.size.width;
            if(self.model.imageSize.width>self.model.imageSize.height){
                defaultImage = KWidthImageDefault;
            }else{
                defaultImage = KHeightImageDefault;
            }
        }
        imageView.frame = frame;
        if(self.collectionArray.count!=1){
            if([imageUrl hasPrefix:@"http://"]){
                imageUrl = [imageUrl stringByAppendingString:[NSString stringWithFormat:@"?imageView2/1/w/%d/h/%d",(int)_cellWidth*2,(int)_cellWidth*2]];
            }
        }
        imageView.backgroundColor = BLACK_COLOR;
        if([imageUrl hasPrefix:@"http://"]){
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:defaultImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if(self.collectionArray.count==1&&image){
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        UIImage *newImage;
                        if(self.collectionArray.count!=1){
                            CGFloat width = MIN(image.size.width, image.size.height);
                            newImage = [image scaleToSquareSize:width];
                        }else{
                            newImage = [self scaleImage:image];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            imageView.image = newImage;
                        });
                    });
                }
            }];
        }else{
            imageView.image = defaultImage;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                UIImage *newImage;
                NSString *DocumentsPath = [NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/dynamic"], imageUrl];
                UIImage *image = [UIImage imageWithContentsOfFile:DocumentsPath];
                if(image){
                    if(self.collectionArray.count!=1){
                        CGFloat width = MIN(image.size.width, image.size.height);
                        newImage = [image scaleToSquareSize:width];
                    }else{
                        newImage = [self scaleImage:image];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageView.image = newImage;
                    });
                }
            });
        }
        [cell.contentView addSubview:imageView];
    }
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.collectionArray.count==1){
        return CGSizeMake(collectionView.frame.size.width, collectionView.frame.size.height-5);
    }else{
        return CGSizeMake(_cellWidth, _cellWidth);
    }
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 5, 0);
}

//这个是两行cell之间的间距（上下行cell的间距）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}

//两个cell之间的间距（同一行的cell的间距）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}

#pragma mark --UICollectionViewDelegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *imageUrl = self.collectionArray[indexPath.row];
    if(imageUrl.length){
        NSInteger index = [self.imageArray indexOfObject:imageUrl];
        [self photoButtonClicked:index];
    }else{
        if(self.model.dynamic_id.integerValue<0){
            return;
        }
        NSNumber *dynamicId;
        if(self.isShare){
            dynamicId = self.model.parent;
        }else{
            dynamicId = self.model.dynamic_id;
        }
        VariousDetailController *vc = [CommonMethod getVCFromNib:[VariousDetailController class]];
        vc.dynamicid = dynamicId;
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
}

//点击图片
- (void)photoButtonClicked:(NSInteger)index{
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    photoBrowser.displayActionButton = YES;
    photoBrowser.displayNavArrows = YES;
    photoBrowser.displaySelectionButtons = NO;
    photoBrowser.alwaysShowControls = YES;
    photoBrowser.autoPlayOnAppear = NO;
    photoBrowser.zoomPhotosToFill = YES;
    photoBrowser.enableGrid = NO;
    photoBrowser.startOnGrid = NO;
    photoBrowser.enableSwipeToDismiss = YES;
    [photoBrowser setCurrentPhotoIndex:index];
    photoBrowser.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [[self viewController] presentViewController:photoBrowser animated:YES completion:nil];
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.imageArray.count;
}

- (id )photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    NSString *imageUrl = self.imageArray[index];
    if([imageUrl hasPrefix:@"http://"]){
        NSURL *url = [NSURL URLWithString:imageUrl];
        MWPhoto *photo = [MWPhoto photoWithURL:url];
        return photo;
    }else{
        NSString *documentsPath = [NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/dynamic"], imageUrl];
        MWPhoto *photo = [MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:documentsPath]];
        return photo;
    }
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    [[self viewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
