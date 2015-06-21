//
//  NHVideoPlayerViewController.m
//  Pods
//
//  Created by Sergey Minakov on 21.06.15.
//
//

#import "NHVideoPlayerViewController.h"

@interface NHVideoPlayerViewController ()<NHVideoPlayerDelegate> {
}

@property (nonatomic, strong) NSURL *playerURL;

@property (nonatomic, strong) UIView *topBarView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *aspectButton;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) NHVideoPlayer *videoPlayerView;

@property (nonatomic, strong) UIView *bottomBarView;

@property (nonatomic, strong) id resignActive;
@property (nonatomic, strong) id enterForeground;

@end

@implementation NHVideoPlayerViewController

- (instancetype)initWithPlayerUrl:(NSURL*)playerURL {
    self = [super init];
    
    if (self) {
        _playerURL = playerURL;
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.view.backgroundColor = [UIColor blackColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithImage:[UIImage
                                                            imageNamed:@"NHVideoPlayer.close.png"]
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(closeButtonTouch:)];
    
    self.videoPlayerView = [[NHVideoPlayer alloc] initWithFrame:CGRectZero];
    self.videoPlayerView.backgroundColor = [UIColor blackColor];
    self.videoPlayerView.nhDelegate = self;
    self.videoPlayerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.videoPlayerView.videoUrl = self.playerURL;
    self.videoPlayerView.videoLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view addSubview:self.videoPlayerView];
    [self setupVideoPlayerViewConstraints];
    
    self.topBarView = [[UIView alloc] init];
    self.topBarView.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.75];
    self.topBarView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.topBarView];
    
    [self setupTopBarViewConstraints];
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.closeButton.tintColor = [UIColor whiteColor];
    [self.closeButton setTitle:nil forState:UIControlStateNormal];
    [self.closeButton setImage:[[UIImage imageNamed:@"NHVideoPlayer.close.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBarView addSubview:self.closeButton];
    [self setupCloseButtonConstraints];
    
    self.aspectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.aspectButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.aspectButton.tintColor = [UIColor whiteColor];
    [self.aspectButton setTitle:nil forState:UIControlStateNormal];
    [self.aspectButton setImage:[[UIImage imageNamed:@"NHVideoPlayer.close.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.aspectButton addTarget:self action:@selector(aspectButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBarView addSubview:self.aspectButton];
    [self setupAspectButtonConstraints];
    
    __weak __typeof(self) weakSelf = self;
    self.resignActive = [[NSNotificationCenter defaultCenter]
                         addObserverForName:UIApplicationWillResignActiveNotification
                         object:nil queue:nil
                         usingBlock:^(NSNotification *note) {
                             __strong __typeof(weakSelf) strongSelf = weakSelf;
                             
                             [strongSelf pause];
                             [strongSelf resetState];
                         }];
    
    self.enterForeground = [[NSNotificationCenter defaultCenter]
                            addObserverForName:UIApplicationWillEnterForegroundNotification
                            object:nil queue:nil
                            usingBlock:^(NSNotification *note) {
                                __strong __typeof(weakSelf) strongSelf = weakSelf;
                                
                                [strongSelf resetState];
                            }];
}

- (void)closeButtonTouch:(id)sender {
    [self dismiss];
}

- (void)dismiss {
    BOOL wasPlaying = self.videoPlayerView.videoPlayer.rate != 0;
    [self.videoPlayerView.videoPlayer pause];
    NSTimeInterval time = self.videoPlayerView.videoPlayer.currentTime.value / self.videoPlayerView.videoPlayer.currentTime.timescale;
    
    [UIView transitionWithView:self.view.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self dismissViewControllerAnimated:NO completion:nil];
                        
                        __weak __typeof(self) weakSelf = self;
                        if ([weakSelf.nhDelegate respondsToSelector:@selector(playerViewController:didDismissWithTime:andPlaying:)]) {
                            [weakSelf.nhDelegate playerViewController:weakSelf
                                                   didDismissWithTime:time
                                                           andPlaying:wasPlaying];
                        }
                    } completion:nil];
}

- (void)aspectButtonTouch:(id)sender {
    if ([self.videoPlayerView.videoLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        self.videoPlayerView.videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    else {
        self.videoPlayerView.videoLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
}

- (void)setupVideoPlayerViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayerView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayerView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayerView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.videoPlayerView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
}

- (void)setupTopBarViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topBarView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topBarView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topBarView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.topBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.topBarView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topBarView
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:0 constant:50]];
}

- (void)setupCloseButtonConstraints {
    [self.topBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topBarView
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0 constant:0]];
    
    [self.topBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topBarView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.closeButton addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.closeButton
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:0 constant:44]];
    
    [self.closeButton addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.closeButton
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:0 constant:44]];
}

- (void)setupAspectButtonConstraints {
    [self.topBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.aspectButton
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.topBarView
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.0 constant:0]];
    
    [self.topBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.aspectButton
                                                                attribute:NSLayoutAttributeRight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.topBarView
                                                                attribute:NSLayoutAttributeRight
                                                               multiplier:1.0 constant:0]];
    
    [self.aspectButton addConstraint:[NSLayoutConstraint constraintWithItem:self.aspectButton
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.aspectButton
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:0 constant:44]];
    
    [self.aspectButton addConstraint:[NSLayoutConstraint constraintWithItem:self.aspectButton
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.aspectButton
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:0 constant:44]];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)play {
    [self.videoPlayerView.videoPlayer play];
}

- (void)pause {
    [self.videoPlayerView.videoPlayer pause];
}

- (void)resetState {
//    self.playButton.hidden = self.videoPlayer.rate != 0;
}

- (void)videoPlayer:(NHVideoPlayer *)player didChangeStatus:(AVPlayerStatus)status {
    if (status == AVPlayerStatusReadyToPlay) {
        [self.videoPlayerView.videoPlayer seekToTime:CMTimeMakeWithSeconds(self.initialTime, self.videoPlayerView.videoPlayerItem.asset.duration.timescale)];
        if (self.initialPlay) {
            [self.videoPlayerView.videoPlayer play];
        }
    }
}

- (void)setInitialTime:(NSTimeInterval)initialTime {
    [self willChangeValueForKey:@"initialTime"];
    _initialTime = initialTime;
    [self.videoPlayerView.videoPlayer seekToTime:CMTimeMakeWithSeconds(self.initialTime, self.videoPlayerView.videoPlayerItem.asset.duration.timescale)];
    [self didChangeValueForKey:@"initialTime"];
}

- (void)dealloc {
    [self.videoPlayerView clear];
    [self.videoPlayerView removeFromSuperview];
    self.videoPlayerView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.resignActive];
    [[NSNotificationCenter defaultCenter] removeObserver:self.enterForeground];
}
@end
