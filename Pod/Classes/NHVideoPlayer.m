//
//  NHVideoPlayer.m
//  Pods
//
//  Created by Sergey Minakov on 20.06.15.
//
//

#import "NHVideoPlayer.h"


@interface NHVideoPlayer ()

@property (nonatomic, strong) AVPlayerItem *videoPlayerItem;
@property (nonatomic, strong) AVPlayer *videoPlayer;

@property (nonatomic, strong) NSTimer *videoTimer;
@property (nonatomic, assign) UIBackgroundTaskIdentifier videoTaskIdentifier;

@property (nonatomic, strong) id videoEndObserver;
@end

@implementation NHVideoPlayer

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer*)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (AVPlayerLayer*)videoLayer {
    return (AVPlayerLayer *)[self layer];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithVideoPlayerItem:(AVPlayerItem*)item andPlayer:(AVPlayer*)player {
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        [self commonInit];
        _videoPlayerItem = item;
        _videoPlayer = player;
        [self resetVideoPlayer];
    }
    
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor blackColor];
    
    [self startTimer];
}

- (void)resetVideoPlayer {
    [self setPlayer:self.videoPlayer];
}

- (void)resetVideoPlayerOnUrl {
    [self.videoPlayer pause];
    
    self.videoPlayerItem = [AVPlayerItem playerItemWithURL:self.videoUrl];
    self.videoPlayer = [AVPlayer playerWithPlayerItem:self.videoPlayerItem];
    
    [self setPlayer:self.videoPlayer];
}

- (void)videoTimerMain:(id)sender {
    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.nhDelegate respondsToSelector:@selector(videoPlayer:didChangeCurrentTime:)]) {
        [weakSelf.nhDelegate videoPlayer:weakSelf didChangeCurrentTime:weakSelf.videoPlayer.currentTime];
    }
}

- (void)setVideoUrl:(NSURL *)videoUrl {
    if (![videoUrl.absoluteString isEqualToString:self.videoUrl.absoluteString]) {
        [self willChangeValueForKey:@"videoUrl"];
        _videoUrl = videoUrl;
        [self resetVideoPlayerOnUrl];
        [self didChangeValueForKey:@"videoUrl"];
    }
}

- (void)setVideoPlayer:(AVPlayer *)videoPlayer {
    [self willChangeValueForKey:@"videoPlayer"];
    [self removeVideoObserver];
    _videoPlayer = videoPlayer;
    [self addVideoObserver];
    [self didChangeValueForKey:@"videoPlayer"];
}

- (void)startTimer {
    [self stopTimer];
    self.videoTaskIdentifier = UIBackgroundTaskInvalid;
    self.videoTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
    
    self.videoTimer = [NSTimer timerWithTimeInterval:0.5
                                              target:self
                                            selector:@selector(videoTimerMain:)
                                            userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:self.videoTimer
                              forMode:NSRunLoopCommonModes];
    [[NSRunLoop mainRunLoop] addTimer:self.videoTimer
                              forMode:UITrackingRunLoopMode];
    
}

- (void)stopTimer {
    self.videoTaskIdentifier = UIBackgroundTaskInvalid;
    [self.videoTimer invalidate];
    self.videoTimer = nil;
}

- (void)addVideoObserver {
    
    __weak __typeof(self) weakSelf = self;
    self.videoEndObserver = [[NSNotificationCenter defaultCenter]
                             addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                             object:self.videoPlayer
                             queue:nil usingBlock:^(NSNotification *note) {
                                 
                                 if ([weakSelf.nhDelegate respondsToSelector:@selector(didPlayToEndForVideoPlayer:)]) {
                                     [weakSelf.nhDelegate didPlayToEndForVideoPlayer:weakSelf];
                                 }
                                 
                                 __strong __typeof(weakSelf) strongSelf = weakSelf;
                                 [strongSelf resetVideoDuration];
                             }];
}

- (void)resetVideoDuration {
    [self.videoPlayer pause];
    
    BOOL shouldReset = YES;
    __weak __typeof(self) weakSelf = self;
    if ([weakSelf.nhDelegate respondsToSelector:@selector(shouldResetDurationForVideoPlayer:)]) {
        shouldReset = [weakSelf.nhDelegate shouldResetDurationForVideoPlayer:weakSelf];
    }
    
    if (shouldReset) {
        [self.videoPlayer seekToTime:kCMTimeZero];
    }
    
}

- (void)removeVideoObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self.videoEndObserver];
}

- (void)dealloc {
    [self.videoPlayer pause];
    [self stopTimer];
    [self removeVideoObserver];
}


@end
