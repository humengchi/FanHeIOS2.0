//
//  SYWaveformPlayerView.m
//  SCWaveformView
//
//  Created by Spencer Yen on 12/26/14.
//  Copyright (c) 2014 Simon CORSIN. All rights reserved.
//

#import "SYWaveformPlayerView.h"

@interface SYWaveformPlayerView () {
    AVAudioPlayer *player;
    SCWaveformView *waveformView;
    NSTimer *_timer;
}

@end

@implementation SYWaveformPlayerView

- (id)initWithFrame:(CGRect)frame asset:(AVURLAsset *)asset color:(UIColor *)normalColor progressColor:(UIColor *)progressColor {
    if (self = [super initWithFrame:frame]) {
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:asset.URL error:nil];
        player.volume = 1;
        player.delegate = self;
        [player prepareToPlay];
        
        waveformView = [[SCWaveformView alloc] init];
        waveformView.normalColor = normalColor;
        waveformView.progressColor = progressColor;
        waveformView.alpha = 0.8;
        waveformView.backgroundColor = [UIColor clearColor];
        waveformView.asset = asset;
        [self addSubview:waveformView];
    }
  
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    waveformView.frame = CGRectMake(0, 0, WIDTH, self.frame.size.height);
}

- (void)playPauseTapped:(BOOL)isplay{
    if(player.playing){
        [player pause];
        [_timer invalidate];
        _timer = nil;
    } else {
        [player play];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target: self
                                                selector: @selector(updateWaveform:) userInfo: nil repeats: YES];
    }
    if (isplay == NO) {
        [player pause];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"playVideo" object:nil];
    }
}

- (void)appGotoBackground{
    [player stop];
    [_timer invalidate];
    _timer = nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchesMoved:touches withEvent:event];
    [player pause];
    [_timer invalidate];
    _timer = nil;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches]anyObject];
    CGPoint location = [touch locationInView:touch.view];
    if(location.x/self.frame.size.width > 0) {
        waveformView.progress = location.x/self.frame.size.width;
    }else{
        
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSTimeInterval newTime = waveformView.progress * player.duration;
    player.currentTime = newTime;
    [player play];
}

- (void)updateWaveform:(id)sender {
    if(player.playing) {
        waveformView.progress = player.currentTime/player.duration;
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"playVideo" object:nil];
    waveformView.progress = 1;
    [_timer invalidate];
    _timer = nil;
}
@end
