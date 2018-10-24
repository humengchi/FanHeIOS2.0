//
//  PhotosController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/7/18.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "PhotosController.h"

@interface PhotosController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,MWPhotoBrowserDelegate, TZImagePickerControllerDelegate>{
    CGFloat _cellWidth;
    BOOL _isEdit;
    BOOL _isMyHomePage;
}

@property (nonatomic, weak) IBOutlet UIButton *editBtn;
@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *photosArray;
@property (nonatomic, strong) NSMutableArray *deleteArray;
@property (nonatomic, weak) IBOutlet UIButton *deleteBtn;

@end

@implementation PhotosController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isEdit = NO;
    self.photosArray = [NSMutableArray array];
    self.deleteArray = [NSMutableArray array];
    
    _isMyHomePage = self.userId.integerValue==[DataModelInstance shareInstance].userModel.userId.integerValue;
    self.editBtn.hidden = !_isMyHomePage;
    
    _cellWidth = (NSInteger)(WIDTH-42)/3;
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:
     UICollectionViewScrollDirectionVertical];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT-64) collectionViewLayout:flowLayout];
    self.collectionView.dataSource=self;
    self.collectionView.delegate=self;
    [self.collectionView setBackgroundColor:WHITE_COLOR];
    self.collectionView.bounces = YES;
    self.collectionView.scrollEnabled = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    //注册Cell，必须要有
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    [self.view addSubview:self.collectionView];
    [self loadHttpListData];
}


#pragma mark - method
- (IBAction)navBackButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)editButtonClicked:(UIButton*)sender{
    _isEdit = !_isEdit;
    if(_isEdit){
        self.collectionView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64-55);
        [self.deleteArray removeAllObjects];
        self.deleteBtn.enabled = NO;
        [sender setTitle:@"取消" forState:UIControlStateNormal];
    }else{
        self.collectionView.frame = CGRectMake(0, 64, WIDTH, HEIGHT-64);
        [sender setTitle:@"编辑" forState:UIControlStateNormal];
    }
    [self.collectionView reloadData];
}

- (IBAction)deletePhototsButtonClicked:(id)sender{
    if(self.deleteArray.count==0){
        return;
    }
    [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:[NSString stringWithFormat:@"是否删除%lu张照片？",(unsigned long)self.deleteArray.count] cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
        
    } confirm:^{
        __weak typeof(self) weakSelf = self;
        __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"删除中..." toView:self.view];
        NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
        [requestDict setObject:[NSString stringWithFormat:@"%@", self.userId] forKey:@"userid"];
        [requestDict setObject:[self.deleteArray componentsJoinedByString:@","] forKey:@"image"];
        [self requstType:RequestType_Post apiName:API_NAME_DELETE_USER_DELALBUM paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
            [hud hideAnimated:YES];
            if([CommonMethod isHttpResponseSuccess:responseObject]){
                [MBProgressHUD showSuccess:@"删除成功!" toView:weakSelf.view];
                [weakSelf.photosArray removeObjectsInArray:weakSelf.deleteArray];
                [weakSelf editButtonClicked:weakSelf.editBtn];
                if(weakSelf.photosChange){
                    weakSelf.photosChange(weakSelf.photosArray);
                }
            }else{
                [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }];
    }];
}

- (void)choiceImageButtonClicked:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -获取数据
- (void)loadHttpListData{
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"加载中..." toView:self.view];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[NSString stringWithFormat:@"/%@", self.userId] forKey:@"param"];
    [self requstType:RequestType_Get apiName:API_NAME_GET_USER_ALBUMLIST paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            weakSelf.photosArray = [NSMutableArray arrayWithArray:[CommonMethod paramArrayIsNull:responseObject[@"data"]]];
            [weakSelf.collectionView reloadData];
        }else{
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

#pragma mark -- UICollectionViewDataSource
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(_isMyHomePage&&!_isEdit){
        return self.photosArray.count+1;
    }else{
        return self.photosArray.count;
    }
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
    NSString *imageUrl = @"";
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _cellWidth, _cellWidth)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [cell.contentView addSubview:imageView];
    if(_isMyHomePage&&!_isEdit){
        if(indexPath.row){
            imageUrl = self.photosArray[indexPath.row-1];
        }
    }else{
       imageUrl = self.photosArray[indexPath.row];
    }
    if(imageUrl.length){
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:KSquareImageDefault];
    }else{
        imageView.image = kImageWithName(@"image_my_addphoto");
    }
    if(_isEdit){
        UIImageView *choiceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_cellWidth-29, 8, 21, 21)];
        if([self.deleteArray containsObject:imageUrl]){
            choiceImageView.image = kImageWithName(@"btn_check");
        }else{
            choiceImageView.image = kImageWithName(@"icon_checkbox_uncheck");//btn_no_check
        }
        [cell.contentView addSubview:choiceImageView];
    }
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个Item 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(_cellWidth, _cellWidth);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(16, 16, 5, 16);
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
    if(!_isEdit){
        NSInteger index = -1;
        if(_isMyHomePage&&!_isEdit){
            if(indexPath.row){
                index = indexPath.row - 1;
            }
        }else{
            index = indexPath.row;
        }
        if(index>=0){
            [self photoButtonClicked:index];
        }else{
            [self openPhoto];
        }
    }else{
        NSString *imageUrl = self.photosArray[indexPath.row];
        if([self.deleteArray containsObject:imageUrl]){
            [self.deleteArray removeObject:imageUrl];
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }else{
            if(self.deleteArray.count<=9){
                [self.deleteArray addObject:imageUrl];
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        }
        self.deleteBtn.enabled = self.deleteArray.count>0;
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
    [self presentViewController:photoBrowser animated:YES completion:nil];
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return self.photosArray.count;
}

- (id )photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    NSString *imageUrl = self.photosArray[index];
    NSURL *url = [NSURL URLWithString:imageUrl];
    MWPhoto *photo = [MWPhoto photoWithURL:url];
    return photo;
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//相册选择器
- (void)openPhoto{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied){
        [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"请在iPhone的“设置>隐私>相册”选项中，允许3号圈访问你的相册" cancelButtonTitle:@"取消" otherButtonTitle:@"设置" cancle:^{
        } confirm:^{
            if(IOS_X >= 10){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
            }
        }];
        return;
    }
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    imagePickerVc.allowTakePicture = NO;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    [[UINavigationBar appearance] setBackgroundImage:kImageWithColor(kDefaultColor, CGRectMake(0, 0, WIDTH, 1)) forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:kImageWithColor(kDefaultColor, CGRectMake(0, 0, WIDTH, 1))];
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray *photos, NSArray *assets, BOOL success) {
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
        NSMutableArray *imagesArray = [NSMutableArray array];
        for (UIImage *image in photos) {
            UIImage *newImage = image;
            //旋转
            UIImageOrientation imageOrientation=image.imageOrientation;
            if(imageOrientation!=UIImageOrientationUp){
                UIGraphicsBeginImageContext(image.size);
                [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
                newImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            [imagesArray addObject:newImage];
        }
        [self uploadImageHttp:nil imagesArray:imagesArray];
    }];
    [imagePickerVc setImagePickerControllerDidCancelHandle:^{
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - 上传图片
- (void)uploadImageHttp:(MBProgressHUD*)hud imagesArray:(NSMutableArray*)imagesArray{
    UIImage *image;
    NSInteger index = 0;
    for(id param in imagesArray){
        if([param isKindOfClass:[UIImage class]]){
            image = param;
            break;
        }
        index++;
    }
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionary];
    if(image){
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        [requestDict setObject:imageData forKey:@"pphoto"];
        if(hud==nil){
            hud = [MBProgressHUD showMessag:@"上传图片中..." toView:self.view];
        }
    }else{
        if(hud==nil){
            hud = [MBProgressHUD showMessag:@"上传图片中..." toView:self.view];
        }
        [self savePhotos:hud imagesArray:imagesArray];
        return;
    }
    [self requstType:RequestType_UPLOAD_IMG apiName:API_NAME_UPLOAD_IMAGE paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject] == HttpResponseTypeSuccess){
            NSString *urlStr = [responseObject objectForKey:@"msg"];
            imagesArray[index] = urlStr;
            [weakSelf uploadImageHttp:hud imagesArray:imagesArray];
        }else{
            [hud hideAnimated:YES];
            [MBProgressHUD showMessag:@"图片上传失败，请重试！" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        
    }];
}

#pragma mark - 保存相册
- (void)savePhotos:(MBProgressHUD*)hud imagesArray:(NSMutableArray*)imagesArray{
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:[imagesArray componentsJoinedByString:@","] forKey:@"image"];
    [self requstType:RequestType_Post apiName:API_NAME_POST_USER_UPLOAD_ALBUM paramDict:requestDict hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"上传成功!" toView:weakSelf.view];
            [weakSelf.photosArray insertObjects:imagesArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, imagesArray.count)]];
            [weakSelf.collectionView reloadData];
            if(weakSelf.photosChange){
                weakSelf.photosChange(weakSelf.photosArray);
            }
        }else{
            [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showError:@"网络请求失败，请检查网络" toView:weakSelf.view];
    }];
}

@end
