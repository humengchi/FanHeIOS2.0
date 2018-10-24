//
//  EaseMessageViewController.m
//  ChatDemo-UI3.0
//
//  Created by dhc on 15/6/26.
//  Copyright (c) 2015年 easemob.com. All rights reserved.
//

#import "EaseMessageViewController.h"

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "NSDate+Category.h"
#import "EaseUsersListViewController.h"
#import "EaseMessageReadManager.h"
#import "EaseEmotionManager.h"
#import "EaseEmoji.h"
#import "EaseEmotionEscape.h"
#import "EaseCustomMessageCell.h"
#import "UIImage+GIF.h"
#import "SendCardCell.h"
#import "SendScanCardCell.h"
#import "SupplyAndNeedMyCell.h"
#import "ActivityDetailController.h"
#import "NotPassController.h"
#import "PassReviewController.h"
#import "MyCofferViewController.h"
#import "ShareNormalView.h"
#import "GetWallCoffeeDetailViewController.h"
#import <MessageUI/MessageUI.h>
#import "NewFriendsController.h"
#import "TopicViewController.h"
#import "EditPersonalInfoViewController.h"
#import "VariousDetailController.h"
#import "InformationDetailController.h"
#import "TicketDetailViewController.h"

#import "ViewpointDetailViewController.h"
#import "CommentPersonController.h"
#import "CardDetailViewController.h"
#import "CardManagerViewController.h"
#import "NeedSupplyListController.h"

#define KHintAdjustY    50

#define IOS_VERSION [[UIDevice currentDevice] systemVersion]>=9.0

@interface EaseMessageViewController ()<EaseMessageCellDelegate,MFMessageComposeViewControllerDelegate>
{
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    UILongPressGestureRecognizer *_lpgr;
    
    dispatch_queue_t _messageQueue;
    NSInteger   _coffeeSum;
     NSMutableArray *_atTargets;
    BOOL _isSendLocation;
}

@property (strong, nonatomic) id<IMessageModel> playingVoiceModel;
@property (nonatomic) BOOL isKicked;
@property (nonatomic) BOOL isPlayingAudio;

@end

@implementation EaseMessageViewController

@synthesize conversation = _conversation;
@synthesize deleteConversationIfNull = _deleteConversationIfNull;
@synthesize messageCountOfPage = _messageCountOfPage;
@synthesize timeCellHeight = _timeCellHeight;
@synthesize messageTimeIntervalTag = _messageTimeIntervalTag;

- (instancetype)initWithConversationChatter:(NSString *)conversationChatter
                           conversationType:(EMConversationType)conversationType
{
    if ([conversationChatter length] == 0) {
        return nil;
    }
    
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _conversation = [[EMClient sharedClient].chatManager getConversation:conversationChatter type:conversationType createIfNotExist:YES];
        
        _messageCountOfPage = 10;
        _timeCellHeight = 30;
        _deleteConversationIfNull = YES;
        _scrollToBottomWhenAppear = YES;
        _messsagesSource = [NSMutableArray array];
        
        [_conversation markAllMessagesAsRead:nil];
    }
    
    return self;
}
#pragma mark - 获取咖啡总数
- (void)getCoffeeCountNumHttpShare{
    [self requstType:RequestType_Get apiName:API_NAME_USER_GET_COFF_COUNT paramDict:nil hud:nil success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            _coffeeSum = [responseObject[@"data"] integerValue];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self getCoffeeCountNumHttpShare];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:248 / 255.0 green:248 / 255.0 blue:248 / 255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //初始化页面
    CGFloat chatbarHeight = [EaseChatToolbar defaultHeight];
    EMChatToolbarType barType = self.conversation.type == EMConversationTypeChat ? EMChatToolbarTypeChat : EMChatToolbarTypeGroup;
    
    self.chatToolbar = [[EaseChatToolbar alloc] initWithFrame:CGRectMake(0, HEIGHT - chatbarHeight, WIDTH, chatbarHeight) type:barType ];
//    self.chatToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;    
    
    //初始化手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden:)];
    [self.view addGestureRecognizer:tap];
    
    _lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _lpgr.minimumPressDuration = 0.5;
    [self.tableView addGestureRecognizer:_lpgr];
    
    _messageQueue = dispatch_queue_create("easemob.com", NULL);
    
    //注册代理
    [EMCDDeviceManager sharedInstance].delegate = self;
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].roomManager addDelegate:self delegateQueue:nil];

    if (self.conversation.type == EMConversationTypeChatRoom)
    {
        [self joinChatroom:self.conversation.conversationId];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
   
}
#pragma mark ------groupMemberViewControllerDelegate
- (BOOL)didInputAtInLocation:(NSUInteger)location
{
    if ([self.delegate respondsToSelector:@selector(messageViewController:selectAtTarget:)] && self.conversation.type == EMConversationTypeGroupChat) {
        location += 1;
        __weak typeof(self) weakSelf = self;
        [self.delegate messageViewController:self selectAtTarget:^(ChartModel *target) {
            __strong EaseMessageViewController *strongSelf = weakSelf;
            if (strongSelf && target) {
                if ([target.userid.stringValue length] || [target.realname length]) {
                    [strongSelf.atTargets addObject:target];
                    NSString *insertStr = [NSString stringWithFormat:@"%@ ", target.realname ? target.realname : target.userid];
                    EaseChatToolbar *toolbar = (EaseChatToolbar*)strongSelf.chatToolbar;
                    NSMutableString *originStr = [toolbar.inputTextView.text mutableCopy];
                    NSUInteger insertLocation = location > originStr.length ? originStr.length : location;
                    [originStr insertString:insertStr atIndex:insertLocation];
                    toolbar.inputTextView.text = originStr;
                    toolbar.inputTextView.selectedRange = NSMakeRange(insertLocation + insertStr.length, 0);
                    [toolbar.inputTextView becomeFirstResponder];
                }
            }
            else if (strongSelf) {
                EaseChatToolbar *toolbar = (EaseChatToolbar*)strongSelf.chatToolbar;
                [toolbar.inputTextView becomeFirstResponder];
            }
        }];
        EaseChatToolbar *toolbar = (EaseChatToolbar*)self.chatToolbar;
        toolbar.inputTextView.text = [NSString stringWithFormat:@"%@@", toolbar.inputTextView.text];
        [toolbar.inputTextView resignFirstResponder];
        return YES;
    }
    else {
        return NO;
    }
}



- (void)setupEmotion{
    if ([self.dataSource respondsToSelector:@selector(emotionFormessageViewController:)]) {
        NSArray* emotionManagers = [self.dataSource emotionFormessageViewController:self];
        [self.faceView setEmotionManagers:emotionManagers];
    } else {
        NSMutableArray *emotions = [NSMutableArray array];
        for (NSString *name in [EaseEmoji allEmoji]) {
            EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:name emotionThumbnail:name emotionOriginal:name emotionOriginalURL:@"" emotionType:EMEmotionDefault];
            [emotions addObject:emotion];
        }
        EaseEmotion *emotion = [emotions objectAtIndex:0];
        EaseEmotionManager *manager= [[EaseEmotionManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:emotions tagImage:[UIImage imageNamed:emotion.emotionId]];
        [self.faceView setEmotionManagers:@[manager]];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [EMCDDeviceManager sharedInstance].delegate = nil;
    
    if (_imagePicker){
        [_imagePicker dismissViewControllerAnimated:NO completion:nil];
        _imagePicker = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(self.isPushVC){
        self.isPushVC = NO;
        return;
    }
    _messageQueue = dispatch_queue_create("easemob.com", NULL);
    self.isViewDidAppear = YES;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
    
    if (self.scrollToBottomWhenAppear) {
        [self _scrollViewToBottom:NO];
    }
    self.scrollToBottomWhenAppear = YES;
    
    if(_isSendLocation == NO){
        [self.dataArray removeAllObjects];
        [self.messsagesSource removeAllObjects];
        [self tableViewDidTriggerHeaderRefresh];
    }
    _isSendLocation = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.isViewDidAppear = NO;
    [_conversation markAllMessagesAsRead:nil];
    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
}

#pragma mark - chatroom
- (void)saveChatroom:(EMChatroom *)chatroom{
    NSString *chatroomName = chatroom.subject ? chatroom.subject : @"";
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"OnceJoinedChatrooms_%@", [[EMClient sharedClient] currentUsername]];
    NSMutableDictionary *chatRooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
    if (![chatRooms objectForKey:chatroom.chatroomId]){
        [chatRooms setObject:chatroomName forKey:chatroom.chatroomId];
        [ud setObject:chatRooms forKey:key];
        [ud synchronize];
    }
}

- (void)joinChatroom:(NSString *)chatroomId{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"chatroom.joining",@"Joining the chatroom")];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        EMChatroom *chatroom = [[EMClient sharedClient].roomManager joinChatroom:chatroomId error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf) {
                EaseMessageViewController *strongSelf = weakSelf;
                [strongSelf hideHud];
                if (error != nil) {
                    [strongSelf showHint:[NSString stringWithFormat:NSLocalizedString(@"chatroom.joinFailed",@"join chatroom \'%@\' failed"), chatroomId]];
                } else {
                    [strongSelf saveChatroom:chatroom];
                }
            }  else {
                if (!error || (error.code == EMErrorChatroomAlreadyJoined)) {
                    EMError *leaveError;
                    [[EMClient sharedClient].roomManager leaveChatroom:chatroomId error:&leaveError];
                    if (leaveError == nil) {
                        [[EMClient sharedClient].chatManager deleteConversation:chatroomId isDeleteMessages:YES completion:nil];
                    }
                }
            }
        });
    });
}

#pragma mark - EMChatManagerChatroomDelegate
- (void)didReceiveUserJoinedChatroom:(EMChatroom *)aChatroom
                            username:(NSString *)aUsername{

}

- (void)didReceiveUserLeavedChatroom:(EMChatroom *)aChatroom
                            username:(NSString *)aUsername{
}

- (void)didReceiveKickedFromChatroom:(EMChatroom *)aChatroom
                              reason:(EMChatroomBeKickedReason)aReason{
    if ([_conversation.conversationId isEqualToString:aChatroom.chatroomId]){
        _isKicked = YES;
//        CGRect frame = self.chatToolbar.frame;
//        [self showHint:[NSString stringWithFormat:NSEaseLocalizedString(@"chatroom.remove", @"be removed from chatroom\'%@\'"), aChatroom.chatroomId] yOffset:-frame.size.height + KHintAdjustY];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - getter
- (UIImagePickerController *)imagePicker{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.navigationBar.backgroundColor = kDefaultColor;
      
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.delegate = self;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {        //判断当前设备的系统是否是ios7.0以上
            _imagePicker.edgesForExtendedLayout = UIRectEdgeNone;
        }
        _imagePicker.navigationBar.translucent = NO;
    }
    return _imagePicker;
}

#pragma mark - setter
- (void)setIsViewDidAppear:(BOOL)isViewDidAppear{
    _isViewDidAppear =isViewDidAppear;
    if (_isViewDidAppear){
        NSMutableArray *unreadMessages = [NSMutableArray array];
        for (EMMessage *message in self.messsagesSource){
            if ([self _shouldSendHasReadAckForMessage:message read:NO]){
                [unreadMessages addObject:message];
            }
        }
        if ([unreadMessages count]){
            [self _sendHasReadResponseForMessages:unreadMessages isRead:YES];
        }
        [_conversation markAllMessagesAsRead:nil];
    }
}

- (void)setChatToolbar:(EaseChatToolbar *)chatToolbar{
    [_chatToolbar removeFromSuperview];
    
    _chatToolbar = chatToolbar;
    if (_chatToolbar) {
        [self.view addSubview:_chatToolbar];
    }
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = HEIGHT - _chatToolbar.frame.size.height -64;
    self.tableView.frame = tableFrame;
    if ([chatToolbar isKindOfClass:[EaseChatToolbar class]]) {
        [(EaseChatToolbar *)self.chatToolbar setDelegate:self];
        self.chatBarMoreView = (EaseChatBarMoreView*)[(EaseChatToolbar *)self.chatToolbar moreView];
        self.faceView = (EaseFaceView*)[(EaseChatToolbar *)self.chatToolbar faceView];
        self.recordView = (EaseRecordView*)[(EaseChatToolbar *)self.chatToolbar recordView];
    }
}

- (void)setDataSource:(id<EaseMessageViewControllerDataSource>)dataSource{
    _dataSource = dataSource;
    [self setupEmotion];
}

- (void)setDelegate:(id<EaseMessageViewControllerDelegate>)delegate{
    _delegate = delegate;
}

#pragma mark - private helper
- (void)_scrollViewToBottom:(BOOL)animated{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height){
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:animated];
    }
}

- (BOOL)_canRecord{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending){
    }
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            bCanRecord = granted;
            if(granted == NO){
                [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"请在iPhone的“设置>隐私>麦克风”选项中，允许3号圈访问你的麦克风" cancelButtonTitle:@"取消" otherButtonTitle:@"设置" cancle:^{
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
    
    return bCanRecord;
}

- (void)_showMenuViewController:(UIView *)showInView
                   andIndexPath:(NSIndexPath *)indexPath
                    messageType:(EMMessageBodyType)messageType{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    
    if (_deleteMenuItem == nil) {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteMenuAction:)];
    }
    if (_copyMenuItem == nil ) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyMenuAction:)];
    }
    if (messageType == EMMessageBodyTypeText) {
        [_menuController setMenuItems:@[_copyMenuItem, _deleteMenuItem]];
    } else {
        [_menuController setMenuItems:@[_deleteMenuItem]];
    }
    [_menuController setTargetRect:showInView.frame inView:showInView.superview];
    [_menuController setMenuVisible:YES animated:YES];
}

- (void)_stopAudioPlayingWithChangeCategory:(BOOL)isChange{
    //停止音频播放及播放动画
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
    [EMCDDeviceManager sharedInstance].delegate = nil;
    
    //    MessageModel *playingModel = [self.EaseMessageReadManager stopMessageAudioModel];
    //    NSIndexPath *indexPath = nil;
    //    if (playingModel) {
    //        indexPath = [NSIndexPath indexPathForRow:[self.dataSource indexOfObject:playingModel] inSection:0];
    //    }
    //
    //    if (indexPath) {
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            [self.tableView beginUpdates];
    //            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    //            [self.tableView endUpdates];
    //        });
    //    }
}

- (NSURL *)_convert2Mp4:(NSURL *)movUrl{
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
        mp4Url = [movUrl copy];
        mp4Url = [mp4Url URLByDeletingPathExtension];
        mp4Url = [mp4Url URLByAppendingPathExtension:@"mp4"];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
//                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
//                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
//                    NSLog(@"completed.");
                } break;
                default: {
//                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
//            NSLog(@"timeout.");
        }
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return mp4Url;
}

- (EMChatType)_messageTypeFromConversationType{
    EMChatType type = EMChatTypeChat;
    switch (self.conversation.type) {
        case EMConversationTypeChat:
            type = EMChatTypeChat;
            break;
        case EMConversationTypeGroupChat:
            type = EMChatTypeGroupChat;
            break;
        case EMConversationTypeChatRoom:
            type = EMChatTypeChatRoom;
            break;
        default:
            break;
    }
    return type;
}

- (void)_downloadMessageAttachments:(EMMessage *)message{
    __weak typeof(self) weakSelf = self;
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        if (!error)
        {
            [weakSelf _reloadTableViewDataWithMessage:message];
        }
    };
    
    EMMessageBody *messageBody = message.body;
    if ([messageBody type] == EMMessageBodyTypeImage) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)messageBody;
        if (imageBody.thumbnailDownloadStatus > EMDownloadStatusSuccessed)
        {
            //下载缩略图
            [[[EMClient sharedClient] chatManager] downloadMessageThumbnail:message progress:^(int progress) {
                
            } completion:^(EMMessage *message, EMError *error) {
                
            }];
           
        }
    }
    else if ([messageBody type] == EMMessageBodyTypeVideo)
    {
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)messageBody;
        if (videoBody.thumbnailDownloadStatus > EMDownloadStatusSuccessed)
        {
            //下载缩略图
            [[[EMClient sharedClient] chatManager] downloadMessageThumbnail:message progress:^(int progress) {
                
            } completion:^(EMMessage *message, EMError *error) {
                
            }];

        }
    }
    else if ([messageBody type] == EMMessageBodyTypeVoice)
    {
        EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody*)messageBody;
        if (voiceBody.downloadStatus > EMDownloadStatusSuccessed)
        {
             //下载语言
            [[EMClient sharedClient].chatManager downloadMessageAttachment:message progress:^(int progress) {
                
            } completion:^(EMMessage *message, EMError *error) {
                
            }];
            
        }
    }
}

- (BOOL)_shouldSendHasReadAckForMessage:(EMMessage *)message
                                   read:(BOOL)read
{
    NSString *account = [[EMClient sharedClient] currentUsername];
    if (message.chatType != EMChatTypeChat || message.isReadAcked || [account isEqualToString:message.from] || ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || !self.isViewDidAppear)
    {
        return NO;
    }
    
    EMMessageBody *body = message.body;
    if (((body.type == EMMessageBodyTypeVideo) ||
         (body.type == EMMessageBodyTypeVoice) ||
         (body.type == EMMessageBodyTypeImage)) &&
        !read)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}


- (void)_sendHasReadResponseForMessages:(NSArray*)messages
                                 isRead:(BOOL)isRead
{
    NSMutableArray *unreadMessages = [NSMutableArray array];
    for (NSInteger i = 0; i < [messages count]; i++)
    {
        EMMessage *message = messages[i];
        BOOL isSend = YES;
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:shouldSendHasReadAckForMessage:read:)]) {
            isSend = [_dataSource messageViewController:self
                         shouldSendHasReadAckForMessage:message read:NO];
        }
        else{
            isSend = [self _shouldSendHasReadAckForMessage:message read:isRead];
        }
        
        if (isSend)
        {
            [unreadMessages addObject:message];
        }
    }
    
    if ([unreadMessages count])
    {
        for (EMMessage *message in unreadMessages)
        {
            [[EMClient sharedClient].chatManager sendMessageReadAck:message completion:^(EMMessage *aMessage, EMError *aError) {
                
            }];
        }
    }
}

- (BOOL)_shouldMarkMessageAsRead
{
    BOOL isMark = YES;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewControllerShouldMarkMessagesAsRead:)]) {
        isMark = [_dataSource messageViewControllerShouldMarkMessagesAsRead:self];
    }
    else{
        if (([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || !self.isViewDidAppear)
        {
            isMark = NO;
        }
    }
    
    return isMark;
}

- (void)_locationMessageCellSelected:(id<IMessageModel>)model
{
    _scrollToBottomWhenAppear = NO;
    
    EaseLocationViewController *locationController = [[EaseLocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(model.latitude, model.longitude)];
    _isSendLocation = YES;
    [self.navigationController pushViewController:locationController animated:YES];
}

- (void)_videoMessageCellSelected:(id<IMessageModel>)model
{
    _scrollToBottomWhenAppear = NO;
    
    EMVideoMessageBody *videoBody = (EMVideoMessageBody*)model.message.body;
    
    //判断本地路劲是否存在
    NSString *localPath = [model.fileLocalPath length] > 0 ? model.fileLocalPath : videoBody.localPath;
    if ([localPath length] == 0) {

        return;
    }
    
    dispatch_block_t block = ^{
        //发送已读回执
        [self _sendHasReadResponseForMessages:@[model.message]
                                       isRead:YES];
        
        NSURL *videoURL = [NSURL fileURLWithPath:localPath];
        MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        [moviePlayerController.moviePlayer prepareToPlay];
        moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
    };
    
    __weak typeof(self) weakSelf = self;
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        if (!error)
        {
            [weakSelf _reloadTableViewDataWithMessage:aMessage];
        }
    };
    
    if (videoBody.thumbnailDownloadStatus == EMDownloadStatusFailed || ![[NSFileManager defaultManager] fileExistsAtPath:videoBody.thumbnailLocalPath]) {
        [self showHint:@"begin downloading thumbnail image, click later"];
          [[EMClient sharedClient].chatManager downloadMessageThumbnail:model.message progress:^(int progress) {
              
          } completion:^(EMMessage *message, EMError *error) {
              
          }];
              return;
    }
    
    if (videoBody.downloadStatus == EMDownloadStatusSuccessed && [[NSFileManager defaultManager] fileExistsAtPath:localPath])
    {
        block();
        return;
    }

     [[EMClient sharedClient].chatManager  downloadMessageAttachment:model.message progress:^(int progress) {
         
     } completion:^(EMMessage *message, EMError *error) {
         
     }];
 
}

- (void)_imageMessageCellSelected:(id<IMessageModel>)model{
    __weak EaseMessageViewController *weakSelf = self;
    EMImageMessageBody *imageBody = (EMImageMessageBody*)[model.message body];
    if ([imageBody type] == EMMessageBodyTypeImage) {
        if (imageBody.thumbnailDownloadStatus == EMDownloadStatusFailed) {
            [[EMClient sharedClient].chatManager downloadMessageThumbnail:model.message progress:^(int progress) {
            }completion:^(EMMessage *message, EMError *error) {
                if (!error) {
                    [weakSelf _reloadTableViewDataWithMessage:model.message];
                }
            }];
        }
        //发送已读回执
        [self _sendHasReadResponseForMessages:@[model.message] isRead:YES];
        [self.conversation loadMessagesWithType:EMMessageBodyTypeImage timestamp:-1 count:10000 fromUser:@"" searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
            __block NSMutableArray *array = [NSMutableArray arrayWithCapacity:aMessages.count];
            NSUInteger index = 0;
            NSUInteger currentIndex = 0;
            for(EMMessage *tmpMessage in aMessages){
                if(tmpMessage == nil){
                    [array addObject:KWidthImageDefault];
                    index++;
                    continue;
                }
                //定位点击的位置index
                if(tmpMessage.timestamp == model.message.timestamp){
                    currentIndex = index;
                }
                EMImageMessageBody *imageBodyTmp = (EMImageMessageBody*)[tmpMessage body];
                if (imageBodyTmp.downloadStatus == EMDownloadStatusSuccessed){
                    NSString *localPath = imageBodyTmp.localPath;
                    if (localPath && localPath.length > 0) {
                        UIImage *imageTmp = [UIImage imageWithContentsOfFile:localPath];
                        if(imageTmp){
                            [array addObject:imageTmp];
                            index++;
                            continue;
                        }
                    }
                }
                [array addObject:KWidthImageDefault];
                __block NSInteger insertIndex = index;
                [[EMClient sharedClient].chatManager downloadMessageAttachment:tmpMessage progress:^(int progress) {
                } completion:^(EMMessage *message, EMError *error) {
                    if (!error) {
                        EMImageMessageBody *imageBodyDown = (EMImageMessageBody*)[message body];
                        UIImage *imageTmp;
                        if (imageBodyTmp.downloadStatus == EMDownloadStatusSuccessed){
                            NSString *localPath = imageBodyDown.localPath;
                            NSString *thumbnailLocalPath = imageBodyDown.thumbnailLocalPath;
                            if ([CommonMethod paramStringIsNull:localPath]) {
                                imageTmp = [UIImage imageWithContentsOfFile:localPath];
                            }
                            if(imageTmp == nil){
                                imageTmp = [UIImage imageWithContentsOfFile:thumbnailLocalPath];
                            }
                        }
                        if(imageTmp){
                            [array replaceObjectAtIndex:insertIndex withObject:imageTmp];
                        }else{
                            [array replaceObjectAtIndex:insertIndex withObject:KWidthImageDefault];
                        }
                    }else{
                        [array replaceObjectAtIndex:insertIndex withObject:KWidthImageDefault];
                    }
                }];
                index++;
            }
            [[EaseMessageReadManager defaultManager] showBrowserWithImages:array];
            [[[EaseMessageReadManager defaultManager] photoBrowser] setCurrentPhotoIndex:currentIndex];
            _isSendLocation = YES;
        }];
    }
}

- (void)_audioMessageCellSelected:(id<IMessageModel>)model
{
    _scrollToBottomWhenAppear = NO;
    EMVoiceMessageBody *body = (EMVoiceMessageBody*)model.message.body;
    EMDownloadStatus downloadStatus = [body downloadStatus];
    if (downloadStatus == EMDownloadStatusDownloading) {

        return;
    }
    else if (downloadStatus == EMDownloadStatusFailed)
    {
         [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:^(int progress) {
             
         } completion:^(EMMessage *message, EMError *error) {
             
         }];
       
        return;
    }
    
    // 播放音频
    if (model.bodyType == EMMessageBodyTypeVoice) {
        //发送已读回执
        [self _sendHasReadResponseForMessages:@[model.message] isRead:YES];
        __weak EaseMessageViewController *weakSelf = self;
        BOOL isPrepare = [[EaseMessageReadManager defaultManager] prepareMessageAudioModel:model updateViewCompletion:^(EaseMessageModel *prevAudioModel, EaseMessageModel *currentAudioModel) {
            if (prevAudioModel || currentAudioModel) {
                [weakSelf.tableView reloadData];
            }
        }];
        
        if (isPrepare) {
            _isPlayingAudio = YES;
            __weak EaseMessageViewController *weakSelf = self;
            [[EMCDDeviceManager sharedInstance] enableProximitySensor];
            [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:model.fileLocalPath completion:^(NSError *error) {
                [[EaseMessageReadManager defaultManager] stopMessageAudioModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                    weakSelf.isPlayingAudio = NO;
                    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
                });
            }];
        }
        else{
            _isPlayingAudio = NO;
        }
    }
}

#pragma mark - pivate data

- (void)_loadMessagesBefore:(NSString*)messageId
                      count:(NSInteger)count
                     append:(BOOL)isAppend
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *moreMessages = nil;
             
        if (weakSelf.dataSource && [weakSelf.dataSource respondsToSelector:@selector(messageViewController:loadMessageFromTimestamp:count:)]) {
     //    moreMessages = [weakSelf.dataSource messageViewController:weakSelf loadMessageFromTimestamp:timestamp count:count];
        }
        else{
                moreMessages = [weakSelf.conversation loadMoreMessagesFromId:messageId limit:(int)count direction:EMMessageSearchDirectionUp];
        }
      
        if (moreMessages == nil || [moreMessages count] == 0) {
            return;
        }
             
        //格式化消息
        NSArray *formattedMessages = [weakSelf formatMessages:moreMessages];
        
        NSInteger scrollToIndex = 0;
        if (isAppend) {
            [weakSelf.messsagesSource insertObjects:moreMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [moreMessages count])]];
            
            //合并消息
            id object = [weakSelf.dataArray firstObject];
            if ([object isKindOfClass:[NSString class]])
            {
                NSString *timestamp = object;
                [formattedMessages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id model, NSUInteger idx, BOOL *stop) {
                    if ([model isKindOfClass:[NSString class]] && [timestamp isEqualToString:model])
                    {
                        [weakSelf.dataArray removeObjectAtIndex:0];
                        *stop = YES;
                    }
                }];
            }
            scrollToIndex = [weakSelf.dataArray count];
            [weakSelf.dataArray insertObjects:formattedMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [formattedMessages count])]];
        }
        else{
            [weakSelf.messsagesSource removeAllObjects];
            [weakSelf.messsagesSource addObjectsFromArray:moreMessages];
            
            [weakSelf.dataArray removeAllObjects];
            [weakSelf.dataArray addObjectsFromArray:formattedMessages];
        }
        
        EMMessage *latest = [weakSelf.messsagesSource lastObject];
        weakSelf.messageTimeIntervalTag = latest.timestamp;
        
        //刷新页面
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.005 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSInteger row = [weakSelf.dataArray count] - scrollToIndex - 1;
                if(row<0){
                    row = 0;
                }
                [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            });
        });
        
        //从数据库导入时重新下载没有下载成功的附件
        for (EMMessage *message in moreMessages)
        {
            [weakSelf _downloadMessageAttachments:message];
        }
        
        //发送已读回执
        [weakSelf _sendHasReadResponseForMessages:moreMessages
                                       isRead:NO];
    });
}

#pragma mark - GestureRecognizer

// 点击背景隐藏
-(void)keyBoardHidden:(UITapGestureRecognizer *)tapRecognizer
{
    if (tapRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.chatToolbar endEditing:YES];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan && [self.dataArray count] > 0)
    {
        CGPoint location = [recognizer locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
        BOOL canLongPress = NO;
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:canLongPressRowAtIndexPath:)]) {
            canLongPress = [_dataSource messageViewController:self
                                   canLongPressRowAtIndexPath:indexPath];
        }
        
        if (!canLongPress) {
            return;
        }
        
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:didLongPressRowAtIndexPath:)]) {
            [_dataSource messageViewController:self
                    didLongPressRowAtIndexPath:indexPath];
        }
        else{
            id object = [self.dataArray objectAtIndex:indexPath.row];
            if (![object isKindOfClass:[NSString class]]) {
                EaseMessageCell *cell = (EaseMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [cell becomeFirstResponder];
                _menuIndexPath = indexPath;
                [self _showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.model.bodyType];
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    
    //时间cell
    if ([object isKindOfClass:[NSString class]]) {
        NSString *TimeCellIdentifier = [EaseMessageTimeCell cellIdentifier];
        EaseMessageTimeCell *timeCell = (EaseMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
        
        if (timeCell == nil) {
            timeCell = [[EaseMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier];
            timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        timeCell.title = object;
        return timeCell;
    }
    else{
        id<IMessageModel> model = object;
        if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:cellForMessageModel:)]) {
            UITableViewCell *cell = [_delegate messageViewController:tableView cellForMessageModel:model];
            if (cell) {
                if ([cell isKindOfClass:[EaseMessageCell class]]) {
                    EaseMessageCell *emcell= (EaseMessageCell*)cell;
                    if (emcell.delegate == nil) {
                        emcell.delegate = self;
                    }
                }
               
                return cell;
            }
        }
        
        if (_dataSource && [_dataSource respondsToSelector:@selector(isEmotionMessageFormessageViewController:messageModel:)]) {
            BOOL flag = [_dataSource isEmotionMessageFormessageViewController:self messageModel:model];
            if (flag) {
                NSString *CellIdentifier = [EaseCustomMessageCell cellIdentifierWithModel:model];
                //发送cell
                EaseCustomMessageCell *sendCell = (EaseCustomMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                // Configure the cell...
                if (sendCell == nil) {
                    sendCell = [[EaseCustomMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:model];
                    sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                
                if (_dataSource && [_dataSource respondsToSelector:@selector(emotionURLFormessageViewController:messageModel:)]) {
                    EaseEmotion *emotion = [_dataSource emotionURLFormessageViewController:self messageModel:model];
                    if (emotion) {
                        NSString *filePath = [[NSBundle mainBundle] pathForResource:emotion.emotionOriginal ofType:@"gif"];
                        model.image = [UIImage sd_animatedGIFWithData:[NSData dataWithContentsOfFile:filePath]];//[UIImage sd_animatedGIFNamed:emotion.emotionOriginal];
                        model.fileURLPath = emotion.emotionOriginalURL;
                    }
                }
                sendCell.model = model;
                sendCell.delegate = self;
                return sendCell;
            }
        }
        
        NSString *CellIdentifier = [EaseMessageCell cellIdentifierWithModel:model];
        
        EaseBaseMessageCell *sendCell = (EaseBaseMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (sendCell == nil) {
            sendCell = [[EaseBaseMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:model];
            sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
            sendCell.delegate = self;
        }
        sendCell.model = model;
        return sendCell;
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[NSString class]]) {
        return self.timeCellHeight;
    }else{
        id<IMessageModel> model = object;
        NSDictionary *ext = model.message.ext;
        if ([ext[@"money_type_special"] isEqualToString:@"rand"]) {
            return [SendCardCell cellHeightWithModel:model];
        }
        if ([ext[@"money_type_special"] isEqualToString:@"scanCardInformation"]) {
            return [SendScanCardCell cellHeightWithModel:model];
        }
        if ([ext[@"money_type_special"] isEqualToString:@"activity"]) {
            return 135;
        }
        if ([ext[@"money_type_special"] isEqualToString:@"dynamic"]) {
            return 110;
        }
        if ([ext[@"money_type_special"] isEqualToString:@"viewPoint"]) {
            return 110;
        }
        if ([ext[@"money_type_special"] isEqualToString:@"shareSupply"]) {
             return [SupplyAndNeedMyCell cellHeightWithModel:model];
        }
        if ([ext[@"money_type_special"] isEqualToString:@"joinGroup"]) {
            return 50;
        }

        if ([ext[@"money_type_special"] isEqualToString:@"activityOrinformation"]) {
            return 100;
        }

        if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:heightForMessageModel:withCellWidth:)]) {
            CGFloat height = [_delegate messageViewController:self heightForMessageModel:model withCellWidth:tableView.frame.size.width];
            if (height) {
                return height;
            }
        }
        
        if (_dataSource && [_dataSource respondsToSelector:@selector(isEmotionMessageFormessageViewController:messageModel:)]) {
            BOOL flag = [_dataSource isEmotionMessageFormessageViewController:self messageModel:model];
            if (flag) {
                return [EaseCustomMessageCell cellHeightWithModel:model];
            }
        }
        
      
        return [EaseBaseMessageCell cellHeightWithModel:model];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.navigationController.navigationBarHidden = YES;
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        // video url:
        // file:///private/var/mobile/Applications/B3CDD0B2-2F19-432B-9CFA-158700F4DE8F/tmp/capture-T0x16e39100.tmp.9R8weF/capturedvideo.mp4
        // we will convert it to mp4 format
        NSURL *mp4 = [self _convert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
//                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        [self sendVideoMessageWithURL:mp4];
        
    }else{
        
        NSURL *url = info[UIImagePickerControllerReferenceURL];
        if (url == nil) {
            UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
            [self sendImageMessage:orgImage];
        } else {
            if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0f) {
                PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
                [result enumerateObjectsUsingBlock:^(PHAsset *asset , NSUInteger idx, BOOL *stop){
                    if (asset) {
                        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *data, NSString *uti, UIImageOrientation orientation, NSDictionary *dic){
                            if (data.length > 10 * 1000 * 1000) {
                                [self showHint:@"图片太大了，换个小点的"];
                                return;
                            }
                            if (data != nil) {
                                [self sendImageMessageWithData:data];
                            } else {
                                [self showHint:@"图片太大了，换个小点的"];
                            }
                        }];
                    }
                }];
            } else {
                ALAssetsLibrary *alasset = [[ALAssetsLibrary alloc] init];
                [alasset assetForURL:url resultBlock:^(ALAsset *asset) {
                    if (asset) {
                        ALAssetRepresentation* assetRepresentation = [asset defaultRepresentation];
                        Byte* buffer = (Byte*)malloc([assetRepresentation size]);
                        NSUInteger bufferSize = [assetRepresentation getBytes:buffer fromOffset:0.0 length:[assetRepresentation size] error:nil];
                        NSData* fileData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:YES];
                        if (fileData.length > 10 * 1000 * 1000) {
                            [self showHint:@"图片太大了，换个小点的"];
                            return;
                        }
                        [self sendImageMessageWithData:fileData];
                    }
                } failureBlock:NULL];
            }
        }
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    self.isViewDidAppear = YES;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    
    self.isViewDidAppear = YES;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
}
- (void)removeImageView:(UIGestureRecognizer*)gesture{
    [gesture.view removeFromSuperview];
}
#pragma mark - EaseMessageCellDelegate
- (void)messageCellSelected:(id<IMessageModel>)model{
    [self.view endEditing:YES];
    NSDictionary *ext = model.message.ext;
    NSNumber *topage = [CommonMethod paramNumberIsNull:ext[@"topage"]];
    if (topage.integerValue == 16) {
        self.isPushVC = YES;
        NSNumber *valueNymb = ext[@"value"];
        ActivityDetailController *vc = [[ActivityDetailController alloc] init];
        vc.activityid = valueNymb;

        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if ([ext[@"money_type_special"] isEqualToString:@"rand"]) {
        self.isPushVC = YES;
        NewMyHomePageController *home = [[NewMyHomePageController alloc]init];
        NSString *uid = ext[@"userID"];
        home.userId = [NSNumber numberWithUnsignedInteger:uid.integerValue];
        [self.navigationController pushViewController:home animated:YES];
        return;
    }
    if ([ext[@"money_type_special"] isEqualToString:@"activity"]) {
        self.isPushVC = YES;
        ActivityDetailController *vc = [[ActivityDetailController alloc]init];
        vc.activityid = ext[@"activityid"];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if ([ext[@"money_type_special"] isEqualToString:@"dynamic"]) {
        self.isPushVC = YES;
        VariousDetailController *varDynamic = [[VariousDetailController alloc]init];
     
        varDynamic.dynamicid = ext[@"dynamicid"];;
        [self.navigationController pushViewController:varDynamic animated:YES];
        return;
    }
    if ([ext[@"money_type_special"] isEqualToString:@"shareSupply"]) {
        self.isPushVC = YES;
        VariousDetailController *vc = [CommonMethod getVCFromNib:[VariousDetailController class]];
        vc.dynamicid =ext[@"dynamic_id"];
    [self.navigationController pushViewController:vc animated:YES];
            return;
    }
  
    
    if ([ext[@"money_type_special"] isEqualToString:@"viewPoint"]) {
        self.isPushVC = YES;
        ViewpointDetailViewController *vc = [CommonMethod getVCFromNib:[ViewpointDetailViewController class]];
        NSString *str = [NSString stringWithFormat:@"%@",ext[@"dynamic_id"]];
        vc.viewpointId =  [NSNumber numberWithInteger:str.integerValue];
        TopicDetailModel *topicDetailModel = [[TopicDetailModel alloc] init];
        vc.topicDetailModel = topicDetailModel;
        [self.navigationController pushViewController:vc animated:YES];
        
        return;
    }
    
    
    
    
    if ([ext[@"money_type_special"] isEqualToString:@"activityOrinformation"]) {
        self.isPushVC = YES;
        NSNumber *numBer = ext[@"type"];
        if (numBer.integerValue == 1) {
            TopicViewController *intViwCtr = [[TopicViewController alloc]init];
            intViwCtr.subjectId = ext[@"activityId"];
            [self.navigationController pushViewController:intViwCtr animated:YES];
        }else{
            InformationDetailController *intViwCtr = [[InformationDetailController alloc]init];
            intViwCtr.postID = ext[@"activityId"];
            [self.navigationController pushViewController:intViwCtr animated:YES];
        }
        return;
    }
    if ([ext[@"money_type_special"] isEqualToString:@"scanCardInformation"]) {
        self.isPushVC = YES;
        CardDetailViewController *vc = [CommonMethod getVCFromNib:[CardDetailViewController class]];
        vc.cardId = ext[@"cardId"];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }


    //金脉小助手 -- 4.认证通过 5.认证失败 6.商脉违规 7.获得咖啡 8.咖啡挂出 9.咖啡被领取 10.咖啡被领完
    //11.去完善个人资料 12.新的好友 15.话题合并 17.活动报名详情页 18.邀请好友点评我 19.好友给我新增了一条评论
    switch ([[CommonMethod paramNumberIsNull:ext[@"topage"]] integerValue]) {
        case 4:{
            self.isPushVC = YES;
            PassReviewController *passVC = [[PassReviewController alloc]init];
            passVC.urlImage = [CommonMethod paramStringIsNull:ext[@"value"]];
            passVC.rootTmpViewController = self;
            [self.navigationController pushViewController:passVC animated:YES];
            return;
        }
            break;
        case 5:{
            self.isPushVC = YES;
            NotPassController * NotPass= [[NotPassController alloc]init];
            NotPass.rootTmpViewController = self;
            [self.navigationController pushViewController:NotPass animated:YES];
            return;
        }
            break;
        case 6:{
            
            return;
        }
            break;
        case 7:{
            self.isPushVC = YES;
            MyCofferViewController * myCoffeeVC= [[MyCofferViewController alloc]init];
            myCoffeeVC.showBackBtn = YES;
            [self.navigationController pushViewController:myCoffeeVC animated:YES];
            return;
        }
            break;
        case 8:{
            self.isPushVC = YES;
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.backgroundColor = BLACK_COLOR;
            [imageView sd_setImageWithURL:[NSURL URLWithString:[CommonMethod paramStringIsNull:ext[@"value"]]] placeholderImage:KWidthImageDefault];
            [CommonMethod viewAddGuestureRecognizer:imageView tapsNumber:1 withTarget:self withSEL:@selector(removeImageView:)];
            [[UIApplication sharedApplication].keyWindow addSubview:imageView];
            return;
        }
            break;
        case 9:{
            self.isPushVC = YES;
            GetWallCoffeeDetailViewController * myCoffeeVC= [[GetWallCoffeeDetailViewController alloc]init];
            myCoffeeVC.coffeegetid = [CommonMethod paramNumberIsNull:ext[@"value"]];
            myCoffeeVC.isMygetCoffee = NO;
            myCoffeeVC.type = @(1);
            [self.navigationController pushViewController:myCoffeeVC animated:YES];
            return;
        }
            break;
        case 10:{
            self.isPushVC = YES;
            ShareNormalView *shareView = [CommonMethod getViewFromNib:NSStringFromClass([ShareNormalView class])];
            shareView.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
            @weakify(self);
            shareView.shareIndex = ^(NSInteger index){
                @strongify(self);
                [self firendClick:index];
            };
            [[UIApplication sharedApplication].keyWindow addSubview:shareView];
            [shareView showShareNormalView];
            return;
        }
            break;
        case 11:{
            self.isPushVC = YES;
            EditPersonalInfoViewController *vc = [[EditPersonalInfoViewController alloc] init];
            vc.saveType = SaveType_Normal;
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
            break;
        case 12:{
            self.isPushVC = YES;
            NewFriendsController *vc = [[NewFriendsController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
            break;
        case 15:{
            self.isPushVC = YES;
            TopicViewController *vc = [CommonMethod getVCFromNib:[TopicViewController class]];
            vc.subjectId = [CommonMethod paramNumberIsNull:ext[@"value"]];
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
            break;
        case 17:{
            self.isPushVC = YES;
            TicketDetailViewController *vc = [CommonMethod getVCFromNib:[TicketDetailViewController class]];
            vc.ordernum = [CommonMethod paramStringIsNull:ext[@"value"]];
            vc.status = @(0);
            vc.amount = @"0";
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
            break;
        case 18:{
            self.isPushVC = YES;
            CommentPersonController *vc = [CommonMethod getVCFromNib:[CommentPersonController class]];
            vc.userId = [CommonMethod paramNumberIsNull:ext[@"value"]];
            vc.realname = @"";
            [self.navigationController pushViewController:vc animated:YES];
            return;
        }
        case 19:{
            self.isPushVC = YES;
            NewMyHomePageController *home = [[NewMyHomePageController alloc]init];
            home.userId = [CommonMethod paramNumberIsNull:ext[@"value"]];
            [self.navigationController pushViewController:home animated:YES];
        }
            break;
            
        default:
            break;
    }


    if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didSelectMessageModel:)]) {
        BOOL flag = [_delegate messageViewController:self didSelectMessageModel:model];
        if (flag) {
            [self _sendHasReadResponseForMessages:@[model.message] isRead:YES];
            return;
        }
    }
    
    switch (model.bodyType) {
        case EMMessageBodyTypeImage:
        {
            _scrollToBottomWhenAppear = NO;
            [self _imageMessageCellSelected:model];
        }
            break;
        case EMMessageBodyTypeLocation:
        {
             [self _locationMessageCellSelected:model];
        }
            break;
        case EMMessageBodyTypeVoice:
        {
            [self _audioMessageCellSelected:model];
        }
            break;
        case EMMessageBodyTypeVideo:
        {
            [self _videoMessageCellSelected:model];

        }
            break;
        case EMMessageBodyTypeFile:
        {
            _scrollToBottomWhenAppear = NO;
            [self showHint:@"Custom implementation!"];
        }
            break;
        default:
            break;
    }
}

#pragma mark ----------分享 ---
- (void)firendClick:(NSInteger )index{
    UserModel *model = [DataModelInstance shareInstance].userModel;
    NSString *html = @"祝我一臂之力，邀请金融同行免费喝一杯“人脉咖啡”！";
    NSString *content = html.length>100?[html substringToIndex:100]:html;
    NSString *title = [NSString stringWithFormat:@"这家咖啡馆已为金融界同行送出了%ld杯“人脉咖啡”！", (long)_coffeeSum];
    NSString *imageUrl = @"";
    NSString *contentUrl = [NSString stringWithFormat:@"%@%@",InvitFriendRegisterUrl, model.userId];
   UIImage *imageSource;
    if(imageUrl && imageUrl.length){
        imageSource = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
    }else{
        imageSource = kImageWithName(@"icon-60");
    }
    switch (index){
        case 0:
        {
            [self shareUMengWeiXInTitle:title count:content url:contentUrl image:imageSource index:index];            break;
        }
        case 1:
        {
            [self shareUMengWeiXInTitle:title count:content url:contentUrl image:imageSource index:index];                        break;
        }
        case 2:{
            NSString *content1 = [NSString stringWithFormat:@"这里可以认识金融同行，请他们免费喝咖啡！我给你送了一杯咖啡兑换券，赶紧注册领取：%@", contentUrl];
          
            [self showMessageViewtitle:content1];
            return;
        }
   }
}
- (void)shareUMengWeiXInTitle:(NSString *)title count:(NSString *)count url:(NSString *)url image:(UIImage *)imageSource index:(NSInteger)index{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    UMSocialPlatformType shareType;
    if (index == 0) {
        shareType = UMSocialPlatformType_WechatSession;
    }else  {
        shareType = UMSocialPlatformType_WechatTimeLine;
    }
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:count thumImage:imageSource];
    //设置网页地址
    shareObject.webpageUrl = url;
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:shareType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            NSLog(@"************Share fail with error %@*********",error);
        }else{
            NSLog(@"response data is %@",data);
        }
    }];
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    //短信导航
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:19],NSFontAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:kDefaultColor];
    
    switch (result) {
        case MessageComposeResultSent:
            //信息传送成功
            break;
        case MessageComposeResultFailed:
            //信息传送失败
            break;
        case MessageComposeResultCancelled:
            //信息被用户取消传送
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showMessageViewtitle:(NSString *)title{
    //短信导航
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:19],NSFontAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    [[UINavigationBar appearance] setTintColor:[UIColor blueColor]];
    [[UINavigationBar appearance] setBarTintColor:kBackgroundColorDefault];
    MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
    if( [MFMessageComposeViewController canSendText] ){
      //  controller.recipients = phones;
        controller.body = title;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:^{
            
        }];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"该设备不支持短信功能" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)statusButtonSelcted:(id<IMessageModel>)model withMessageCell:(EaseMessageCell*)messageCell
{
    if ((model.messageStatus != EMMessageStatusFailed) && (model.messageStatus != EMMessageStatusPending))
    {
        return;
    }
    
    __weak typeof(self) weakself = self;
   
     [[[EMClient sharedClient] chatManager] resendMessage:model.message progress:^(int progress) {
         
     } completion:^(EMMessage *message, EMError *error) {
          [weakself.tableView reloadData];
     }];
    
    [self.tableView reloadData];
}

- (void)avatarViewSelcted:(id<IMessageModel>)model
{
    if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didSelectAvatarMessageModel:)]) {
        [_delegate messageViewController:self didSelectAvatarMessageModel:model];
        
        return;
    }
    
    _scrollToBottomWhenAppear = NO;
}

#pragma mark - EMChatToolbarDelegate

- (void)chatToolbarDidChangeFrameToHeight:(CGFloat)toHeight
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.tableView.frame;
        rect.origin.y = 64;
        rect.size.height = HEIGHT - toHeight -64;
        self.tableView.frame = rect;
    }];
    
    [self _scrollViewToBottom:NO];
}

- (void)inputTextViewWillBeginEditing:(EaseTextView *)inputTextView
{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    [_menuController setMenuItems:nil];
}

- (void)didSendText:(NSString *)text
{
    if (text && text.length > 0) {
        [self sendTextMessage:text];
    }
}

- (void)didSendText:(NSString *)text withExt:(NSDictionary*)ext
{
    if ([ext objectForKey:EASEUI_EMOTION_DEFAULT_EXT]) {
        EaseEmotion *emotion = [ext objectForKey:EASEUI_EMOTION_DEFAULT_EXT];
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(emotionExtFormessageViewController:easeEmotion:)]) {
            NSDictionary *ext = [self.dataSource emotionExtFormessageViewController:self easeEmotion:emotion];
            [self sendTextMessage:emotion.emotionTitle withExt:ext];
        } else {
            [self sendTextMessage:emotion.emotionTitle withExt:@{MESSAGE_ATTR_EXPRESSION_ID:emotion.emotionId,MESSAGE_ATTR_IS_BIG_EXPRESSION:@(YES)}];
        }
        return;
    }
    if (text && text.length > 0) {
        [self sendTextMessage:text withExt:ext];
    }
}

/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction:(UIView *)recordView
{
    if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectRecordView:withEvenType:)]) {
        [self.delegate messageViewController:self didSelectRecordView:recordView withEvenType:EaseRecordViewTypeTouchDown];
    } else {
        if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
            [(EaseRecordView *)self.recordView recordButtonTouchDown];
        }
    }
    
    if ([self _canRecord]) {
        EaseRecordView *tmpView = (EaseRecordView *)recordView;
        tmpView.center = self.view.center;
        [self.view addSubview:tmpView];
        [self.view bringSubviewToFront:recordView];
        int x = arc4random() % 100000;
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
        
        [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error)
         {
             if (error) {
//                 NSLog(@"%@",NSEaseLocalizedString(@"message.startRecordFail", @"failure to start recording"));
             }
         }];
    }
}

/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction:(UIView *)recordView
{
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
    if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectRecordView:withEvenType:)]) {
        [self.delegate messageViewController:self didSelectRecordView:recordView withEvenType:EaseRecordViewTypeTouchUpOutside];
    } else {
        if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
            [(EaseRecordView *)self.recordView recordButtonTouchUpOutside];
        }
        [self.recordView removeFromSuperview];
    }
}

/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction:(UIView *)recordView
{
    if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectRecordView:withEvenType:)]) {
        [self.delegate messageViewController:self didSelectRecordView:recordView withEvenType:EaseRecordViewTypeTouchUpInside];
    } else {
        if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
            [(EaseRecordView *)self.recordView recordButtonTouchUpInside];
        }
        [self.recordView removeFromSuperview];
    }
    __weak typeof(self) weakSelf = self;
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error) {
            if (aDuration <= 0)
            {
                [weakSelf showHint:@"时间过短"];
            }
            else if (aDuration > 60){
                 [weakSelf showHint:@"录音时间不能超过60s"];
            }
            else
            {
                NSLog(@"%@", recordPath);
              [weakSelf sendVoiceMessageWithLocalPath:recordPath duration:aDuration];  
            }
            
        }
        else {
//            [weakSelf showHudInView:self.view hint:NSEaseLocalizedString(@"media.timeShort", @"The recording time is too short")];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf hideHud];
            });
        }
    }];
}

- (void)didDragInsideAction:(UIView *)recordView
{
    if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectRecordView:withEvenType:)]) {
        [self.delegate messageViewController:self didSelectRecordView:recordView withEvenType:EaseRecordViewTypeDragInside];
    } else {
        if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
            [(EaseRecordView *)self.recordView recordButtonDragInside];
        }
    }
}

- (void)didDragOutsideAction:(UIView *)recordView
{
    if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectRecordView:withEvenType:)]) {
        [self.delegate messageViewController:self didSelectRecordView:recordView withEvenType:EaseRecordViewTypeDragOutside];
    } else {
        if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
            [(EaseRecordView *)self.recordView recordButtonDragOutside];
        }
    }
}

#pragma mark - EaseChatBarMoreViewDelegate

- (void)moreView:(EaseChatBarMoreView *)moreView didItemInMoreViewAtIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectMoreView:AtIndex:)]) {
        [self.delegate messageViewController:self didSelectMoreView:moreView AtIndex:index];
        return;
    }
}

- (void)moreViewPhotoAction:(EaseChatBarMoreView *)moreView
{
    // 隐藏键盘
    [self.chatToolbar endEditing:YES];
    
    // 弹出照片选择
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
   
    
    [self presentViewController:self.imagePicker animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    self.isViewDidAppear = NO;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:YES];
}

- (void)moreViewTakePicAction:(EaseChatBarMoreView *)moreView
{
    // 隐藏键盘
    [self.chatToolbar endEditing:YES];
    
#if TARGET_IPHONE_SIMULATOR
//    [self showHint:NSEaseLocalizedString(@"message.simulatorNotSupportCamera", @"simulator does not support taking picture")];
#elif TARGET_OS_IPHONE
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
    
    self.isViewDidAppear = NO;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:YES];
#endif
}

- (void)moreViewLocationAction:(EaseChatBarMoreView *)moreView
{
    // 隐藏键盘
    [self.chatToolbar endEditing:YES];
    
    EaseLocationViewController *locationController = [[EaseLocationViewController alloc] init];
    locationController.delegate = self;
    [self.navigationController pushViewController:locationController animated:YES];
}

- (void)moreViewAudioCallAction:(EaseChatBarMoreView *)moreView
{
    // 隐藏键盘
    [self.chatToolbar endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":self.conversation.conversationId, @"type":[NSNumber numberWithInt:0]}];
}
- (void)moreViewSupplyAction:(EaseChatBarMoreView *)moreView{
    // 隐藏键盘
    [self.chatToolbar endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":self.conversation.conversationId, @"type":[NSNumber numberWithInt:3]}];
    NeedSupplyListController *vc = [CommonMethod getVCFromNib:[NeedSupplyListController class]];
      vc.isShare = YES;
    if (self.conversation.type  == EMConversationTypeGroupChat ) {
        vc.chatType = EMChatTypeGroupChat;
    }else if (self.conversation.type  == EMConversationTypeChat){
        vc.chatType = EMChatTypeChat;
    }
    vc.chartRoomId = self.conversation.conversationId;
        vc.userId =  [DataModelInstance shareInstance].userModel.userId;
    //    vc.needOrSupplyChange = ^{
    //        if(self.needOrSupplyChange){
    //            self.needOrSupplyChange();
    //        }
    //    };
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)moreViewNeedAction:(EaseChatBarMoreView *)moreView{
    // 隐藏键盘
    [self.chatToolbar endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":self.conversation.conversationId, @"type":[NSNumber numberWithInt:4]}];
    NeedSupplyListController *vc = [CommonMethod getVCFromNib:[NeedSupplyListController class]];
     vc.isNeed = YES;
    vc.isShare = YES;
   
    if (self.conversation.type  == EMConversationTypeGroupChat ) {
         vc.chatType = EMChatTypeGroupChat;
    }else if (self.conversation.type  == EMConversationTypeChat){
         vc.chatType = EMChatTypeChat;
    }
    
     vc.chartRoomId = self.conversation.conversationId;
    vc.userId = [DataModelInstance shareInstance].userModel.userId;
//    vc.needOrSupplyChange = ^{
//        if(self.needOrSupplyChange){
//            self.needOrSupplyChange();
//        }
//    };
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)moreViewCardAction:(EaseChatBarMoreView *)moreView{
    // 隐藏键盘
    [self.chatToolbar endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":self.conversation.conversationId, @"type":[NSNumber numberWithInt:5]}];
    CardManagerViewController *card = [[CardManagerViewController alloc]init];
    if (self.conversation.type  == EMConversationTypeGroupChat ) {
        card.chatType = EMChatTypeGroupChat;
    }else if (self.conversation.type  == EMConversationTypeChat){
        card.chatType = EMChatTypeChat;
    }

    card.conversation = self.conversation;
    [self.navigationController pushViewController:card animated:YES];
}
- (void)moreViewVideoCallAction:(EaseChatBarMoreView *)moreView
{
    // 隐藏键盘
    [self.chatToolbar endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":self.conversation.conversationId, @"type":[NSNumber numberWithInt:1]}];
}

#pragma mark - EMLocationViewDelegate

-(void)sendLocationLatitude:(double)latitude
                  longitude:(double)longitude
                 andAddress:(NSString *)address
{
    _isSendLocation = YES;
    [self sendLocationMessageLatitude:latitude longitude:longitude andAddress:address];
}

#pragma mark - EaseMob

#pragma mark - EMChatManagerDelegate

- (void)didReceiveMessages:(NSArray *)aMessages{
    for (EMMessage *message in aMessages) {
        if ([self.conversation.conversationId isEqualToString:message.conversationId]) {
            [self addMessageToDataSource:message progress:nil];
            [self _sendHasReadResponseForMessages:@[message]
                                           isRead:NO];
            if ([self _shouldMarkMessageAsRead]){
                [self.conversation markMessageAsReadWithId:message.messageId error:nil];
            }
        }
        if(message.body.type==EMMessageBodyTypeImage && ((EMImageMessageBody*)message.body).downloadStatus!=EMDownloadStatusSuccessed){
            [[EMClient sharedClient].chatManager downloadMessageAttachment:message progress:^(int progress) {
            } completion:^(EMMessage *message, EMError *error) {
            }];
        }
    }
}

- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages{
    for (EMMessage *message in aCmdMessages) {
        if ([message.from isEqualToString:@"jm_assistant"]) {
            return;
        }
        if ([self.conversation.conversationId isEqualToString:message.conversationId]) {
            break;
        }
    }
}


- (void)didReceiveHasDeliveredAcks:(NSArray *)aMessages
{
    for(EMMessage *message in aMessages){
        [self _updateMessageStatus:message];
    }
}

- (void)didReceiveHasReadAcks:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages) {
        if (![self.conversation.conversationId isEqualToString:message.conversationId]){
            continue;
        }
        
        __block id<IMessageModel> model = nil;
        __block BOOL isHave = NO;
        [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             if ([obj conformsToProtocol:@protocol(IMessageModel)])
             {
                 model = (id<IMessageModel>)obj;
                 if ([model.messageId isEqualToString:message.messageId])
                 {
                     model.message.isReadAcked = YES;
                     isHave = YES;
                     *stop = YES;
                 }
             }
         }];
        
        if(!isHave){
            return;
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didReceiveHasReadAckForModel:)]) {
            [_delegate messageViewController:self didReceiveHasReadAckForModel:model];
        }
        else{
            [self.tableView reloadData];
        }
    }
}

- (void)didMessageStatusChanged:(EMMessage *)aMessage
                          error:(EMError *)aError;
{
    [self _updateMessageStatus:aMessage];
}

- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message
                                     error:(EMError *)error{
    if (!error) {
        EMFileMessageBody *fileBody = (EMFileMessageBody*)[message body];
        if ([fileBody type] == EMMessageBodyTypeImage) {
            EMImageMessageBody *imageBody = (EMImageMessageBody *)fileBody;
            if ([imageBody thumbnailDownloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody type] == EMMessageBodyTypeVideo){
            EMVideoMessageBody *videoBody = (EMVideoMessageBody *)fileBody;
            if ([videoBody thumbnailDownloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody type] == EMMessageBodyTypeVoice){
            if ([fileBody downloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }
        
    }else{
        
    }
}

#pragma mark - EMCDDeviceManagerProximitySensorDelegate

- (void)proximitySensorChanged:(BOOL)isCloseToUser
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (isCloseToUser)
    {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (self.playingVoiceModel == nil) {
            [[EMCDDeviceManager sharedInstance] disableProximitySensor];
        }
    }
    [audioSession setActive:YES error:nil];
}

#pragma mark - action

- (void)copyMenuAction:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        pasteboard.string = model.text;
    }
    
    self.menuIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender
{
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:self.menuIndexPath.row];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:self.menuIndexPath, nil];
        
        [self.conversation deleteMessageWithId:model.message.messageId error:nil];
        [self.messsagesSource removeObject:model.message];
        
        if (self.menuIndexPath.row - 1 >= 0) {
            id nextMessage = nil;
            id prevMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row - 1)];
            if (self.menuIndexPath.row + 1 < [self.dataArray count]) {
                nextMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row + 1)];
            }
            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                [indexs addIndex:self.menuIndexPath.row - 1];
                [indexPaths addObject:[NSIndexPath indexPathForRow:(self.menuIndexPath.row - 1) inSection:0]];
            }
        }
        
        [self.dataArray removeObjectsAtIndexes:indexs];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    
    self.menuIndexPath = nil;
}

#pragma mark - public

- (NSArray *)formatMessages:(NSArray *)messages
{
    NSMutableArray *formattedArray = [[NSMutableArray alloc] init];
    if (messages == nil || [messages count] == 0) {
        return formattedArray;
    }
    
    for (EMMessage *message in messages) {
        //计算時間间隔
        CGFloat interval = (self.messageTimeIntervalTag - message.timestamp) / 1000;
        if (self.messageTimeIntervalTag < 0 || interval > 60 || interval < -60) {
            NSDate *messageDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
            NSString *timeStr = @"";
            
            if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:stringForDate:)]) {
                timeStr = [_dataSource messageViewController:self stringForDate:messageDate];
            }
            else{
                timeStr = [messageDate formattedTime];
            }
            [formattedArray addObject:timeStr];
            self.messageTimeIntervalTag = message.timestamp;
        }
        
        //构建数据模型
        id<IMessageModel> model = nil;
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:modelForMessage:)]) {
            model = [_dataSource messageViewController:self modelForMessage:message];
        }
        else{
            model = [[EaseMessageModel alloc] initWithMessage:message];
            if (model.isSender) {
                model.avatarURLPath = [DataModelInstance shareInstance].userModel.image;
                model.nickname =  [DataModelInstance shareInstance].userModel.realname;
                model.avatarImage = KHeadImageDefaultName([DataModelInstance shareInstance].userModel.realname);
            }
            else
            {
                
             //环信图片
                if ([message.from isEqualToString:@"jm_assistant"]){
                    model.avatarImage = [UIImage imageNamed:@"icon_avatar_jmxms_round"];
                }else if ([message.from isEqualToString:@"activity_assistant"]){
                    model.avatarImage = [UIImage imageNamed:@"icon_event_assis"];
                }else if ([message.from isEqualToString:@"jm_topic"]){
                    model.avatarImage = [UIImage imageNamed:@"avatar_jmtt"];
                }else{
                    NSMutableArray *array = [[DBInstance shareInstance] selectCharttingID:message.from];
                    if (array.count != 0){
                        ChartModel *chatModel = array[0];
                        model.avatarURLPath = chatModel.image;
                        model.avatarImage = KHeadImageDefaultName(chatModel.realname);
                    }else{
                        model.avatarImage = KHeadImageDefaultName(@"");
                    }
                }
            }
//            model.failImageName = @"icon_connection_sendfailed";
        }
        if (model) {
            [formattedArray addObject:model];
        }
    }
    
    return formattedArray;
}

-(void)addMessageToDataSource:(EMMessage *)message
                     progress:(id)progress
{
    if(message == nil){
        return;
    }
    [self.messsagesSource addObject:message];
    
     __weak EaseMessageViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf formatMessages:@[message]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.dataArray addObjectsFromArray:messages];
            [weakSelf.tableView reloadData];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.005 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if([weakSelf.dataArray count]){
                    [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
            });
        });
    });
}

#pragma mark - public

- (void)tableViewDidTriggerHeaderRefresh
{
    self.messageTimeIntervalTag = -1;
    NSString *messageId = nil;
    if ([self.messsagesSource count] > 0) {
        messageId = [(EMMessage *)self.messsagesSource.firstObject messageId];
    }
    else {
        messageId = nil;
    }
    [self _loadMessagesBefore:messageId count:self.messageCountOfPage append:YES];
    
    [self tableViewDidFinishTriggerHeader:YES reload:YES];
}

#pragma mark - send message

- (void)_sendMessage:(EMMessage *)message
{
    if (self.conversation.type == EMConversationTypeGroupChat){
        message.chatType = EMChatTypeGroupChat;
    }
    else if (self.conversation.type == EMConversationTypeChatRoom){
        message.chatType = EMChatTypeChatRoom;
    }
    
    [self addMessageToDataSource:message
                        progress:nil];
    
    __weak typeof(self) weakself = self;
     [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
         
     } completion:^(EMMessage *message, EMError *error) {
         [weakself.tableView reloadData];
     }];
}

- (void)sendTextMessage:(NSString *)text
{
    
    NSDictionary *ext = nil;
    if (self.conversation.type == EMConversationTypeGroupChat) {
        NSArray *targets = [self _searchAtTargets:text];
        if ([targets count]) {
            __block BOOL atAll = NO;
            [targets enumerateObjectsUsingBlock:^(NSString *target, NSUInteger idx, BOOL *stop) {
                if ([target compare:kGroupMessageAtAll options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                    atAll = YES;
                    *stop = YES;
                }
            }];
            if (atAll) {
                ext = @{kGroupMessageAtList: kGroupMessageAtAll};
            }
            else {
                ext = @{kGroupMessageAtList: targets};
            }
        }
    }

   
    [self sendTextMessage:text withExt:ext];
 }

- (void)sendTextMessage:(NSString *)text withExt:(NSDictionary*)ext
{
        EMMessage *message = [EaseSDKHelper sendTextMessage:text
                                                   to:self.conversation.conversationId
                                          messageType:[self _messageTypeFromConversationType]
                                           messageExt:ext];
    [self _sendMessage:message];
}

- (void)sendLocationMessageLatitude:(double)latitude
                          longitude:(double)longitude
                         andAddress:(NSString *)address
{
    EMMessage *message = [EaseSDKHelper sendLocationMessageWithLatitude:latitude
                                                            longitude:longitude
                                                              address:address
                                                                   to:self.conversation.conversationId
                                                          messageType:[self _messageTypeFromConversationType]
                                                    requireEncryption:NO
                                                           messageExt:nil];
    [self _sendMessage:message];
}

- (void)sendImageMessageWithData:(NSData *)imageData
{
    id progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:EMMessageBodyTypeImage];
    }
    else{
        progress = self;
    }
    
    EMMessage *message = [EaseSDKHelper sendImageMessageWithImageData:imageData
                                                                   to:self.conversation.conversationId
                                                          messageType:[self _messageTypeFromConversationType]
                                                    requireEncryption:NO
                                                           messageExt:nil
                                                             progress:progress];
    [self _sendMessage:message];
}

- (void)sendImageMessage:(UIImage *)image
{
    id progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:EMMessageBodyTypeImage];
    }
    else{
        progress = self;
    }
    
//    UIImageView *view = [UIImageView drawImageViewLine:CGRectMake(WIDTH/2 - 50, HEIGHT/2 - 50, 100, 100) bgColor:[UIColor whiteColor]];
//    view.image = image;
//    
//    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    EMMessage *message = [EaseSDKHelper sendImageMessageWithImage:image
                                                             to:self.conversation.conversationId
                                                    messageType:[self _messageTypeFromConversationType]
                                              requireEncryption:NO
                                                     messageExt:nil
                                                       progress:progress];
    [self _sendMessage:message];
}

- (void)sendVoiceMessageWithLocalPath:(NSString *)localPath
                             duration:(NSInteger)duration
{
    id progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:EMMessageBodyTypeVoice];
    }
    else{
        progress = self;
    }
    
    EMMessage *message = [EaseSDKHelper sendVoiceMessageWithLocalPath:localPath
                                                           duration:duration
                                                                 to:self.conversation.conversationId
                                                        messageType:[self _messageTypeFromConversationType]
                                                  requireEncryption:NO
                                                         messageExt:nil
                                                           progress:progress];
    [self _sendMessage:message];
}

- (void)sendVideoMessageWithURL:(NSURL *)url
{
    id progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:EMMessageBodyTypeVideo];
    }
    else{
        progress = self;
    }
    
    EMMessage *message = [EaseSDKHelper sendVideoMessageWithURL:url
                                                           to:self.conversation.conversationId
                                                  messageType:[self _messageTypeFromConversationType]
                                            requireEncryption:NO
                                                   messageExt:nil
                                                     progress:progress];
    [self _sendMessage:message];
}

#pragma mark - notifycation
- (void)didBecomeActive
{
//    self.dataArray = [[self formatMessages:self.messsagesSource] mutableCopy];
//    [self.tableView reloadData];
    
    if (self.isViewDidAppear)
    {
        NSMutableArray *unreadMessages = [NSMutableArray array];
        for (EMMessage *message in self.messsagesSource)
        {
            if ([self _shouldSendHasReadAckForMessage:message read:NO])
            {
                [unreadMessages addObject:message];
            }
        }
        if ([unreadMessages count])
        {
            [self _sendHasReadResponseForMessages:unreadMessages isRead:YES];
        }
        
        [_conversation markAllMessagesAsRead:nil];
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(messageViewControllerMarkAllMessagesAsRead:)]) {
            
        [self.dataSource messageViewControllerMarkAllMessagesAsRead:self];
            
        }
    }

}

#pragma mark - private
- (void)_reloadTableViewDataWithMessage:(EMMessage *)message{
    __weak EaseMessageViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        if ([weakSelf.conversation.conversationId isEqualToString:message.conversationId])
        {
            for (int i = 0; i < weakSelf.dataArray.count; i ++) {
                id object = [weakSelf.dataArray objectAtIndex:i];
                if ([object isKindOfClass:[EaseMessageModel class]]) {
                    id<IMessageModel> model = object;
                    if ([message.messageId isEqualToString:model.messageId]) {
                        id<IMessageModel> model = nil;
                        if (weakSelf.dataSource && [weakSelf.dataSource respondsToSelector:@selector(messageViewController:modelForMessage:)]) {
                            model = [weakSelf.dataSource messageViewController:self modelForMessage:message];
                        }
                        else{
                            
//                             model = [[EaseMessageModel alloc] initWithMessage:message];
//                            if (message.to)
//                            {
//                                NSMutableArray *array = [[DBInstance shareInstance] selectCharttingID:message.to];
//                                
//                                if (array.count != 0)
//                                {
//                                    ContactsModel *chatModel = array[0];
//                                    model.avatarURLPath = chatModel.image;
//                                    
//                                }
//                                
//                                
//                            }
//                            if (message.from)
//                            {
//                                NSMutableArray *array = [[DBInstance shareInstance] selectCharttingID:message.from];
//                                
//                                if (array.count != 0)
//                                {
//                                    ContactsModel *chatModel = array[0];
//                                    model.avatarURLPath = chatModel.image;
//                                    
//                                }
//                                
//                            }
                        
                           
//                            model.avatarImage = [UIImage imageNamed:@"EaseUIResource.bundle/user"];
//                            model.failImageName = @"imageDownloadFail";
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.tableView beginUpdates];
                            if (model) {
                                  [weakSelf.dataArray replaceObjectAtIndex:i withObject:model];
                            }
                  
                            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                            [weakSelf.tableView endUpdates];
                        });
                        break;
                    }
                }
            }
        }
    });
}

- (void)_updateMessageStatus:(EMMessage *)aMessage
{
    BOOL isChatting = [aMessage.conversationId isEqualToString:self.conversation.conversationId];
    if (aMessage && isChatting) {
        id<IMessageModel> model = nil;
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:modelForMessage:)]) {
            model = [_dataSource messageViewController:self modelForMessage:aMessage];
        }
        else{
            model = [[EaseMessageModel alloc] initWithMessage:aMessage];
            if (aMessage.to)
            {
                 //环信头像
//                NSMutableArray *array = [[DBInstance shareInstance] selectCharttingID:aMessage.to];
                
//                if (array.count != 0)
//                {
                     //环信头像
//                    ContactsModel *chatModel = array[0];
//                    model.avatarURLPath = chatModel.image;
                    
//                }
                
                
            }
            if (aMessage.from)
            {
                 //环信头像
//                NSMutableArray *array = [[DBInstance shareInstance] selectCharttingID:aMessage.from];
//                
//                if (array.count != 0)
//                {
//                    ContactsModel *chatModel = array[0];
//                    model.avatarURLPath = chatModel.image;
//                    
//                }
                
            }
            
        }
        if (model) {
            __block NSUInteger index = NSNotFound;
            [self.dataArray enumerateObjectsUsingBlock:^(EaseMessageModel *model, NSUInteger idx, BOOL *stop){
                if ([model conformsToProtocol:@protocol(IMessageModel)]) {
                    if ([aMessage.messageId isEqualToString:model.message.messageId])
                    {
                        index = idx;
                        *stop = YES;
                    }
                }
            }];
            
            if (index != NSNotFound)
            {
                if (model) {
                     [self.dataArray replaceObjectAtIndex:index withObject:model];
                }
               
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            }
        }
    }
}
- (NSMutableArray*)atTargets
{
    if (!_atTargets) {
        _atTargets = [NSMutableArray array];
    }
    return _atTargets;
}
- (NSArray*)_searchAtTargets:(NSString*)text
{
    NSMutableArray *targets = nil;
    if (text.length > 1) {
        targets = [NSMutableArray array];
        NSArray *splits = [text componentsSeparatedByString:@"@"];
        if ([splits count]) {
            for (NSString *split in splits) {
                if (split.length) {
                    NSString *atALl =  @"all";
                    if (split.length >= atALl.length && [split compare:atALl options:NSCaseInsensitiveSearch range:NSMakeRange(0, atALl.length)] == NSOrderedSame) {
                        [targets removeAllObjects];
                        [targets addObject:kGroupMessageAtAll];
                        return targets;
                    }
                    for (ChartModel *target in self.atTargets) {
                        if ([target.userid.stringValue length]) {
                            if ([split hasPrefix:target.userid.stringValue] || (target.realname && [split hasPrefix:target.realname])) {
                                [targets addObject:[NSString stringWithFormat:@"%@",target.userid]];
                                [self.atTargets removeObject:target];
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    return targets;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    // 隐藏键盘
    [self.chatToolbar endEditing:YES];
}

@end
