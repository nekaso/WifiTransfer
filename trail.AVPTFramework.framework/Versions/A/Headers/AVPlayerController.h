/*
 *  AVPlayerController.h
 *  This file is part of AVPlayerTouch framework.
 *
 *  Player obj-c wrapper class.
 *
 *  Created by iMoreApps on 2/24/2014.
 *  Copyright (C) 2014 iMoreApps Inc. All rights reserved.
 *  Author: imoreapps <imoreapps@gmail.com>
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    
    kAVPlayerStateInitialized=0,
    kAVPlayerStatePlaying,
    kAVPlayerStatePaused,
    kAVPlayerStateFinishedPlayback,
    kAVPlayerStateStoped,
    
    kAVPlayerStateUnknown=0xff
    
} AVPlayerState;


@protocol AVPlayerControllerDelegate;

/**
 * !!! AVPlayerController component is NOT thread-safe !!!
 */
@interface AVPlayerController : NSObject

@property (nonatomic, readonly) NSString *moviePath;
@property (nonatomic, weak) id <AVPlayerControllerDelegate> delegate;
@property (nonatomic, assign) BOOL shouldAutoPlay;
@property (nonatomic, assign) BOOL shouldPlayOnBackground;

@property (nonatomic, readonly) NSInteger currentAudioTrack;
@property (nonatomic, readonly) NSArray *audioTracks;

@property (nonatomic, readonly) NSInteger currentSubtitleTrack;
@property (nonatomic, readonly) NSArray *subtitleTracks;

/**
 * Adjust contrast and saturation of the video display.
 * @contrast: 0.0 to 4.0, default 1.0
 * @saturation: 0.0 to 2.0, default 1.0
 **/
@property (nonatomic, assign) float contrast;
@property (nonatomic, assign) float saturation;

/*
 * Adjust the screen's brightness.
 */
@property (nonatomic, assign) float brightness;


/*
 * Convert ISO 639-1/2B/2T language code to full english name.
 * @langCode: ISO 639 language code.
 * @isLeft: YES - show negative symbol.
 * @return full english name of the ISO language code or "Unknown".
 */
+ (NSString *)convertISO639LanguageCodeToEnName:(NSString *)langCode;

/*
 * Format second to human readable time string.
 * @seconds: number of seconds
 * @isLeft: YES - show negative symbol.
 * @return formatted time string.
 */
+ (NSString *)formatTimeInterval:(CGFloat)seconds isLeft:(BOOL)isLeft;

/*
 * Init AVPlayerController object.
 * @If failed, return nil, otherwise return initialized AVPlayerController instance.
 */
- (id)init;

/*
 * Open media file at path.
 * @path - path to media file.
 * @If failed, return NO, otherwise return YES.
 */
- (BOOL)openMedia:(NSString *)path onFinishedHandler:(void (^)(BOOL))handler;

/*
 * Get drawable view object
 */
- (UIView *)drawableView;

/*
 * Is movie file from network?
 * @If movie file from network return YES, otherwise return NO.
 */
- (BOOL)isNetworkFile;

/*
 * Enter or exit full screen mode.
 * @enter - YES to enter, NO to exit.
 * @This function does not return a value.
 */
- (void)fullScreen:(BOOL)enter;

/*
 * Determine AVPlayer whether or not is in full screen mode.
 * @If it is in full screen mode, return YES, otherwise return NO.
 */
- (BOOL)isFullscreen;

/*
 * Has audio, video, subtitle stream.
 * @If media has video or audio stream this function return YES, otherwise return NO.
 */
- (BOOL)hasAudio;
- (BOOL)hasVideo;
- (BOOL)hasSubtitle;

/*
 * Switch to special audio tracker
 * @index: index of the audio tracker.
 */
- (void)switchAudioTracker:(int)index;

/*
 * Switch to special subtitle stream
 * @index: index of the subtitle stream.
 */
- (void)switchSubtitleStream:(int)index;

/*
 * Open or close external subtitle file support.
 * @path: subtitle file path.
 * @encoding: encoding of the file.
 */
- (BOOL)openSubtitleFile:(NSString *)path encoding:(CFStringEncoding)encoding;
- (void)closeSubtitleFile;

/*
 * Set subtitle display font.
 * @font: subtitle font.
 */
- (void)setSubtitleFont:(UIFont *)font;

/*
 * Query video frame size.
 * @This function return a CGSize value.
 */
- (CGSize)videoFrameSize;

/*
 * Query AVPlayer current state.
 * @This function return AVPlayer current state info.
 */
- (AVPlayerState)playerState;

/*
 * Query media total duration.
 * @This function return media total duration info.
 */
- (NSTimeInterval)duration;

/*
 * Query AVPlayer current playback time.
 * @This function return current playback time info.
 */
- (NSTimeInterval)currentTime;

/*
 * Start playback.
 * @fact - playback start position, 0~1.0f
 * @If failed, return NO, otherwise return YES.
 */
- (BOOL)play:(double)fact;

/*
 * Fast forward.
 * @This function does not return a value.
 */
- (void)fastforward;

/*
 * Fast backward.
 * @This function does not return a value.
 */
- (void)fastbackward;

/*
 * Pause playback.
 * @This function does not return a value.
 */
- (void)pause;

/*
 * Resume playback.
 * @This function does not return a value.
 */
- (void)resume;

/*
 * Stop playback.
 * @This function does not return a value.
 */
- (void)stop;

/*
 * Seek to position.
 * @fact - 0~1.0f
 * @This function does not return a value.
 */
- (void)seekto:(double)fact;

/*
 * Enable real frame rate calculator.
 * @enable - YES to enable or NO to disable.
 * @This function does not return a value.
 */
- (void)enableCalcFramerate:(BOOL)enable;

/*
 * Get real frame rate.
 * @This function return real frame rate.
 */
- (int)framerate;

/*
 * Enable bit rate calculator.
 * @enable - YES to enable or NO to disable.
 * @This function does not return a value.
 */
- (void)enableCalcBitrate:(BOOL)enable;

/*
 * Get real bit rate.
 * @This function return real bit rate.
 */
- (int)bitrate;

/*
 * Get buffering progress.
 * @This function return buffering progress (0~1.0f).
 */
- (int)bufferingProgress;

/*
 * Get playback speed.
 * @This function return current playback speed (0.5~2.0f).
 */
- (float)playbackSpeed;

/*
 * Get playback speed.
 * @speed - new playback speed.
 * @This function does not return a value.
 */
- (void)setPlaybackSpeed:(float)speed;

@end


@protocol AVPlayerControllerDelegate

@optional

// AVPlayer state was changed
- (void)AVPlayerControllerDidStateChange:(AVPlayerController *)controller;

// AVPlayer current play time was changed
- (void)AVPlayerControllerDidCurTimeChange:(AVPlayerController *)controller position:(NSTimeInterval)position;

// AVPlayer current buffering progress was changed
- (void)AVPlayerControllerDidBufferingProgressChange:(AVPlayerController *)controller progress:(double)progress;

// Enter or exit full screen mode
- (void)AVPlayerControllerDidEnterFullscreenMode:(AVPlayerController *)controller;
- (void)AVPlayerControllerDidExitFullscreenMode:(AVPlayerController *)controller;

@end
