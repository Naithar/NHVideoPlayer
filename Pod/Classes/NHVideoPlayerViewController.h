//
//  NHVideoPlayerViewController.h
//  Pods
//
//  Created by Sergey Minakov on 21.06.15.
//
//

@import UIKit;
@import AVFoundation;
#import "NHVideoPlayer.h"

@class NHVideoPlayerViewController;

@protocol NHVideoPlayerViewControllerDelegate <NSObject>

@optional
- (void)playerViewController:(NHVideoPlayerViewController*)controller didDismissWithTime:(NSTimeInterval)seconds andPlaying:(BOOL)playing;

@end

@interface NHVideoPlayerViewController : UIViewController

@property (nonatomic, weak) id<NHVideoPlayerViewControllerDelegate> nhDelegate;

@property (nonatomic, readonly, strong) NHVideoPlayer *videoPlayerView;

@property (nonatomic, readonly, strong) UIView *topBarView;
@property (nonatomic, readonly, strong) UIButton *closeButton;
@property (nonatomic, readonly, strong) UIButton *muteButton;
@property (nonatomic, readonly, strong) UIButton *aspectButton;

@property (nonatomic, readonly, strong) UIView *bottomBarView;
@property (nonatomic, readonly, strong) UIButton *zoomOutButton;
@property (nonatomic, readonly, strong) UIButton *playButton;

@property (nonatomic, readonly, strong) UILabel *currentTimeLabel;
@property (nonatomic, readonly, strong) UILabel *durationTimeLabel;
@property (nonatomic, readonly, strong) UISlider *videoSliderView;

@property (nonatomic, readonly, assign) BOOL sliderEditing;

@property (nonatomic, weak) NHVideoPlayer *initialView;
@property (nonatomic, assign) NSTimeInterval initialTime;
@property (nonatomic, assign) BOOL initialPlay;

- (instancetype)initWithPlayerUrl:(NSURL*)playerURL;

@end
