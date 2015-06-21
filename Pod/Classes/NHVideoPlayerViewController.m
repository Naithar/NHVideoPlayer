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
@property (nonatomic, strong) UIButton *zoomOutButton;
@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
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
    [self.aspectButton setImage:[[UIImage imageNamed:@"NHVideoPlayer.aspect.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.aspectButton addTarget:self action:@selector(aspectButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBarView addSubview:self.aspectButton];
    [self setupAspectButtonConstraints];
    
    self.bottomBarView = [[UIView alloc] init];
    self.bottomBarView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.75];
    self.bottomBarView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.bottomBarView];
    [self setupBottomBarViewConstraints];
    
    self.zoomOutButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.zoomOutButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.zoomOutButton.tintColor = [UIColor whiteColor];
    [self.zoomOutButton setTitle:nil forState:UIControlStateNormal];
    [self.zoomOutButton setImage:[[UIImage imageNamed:@"NHVideoPlayer.zoom-out.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.zoomOutButton addTarget:self action:@selector(closeButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBarView addSubview:self.zoomOutButton];
    [self setupZoomOutButtonConstraints];
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.playButton.tintColor = [UIColor whiteColor];
    [self.playButton setTitle:nil forState:UIControlStateNormal];
    [self.playButton setImage:[[UIImage imageNamed:@"NHVideoPlayer.play-main.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.playButton setImage:[[UIImage imageNamed:@"NHVideoPlayer.pause.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    [self.playButton addTarget:self action:@selector(playButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBarView addSubview:self.playButton];
    [self setupPlayButtonConstraints];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self.videoPlayerView addGestureRecognizer:self.tapGesture];
    
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
    [self pause];
    NSTimeInterval time = CMTimeGetSeconds(self.videoPlayerView.videoPlayer.currentTime);
    
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

- (void)playButtonTouch:(id)sender {
    if (self.videoPlayerView.videoPlayer.status == AVPlayerStatusReadyToPlay) {
        if (self.videoPlayerView.videoPlayer.rate == 0) {
            [self play];
        }
        else {
            [self pause];
        }
    }
}

- (void)tapGestureAction:(id)sender {
    [self changeVisibilityState];
    
    if (self.videoPlayerView.videoPlayer.rate != 0) {
        [self performSelector:@selector(hideBars) withObject:nil afterDelay:4];
    }
}

- (void)changeVisibilityState {
    [UIView animateWithDuration:0.5 animations:^{
        self.topBarView.alpha = self.topBarView.alpha == 0 ? 1 : 0;
        self.bottomBarView.alpha = self.bottomBarView.alpha == 0 ? 1 : 0;
    }];
}

- (void)hideBars {
    [UIView animateWithDuration:0.5 animations:^{
        self.topBarView.alpha = 0;
        self.bottomBarView.alpha = 0;
    }];
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

- (void)setupBottomBarViewConstraints {
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBarView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBarView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBarView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0 constant:0]];
    
    [self.bottomBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBarView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.bottomBarView
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:0 constant:50]];
}

- (void)setupZoomOutButtonConstraints {
    [self.bottomBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.zoomOutButton
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.bottomBarView
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.0 constant:0]];
    
    [self.bottomBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.zoomOutButton
                                                                attribute:NSLayoutAttributeRight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.bottomBarView
                                                                attribute:NSLayoutAttributeRight
                                                               multiplier:1.0 constant:0]];
    
    [self.zoomOutButton addConstraint:[NSLayoutConstraint constraintWithItem:self.zoomOutButton
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.zoomOutButton
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:0 constant:44]];
    
    [self.zoomOutButton addConstraint:[NSLayoutConstraint constraintWithItem:self.zoomOutButton
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.zoomOutButton
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:0 constant:44]];
}

- (void)setupPlayButtonConstraints {
    [self.bottomBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.playButton
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.bottomBarView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.0 constant:0]];
    
    [self.bottomBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.playButton
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.bottomBarView
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1.0 constant:0]];
    
    [self.playButton addConstraint:[NSLayoutConstraint constraintWithItem:self.playButton
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.playButton
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:0 constant:44]];
    
    [self.playButton addConstraint:[NSLayoutConstraint constraintWithItem:self.playButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.playButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:0 constant:44]];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)play {
    self.videoPlayerView.videoPlayer.rate = 1;
    [self.videoPlayerView.videoPlayer play];
    self.playButton.selected = YES;
    
    [self performSelector:@selector(hideBars) withObject:nil afterDelay:2];
}

- (void)pause {
    self.videoPlayerView.videoPlayer.rate = 0;
    [self.videoPlayerView.videoPlayer pause];
    self.playButton.selected = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBars) object:nil];
}

- (void)resetState {
    self.playButton.selected = self.videoPlayerView.videoPlayer.rate != 0;
}

- (void)videoPlayer:(NHVideoPlayer *)player didChangeStatus:(AVPlayerStatus)status {
    if (status == AVPlayerStatusReadyToPlay) {
        [self.videoPlayerView.videoPlayer seekToTime:CMTimeMakeWithSeconds(self.initialTime, self.videoPlayerView.videoPlayerItem.asset.duration.timescale)];
        if (self.initialPlay) {
            [self play];
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
    [self pause];
    [self.videoPlayerView removeGestureRecognizer:self.tapGesture];
    [self.videoPlayerView clear];
    [self.videoPlayerView removeFromSuperview];
    self.videoPlayerView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.resignActive];
    [[NSNotificationCenter defaultCenter] removeObserver:self.enterForeground];
}
@end
