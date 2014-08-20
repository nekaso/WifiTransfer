//
//  AVPlayerViewController.h
//  AVPlayer
//
//  Created by apple on 13-5-22.
//  Copyright (c) 2013年 iMoreApp Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <trail.AVPTFramework/AVPlayerController.h>

@interface AVPlayerViewController : UIViewController

// audio or video file path (local or network file path)
@property (nonatomic, strong) NSString *mediaPath;

// did load video successfully callback.
@property (nonatomic, copy) void (^didLoadVideo)(AVPlayerController *player);

// get start playback time (>= 0 and <= media duration).
// if the property is nil, player will start playback from begining.
// the callback returns a float number value or nil.
@property (nonatomic, copy) NSNumber* (^getStartTime)(AVPlayerController *player, NSString *path);

// required saving progress info, you can save progress here.
@property (nonatomic, copy) void (^saveProgress)(AVPlayerController *player);

// on video playback did finish.
@property (nonatomic, copy) void (^didFinishPlayback)(AVPlayerController *player);

// on video player controller will be dismissed.
@property (nonatomic, copy) void (^willDismiss)(void);

// Start playback at special time position
- (void)startPlaybackAt:(NSNumber *)startTimePosition;

@end
