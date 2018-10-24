//
//  ActivityCoverViewController.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/1/3.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "ActivityCoverViewController.h"
#import "CropImageViewController.h"

@interface ActivityCoverViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    NSInteger _selectedRow;
}

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ActivityCoverViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedRow = -1;
    [self createCustomNavigationBar:@"活动封面"];
    [self initTableView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.dataArray = [NSMutableArray arrayWithObjects:@[@{@"name":@"封面"},@{@"name":@"标题"},@{@"name":@"开始时间"},@{@"name":@"结束时间"},@{@"name":@"活动地点"},@{@"name":@"标签"},@{@"name":@"活动简介"}], @[@{@"name":@"报名设置"},@{@"name":@"活动嘉宾"}], nil];
}

#pragma mark -UITableViewDelegate/datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }else{
        return 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section==0){
        return 0;
    }else{
        return 32;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section==1){
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 32)];
        headerView.backgroundColor = kTableViewBgColor;
        UILabel *titleLabel = [UILabel createrLabelframe:CGRectMake(16, 0, WIDTH-16, 32) backColor:kTableViewBgColor textColor:HEX_COLOR(@"818c9e") test:@"从默认图库选择" font:14 number:1 nstextLocat:NSTextAlignmentLeft];
        [headerView addSubview:titleLabel];
        return headerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        return 49;
    }else{
        return (WIDTH-32)*9/16.0+32;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identify = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    for(UIView *view in cell.contentView.subviews){
        [view removeFromSuperview];
    }
    if(indexPath.section==0){
        UILabel *contentLabel = [UILabel createrLabelframe:CGRectMake(16, 16, WIDTH-50, 20) backColor:WHITE_COLOR textColor:HEX_COLOR(@"41464e") test:(indexPath.row==0?@"从手机相册选取 ":@"拍照") font:17 number:1 nstextLocat:NSTextAlignmentLeft];
        [cell.contentView addSubview:contentLabel];
        
        UILabel *subContentLabel = [UILabel createrLabelframe:CGRectMake(WIDTH-130, 17, 100, 14) backColor:WHITE_COLOR textColor:HEX_COLOR(@"afb6c1") test:@"请上传16:9的照片" font:12 number:1 nstextLocat:NSTextAlignmentRight];
        [cell.contentView addSubview:subContentLabel];
        
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-30, 16, 14, 15)];
        iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        iconImageView.image = kImageWithName(@"icon_next_gray");
        [cell.contentView addSubview:iconImageView];
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 48.5, WIDTH-32, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [cell.contentView addSubview:lineLabel];
        if(indexPath.row==0){
            lineLabel.frame = CGRectMake(0, 48.5, WIDTH, 0.5);
        }
    }else{
        NSArray *imageArray = @[@"http://image.51jinmai.com/mr_hd_01.jpg",@"http://image.51jinmai.com/mr_hd_02.jpg",@"http://image.51jinmai.com/mr_hd_03.jpg"];
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16, WIDTH-32, (WIDTH-32)*9/16.0)];
        [iconImageView sd_setImageWithURL:[NSURL URLWithString:imageArray[indexPath.row]]];
        [cell.contentView addSubview:iconImageView];
        
        UIImageView *selectedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH-44, 23, 21, 21)];
        selectedImageView.contentMode = UIViewContentModeScaleAspectFit;
        if(_selectedRow==indexPath.row){
            selectedImageView.image = kImageWithName(@"btn_check");
        }else{
            selectedImageView.image = kImageWithName(@"btn_no_check");
        }
        [cell.contentView addSubview:selectedImageView];
        UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, (WIDTH-32)*9/16.0+32-0.5, WIDTH-32, 0.5)];
        lineLabel.backgroundColor = kCellLineColor;
        [cell.contentView addSubview:lineLabel];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0){
        [self choiceType:indexPath.row];
    }else{
        _selectedRow = indexPath.row;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        NSArray *imageArray = @[@"http://image.51jinmai.com/mr_hd_01.jpg",@"http://image.51jinmai.com/mr_hd_02.jpg",@"http://image.51jinmai.com/mr_hd_03.jpg"];
        self.tableView.userInteractionEnabled = NO;
        if(self.selectedCover){
            self.selectedCover(nil, imageArray[indexPath.row]);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    }
}

#pragma mark -拍照、相册
- (void)choiceType:(NSInteger)type{
    if(type == 1){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] setStatusBarHidden:NO];
                });
                [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"请在iPhone的“设置>隐私>相机”选项中，允许3号圈访问你的相机" cancelButtonTitle:@"取消" otherButtonTitle:@"设置" cancle:^{
                } confirm:^{
                    if(IOS_X >= 10){
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }else{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
                    }
                }];
                return;
            }
        }];
    }else{
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
    }
    UIImagePickerController *ctrl = [[UIImagePickerController alloc] init];
    ctrl.delegate = self;
    if(type == 1){
        ctrl.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else{
        [self setNavigationBar_white];
        ctrl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
        self.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    }
    [self presentViewController:ctrl animated:YES completion:^{
        if(type==1){
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }else{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }
    }];
}

#pragma mark -- UIImagePickerControllerDelegate
//点击相册中的图片 货照相机照完后点击use  后触发的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self setNavigationBar_kdefaultColor];
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
//    if(image.size.width != image.size.height){
//        image = [UIImage resizeImageWithRect:image];
//    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    __weak typeof(self) weakSelf = self;
    CropImageViewController *cropImageViewController = [[CropImageViewController alloc] initWithOriginImage:image callBack:^(UIImage *cropImage, CropImageViewController *viewController) {
        [viewController dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
        if(weakSelf.selectedCover){
            weakSelf.selectedCover(cropImage, @"");
        }
    }];
    cropImageViewController.fixCropSize = YES;
    [self presentViewController:cropImageViewController animated:YES completion:^{
    }];
}

//点击cancel 调用的方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self setNavigationBar_kdefaultColor];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 32;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

@end
