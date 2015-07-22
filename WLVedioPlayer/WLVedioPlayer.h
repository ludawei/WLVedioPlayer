//
//  CWMyMoviePlayController.h
//  ChinaWeather
//
//  Created by 卢大维 on 14/11/21.
//  Copyright (c) 2014年 Platomix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerView.h"

@interface WLVedioPlayer : UIViewController

@property (nonatomic,strong) NSURL *url;
@property (nonatomic) BOOL showShare;

@property (nonatomic,assign) BOOL fullStatus;

@property (nonatomic ,strong) PlayerView *playerView;

- (void)stateButtonTouched;

// 子类使用
-(void)setTotalTimeWithTime:(NSString *)totalTime withMaxSliderValue:(CGFloat)maxValue;
-(void)setCurrentTime:(NSString *)time withSliderValue:(CGFloat)sliderValue;
-(void)setPlayStatus:(BOOL)isPlay;
-(void)setCustomViewHidden:(BOOL)hidden;
@end
