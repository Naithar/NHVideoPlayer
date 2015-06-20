//
//  NHVideoPlayer.h
//  Pods
//
//  Created by Sergey Minakov on 20.06.15.
//
//

@import UIKit;
@import AVFoundation;

@class NHVideoPlayer;

@protocol NHVideoPlayerDelegate <NSObject>

@optional
- (void)videoPlayer:(NHVideoPlayer*)player didChangeCurrentTime:(CMTime)time;
- (void)didPlayToEndForVideoPlayer:(NHVideoPlayer*)player;
- (BOOL)shouldResetDurationForVideoPlayer:(NHVideoPlayer*)player;

@end

@interface NHVideoPlayer : UIView

@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, readonly, strong) AVPlayerItem *videoPlayerItem;
@property (nonatomic, readonly, strong) AVPlayer *videoPlayer;

@property (nonatomic, weak) id<NHVideoPlayerDelegate> nhDelegate;

- (instancetype)initWithVideoPlayerItem:(AVPlayerItem*)item andPlayer:(AVPlayer*)player;
- (AVPlayerLayer*)videoLayer;
@end
