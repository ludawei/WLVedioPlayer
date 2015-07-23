//
//  CWMyMoviePlayController.m
//  ChinaWeather
//
//  Created by 卢大维 on 14/11/21.
//  Copyright (c) 2014年 Platomix. All rights reserved.
//

#import "WLVedioPlayer.h"
#import <AVFoundation/AVFoundation.h>

#import "UIView+Extra.h"

#define SCREEN_SIZE ((CGSize)[UIScreen mainScreen].bounds.size)
#define LOG(fmt, ...) NSLog((@"[LOG %@-%@-%d] " fmt), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], NSStringFromSelector(_cmd), __LINE__, ##__VA_ARGS__);

@interface WLVedioPlayer ()
{
    BOOL _played;
    NSString *_totalTime;
    BOOL showControlls;
    BOOL isLoaded;
}

@property (nonatomic ,strong) AVPlayer *player;
@property (nonatomic ,strong) AVPlayerItem *playerItem;

@property (nonatomic,strong) UIView *toolView;
@property (nonatomic ,strong) UIButton *stateButton,*expButton;
@property (nonatomic ,strong) UILabel *timeLabel,*totalTimeLabel;
@property (nonatomic ,strong) id playbackTimeObserver;
@property (nonatomic ,strong) UISlider *videoSlider;
@property (nonatomic ,strong) UIProgressView *videoProgress;

@property (nonatomic,strong) UIButton *shareButton;

//- (void)videoSlierChangeValue:(id)sender;
//- (void)videoSlierChangeValueEnd:(id)sender;

@end

@implementation WLVedioPlayer

// 状态栏样式
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    NSNumber *value = [NSNumber numberWithInt:UIDeviceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    self.view.frame = CGRectMake(0, 0, MIN(SCREEN_SIZE.width, SCREEN_SIZE.height), MAX(SCREEN_SIZE.width, SCREEN_SIZE.height));
    
    [self initViews];
    
    NSURL *videoUrl = self.url;//[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Movie" ofType:@"m4v"]];//[NSURL URLWithString:@"http://www.jxvdy.com/file/upload/201405/05/18-24-58-42-627.mp4"];
    self.playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerView.player = self.player;
    self.playerView.backgroundColor = [UIColor blackColor];
    self.stateButton.enabled = NO;
    
    // 添加视频播放结束通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    
    // 注册
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

-(void)initViews
{
    self.playerView = [[PlayerView alloc] initWithFrame:self.fullStatus?self.view.bounds:CGRectMake(0, 64, self.view.width, self.view.width*9/16)];
    [self.view addSubview:self.playerView];
    
    self.toolView = [[UIView alloc] initWithFrame:CGRectZero];
    self.toolView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self.view addSubview:self.toolView];
    
    self.stateButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.stateButton setImage:[UIImage imageNamed:@"icon_full_play"] forState:UIControlStateNormal];
    [self.stateButton addTarget:self action:@selector(stateButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView addSubview:self.stateButton];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeLabel.text = @"time";
    self.timeLabel.font = [UIFont systemFontOfSize:10];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.toolView addSubview:self.timeLabel];
    
    self.videoProgress = [[UIProgressView alloc] initWithFrame:CGRectZero];
    [self.toolView addSubview:self.videoProgress];
    
    self.videoSlider = [[UISlider alloc] initWithFrame:self.videoProgress.frame];
    [self.videoSlider addTarget:self action:@selector(videoSlierChangeValue:) forControlEvents:UIControlEventValueChanged];
    [self.videoSlider addTarget:self action:@selector(videoSlierChangeValueEnd:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoSlider setThumbImage:[UIImage imageNamed:@"icon_full_slider_thuml"] forState:UIControlStateNormal];
    [self.toolView addSubview:self.videoSlider];
    
    self.totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.totalTimeLabel.text = @"time";
    self.totalTimeLabel.font = [UIFont systemFontOfSize:10];
    self.totalTimeLabel.textColor = [UIColor whiteColor];
    self.totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.toolView addSubview:self.totalTimeLabel];
    
    self.expButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.expButton setImage:[UIImage imageNamed:@"icon_full_exp"] forState:UIControlStateNormal];
    [self.expButton addTarget:self action:@selector(expButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView addSubview:self.expButton];
    
    self.toolView.hidden = !self.fullStatus;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    isLoaded = YES;
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
//    [self.view addGestureRecognizer:tap];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    if (self.view.width > self.view.height) {
        self.fullStatus = YES;
        self.toolView.hidden = !self.fullStatus;
        
        self.toolView.frame = CGRectMake(0, self.view.bounds.size.height-40, self.view.bounds.size.width, 40);
        
        CGFloat buttonWidth = 60;
        CGFloat toolWidth = self.toolView.bounds.size.width,toolHeight = self.toolView.bounds.size.height;
        self.stateButton.frame = CGRectMake(0, 0, buttonWidth, toolHeight);
        self.timeLabel.frame = CGRectMake(CGRectGetMaxX(self.stateButton.frame), 0, buttonWidth, toolHeight);
        self.videoProgress.frame = CGRectMake(CGRectGetMaxX(self.timeLabel.frame), 0, toolWidth-CGRectGetMaxX(self.timeLabel.frame)*2, 10);
        self.videoProgress.center = CGPointMake(toolWidth/2, toolHeight/2);
        self.videoSlider.frame = self.videoProgress.frame;
        self.totalTimeLabel.frame = CGRectMake(CGRectGetMaxX(self.videoSlider.frame), 0, buttonWidth, toolHeight);
        self.expButton.frame = CGRectMake(toolWidth-buttonWidth, 0, buttonWidth, toolHeight);

    }
    else
    {
        self.fullStatus = NO;
        self.toolView.hidden = !self.fullStatus;
    }
    
    // 子类调用
    if ([self respondsToSelector:@selector(setCustomViewHidden:)]) {
        [self setCustomViewHidden:self.fullStatus];
    }
    self.playerView.frame = self.fullStatus?self.view.bounds:CGRectMake(0, 64, self.view.width, self.view.width*9/16);
}

#pragma mark - view rotate
- (NSUInteger)supportedInterfaceOrientations
{
    if (isLoaded) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

#pragma mark - update UI
- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    
    __weak typeof(self) weakSelf = self;
    self.playbackTimeObserver = [self.playerView.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        [weakSelf updateTimeLabel];
    }];
}

-(void)updateTimeLabel
{
    CGFloat currentSecond = self.playerItem.currentTime.value/self.playerItem.currentTime.timescale;// 计算当前在第几秒
    [self updateVideoSlider:currentSecond];
    NSString *timeString = [self convertTime:currentSecond];
    self.timeLabel.text = timeString;//[NSString stringWithFormat:@"%@/%@",timeString,_totalTime];
    
    // 子类使用
    if ([self respondsToSelector:@selector(setCurrentTime:withSliderValue:)]) {
        [self setCurrentTime:timeString withSliderValue:currentSecond];
    }
}

#pragma mark - KVO方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            LOG(@"AVPlayerStatusReadyToPlay");
            self.stateButton.enabled = YES;
            CMTime duration = self.playerItem.duration;// 获取视频总长度
            CGFloat totalSecond = playerItem.duration.value / playerItem.duration.timescale;// 转换成秒
            _totalTime = [self convertTime:totalSecond];// 转换成播放时间
            self.totalTimeLabel.text = _totalTime;
            
            // 子类使用
            if ([self respondsToSelector:@selector(setTotalTimeWithTime:withMaxSliderValue:)]) {
                [self setTotalTimeWithTime:_totalTime withMaxSliderValue:CMTimeGetSeconds(duration)];
            }
            
            [self customVideoSlider:duration];// 自定义UISlider外观
            LOG(@"movie total duration:%f",CMTimeGetSeconds(duration));
            [self monitoringPlayback:self.playerItem];// 监听播放状态
            [self updateTimeLabel];
            
            [self stateButtonTouchedWithStatus:YES];
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            LOG(@"AVPlayerStatusFailed");
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
        LOG(@"Time Interval:%f",timeInterval);
        CMTime duration = self.playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self.videoProgress setProgress:timeInterval / totalDuration animated:YES];
    }
    else if ([keyPath isEqualToString:@"playbackBufferEmpty"])
    {
        if (self.playerItem.playbackBufferEmpty)
        {
            [self stateButtonTouchedWithStatus:NO];
            LOG(@"player item playback buffer is empty");
        }
    }

}

#pragma mark - video actions
- (void)customVideoSlider:(CMTime)duration {
    self.videoSlider.maximumValue = CMTimeGetSeconds(duration);
    UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, NO, 0.0f);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.videoSlider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
    [self.videoSlider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
}

- (void)stateButtonTouchedWithStatus:(BOOL)isPlay
{
    if (isPlay) {
        [self.playerView.player play];
        [self.stateButton setImage:[UIImage imageNamed:@"icon_full_pause"] forState:UIControlStateNormal];
        
        // 子类使用
        if ([self respondsToSelector:@selector(setPlayStatus:)]) {
            [self setPlayStatus:NO];
        }
    }
    
    if (!isPlay) {
        [self.playerView.player pause];
        [self.stateButton setImage:[UIImage imageNamed:@"icon_full_play"] forState:UIControlStateNormal];
        
        // 子类使用
        if ([self respondsToSelector:@selector(setPlayStatus:)]) {
            [self setPlayStatus:YES];
        }
    }
    _played = isPlay;
}

- (void)stateButtonTouched
{
    if (!_played) {
        [self.playerView.player play];
        [self.stateButton setImage:[UIImage imageNamed:@"icon_full_pause"] forState:UIControlStateNormal];
        
        // 子类使用
        if ([self respondsToSelector:@selector(setPlayStatus:)]) {
            [self setPlayStatus:NO];
        }
    } else {
        [self.playerView.player pause];
        [self.stateButton setImage:[UIImage imageNamed:@"icon_full_play"] forState:UIControlStateNormal];
        
        // 子类使用
        if ([self respondsToSelector:@selector(setPlayStatus:)]) {
            [self setPlayStatus:YES];
        }
    }
    _played = !_played;
}

- (void)videoSlierChangeValue:(id)sender {
    UISlider *slider = (UISlider *)sender;
    LOG(@"value change:%f",slider.value);
    
    if (slider.value == 0.000000) {
        [self.playerView.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [self.playerView.player play];
        }];
    }
}

- (void)videoSlierChangeValueEnd:(id)sender {
    UISlider *slider = (UISlider *)sender;
    LOG(@"value end:%f",slider.value);
    CMTime changedTime = CMTimeMakeWithSeconds(slider.value, 1);
    [self.playerView.player seekToTime:changedTime completionHandler:^(BOOL finished) {
        [self.playerView.player play];
        [self.stateButton setImage:[UIImage imageNamed:@"icon_full_pause"] forState:UIControlStateNormal];
        
        // 子类使用
        if ([self respondsToSelector:@selector(setPlayStatus:)]) {
            [self setPlayStatus:NO];
        }
    }];
}

- (void)updateVideoSlider:(CGFloat)currentSecond {
    [self.videoSlider setValue:currentSecond animated:YES];
}


- (void)moviePlayDidEnd:(NSNotification *)notification {
    LOG(@"Play end");
    [self.playerView.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        _played = NO;
        [self updateVideoSlider:0.0];
        [self.stateButton setImage:[UIImage imageNamed:@"icon_full_play"] forState:UIControlStateNormal];
        
        // 子类使用
        if ([self respondsToSelector:@selector(setPlayStatus:)]) {
            [self setPlayStatus:YES];
        }
    }];
}

#pragma mark - tool methods
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.playerView.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}

-(void)clear
{
    [self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    [self.playerView.player removeTimeObserver:self.playbackTimeObserver];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [self clear];
    
    self.playerItem = nil;
    
    if (self.playerView.player) {
        [self.playerView.player pause];
        self.playerView.player = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)willEnterForeground
{
    if (self.playerView.player) {
        [self.playerView.player play];
    }
}

-(void)didEnterBackground
{
    if (self.playerView.player) {
        [self.playerView.player pause];
    }
}

#pragma mark - button actions
-(void)backButtonClicked
{
    self.shareButton.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)expButtonTouched
{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

@end
