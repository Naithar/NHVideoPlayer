//
//  NHVideoPlayerView.m
//  Pods
//
//  Created by Sergey Minakov on 20.06.15.
//
//

#import "NHVideoPlayerView.h"
#import "NHVideoPlayerViewController.h"

#define image(name) \
[UIImage imageWithContentsOfFile: \
[[NSBundle bundleForClass:[NHVideoPlayerView class]]\
pathForResource:name ofType:@"png"]]

@interface NHVideoPlayerView ()<NHVideoPlayerDelegate, NHVideoPlayerViewControllerDelegate>

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) UIView *videoDataView;
@property (nonatomic, strong) UIButton *muteButton;
@property (nonatomic, strong) UILabel *durationLabel;

@property (nonatomic, strong) UIButton *openButton;

@property (nonatomic, strong) id resignActive;
@property (nonatomic, strong) id enterForeground;

@end

@implementation NHVideoPlayerView

+ (Class)videoControllerClass {
    return [NHVideoPlayerViewController class];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self nhCommonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self nhCommonInit];
    }
    
    return self;
}

- (instancetype)initWithVideoPlayerItem:(AVPlayerItem *)item andPlayer:(AVPlayer *)player {
    self = [super initWithVideoPlayerItem:item andPlayer:player];
    
    if (self) {
        [self nhCommonInit];
    }
    
    return self;
}

- (void)nhCommonInit {
    
    self.nhDelegate = self;
    [self videoLayer].videoGravity = AVLayerVideoGravityResizeAspect;
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.playButton.backgroundColor = [UIColor clearColor];
    [self.playButton setTitle:nil forState:UIControlStateNormal];
    [self.playButton setImage:image(@"NHVideoPlayer.play") forState:UIControlStateNormal];
    self.playButton.imageView.contentMode = UIViewContentModeCenter;
    self.playButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.playButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    [self.playButton addTarget:self action:@selector(playButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.playButton];
    [self setupPlayButtonConstraints];
    
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self addGestureRecognizer:self.tapGesture];
    
    self.videoDataView = [[UIView alloc] init];
    self.videoDataView.translatesAutoresizingMaskIntoConstraints = NO;
    self.videoDataView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    self.videoDataView.clipsToBounds = YES;
    self.videoDataView.layer.cornerRadius = 5;
    self.videoDataView.userInteractionEnabled = YES;
    
    [self addSubview:self.videoDataView];
    [self setupVideoDataViewConstraints];
    
    self.muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.muteButton.frame = CGRectMake(0, 0, 35, 35);
    self.muteButton.backgroundColor = [UIColor clearColor];
    self.muteButton.tintColor = [UIColor whiteColor];
    [self.muteButton setImage:[image(@"NHVideoPlayer.sound") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];

    [self.muteButton setImage:[image(@"NHVideoPlayer.mute") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    [self.muteButton addTarget:self action:@selector(muteButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoDataView addSubview:self.muteButton];
    
    self.durationLabel = [[UILabel alloc] init];
    self.durationLabel.backgroundColor = [UIColor clearColor];
    self.durationLabel.textAlignment = NSTextAlignmentRight;
    self.durationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.durationLabel.font = [UIFont systemFontOfSize:14];
    self.durationLabel.textColor = [UIColor whiteColor];
    self.durationLabel.text = @"00:00";
    
    [self.videoDataView addSubview:self.durationLabel];
    
    [self setupDurationLabelConstraints];
    
    
    self.openButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.openButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.75];
    self.openButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.openButton.tintColor = [UIColor whiteColor];
    [self.openButton setTitle:nil forState:UIControlStateNormal];
    [self.openButton setImage:[image(@"NHVideoPlayer.zoom") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.openButton addTarget:self action:@selector(openButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
//    self.openButton.hidden = YES;
    self.openButton.layer.cornerRadius = 5;
    self.openButton.clipsToBounds = YES;
    
    [self addSubview:self.openButton];
    
    [self setupOpenButtonConstraints];
    
    __weak __typeof(self) weakSelf = self;
    self.resignActive = [[NSNotificationCenter defaultCenter]
                         addObserverForName:UIApplicationWillResignActiveNotification
                         object:nil queue:nil
                         usingBlock:^(NSNotification *note) {
                             __strong __typeof(weakSelf) strongSelf = weakSelf;
                             
                             [strongSelf.videoPlayer pause];
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

- (void)setupPlayButtonConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.playButton
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0 constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.playButton
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0 constant:0]];
    
    [self.playButton addConstraint:[NSLayoutConstraint constraintWithItem:self.playButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.playButton
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:0 constant:50]];
    [self.playButton addConstraint:[NSLayoutConstraint constraintWithItem:self.playButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.playButton
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0 constant:50]];
}

- (void)setupVideoDataViewConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.videoDataView
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0 constant:15]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.videoDataView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0 constant:-10]];
    
    [self.videoDataView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoDataView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.videoDataView
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:0 constant:35]];
    
    [self.videoDataView addConstraint:[NSLayoutConstraint constraintWithItem:self.videoDataView
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                   toItem:self.videoDataView
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:0 constant:60]];
}

- (void)setupDurationLabelConstraints {
    [self.videoDataView addConstraint:[NSLayoutConstraint constraintWithItem:self.durationLabel
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.videoDataView
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0 constant:35]];
    
    [self.videoDataView addConstraint:[NSLayoutConstraint constraintWithItem:self.durationLabel
                                                                   attribute:NSLayoutAttributeRight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.videoDataView
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1.0 constant:-5]];
    
    [self.videoDataView addConstraint:[NSLayoutConstraint constraintWithItem:self.durationLabel
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.videoDataView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0 constant:0]];
    
    [self.videoDataView addConstraint:[NSLayoutConstraint constraintWithItem:self.durationLabel
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.videoDataView
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1.0 constant:0]];
}

- (void)setupOpenButtonConstraints {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.openButton
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1.0 constant:-15]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.openButton
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0 constant:-10]];
    
    [self.openButton addConstraint:[NSLayoutConstraint constraintWithItem:self.openButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.openButton
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:0 constant:35]];
    
    [self.openButton addConstraint:[NSLayoutConstraint constraintWithItem:self.openButton
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.openButton
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:0 constant:35]];
}

- (void)playButtonTouch:(id)sender {
    if (self.videoPlayer.status == AVPlayerStatusReadyToPlay) {
        [self play];
    }
}

- (void)tapGestureAction:(id)sender {
    if (self.videoPlayer.status == AVPlayerStatusReadyToPlay) {
        if (self.videoPlayer.rate == 0) {
            [self play];
        }
        else {
            [self pause];
        }
    }
}

- (void)muteButtonTouch:(id)sender {
    [self.videoPlayer setMuted:!self.muteButton.selected];
    self.muteButton.selected = self.videoPlayer.isMuted;
}

- (void)openButtonTouch:(id)sender {
    
    BOOL wasPlaying = self.videoPlayer.rate != 0;
    
    [self pause];
    NHVideoPlayerViewController *viewController = [[[[self class] videoControllerClass] alloc]
                                                         initWithPlayerUrl:self.videoUrl];
    
    viewController.initialView = self;
    viewController.initialTime = CMTimeGetSeconds(self.videoPlayer.currentTime);
    viewController.initialPlay = wasPlaying;
    viewController.nhDelegate = self;
    
    [UIView transitionWithView:self.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self.window.rootViewController presentViewController:viewController
                                                                     animated:NO
                                                                   completion:nil];
                    } completion:nil];
}

- (void)videoPlayer:(NHVideoPlayer *)player didChangeCurrentTime:(CMTime)time {
    double duration = time.value / time.timescale;
    
    long minutes = duration / 60;
    long seconds = (long)duration % 60;
    
    self.durationLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", minutes, seconds];
}

- (void)playerViewController:(NHVideoPlayerViewController *)controller
          didDismissWithTime:(NSTimeInterval)seconds
                  andPlaying:(BOOL)playing {
    [self.videoPlayer seekToTime:CMTimeMakeWithSeconds(seconds, self.videoPlayerItem.asset.duration.timescale)];
    
    if (playing) {
        [self play];
    }
    else {
        [self pause];
    }
}

- (void)resetState {
    self.playButton.hidden = self.videoPlayer.rate != 0;
}

- (void)didPlayToEndForVideoPlayer:(NHVideoPlayer *)player {
    [self pause];
}

- (void)play {
    self.playButton.hidden = YES;
    [self.videoPlayer play];
    self.videoPlayer.rate = 1;
}

- (void)pause {
    self.playButton.hidden = NO;
    self.videoPlayer.rate = 0;
    [self.videoPlayer pause];
}

-(void)dealloc {
    [self clear];
    [[NSNotificationCenter defaultCenter] removeObserver:self.resignActive];
    [[NSNotificationCenter defaultCenter] removeObserver:self.enterForeground];
}

@end
