//
//  CreateTAAView.m
//  FanHeIOS2.0
//
//  Created by 胡梦驰 on 2017/3/1.
//  Copyright © 2017年 胡梦驰. All rights reserved.
//

#import "CreateTAAView.h"
#import "InformationDetailController.h"
#import "ActivityDetailController.h"
#import "TopicViewController.h"

@interface CreateTAAView ()

@property (nonatomic, strong) DynamicModel *model;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *onlyTitleLabel;

@end

@implementation CreateTAAView


- (void)drawRect:(CGRect)rect {
    [CommonMethod viewAddGuestureRecognizer:self tapsNumber:1 withTarget:self withSEL:@selector(gotoDetailButtonClicked)];
}

- (void)updateDisplay:(DynamicModel*)model{
    self.model = model;
    self.onlyTitleLabel.backgroundColor = self.backgroundColor;
    //资讯
    if([CommonMethod paramNumberIsNull:model.parent_post_id].integerValue){
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.parent_post_image] placeholderImage:kImageWithName(@"icon_dtfx_wz") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if(image){
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *newImage = [self scaleImage:image];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageView.image = newImage;
                    });
                });
            }
        }];
        self.onlyTitleLabel.hidden = NO;
        self.timeLabel.hidden = YES;
        self.titleLabel.hidden = YES;
        self.onlyTitleLabel.text = model.parent_post_title;
    }
    if([CommonMethod paramNumberIsNull:model.post_id].integerValue){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.post_image] placeholderImage:kImageWithName(@"icon_dtfx_wz") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if(image){
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        UIImage *newImage = [self scaleImage:image];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.imageView.image = newImage;
                        });
                    });
                }
            }];
        });
        
        self.onlyTitleLabel.hidden = NO;
        self.timeLabel.hidden = YES;
        self.titleLabel.hidden = YES;
        self.onlyTitleLabel.text = model.post_title;
    }
    //活动
    if([CommonMethod paramNumberIsNull:model.parent_activity_id].integerValue){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.parent_activity_image] placeholderImage:kImageWithName(@"icon_dtfx_hd") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if(image){
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        UIImage *newImage = [self scaleImage:image];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.imageView.image = newImage;
                        });
                    });
                }
            }];
        });
        self.onlyTitleLabel.hidden = YES;
        self.timeLabel.hidden = NO;
        self.titleLabel.hidden = NO;
        self.timeLabel.text = model.parent_activity_timestr;
        self.titleLabel.text = model.parent_activity_title;
    }
    if([CommonMethod paramNumberIsNull:model.activity_id].integerValue){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.activity_image] placeholderImage:kImageWithName(@"icon_dtfx_hd") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if(image){
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        UIImage *newImage = [self scaleImage:image];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.imageView.image = newImage;
                        });
                    });
                }
            }];
        });
        self.onlyTitleLabel.hidden = YES;
        self.timeLabel.hidden = NO;
        self.titleLabel.hidden = NO;
        self.timeLabel.text = model.activity_timestr;
        self.titleLabel.text = model.activity_title;
    }
    //话题
    if([CommonMethod paramNumberIsNull:model.parent_subject_id].integerValue){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.parent_subject_photo] placeholderImage:kImageWithName(@"icon_dtfx_ht") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if(image){
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        UIImage *newImage = [self scaleImage:image];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.imageView.image = newImage;
                        });
                    });
                }
            }];
        });
        self.onlyTitleLabel.hidden = NO;
        self.timeLabel.hidden = YES;
        self.titleLabel.hidden = YES;
        self.onlyTitleLabel.text = model.parent_subject_title;
    }
    if([CommonMethod paramNumberIsNull:model.subject_id].integerValue){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.subject_photo] placeholderImage:kImageWithName(@"icon_dtfx_ht") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if(image){
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        UIImage *newImage = [self scaleImage:image];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.imageView.image = newImage;
                        });
                    });
                }
            }];
        });
        self.onlyTitleLabel.hidden = NO;
        self.timeLabel.hidden = YES;
        self.titleLabel.hidden = YES;
        self.onlyTitleLabel.text = model.subject_title;
    }
}

- (UIImage*)scaleImage:(UIImage*)originImage{
    CGSize retSize = originImage.size;
    CGFloat sizeWidth = MIN(retSize.width, retSize.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([originImage CGImage], CGRectMake((retSize.width-sizeWidth)/2, (retSize.height-sizeWidth)/2, sizeWidth, sizeWidth));//获取图片整体部分
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:originImage.scale orientation:UIImageOrientationUp];
    return image;
}

- (void)gotoDetailButtonClicked{
    //资讯
    if([CommonMethod paramNumberIsNull:self.model.parent_post_id].integerValue){
        InformationDetailController *vc = [[InformationDetailController alloc] init];
        vc.postID = self.model.parent_post_id;
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
    if([CommonMethod paramNumberIsNull:self.model.post_id].integerValue){
        InformationDetailController *vc = [[InformationDetailController alloc] init];
        vc.postID = self.model.post_id;
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
    //活动
    if([CommonMethod paramNumberIsNull:self.model.parent_activity_id].integerValue){
        ActivityDetailController *vc = [[ActivityDetailController alloc] init];
        vc.activityid = self.model.parent_activity_id;
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
    if([CommonMethod paramNumberIsNull:self.model.activity_id].integerValue){
        ActivityDetailController *vc = [[ActivityDetailController alloc] init];
        vc.activityid = self.model.activity_id;
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
    //话题
    if([CommonMethod paramNumberIsNull:self.model.parent_subject_id].integerValue){
        TopicViewController *vc = [[TopicViewController alloc] init];
        vc.subjectId = self.model.parent_subject_id;
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
    if([CommonMethod paramNumberIsNull:self.model.subject_id].integerValue){
        TopicViewController *vc = [[TopicViewController alloc] init];
        vc.subjectId = self.model.subject_id;
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
}

@end
