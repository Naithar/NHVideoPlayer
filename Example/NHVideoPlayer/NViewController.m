//
//  NViewController.m
//  NHVideoPlayer
//
//  Created by Naithar on 06/20/2015.
//  Copyright (c) 2014 Naithar. All rights reserved.
//

#import "NViewController.h"
#import <NHVideoPlayerView.h>
@interface NViewController ()

@property (nonatomic, strong) NHVideoPlayerView *videoPlayer;

@end

@implementation NViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.videoPlayer = [[NHVideoPlayerView alloc] initWithFrame:CGRectMake(0, 100, 320, 170)];
    self.videoPlayer.videoUrl = [NSURL URLWithString:@"http://techslides.com/demos/sample-videos/small.mp4"];
    
    
    [self.view addSubview:self.videoPlayer];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
