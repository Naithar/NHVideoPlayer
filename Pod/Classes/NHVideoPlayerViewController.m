//
//  NHVideoPlayerViewController.m
//  Pods
//
//  Created by Sergey Minakov on 21.06.15.
//
//

#import "NHVideoPlayerViewController.h"

#define image(name) \
[UIImage imageWithContentsOfFile: \
[[NSBundle bundleForClass:[NHVideoPlayerViewController class]]\
pathForResource:name ofType:@"png"]]

@interface NHVideoPlayerViewController ()<NHVideoPlayerDelegate> {
}

@property (nonatomic, strong) NSURL *playerURL;

@property (nonatomic, strong) UIView *topBarView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *muteButton;
@property (nonatomic, strong) UIButton *aspectButton;
@property (nonatomic, strong) UIButton *centerButton;

@property (nonatomic, strong) NHVideoPlayer *videoPlayerView;

@property (nonatomic, strong) UIView *bottomBarView;
@property (nonatomic, strong) UIButton *zoomOutButton;
@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *durationTimeLabel;
@property (nonatomic, strong) UISlider *videoSliderView;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, assign) BOOL sliderEditing;



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

- (void)viewDidLoad {
    [super viewDidLoad];
}



- (void)commonInit {
    self.view.backgroundColor = [UIColor blackColor];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithImage:image(@"NHVideoPlayer.close")
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(closeButtonTouch:)];
    
    [self createComponentViews];
    
    [self setupComponentsConstraints];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self.videoPlayerView addGestureRecognizer:self.tapGesture];
    
    [self setBackgroundMode];
}

- (void)createComponentViews{
    [self createVideoPlayerView];
    
    [self createTopBarView];
    
    [self createCloseButton];
    
    [self createAspectButton];
    
    [self createMuteButton];

    [self createBottomBarView];
    
    [self createZoomOutButton];
    
    [self createPlayButton];

    [self createCurrentTimeLabel];
    
    [self createDurationTimeLabel];
    
    [self createSliderView];
    
    [self createCenterButton];

}

- (void)setupComponentsConstraints {
    [self setupVideoPlayerViewConstraints];
    
    [self setupTopBarViewConstraints];
    
    [self setupCloseButtonConstraints];
    
    [self setupAspectButtonConstraints];
    
    [self setupMuteButtonConstraints];
    
    [self setupBottomBarViewConstraints];
    
    [self setupZoomOutButtonConstraints];
    
    [self setupPlayButtonConstraints];
    
    [self setupCurrentTimeLabelConstraints];
    
    [self setupDurationTimeLabelConstraints];
    
    [self setupCenterButtonConstraints];
}

- (void)createVideoPlayerView {
    self.videoPlayerView = [[NHVideoPlayer alloc] initWithFrame:CGRectZero];
    self.videoPlayerView.backgroundColor = [UIColor blackColor];
    self.videoPlayerView.nhDelegate = self;
    self.videoPlayerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.videoPlayerView.videoUrl = self.playerURL;
    self.videoPlayerView.videoLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view addSubview:self.videoPlayerView];
}

- (void)createTopBarView {
    self.topBarView = [[UIView alloc] init];
    self.topBarView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    self.topBarView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.topBarView];
}

- (void)createCloseButton {
    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.closeButton.tintColor = [UIColor whiteColor];
    [self.closeButton setTitle:nil forState:UIControlStateNormal];
    [self.closeButton setImage:[image(@"NHVideoPlayer.close") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBarView addSubview:self.closeButton];
}

- (void)createAspectButton {
    self.aspectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.aspectButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.aspectButton.tintColor = [UIColor whiteColor];
    [self.aspectButton setTitle:nil forState:UIControlStateNormal];
    [self.aspectButton setImage:[image(@"NHVideoPlayer.aspect") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.aspectButton addTarget:self action:@selector(aspectButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBarView addSubview:self.aspectButton];
}

- (void)createMuteButton {
    self.muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.muteButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.muteButton.backgroundColor = [UIColor clearColor];
    self.muteButton.tintColor = [UIColor whiteColor];
    [self.muteButton setImage:[image(@"NHVideoPlayer.sound") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.muteButton setImage:[image(@"NHVideoPlayer.mute") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    [self.muteButton addTarget:self action:@selector(muteButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBarView addSubview:self.muteButton];
}

- (void)createBottomBarView {
    self.bottomBarView = [[UIView alloc] init];
    self.bottomBarView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    self.bottomBarView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.bottomBarView];
}

- (void)createZoomOutButton {
    self.zoomOutButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.zoomOutButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.zoomOutButton.tintColor = [UIColor whiteColor];
    [self.zoomOutButton setTitle:nil forState:UIControlStateNormal];
    [self.zoomOutButton setImage:[image(@"NHVideoPlayer.zoom-out") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.zoomOutButton addTarget:self action:@selector(closeButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBarView addSubview:self.zoomOutButton];
}

- (void)createPlayButton {
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.playButton.tintColor = [UIColor whiteColor];
    [self.playButton setTitle:nil forState:UIControlStateNormal];
    [self.playButton setImage:[image(@"NHVideoPlayer.play-main") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.playButton setImage:[image(@"NHVideoPlayer.pause") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    [self.playButton addTarget:self action:@selector(playButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBarView addSubview:self.playButton];
}

- (void)createCurrentTimeLabel {
    self.currentTimeLabel = [[UILabel alloc] init];
    self.currentTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.currentTimeLabel.text = @"00:00";
    self.currentTimeLabel.textColor = [UIColor whiteColor];
    self.currentTimeLabel.font = [UIFont systemFontOfSize:14];
    self.currentTimeLabel.textAlignment = NSTextAlignmentLeft;
    [self.bottomBarView addSubview:self.currentTimeLabel];
    self.currentTimeLabel.adjustsFontSizeToFitWidth = YES;
    self.currentTimeLabel.minimumScaleFactor = 0.8;
}

- (void)createDurationTimeLabel {
    self.durationTimeLabel = [[UILabel alloc] init];
    self.durationTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.durationTimeLabel.text = @"00:00";
    self.durationTimeLabel.textAlignment = NSTextAlignmentRight;
    self.durationTimeLabel.textColor = [UIColor whiteColor];
    self.durationTimeLabel.font = [UIFont systemFontOfSize:14];
    [self.bottomBarView addSubview:self.durationTimeLabel];
    self.durationTimeLabel.adjustsFontSizeToFitWidth = YES;
    self.durationTimeLabel.minimumScaleFactor = 0.8;
}

- (void)createSliderView {
    self.videoSliderView = [[UISlider alloc] init];
    self.videoSliderView.backgroundColor = [UIColor clearColor];
    self.videoSliderView.minimumTrackTintColor = [UIColor blueColor];
    self.videoSliderView.tintColor = [UIColor whiteColor];
    self.videoSliderView.maximumTrackTintColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.8];
    self.videoSliderView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bottomBarView addSubview:self.videoSliderView];
    [self.videoSliderView setThumbImage:[image(@"NHVideoPlayer.slider") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self setupVideoSliderBarView];
    [self.videoSliderView addTarget:self action:@selector(videoSliderStartChange:) forControlEvents:UIControlEventTouchDown];
    [self.videoSliderView addTarget:self action:@selector(videoSliderViewDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.videoSliderView addTarget:self action:@selector(videoSliderStopChange:) forControlEvents:UIControlEventTouchCancel|UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
}

- (void)createCenterButton {
    self.centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.centerButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.centerButton.tintColor = [UIColor whiteColor];
    [self.centerButton setImage:[image(@"NHVideoPlayer.play-main@3x") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.centerButton setImage:[image(@"NHVideoPlayer.pause@3x") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    
    self.centerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.centerButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    self.centerButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.centerButton addTarget:self action:@selector(playButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.videoPlayerView addSubview:self.centerButton];
}

- (void)setBackgroundMode {
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
    //
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

- (void)muteButtonTouch:(id)sender {
    [self.videoPlayerView.videoPlayer setMuted:!self.muteButton.selected];
    self.muteButton.selected = self.videoPlayerView.videoPlayer.isMuted;
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
        self.centerButton.alpha = self.centerButton.alpha == 0 ? 1: 0;
    }];
}

- (void)showBars {
    [UIView animateWithDuration:0.5 animations:^{
        self.topBarView.alpha = 1;
        self.bottomBarView.alpha = 1;
        self.centerButton.alpha = 1;
    }];
}

- (void)hideBars {
    [UIView animateWithDuration:0.5 animations:^{
        self.topBarView.alpha = 0;
        self.bottomBarView.alpha = 0;
        self.centerButton.alpha = 0;
    }];
}

- (void) setupCenterButtonConstraints{
    [self.videoPlayerView addConstraint:[NSLayoutConstraint constraintWithItem:self.centerButton
                                                                     attribute:NSLayoutAttributeCenterY
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.videoPlayerView
                                                                     attribute:NSLayoutAttributeCenterY
                                                                    multiplier:1.0 constant:0]];
    
    [self.videoPlayerView addConstraint:[NSLayoutConstraint constraintWithItem:self.centerButton
                                                                     attribute:NSLayoutAttributeCenterX
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.videoPlayerView
                                                                     attribute:NSLayoutAttributeCenterX
                                                                    multiplier:1.0 constant:0]];
    
    [self.centerButton addConstraint:[NSLayoutConstraint constraintWithItem:self.centerButton
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.centerButton
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:0 constant:75]];
    
    [self.centerButton addConstraint:[NSLayoutConstraint constraintWithItem:self.centerButton
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.centerButton
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:0 constant:75]];
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

- (void)setupCurrentTimeLabelConstraints {
    [self.bottomBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.currentTimeLabel
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.bottomBarView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.0 constant:0]];
    
    [self.bottomBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.currentTimeLabel
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.playButton
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1.0 constant:0]];
    
    [self.currentTimeLabel addConstraint:[NSLayoutConstraint constraintWithItem:self.currentTimeLabel
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.currentTimeLabel
                                                                      attribute:NSLayoutAttributeWidth
                                                                     multiplier:0 constant:55]];
    
    [self.currentTimeLabel addConstraint:[NSLayoutConstraint constraintWithItem:self.currentTimeLabel
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.currentTimeLabel
                                                                      attribute:NSLayoutAttributeHeight
                                                                     multiplier:0 constant:44]];
}

- (void)setupDurationTimeLabelConstraints {
    [self.bottomBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.durationTimeLabel
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.bottomBarView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.0 constant:0]];
    
    [self.bottomBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.durationTimeLabel
                                                                   attribute:NSLayoutAttributeRight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.zoomOutButton
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1.0 constant:0]];
    
    [self.durationTimeLabel addConstraint:[NSLayoutConstraint constraintWithItem:self.durationTimeLabel
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.durationTimeLabel
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:0 constant:55]];
    
    [self.durationTimeLabel addConstraint:[NSLayoutConstraint constraintWithItem:self.durationTimeLabel
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.durationTimeLabel
                                                                       attribute:NSLayoutAttributeHeight
                                                                      multiplier:0 constant:44]];
}

- (void)setupVideoSliderBarView {
    [self.bottomBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoSliderView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.bottomBarView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.0 constant:0]];
    
    [self.bottomBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoSliderView
                                                                   attribute:NSLayoutAttributeLeft
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.currentTimeLabel
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1.0 constant:1]];
    
    [self.bottomBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoSliderView
                                                                   attribute:NSLayoutAttributeRight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.durationTimeLabel
                                                                   attribute:NSLayoutAttributeLeft
                                                                  multiplier:1.0 constant:-1]];
    
    [self.videoSliderView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoSliderView
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self.videoSliderView
                                                                     attribute:NSLayoutAttributeHeight
                                                                    multiplier:0 constant:44]];
}

- (void)setupMuteButtonConstraints {
    [self.topBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.muteButton
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.topBarView
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.0 constant:0]];
    
    [self.topBarView addConstraint:[NSLayoutConstraint constraintWithItem:self.muteButton
                                                                attribute:NSLayoutAttributeRight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.aspectButton
                                                                attribute:NSLayoutAttributeLeft
                                                               multiplier:1.0 constant:0]];
    
    [self.muteButton addConstraint:[NSLayoutConstraint constraintWithItem:self.muteButton
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.muteButton
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:0 constant:44]];
    
    [self.muteButton addConstraint:[NSLayoutConstraint constraintWithItem:self.muteButton
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.muteButton
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:0 constant:44]];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


#pragma mark - Play&Pause&Reset

- (void)play {
    self.videoPlayerView.videoPlayer.rate = 1;
    [self.videoPlayerView.videoPlayer play];
    self.playButton.selected = YES;
    self.centerButton.selected = YES;
    
    [self performSelector:@selector(hideBars) withObject:nil afterDelay:2];
}

- (void)pause {
    self.videoPlayerView.videoPlayer.rate = 0;
    [self.videoPlayerView.videoPlayer pause];
    self.playButton.selected = NO;
    self.centerButton.selected = NO;
    
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBars) object:nil];
    [self showBars];
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
        
        if (self.initialMute) {
            [self muteButtonTouch:self];
        }
        
        double duration = self.videoPlayerView.videoPlayerItem.asset.duration.value / self.videoPlayerView.videoPlayerItem.asset.duration.timescale;
        
        self.videoSliderView.minimumValue = 0;
        self.videoSliderView.value = self.initialTime;
        self.videoSliderView.maximumValue = duration;
        
        long minutes = duration / 60;
        long seconds = (long)duration % 60;
        
        self.durationTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", minutes, seconds];
    }
}

- (void)videoPlayer:(NHVideoPlayer *)player didChangeCurrentTime:(CMTime)time {
    double duration = time.value / time.timescale;
    
    if (!self.sliderEditing) {
        self.videoSliderView.value = duration;
        
        [self.initialView.videoPlayer seekToTime:CMTimeMakeWithSeconds(duration, self.initialView.videoPlayerItem.asset.duration.timescale)];
    }
    
    long minutes = duration / 60;
    long seconds = (long)duration % 60;
    
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", minutes, seconds];
}

- (void)videoSliderStartChange:(id)sender {
    self.sliderEditing = YES;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideBars) object:nil];
}
- (void)videoSliderViewDidChange:(id)sender {
    [self.videoPlayerView.videoPlayer seekToTime:CMTimeMakeWithSeconds(self.videoSliderView.value, self.videoPlayerView.videoPlayerItem.asset.duration.timescale)];
}

- (void)videoSliderStopChange:(id)sender {
    self.sliderEditing = NO;
    
    if (self.videoPlayerView.videoPlayer.rate != 0) {
        [self performSelector:@selector(hideBars) withObject:nil afterDelay:4];
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
    [self.videoPlayerView removeFromSuperview];
    self.videoPlayerView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.resignActive];
    [[NSNotificationCenter defaultCenter] removeObserver:self.enterForeground];
}
@end
