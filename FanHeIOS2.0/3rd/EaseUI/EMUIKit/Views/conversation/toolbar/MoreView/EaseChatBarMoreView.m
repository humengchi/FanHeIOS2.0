/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "EaseChatBarMoreView.h"

#define CHAT_BUTTON_SIZE 50
#define INSETS 10
#define MOREVIEW_COL 4
#define MOREVIEW_ROW 2
#define MOREVIEW_BUTTON_TAG 1000

@implementation UIView (MoreView)

- (void)removeAllSubview
{
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}

@end

@interface EaseChatBarMoreView ()<UIScrollViewDelegate>
{
    EMChatToolbarType _type;
    NSInteger _maxIndex;
}

@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIButton *takePicButton;
@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) UIButton *videoButton;
@property (nonatomic, strong) UIButton *audioCallButton;
@property (nonatomic, strong) UIButton *videoCallButton;
@property (nonatomic, strong) UIButton *cardButton;
@end

@implementation EaseChatBarMoreView

+ (void)initialize
{
    // UIAppearance Proxy Defaults
    EaseChatBarMoreView *moreView = [self appearance];
    moreView.moreViewBackgroundColor = [UIColor whiteColor];
}

- (instancetype)initWithFrame:(CGRect)frame type:(EMChatToolbarType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _type = type;
        [self setupSubviewsForType:_type];
    }
    return self;
}

- (void)setupSubviewsForType:(EMChatToolbarType)type
{
    //self.backgroundColor = [UIColor clearColor];
    
    _scrollview = [[UIScrollView alloc] init];
    _scrollview.pagingEnabled = YES;
    _scrollview.showsHorizontalScrollIndicator = NO;
    _scrollview.showsVerticalScrollIndicator = NO;
    _scrollview.delegate = self;
    _scrollview.backgroundColor = HEX_COLOR(@"f5f5f5");
    [self addSubview:_scrollview];
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 0.3)];
    lineLabel.backgroundColor = kCellLineColor;
    [_scrollview addSubview:lineLabel];
    
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = 1;
    [self addSubview:_pageControl];
    
    CGFloat insets = (self.frame.size.width - 4 * CHAT_BUTTON_SIZE) / 5;
    
    _photoButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [_photoButton setFrame:CGRectMake(insets, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
//    [_photoButton setImage:[UIImage imageNamed:@"EaseUIResource.bundle/chatBar_colorMore_photo"] forState:UIControlStateNormal];
//    [_photoButton setImage:[UIImage imageNamed:@"EaseUIResource.bundle/chatBar_colorMore_photoSelected"] forState:UIControlStateHighlighted];
    [_photoButton setImage:[UIImage imageNamed:@"icon_more_picture"] forState:UIControlStateNormal];
    [_photoButton setImage:[UIImage imageNamed:@"icon_more_picture"] forState:UIControlStateHighlighted];
    [_photoButton addTarget:self action:@selector(photoAction) forControlEvents:UIControlEventTouchUpInside];
    _photoButton.tag = MOREVIEW_BUTTON_TAG;
    [_scrollview addSubview:_photoButton];
    UILabel *photoLabel = [UILabel createLabel:CGRectMake(insets, 10+CHAT_BUTTON_SIZE+8,CHAT_BUTTON_SIZE, 10) font:[UIFont systemFontOfSize:12] bkColor:[UIColor clearColor] textColor:[UIColor blackColor]];
    photoLabel.text = @"照片";
    photoLabel.textColor = HEX_COLOR(@"818C9E");
    photoLabel.textAlignment = NSTextAlignmentCenter;
    [_scrollview addSubview:photoLabel];
    
    _locationButton =[UIButton buttonWithType:UIButtonTypeCustom];
     [_locationButton setFrame:CGRectMake(insets * 3 + CHAT_BUTTON_SIZE * 2, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
//    [_locationButton setFrame:CGRectMake(insets * 2 + CHAT_BUTTON_SIZE, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
//    [_locationButton setImage:[UIImage imageNamed:@"EaseUIResource.bundle/chatBar_colorMore_location"] forState:UIControlStateNormal];
    //    [_locationButton setImage:[UIImage imageNamed:@"EaseUIResource.bundle/chatBar_colorMore_locationSelected"] forState:UIControlStateHighlighted];
    [_locationButton setImage:[UIImage imageNamed:@"icon_more_location"] forState:UIControlStateNormal];
    [_locationButton setImage:[UIImage imageNamed:@"icon_more_location"] forState:UIControlStateHighlighted];
    [_locationButton addTarget:self action:@selector(locationAction) forControlEvents:UIControlEventTouchUpInside];
    _locationButton.tag = MOREVIEW_BUTTON_TAG + 1;
    [_scrollview addSubview:_locationButton];
    UILabel *location = [UILabel createLabel:CGRectMake(insets * 3 + CHAT_BUTTON_SIZE * 2, 10+CHAT_BUTTON_SIZE+8,CHAT_BUTTON_SIZE, 10) font:[UIFont systemFontOfSize:12] bkColor:[UIColor clearColor] textColor:[UIColor blackColor]];
    location.text = @"位置";
    location.textColor = HEX_COLOR(@"818C9E");
    location.textAlignment = NSTextAlignmentCenter;
    [_scrollview addSubview:location];
    
    _takePicButton =[UIButton buttonWithType:UIButtonTypeCustom];
      [_takePicButton setFrame:CGRectMake(insets * 2 + CHAT_BUTTON_SIZE, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
//    [_takePicButton setFrame:CGRectMake(insets * 3 + CHAT_BUTTON_SIZE * 2, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
//    [_takePicButton setImage:[UIImage imageNamed:@"EaseUIResource.bundle/chatBar_colorMore_camera"] forState:UIControlStateNormal];
//    [_takePicButton setImage:[UIImage imageNamed:@"EaseUIResource.bundle/chatBar_colorMore_cameraSelected"] forState:UIControlStateHighlighted];
    [_takePicButton setImage:[UIImage imageNamed:@"icon_more_camera"] forState:UIControlStateNormal];
    [_takePicButton setImage:[UIImage imageNamed:@"icon_more_camera"] forState:UIControlStateHighlighted];
    [_takePicButton addTarget:self action:@selector(takePicAction) forControlEvents:UIControlEventTouchUpInside];
    _takePicButton.tag = MOREVIEW_BUTTON_TAG + 2;
    _maxIndex = 2;
    [_scrollview addSubview:_takePicButton];
    UILabel *takePicLabel = [UILabel createLabel:CGRectMake(insets * 2 + CHAT_BUTTON_SIZE, 10+CHAT_BUTTON_SIZE+8,CHAT_BUTTON_SIZE, 10) font:[UIFont systemFontOfSize:12] bkColor:[UIColor clearColor] textColor:[UIColor blackColor]];
    takePicLabel.text = @"拍照";
    takePicLabel.textColor = HEX_COLOR(@"818C9E");
    takePicLabel.textAlignment = NSTextAlignmentCenter;
    [_scrollview addSubview:takePicLabel];


      CGRect frame = self.frame;

        frame.size.height = 160;
        _audioCallButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [_audioCallButton setFrame:CGRectMake(insets * 4 + CHAT_BUTTON_SIZE * 3, 10, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
   
        [_audioCallButton setImage:[UIImage imageNamed:@"btn_dh_gy"] forState:UIControlStateNormal];
        [_audioCallButton setImage:[UIImage imageNamed:@"btn_dh_gy"] forState:UIControlStateHighlighted];
    [_audioCallButton addTarget:self action:@selector(moreSupplyAction:) forControlEvents:UIControlEventTouchUpInside];
        _audioCallButton.tag = MOREVIEW_BUTTON_TAG + 3;
        [_scrollview addSubview:_audioCallButton];
    
    UILabel *pushPicLabel = [UILabel createLabel:CGRectMake(insets * 4 + CHAT_BUTTON_SIZE*3, 10+CHAT_BUTTON_SIZE+8,CHAT_BUTTON_SIZE, 10) font:[UIFont systemFontOfSize:12] bkColor:[UIColor clearColor] textColor:[UIColor blackColor]];
    pushPicLabel.text = @"供应";
    pushPicLabel.textColor = HEX_COLOR(@"818C9E");
    pushPicLabel.textAlignment = NSTextAlignmentCenter;
    [_scrollview addSubview:pushPicLabel];
        
        _videoCallButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [_videoCallButton setFrame:CGRectMake(insets, 10 * 2 + CHAT_BUTTON_SIZE + 14, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
        [_videoCallButton setImage:[UIImage imageNamed:@"btn_dh_xq"] forState:UIControlStateNormal];
        [_videoCallButton setImage:[UIImage imageNamed:@"btn_dh_xq"] forState:UIControlStateHighlighted];
    [_videoCallButton addTarget:self action:@selector(moreNeedAction:) forControlEvents:UIControlEventTouchUpInside];
        _videoCallButton.tag =MOREVIEW_BUTTON_TAG + 4;
        _maxIndex = 4;
        [_scrollview addSubview:_videoCallButton];
    UILabel *needPicLabel = [UILabel createLabel:CGRectMake(insets , (10+CHAT_BUTTON_SIZE+8)*2 -1,CHAT_BUTTON_SIZE, 10) font:[UIFont systemFontOfSize:12] bkColor:[UIColor clearColor] textColor:[UIColor blackColor]];
    needPicLabel.text = @"需求";
    needPicLabel.textColor = HEX_COLOR(@"818C9E");
    needPicLabel.textAlignment = NSTextAlignmentCenter;
    [_scrollview addSubview:needPicLabel];
    
    
    _cardButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [_cardButton setFrame:CGRectMake(insets*2 + CHAT_BUTTON_SIZE, 10 * 2 + CHAT_BUTTON_SIZE + 14, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [_cardButton setImage:[UIImage imageNamed:@"btn_dh_mp"] forState:UIControlStateNormal];
    [_cardButton setImage:[UIImage imageNamed:@"btn_dh_mp"] forState:UIControlStateHighlighted];
    [_cardButton addTarget:self action:@selector(moreCcardAction:) forControlEvents:UIControlEventTouchUpInside];
    _cardButton.tag =MOREVIEW_BUTTON_TAG + 4;
    _maxIndex = 5;
    [_scrollview addSubview:_cardButton];
    UILabel *cardPicLabel = [UILabel createLabel:CGRectMake(insets*2 + CHAT_BUTTON_SIZE, (10+CHAT_BUTTON_SIZE+8)*2 -1,CHAT_BUTTON_SIZE, 10) font:[UIFont systemFontOfSize:12] bkColor:[UIColor clearColor] textColor:[UIColor blackColor]];
    cardPicLabel.text = @"名片";
    cardPicLabel.textColor = HEX_COLOR(@"818C9E");
    cardPicLabel.textAlignment = NSTextAlignmentCenter;
    [_scrollview addSubview:cardPicLabel];

    
    
    

    self.frame = frame;
    _scrollview.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
    _pageControl.frame = CGRectMake(0, CGRectGetHeight(frame) - 20, CGRectGetWidth(frame), 20);
    _pageControl.hidden = _pageControl.numberOfPages<=1;
}

- (void)insertItemWithImage:(UIImage *)image highlightedImage:(UIImage *)highLightedImage title:(NSString *)title
{
    CGFloat insets = (self.frame.size.width - MOREVIEW_COL * CHAT_BUTTON_SIZE) / 5;
    CGRect frame = self.frame;
    _maxIndex++;
    NSInteger pageSize = MOREVIEW_COL*MOREVIEW_ROW;
    NSInteger page = _maxIndex/pageSize;
    NSInteger row = (_maxIndex%pageSize)/MOREVIEW_COL;
    NSInteger col = _maxIndex%MOREVIEW_COL;
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setFrame:CGRectMake(page * CGRectGetWidth(self.frame) + insets * (col + 1) + CHAT_BUTTON_SIZE * col, INSETS + INSETS * 2 * row + CHAT_BUTTON_SIZE * row, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
    [moreButton setImage:image forState:UIControlStateNormal];
    [moreButton setImage:highLightedImage forState:UIControlStateHighlighted];
    [moreButton addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.tag = MOREVIEW_BUTTON_TAG+_maxIndex;
    [_scrollview addSubview:moreButton];
    [_scrollview setContentSize:CGSizeMake(CGRectGetWidth(self.frame) * (page + 1), CGRectGetHeight(self.frame))];
    [_pageControl setNumberOfPages:page + 1];
    if (_maxIndex >=5) {
        frame.size.height = 150;
        _scrollview.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
        _pageControl.frame = CGRectMake(0, CGRectGetHeight(frame) - 20, CGRectGetWidth(frame), 20);
    }
    self.frame = frame;
    _pageControl.hidden = _pageControl.numberOfPages<=1;
}

- (void)updateItemWithImage:(UIImage *)image highlightedImage:(UIImage *)highLightedImage title:(NSString *)title atIndex:(NSInteger)index
{
    UIView *moreButton = [_scrollview viewWithTag:MOREVIEW_BUTTON_TAG+index];
    if (moreButton && [moreButton isKindOfClass:[UIButton class]]) {
        [(UIButton*)moreButton setImage:image forState:UIControlStateNormal];
        [(UIButton*)moreButton setImage:highLightedImage forState:UIControlStateHighlighted];
    }
}

- (void)removeItematIndex:(NSInteger)index
{
    UIView *moreButton = [_scrollview viewWithTag:MOREVIEW_BUTTON_TAG+index];
    if (moreButton && [moreButton isKindOfClass:[UIButton class]]) {
        [self _resetItemFromIndex:index];
        [moreButton removeFromSuperview];
    }
}

#pragma mark - private

- (void)_resetItemFromIndex:(NSInteger)index
{
    CGFloat insets = (self.frame.size.width - MOREVIEW_COL * CHAT_BUTTON_SIZE) / 5;
    CGRect frame = self.frame;
    for (NSInteger i = index + 1; i<_maxIndex + 1; i++) {
        UIView *moreButton = [_scrollview viewWithTag:MOREVIEW_BUTTON_TAG+i];
        if (moreButton && [moreButton isKindOfClass:[UIButton class]]) {
            NSInteger moveToIndex = i - 1;
            NSInteger pageSize = MOREVIEW_COL*MOREVIEW_ROW;
            NSInteger page = moveToIndex/pageSize;
            NSInteger row = (moveToIndex%pageSize)/MOREVIEW_COL;
            NSInteger col = moveToIndex%MOREVIEW_COL;
            [moreButton setFrame:CGRectMake(page * CGRectGetWidth(self.frame) + insets * (col + 1) + CHAT_BUTTON_SIZE * col, INSETS + INSETS * 2 * row + CHAT_BUTTON_SIZE * row, CHAT_BUTTON_SIZE , CHAT_BUTTON_SIZE)];
            moreButton.tag = MOREVIEW_BUTTON_TAG+moveToIndex;
            [_scrollview setContentSize:CGSizeMake(CGRectGetWidth(self.frame) * (page + 1), CGRectGetHeight(self.frame))];
            [_pageControl setNumberOfPages:page + 1];
        }
    }
    _maxIndex--;
    if (_maxIndex >=5) {
        frame.size.height = 150;
    } else {
        frame.size.height = 80;
    }
    self.frame = frame;
    _scrollview.frame = CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame));
    _pageControl.frame = CGRectMake(0, CGRectGetHeight(frame) - 20, CGRectGetWidth(frame), 20);
    _pageControl.hidden = _pageControl.numberOfPages<=1;
}

#pragma setter
//- (void)setMoreViewColumn:(NSInteger)moreViewColumn
//{
//    if (_moreViewColumn != moreViewColumn) {
//        _moreViewColumn = moreViewColumn;
//        [self setupSubviewsForType:_type];
//    }
//}
//
//- (void)setMoreViewNumber:(NSInteger)moreViewNumber
//{
//    if (_moreViewNumber != moreViewNumber) {
//        _moreViewNumber = moreViewNumber;
//        [self setupSubviewsForType:_type];
//    }
//}

- (void)setMoreViewBackgroundColor:(UIColor *)moreViewBackgroundColor
{
    _moreViewBackgroundColor = moreViewBackgroundColor;
    if (_moreViewBackgroundColor) {
        [self setBackgroundColor:_moreViewBackgroundColor];
    }
}

/*
- (void)setMoreViewButtonImages:(NSArray *)moreViewButtonImages
{
    _moreViewButtonImages = moreViewButtonImages;
    if ([_moreViewButtonImages count] > 0) {
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                if (button.tag < [_moreViewButtonImages count]) {
                    NSString *imageName = [_moreViewButtonImages objectAtIndex:button.tag];
                    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
                }
            }
        }
    }
}

- (void)setMoreViewButtonHignlightImages:(NSArray *)moreViewButtonHignlightImages
{
    _moreViewButtonHignlightImages = moreViewButtonHignlightImages;
    if ([_moreViewButtonHignlightImages count] > 0) {
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                if (button.tag < [_moreViewButtonHignlightImages count]) {
                    NSString *imageName = [_moreViewButtonHignlightImages objectAtIndex:button.tag];
                    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateHighlighted];
                }
            }
        }
    }
}*/

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGPoint offset =  scrollView.contentOffset;
    if (offset.x == 0) {
        _pageControl.currentPage = 0;
    } else {
        int page = offset.x / CGRectGetWidth(scrollView.frame);
        _pageControl.currentPage = page;
    }
}

#pragma mark - action
- (void)takePicAction{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if(granted){
            dispatch_async(dispatch_get_main_queue(), ^{
                if(_delegate && [_delegate respondsToSelector:@selector(moreViewTakePicAction:)]){
                    [_delegate moreViewTakePicAction:self];
                }
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setStatusBarHidden:NO];
            });
            [[[CommonUIAlert alloc] init] showCommonAlertView:[self viewController] title:@"" message:@"请在iPhone的“设置>隐私>相机”选项中，允许3号圈访问你的相机" cancelButtonTitle:@"取消" otherButtonTitle:@"设置" cancle:^{
            } confirm:^{
                if(IOS_X >= 10){
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }else{
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
                }
            }];
        }
    }];
}

- (void)photoAction{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == kCLAuthorizationStatusRestricted || author ==kCLAuthorizationStatusDenied){
        [[[CommonUIAlert alloc] init] showCommonAlertView:[self viewController] title:@"" message:@"请在iPhone的“设置>隐私>相册”选项中，允许3号圈+访问你的相册" cancelButtonTitle:@"取消" otherButtonTitle:@"设置" cancle:^{
        } confirm:^{
            if(IOS_X >= 10){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
            }
        }];
    }else{
        if (_delegate && [_delegate respondsToSelector:@selector(moreViewPhotoAction:)]) {
            [_delegate moreViewPhotoAction:self];
        }
    }
}

- (void)locationAction{
    if ([CLLocationManager authorizationStatus] ==kCLAuthorizationStatusDenied) {
        [[[CommonUIAlert alloc] init] showCommonAlertView:[self viewController] title:@"" message:@"请在iPhone的“设置>隐私>位置”选项中，允许3号圈访问你的位置" cancelButtonTitle:@"取消" otherButtonTitle:@"设置" cancle:^{
        } confirm:^{
            if(IOS_X >= 10){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy"]];
            }
        }];
    }else{
        if (_delegate && [_delegate respondsToSelector:@selector(moreViewLocationAction:)]) {
            [_delegate moreViewLocationAction:self];
        }
    }
}

- (void)takeAudioCallAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewAudioCallAction:)]) {
        [_delegate moreViewAudioCallAction:self];
    }
}

- (void)takeVideoCallAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewVideoCallAction:)]) {
        [_delegate moreViewVideoCallAction:self];
    }
}

- (void)moreAction:(id)sender
{
    UIButton *button = (UIButton*)sender;
    if (button && _delegate && [_delegate respondsToSelector:@selector(moreView:didItemInMoreViewAtIndex:)]) {
        [_delegate moreView:self didItemInMoreViewAtIndex:button.tag-MOREVIEW_BUTTON_TAG];
    }
}
- (void)moreSupplyAction:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewSupplyAction:)]) {
        [_delegate moreViewSupplyAction:self];
    }
}
- (void)moreNeedAction:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewNeedAction:)]) {
        [_delegate moreViewNeedAction:self];
    }
}
- (void)moreCcardAction:(id)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(moreViewCardAction:)]) {
        [_delegate moreViewCardAction:self];
    }
}
@end
