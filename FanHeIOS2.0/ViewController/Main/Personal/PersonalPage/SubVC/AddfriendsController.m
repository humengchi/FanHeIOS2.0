

//
//  AddfriendsController.m
//  FanHeIOS2.0
//
//  Created by renhao on 16/8/5.
//  Copyright © 2016年 胡梦驰. All rights reserved.
//

#import "AddfriendsController.h"
#import <AVFoundation/AVFoundation.h>
#import <QiniuSDK.h>
#import "lame.h"
#import "WJTimeCircle.h"
#import "SYWaveformPlayerView.h"
#define TOTAL_SECOND 60
@interface AddfriendsController ()<UITextViewDelegate, UIGestureRecognizerDelegate, AVAudioPlayerDelegate>
@property (nonatomic, strong)NSMutableData *audioData;

@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,assign)NSInteger second;
@property (nonatomic,strong)UISegmentedControl *segmentedControl;

@property (nonatomic,strong)AVAudioRecorder *audioRecorder;
@property (nonatomic,strong)AVAudioPlayer *audioPlayer;
@property (nonatomic,strong)AVAudioSession * audioSession;
@property (nonatomic,strong)NSURL* recordUrl;
@property (nonatomic,strong)NSURL* mp3FilePath;
@property (nonatomic,strong)NSURL* audioFileSavePath;
@property (nonatomic,strong)UITextView *suggestionTextView;

@property (nonatomic, strong) UIImageView *recordBtnImageView;
@property (nonatomic, strong) UILabel *remindLabel;
@property (nonatomic, strong) UIButton *delectVoiceBtn;

@property (nonatomic,assign)  NSInteger  isattent;
@property (nonatomic, strong) NSString *mp3Url;
@property (nonatomic, strong) UIButton *sendkBtn;
@property (nonatomic, strong) UIView *WaveformView;

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, assign) BOOL isPlay;
@property (nonatomic, assign) NSInteger typeIndex;
@property (nonatomic, strong) UILabel *numberLabel;

@property (nonatomic, strong) SYWaveformPlayerView *playerView;

@end

@implementation AddfriendsController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initRecordConfig];
    [self createrUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appGotoBackground) name:AppGotoBackground object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideo) name:@"playVideo" object:nil];
}

- (void)appGotoBackground{
    if(_isPlay){
        [self.playerView appGotoBackground];
        self.recordBtnImageView.image = kImageWithName(@"btn_recording_play");
        _isPlay = NO;
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playVideo{
    _isPlay = !_isPlay;
    self.recordBtnImageView.image = kImageWithName(@"btn_recording_play");
}

- (void)createrUI{
    [self initScrollView:CGRectMake(0, 64, WIDTH, HEIGHT-64)];
    self.scrollView.scrollEnabled = YES;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.contentSize= CGSizeMake(WIDTH*2, HEIGHT-240);
    
    [self initRecordVoiceView];
    [self initSuggestionView];
    [self createrAddTabBerView];
    [self cretaerViewWaveform];
}

#pragma mark -------  创建导航
- (void)createrAddTabBerView{
    UIView *backHeaderView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH, 64) backColor:nil];
    backHeaderView.backgroundColor =  [UIColor whiteColor];
    [self.view addSubview:backHeaderView];
    
    UIButton *backBtn = [NSHelper createButton:CGRectMake(7,20 , 42, 42) title:nil unSelectImage:[UIImage imageNamed:@"btn_close_gray"] selectImage:nil target:self selector:@selector(backTaBtnAction)];
    
    [backHeaderView addSubview:backBtn];
    UIView *backView = [NSHelper createrViewFrame:CGRectMake(0, 0, 100, 64) backColor:nil];
    UITapGestureRecognizer *back = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backTaBtnAction)];
    [backView addGestureRecognizer:back];
    [backHeaderView addSubview:backView];
    
    //初始化UISegmentedControl
    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"语音",@"文字",nil];
    self.segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedArray];
    self.segmentedControl.frame = CGRectMake(WIDTH/2 - 70, 30, 140, 30.0);
    self.segmentedControl.selectedSegmentIndex = 0;//设置默认选择项索引
    [self.segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    self.segmentedControl.tintColor = HEX_COLOR(@"818C9E");
    [backHeaderView addSubview:self.segmentedControl];
}

- (void)backTaBtnAction{
    [self.playerView playPauseTapped:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cretaerViewWaveform{
    self.WaveformView = [NSHelper createrViewFrame:CGRectMake(0, 0, WIDTH,254) backColor:@"FFFFFF"];
    self.WaveformView.backgroundColor = [UIColor clearColor];
    self.timeLabel = [UILabel createLabel:CGRectMake(0, 116, WIDTH, 64) font:[UIFont systemFontOfSize:64] bkColor:[UIColor clearColor] textColor:[UIColor colorWithHexString:@"818C9E"]];
    [self.timeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:64]];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.text = @"0:00";
    self.timeLabel.textColor = [UIColor colorWithHexString:@"E6E8EB"];
    [self.WaveformView addSubview:self.timeLabel];
    [self.scrollView addSubview:self.WaveformView];
}

#pragma mark ------- 右边发送按钮
- (void)rightButtonClicked{
    [self.playerView playPauseTapped:NO];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
    [requestDict setObject:[DataModelInstance shareInstance].userModel.userId forKey:@"userid"];
    [requestDict setObject:self.userID forKey:@"other"];
    
    [requestDict setObject:@"1" forKey:@"isattent"];
    if(self.segmentedControl.selectedSegmentIndex == 0) {
        NSString *strMp3 = [NSString stringWithFormat:@"%@",self.mp3FilePath];
        QNUploadManager *upManager = [[QNUploadManager alloc] init];
        QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
        } params:nil checkCrc:NO cancellationSignal:nil];
        
        NSString *keyStr = [NSString stringWithFormat:@"%@-%@.mp3", [DataModelInstance shareInstance].userModel.userId, [NSDate currentTimeString:kTimeFormatSmallLong3]];
        [upManager putFile:strMp3 key:keyStr token:[DataModelInstance shareInstance].qiNiuTokenStr complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            if(info.statusCode==200){
                [requestDict setObject:[NSString stringWithFormat:@"http://image.51jinmai.com/%@", resp[@"key"]] forKey:@"audio"];
                [requestDict setObject:@"" forKey:@"remark"];
                [self sendAddFriends:requestDict];
            }else{
                [[AppDelegate shareInstance] getQiNiuToken];
                [MBProgressHUD showError:@"语音上传失败，请重试" toView:self.view];
            }
        } option:uploadOption];
    }else{
        [requestDict setObject:@"" forKey:@"audio"];
        [requestDict setObject: self.suggestionTextView.text forKey:@"remark"];
        [self sendAddFriends:requestDict];
    }
}

#pragma mark ------- 好友申请请求
- (void)sendAddFriends:(NSMutableDictionary *)dic{
    [self.view endEditing:YES];
    __weak typeof(self) weakSelf = self;
    __weak MBProgressHUD *hud = [MBProgressHUD showMessag:@"发送中..." toView:self.view];
    [self requstType:RequestType_Post apiName:API_NAME_USER_POST_ADDFRIENDS paramDict:dic hud:hud success:^(AFHTTPRequestOperation *operation, id responseObject, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        if([CommonMethod isHttpResponseSuccess:responseObject]){
            [MBProgressHUD showSuccess:@"发送成功" toView:self.view];
            if(weakSelf.exchangeSuccess){
                weakSelf.exchangeSuccess(YES);
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            });
        }else{
            AddFriendError *errorView = [CommonMethod getViewFromNib:@"AddFriendError"];
            errorView.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
            [[UIApplication sharedApplication].keyWindow addSubview:errorView];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error, MBProgressHUD *hud) {
        [hud hideAnimated:YES];
        [MBProgressHUD showSuccess:@"发送失败" toView:self.view];
    }];
    
}

#pragma mark ------UISegmentedControl ----点击方法
- (void)segmentAction:(UISegmentedControl *)segment{
    [self.view endEditing:YES];
    NSInteger Index = segment.selectedSegmentIndex;
    switch (Index) {
        case 0:{
            [self.suggestionTextView resignFirstResponder];
            NSString  *str=[self.mp3FilePath absoluteString];
            
            if (str.length <= 0) {
                self.typeIndex = 3;
                self.playerView = nil;
//                [self createrUI];
                  [self initRecordVoiceView];
            }
            
            self.scrollView.contentOffset = CGPointMake(0, 0);
            break;
        }
        case 1:
            [self.suggestionTextView becomeFirstResponder];
            if (self.mp3FilePath) {
                self.typeIndex = 4;
                [self.playerView playPauseTapped:NO];
            }
            self.scrollView.contentOffset = CGPointMake(WIDTH, 0);
    }
}

#pragma mark ------ 建议
- (void)initSuggestionView{
    self.suggestionTextView = [[UITextView alloc] initWithFrame:CGRectMake(WIDTH + 25, 0, WIDTH - 50, self.scrollView.frame.size.height-50)];
    self.suggestionTextView.textColor = HEX_COLOR(@"383838");
    self.suggestionTextView.font = FONT_SYSTEM_SIZE(14);
    self.suggestionTextView.delegate = self;
    self.suggestionTextView.scrollEnabled = YES;
    //设置键盘，使换行变为完成字样
    self.suggestionTextView.returnKeyType = UIReturnKeySend;
    [self.scrollView addSubview:self.suggestionTextView];
    
    UILabel *statueLabel = [UILabel createrLabelframe:CGRectMake(WIDTH + 30, 10, WIDTH - 50, 15) backColor:[UIColor clearColor] textColor:HEX_COLOR(@"AFB6C1") test:@"建议向对方简单介绍自己的业务和资源" font:12 number:1 nstextLocat:NSTextAlignmentLeft];
    
    [self.scrollView addSubview:statueLabel];
    
    self.numberLabel = [UILabel createrLabelframe:CGRectMake(WIDTH + 25, 140, WIDTH - 50, 15) backColor:WHITE_COLOR textColor:HEX_COLOR(@"AFB6C1") test:@"0/140" font:14 number:1 nstextLocat:NSTextAlignmentRight];
    self.numberLabel.hidden = YES;
    [self.scrollView addSubview:self.numberLabel];
    
    [self.suggestionTextView.rac_textSignal subscribeNext:^(NSString *text) {
        if(text.length >= 140){
            self.suggestionTextView.text = [text substringToIndex:140];
        }
        self.numberLabel.text = [NSString stringWithFormat:@"%ld/140", (unsigned long)self.suggestionTextView.text.length];
        if(text.length){
            statueLabel.hidden = YES;
        }else{
            statueLabel.hidden = NO;
        }
    }];
}

#pragma mark --------  录音设备初始化
- (void)initRecordVoiceView{
    [self.recordBtnImageView removeFromSuperview];
    [self.remindLabel removeFromSuperview];
    [self.sendkBtn removeFromSuperview];
    [self.delectVoiceBtn removeFromSuperview];
    
    self.recordBtnImageView = [[UIImageView alloc] init];
    self.recordBtnImageView.frame = CGRectMake(WIDTH/2- 130,  HEIGHT-340, 260,260);
    self.typeIndex = 1;
    [self.recordBtnImageView setAnimationImages:@[kImageWithName(@"btn_recording_01_2"), kImageWithName(@"btn_recording_02"), kImageWithName(@"btn_recording_03"),kImageWithName(@"btn_recording_04"),kImageWithName(@"btn_recording_05")]];
    self.recordBtnImageView.image = kImageWithName(@"btn_recording_01");
    self.recordBtnImageView.animationDuration = 1;
    self.recordBtnImageView.animationRepeatCount = -1;
    
    self.recordBtnImageView.userInteractionEnabled = YES;
    
    [self.scrollView addSubview:self.recordBtnImageView];
    
    self.remindLabel = [UILabel createrLabelframe:CGRectMake(0, HEIGHT-146,WIDTH ,15) backColor:[UIColor clearColor] textColor:HEX_COLOR(@"999999") test:@"按住说话" font:14 number:1 nstextLocat:NSTextAlignmentCenter];
        
        [self.scrollView addSubview:self.remindLabel];
    
   
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(63, 67, 125, 125)];
    [view.layer setCornerRadius:view.frame.size.width/2.0];
    [view.layer setMasksToBounds:YES];
    view.userInteractionEnabled = YES;
    
    view.backgroundColor = [UIColor clearColor];
    
    UILongPressGestureRecognizer *guesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handSpeakBtnPressed:)];
    guesture.delegate = self;
    guesture.minimumPressDuration = 0.01f;
    
    [view addGestureRecognizer:guesture];
    
    UITapGestureRecognizer *playTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playVoiceBtnAction)];
    [view addGestureRecognizer:playTap];
    
    [self.recordBtnImageView addSubview:view];
    
    self.sendkBtn = [NSHelper createButton:CGRectMake(WIDTH/2- 30,  HEIGHT-240, 60,78) title:nil unSelectImage:[UIImage imageNamed:@"btn_record_send"] selectImage:nil target:self selector:@selector(rightButtonClicked)];
    
    self.sendkBtn.hidden = YES;
    [self.scrollView addSubview:self.sendkBtn];
    self.delectVoiceBtn  = [NSHelper createButton:CGRectMake(WIDTH/2- 30,  HEIGHT-240, 60,78) title:@"" image:nil target:self selector:@selector(delectVoiceBtnAction) addttStr:nil];
    [self.delectVoiceBtn setImage:kImageWithName(@"btn_recording_detele") forState:UIControlStateNormal];
    self.delectVoiceBtn.hidden = YES;
    [self.scrollView addSubview:self.delectVoiceBtn];
}

#pragma mark -------  删除语音
- (void)delectVoiceBtnAction{
    [[[CommonUIAlert alloc] init] showCommonAlertView:self title:nil message:@"是否删除本次录音语音" cancelButtonTitle:@"取消" otherButtonTitle:@"确定" cancle:^{
        
    } confirm:^{
        self.typeIndex = 3;
        [self.playerView playPauseTapped:NO];
        
        for (UIView *view in self.view.subviews) {
            [view removeFromSuperview];
        }
        self.mp3FilePath = nil;
        self.playerView = nil;
        [self createrUI];
        
    }];
}

#pragma mark - 录音设置配置
- (void)initRecordConfig{
    //录音设置
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）, 采样率必须要设为11025才能使转化成mp3格式后不会失真
    [recordSetting setValue:[NSNumber numberWithFloat:11025.0] forKey:AVSampleRateKey];
    //录音通道数  1 或 2 ，要转换成mp3格式必须为双通道
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    //存储录音文件
    _recordUrl = [NSURL URLWithString:[NSTemporaryDirectory() stringByAppendingString:@"selfRecord.caf"]];
    //初始化
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:_recordUrl settings:recordSetting error:nil];
    //开启音量检测
    _audioRecorder.meteringEnabled = YES;
    _audioRecorder.delegate = self;
}

#pragma mark- UILongPressGestureRecognizer
//添加手势操作，长按按钮
- (void)handSpeakBtnPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    __block UIGestureRecognizerState state = gestureRecognizer.state;
    __weak typeof(self) weakSelf = self;
    __block UIView *view  = gestureRecognizer.view;
    __block UIImageView *imageView = (UIImageView*)view.superview;
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted){
        if (granted) {
            if([[NSUserDefaults standardUserDefaults] boolForKey:FirstAVAudioSession]==NO){
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:FirstAVAudioSession];
                [[NSUserDefaults standardUserDefaults] synchronize];
                return;
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (state == UIGestureRecognizerStateBegan) {
                        if (weakSelf.mp3FilePath) {
                            if (weakSelf.typeIndex == 2 ||weakSelf.typeIndex == 4) {
                                [weakSelf playVoiceBtnAction];
                                return;
                            }
                        }
                        [imageView startAnimating];
                        [weakSelf startRecordVoice];
                        weakSelf.remindLabel.text = @"";
                        weakSelf.remindLabel.text = @"松开结束";
                    }else if (state == UIGestureRecognizerStateEnded) {
                        [imageView stopAnimating];
                        [weakSelf stopRecordVoice];
                        weakSelf.remindLabel.text = @"按住说话";
                    }
                });
            }
        } else {
            [[[CommonUIAlert alloc] init] showCommonAlertView:self title:@"" message:@"请在iPhone的“设置>隐私>麦克风”选项中，允许3号圈访问你的麦克风" cancelButtonTitle:@"取消" otherButtonTitle:@"设置" cancle:^{
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
}

#pragma mark ------ 播放
- (void)playVoiceBtnAction{
    _isPlay = !_isPlay;
    if (_isPlay) {
        [self.playerView playPauseTapped:YES];
        self.recordBtnImageView.image = kImageWithName(@"btn_recording_pause");
    }else{
        self.typeIndex = 4;
        self.recordBtnImageView.image = kImageWithName(@"btn_recording_play");
        [self.playerView playPauseTapped:YES];
    }
}

#pragma mark -------- 开始录音
- (void)startRecordVoice{
    _audioSession = [AVAudioSession sharedInstance];//得到AVAudioSession单例对象
    [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];//设置类别,表示该应用同时支持播放和录音
    [self.audioSession setActive:YES error:nil];//启动音频会话管理,此时会阻断后台音乐的播放.
    
    [self.audioRecorder prepareToRecord];
    [self.audioRecorder peakPowerForChannel:1.0];
    
    [self.audioRecorder record];
    
    self.second = 0;
    if(self.timer){
        [self.timer invalidate];
        self.timer = nil;
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeAnim) userInfo:nil repeats:YES];
}

#pragma mark - 定时器
- (void)timeAnim{
    if(self.second >= TOTAL_SECOND){
        [self stopRecordVoice];
        [self.timer invalidate];
    }
    self.second++;
    if (self.second < 10) {
        self.timeLabel.textColor = [UIColor colorWithHexString:@"818C9E"];
        self.timeLabel.text = [NSString stringWithFormat:@"0:0%ld",(long)self.second];
    }else{
        self.timeLabel.textColor = [UIColor colorWithHexString:@"818C9E"];
        self.timeLabel.text = [NSString stringWithFormat:@"0:%ld",(long)self.second];
    }
}

#pragma mark -------- 停止录音
- (void)stopRecordVoice{
    if (self.typeIndex != 1) {
        return;
    }
    [self.recordBtnImageView stopAnimating];
    
    if(self.second < 1) {
        self.timeLabel.text = @"0:00";
        [self.timer invalidate];
        [self.audioRecorder stop];                          //录音停止
        [self.audioSession setActive:NO error:nil];         //一定要在录音停止以后再关闭音频会话管理（否则会报错），此时会延续后台音乐播放
        self.timeLabel.textColor = [UIColor colorWithHexString:@"E6E8EB"];
        [MBProgressHUD showError:@"说话时间不得低于1秒" toView:self.view];
    }else{
        [self transformCAFToMP3];
        [self.timer invalidate];
        [self.audioRecorder stop];//录音停止
        [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];//此处需要恢复设置回放标志，否则会导致其它播放声音也会变小
        [self.audioSession setActive:NO error:nil];         //一定要在录音停止以后再关闭音频会话管理（否则会报错），此时会延续后台音乐播放
        if(self.playerView==nil){
            NSString *videoStr = [NSTemporaryDirectory() stringByAppendingPathComponent:@"myselfRecord.mp3"];
            NSURL *fileURL = [NSURL fileURLWithPath:videoStr];
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
            
            self.playerView = [[SYWaveformPlayerView alloc] initWithFrame:CGRectMake(0, 116, WIDTH, 82) asset:asset color:[UIColor lightGrayColor] progressColor:[UIColor colorWithHexString:@"818C9E"]];
            [self.WaveformView addSubview:self.playerView];
        }
        self.timeLabel.font = [UIFont systemFontOfSize:32];
        [self.timeLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:32]];
        self.timeLabel.frame =CGRectMake(0, 221, WIDTH, 32);
        self.remindLabel.hidden = YES;
        self.typeIndex = 2;
        self.recordBtnImageView.image = kImageWithName(@"btn_recording_play");
        // 基于现有的一个值, 再进行平移
        self.sendkBtn.hidden = NO;
        // 基于现有的一个值, 再进行平移
        self.delectVoiceBtn.hidden = NO;
        self.delectVoiceBtn.alpha = 0;
        self.sendkBtn.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^{
            
            self.delectVoiceBtn.transform = CGAffineTransformTranslate(self.delectVoiceBtn.transform, -(WIDTH/2 - 55), 0);
            self.sendkBtn.transform = CGAffineTransformTranslate(self.sendkBtn.transform, WIDTH/2 - 55, 0);
            self.delectVoiceBtn.alpha = 1;
            self.sendkBtn.alpha = 1;
        }];
    }
}

#pragma mark ------ 转换MP3格式
- (void)transformCAFToMP3 {
    self.mp3FilePath = [NSURL URLWithString:[NSTemporaryDirectory() stringByAppendingString:@"myselfRecord.mp3"]];
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([[self.recordUrl absoluteString] cStringUsingEncoding:1], "rb");   //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                                   //skip file header
        FILE *mp3 = fopen([[self.mp3FilePath absoluteString] cStringUsingEncoding:1], "wb"); //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
    }
    @finally {
        self.audioFileSavePath = self.mp3FilePath;
    }
}

#pragma mark -AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
}

#pragma mark ------UIScrollView  代理
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.scrollView.contentOffset.x/WIDTH == 0){
        [self.suggestionTextView resignFirstResponder];
        
        self.segmentedControl.selectedSegmentIndex = 0;//设置默认选择项索引
        
    }else{
        self.segmentedControl.selectedSegmentIndex = 1;//设置默认选择项索引
        if (self.mp3FilePath) {
            self.typeIndex = 4;
            [self.playerView playPauseTapped:NO];
        }
        
        [self.suggestionTextView becomeFirstResponder];
        
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if (self.suggestionTextView.text.length != 0) {
            [self rightButtonClicked];
        }
        return NO;
    }
    return YES;
}

#pragma mark - Keyboard status
- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardEnd = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardEnd.size.height;
    self.numberLabel.frame = CGRectMake(WIDTH*2 - 125, HEIGHT - keyboardHeight - 100, 100, 12);
    self.numberLabel.hidden = NO;
    [UIView animateWithDuration:duration animations:^{
        if([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        }else{
        }
    }];
}
@end
