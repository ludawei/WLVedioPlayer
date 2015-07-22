//
//  PlayerViewController.m
//  WLVedioPlayerDemo
//
//  Created by 卢大维 on 15/7/22.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "PlayerViewController.h"
#import "UIView+Extra.h"

@interface PlayerViewController ()
{
    BOOL isFullScreen;
}
@property (nonatomic,strong) UIButton *vedioExpButton;

@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic,strong) UISlider *slider;
@property (nonatomic,strong) UILabel *currTimeLbl,*totalTimeLbl;
@property (nonatomic,strong) UIButton *playButton;

@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.playerView.frame)-40, 40, 40)];
    playButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    [playButton setImage:[UIImage imageNamed:@"icon_info_play"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(clickPlayButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playButton];
    self.playButton = playButton;
    
    self.vedioExpButton = [[UIButton alloc] initWithFrame:CGRectMake(self.playerView.width-40, CGRectGetMaxY(self.playerView.frame)-40, 40, 40)];
    self.vedioExpButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    [self.vedioExpButton setImage:[UIImage imageNamed:@"icon_video_expand"] forState:UIControlStateNormal];
    [self.vedioExpButton addTarget:self action:@selector(clickFullExp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.vedioExpButton];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.playerView.frame), self.view.width, self.view.height-CGRectGetMaxY(self.playerView.frame))];
    //    self.bottomView.backgroundColor = [UIColor colorWithRed:0.192 green:0.227 blue:0.271 alpha:1];
    [self.view addSubview:self.bottomView];
    
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, self.bottomView.width, 10)];
    self.slider.center = CGPointMake(self.bottomView.width/2, 2);
    self.slider.minimumTrackTintColor = [UIColor colorWithRed:0.125 green:0.651 blue:0.118 alpha:1];
    self.slider.maximumTrackTintColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.961 alpha:1];
    [self.slider setThumbImage:[UIImage imageNamed:@"icon_video_pre_slider_thuml"] forState:UIControlStateNormal];
    [self.bottomView addSubview:self.slider];
    
}

#pragma mark - 子类使用
-(void)setTotalTimeWithTime:(NSString *)totalTime withMaxSliderValue:(CGFloat)maxValue
{
    self.totalTimeLbl.text = totalTime;
    self.slider.maximumValue = maxValue;
}
-(void)setCurrentTime:(NSString *)time withSliderValue:(CGFloat)sliderValue
{
    self.currTimeLbl.text = time;
    [self.slider setValue:sliderValue animated:YES];
}
-(void)setPlayStatus:(BOOL)isPlay
{
    if (isPlay) {
        [self.playButton setImage:[UIImage imageNamed:@"icon_info_play"] forState:UIControlStateNormal];
    }
    else
    {
        [self.playButton setImage:[UIImage imageNamed:@"icon_info_pause"] forState:UIControlStateNormal];
    }
}
-(void)setCustomViewHidden:(BOOL)hidden
{
    isFullScreen = hidden;
//    if (hidden) {
//        self.navigationItem.rightBarButtonItem = nil;
//        [self.navigationController.navigationBar setBackgroundImage:[Common createImageWithColor:[UIColor colorWithWhite:0 alpha:0.5] width:1 height:44] forBarMetrics:UIBarMetricsDefault];
//        
//        [self.textField resignFirstResponder];
//    }
//    else
//    {
//        //        self.navigationItem.rightBarButtonItem = self.rightBarItem;
//        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"icon_nav"] forBarMetrics:UIBarMetricsDefault];
//    }
    self.playButton.hidden = hidden;
    self.vedioExpButton.hidden = hidden;
    self.bottomView.hidden = hidden;
}


-(void)clickFullExp
{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

-(void)clickPlayButton
{
    [self stateButtonTouched];
}
@end
