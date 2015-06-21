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

@property (nonatomic, weak) NHVideoPlayer *initialView;
@property (nonatomic, assign) NSTimeInterval initialTime;
@property (nonatomic, assign) BOOL initialPlay;

- (instancetype)initWithPlayerUrl:(NSURL*)playerURL;

@end
