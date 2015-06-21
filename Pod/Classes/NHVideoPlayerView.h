//
//  NHVideoPlayerView.h
//  Pods
//
//  Created by Sergey Minakov on 20.06.15.
//
//

#import "NHVideoPlayer.h"

@interface NHVideoPlayerView : NHVideoPlayer

@property (nonatomic, readonly, strong) UIButton *playButton;
@property (nonatomic, readonly, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, readonly, strong) UIView *videoDataView;
@property (nonatomic, readonly, strong) UIButton *muteButton;
@property (nonatomic, readonly, strong) UILabel *durationLabel;

@property (nonatomic, readonly, strong) UIButton *openButton;

+ (Class)videoControllerClass;
@end
