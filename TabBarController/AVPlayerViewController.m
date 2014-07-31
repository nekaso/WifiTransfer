//
//  AVPlayerViewController.m
//  AVPlayer
//
//  Created by apple on 2/27/14.
//  Copyright (c) 2014 iMoreApps Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import <trail.AVPTFramework/AVPlayerController.h>

#import "AVPlayerViewController.h"
#import "UIAlertView+Blocks.h"
#import "AdjustSpeedView.h"
#import "VideoEffectView.h"

@interface AVPlayerViewController () <AVPlayerControllerDelegate> {
    AVPlayerController *_avplayController;
    
    BOOL                _prevStatusBarHidden;
    UIStatusBarStyle    _prevStatusBarStyle;
    
    UINavigationBar     *_topBar;
    UIView              *_topHUD;
    UIView              *_bottomHUD;
    UISlider            *_progressSlider;
    MPVolumeView        *_volumeSlider;
    UIButton            *_playButton;
    UIButton            *_rewindButton;
    UIButton            *_forwardButton;
    UILabel             *_progressLabel;
    UILabel             *_leftLabel;
    UIBarButtonItem     *_fullscreenButton;
    
    AdjustSpeedView     *_adjustSpeedView;
    VideoEffectView     *_videoEffectView;
    
    BOOL                _hudVisible;
    UIView              *_glView;
    UIImageView         *_coverImageView;
    UITapGestureRecognizer *_tapGestureRecognizer;
}
@end

@implementation AVPlayerViewController

// Initialize self

- (void)initialize
{
    // Hold status bar infos
    _prevStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    _prevStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    
    if (![self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.wantsFullScreenLayout = YES;
    }
    
    // Other initalization
    _hudVisible = YES;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialize self
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialize self
        [self initialize];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialize self
        [self initialize];
    }
    return self;
}

// Load root view
- (void)loadView
{
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    
    self.view = [[UIView alloc] initWithFrame:bounds];
    self.view.backgroundColor = [UIColor blackColor];
    self.view.autoresizesSubviews = YES;
}

// Build up sub-views

- (void)buildViews
{
    CGRect bounds = self.view.bounds;
    
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;
    
    CGSize  statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
    CGFloat statusbarHeight = fminf(statusBarSize.width, statusBarSize.height);
    
    // Top HUD
    _topBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,statusbarHeight,width,44)];
    _topBar.barStyle = UIBarStyleBlackTranslucent;
    _topBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_topBar];
    
    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    [_topBar pushNavigationItem:navigationItem animated:NO];
    
    navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                        target:self
                                        action:@selector(doneDidTouch:)];
    navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                         initWithImage:[UIImage imageNamed:@"avplayer.bundle/zoomin"]
                                         style:UIBarButtonItemStyleBordered
                                         target:self
                                         action:@selector(fullscreenDidTouch:)];
    _fullscreenButton = navigationItem.rightBarButtonItem;
    
    CGFloat titleViewWidth = width-120;
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, titleViewWidth, 44)];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.autoresizesSubviews = YES;
    titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    navigationItem.titleView = titleView;
    
    _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,12,50,20)];
    _progressLabel.backgroundColor = [UIColor clearColor];
    _progressLabel.adjustsFontSizeToFitWidth = NO;
    _progressLabel.textAlignment = NSTextAlignmentRight;
    _progressLabel.textColor = [UIColor whiteColor];
    _progressLabel.text = @"00:00:00";
    _progressLabel.font = [UIFont systemFontOfSize:12];
    [titleView addSubview:_progressLabel];
    
    _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(52,7,titleViewWidth-100-4,32)];
    _progressSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _progressSlider.continuous = YES;
    _progressSlider.value = 0;
    [_progressSlider addTarget:self action:@selector(progressSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [titleView addSubview:_progressSlider];
    
    _leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleViewWidth-50,13,50,20)];
    _leftLabel.backgroundColor = [UIColor clearColor];
    _leftLabel.adjustsFontSizeToFitWidth = NO;
    _leftLabel.textAlignment = NSTextAlignmentLeft;
    _leftLabel.textColor = [UIColor whiteColor];
    _leftLabel.text = @"-99:59:59";
    _leftLabel.font = [UIFont systemFontOfSize:12];
    _leftLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [titleView addSubview:_leftLabel];
    
    // Top HUD
    _topHUD = [[UIView alloc] init];
    _topHUD.frame = CGRectMake(0, _topBar.frame.origin.y+_topBar.bounds.size.height, width, 64);
    _topHUD.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
    _topHUD.autoresizesSubviews = YES;
    _topHUD.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_topHUD];
    
    UIButton *buttonPlaybackSpeed;
    buttonPlaybackSpeed = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonPlaybackSpeed.frame = CGRectMake(24, 16, 32, 32);
    buttonPlaybackSpeed.backgroundColor = [UIColor clearColor];
    buttonPlaybackSpeed.showsTouchWhenHighlighted = YES;
    [buttonPlaybackSpeed setImage:[UIImage imageNamed:@"avplayer.bundle/speedIcon"] forState:UIControlStateNormal];
    [buttonPlaybackSpeed addTarget:self action:@selector(adjustSpeedDidTouch:) forControlEvents:UIControlEventTouchUpInside];
    [_topHUD addSubview:buttonPlaybackSpeed];
    
    UIButton *buttonAudioTracker;
    buttonAudioTracker = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonAudioTracker.frame = CGRectMake(104, 16, 32, 32);
    buttonAudioTracker.backgroundColor = [UIColor clearColor];
    buttonAudioTracker.showsTouchWhenHighlighted = YES;
    [buttonAudioTracker setImage:[UIImage imageNamed:@"avplayer.bundle/audioTrackIcon"] forState:UIControlStateNormal];
    [buttonAudioTracker addTarget:self action:@selector(selectAudioTrackDidTouch:) forControlEvents:UIControlEventTouchUpInside];
    [_topHUD addSubview:buttonAudioTracker];
    
    UIButton *buttonSubtitleStream;
    buttonSubtitleStream = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonSubtitleStream.frame = CGRectMake(184, 16, 32, 32);
    buttonSubtitleStream.backgroundColor = [UIColor clearColor];
    buttonSubtitleStream.showsTouchWhenHighlighted = YES;
    [buttonSubtitleStream setImage:[UIImage imageNamed:@"avplayer.bundle/subtitleIcon"] forState:UIControlStateNormal];
    [buttonSubtitleStream addTarget:self action:@selector(selectSubtitleDidTouch:) forControlEvents:UIControlEventTouchUpInside];
    [_topHUD addSubview:buttonSubtitleStream];
    
    UIButton *buttonVideoEffect;
    buttonVideoEffect = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonVideoEffect.frame = CGRectMake(264, 16, 32, 32);
    buttonVideoEffect.backgroundColor = [UIColor clearColor];
    buttonVideoEffect.showsTouchWhenHighlighted = YES;
    [buttonVideoEffect setImage:[UIImage imageNamed:@"avplayer.bundle/videoEffectsIcon"] forState:UIControlStateNormal];
    [buttonVideoEffect addTarget:self action:@selector(videoEffectDidTouch:) forControlEvents:UIControlEventTouchUpInside];
    [_topHUD addSubview:buttonVideoEffect];
    
    // Bottom HUD
    UIImage *backgroundImage;
    CGSize bottomHUDSize = CGSizeZero;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        backgroundImage = [UIImage imageNamed:@"avplayer.bundle/hudbackground_iphone"];
        bottomHUDSize = CGSizeMake(314, 93);
    }
    else {
        backgroundImage = [UIImage imageNamed:@"avplayer.bundle/hudbackground_ipad"];
        bottomHUDSize = CGSizeMake(431, 91);
    }
    
    CGFloat yoffset = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 15:48);
    CGRect bottomHUDRect = CGRectMake((width-bottomHUDSize.width)/2,
                                      height-(bottomHUDSize.height+yoffset),
                                      bottomHUDSize.width,
                                      bottomHUDSize.height);
    
    _bottomHUD = [[UIView alloc] initWithFrame:bottomHUDRect];
    _bottomHUD.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    _bottomHUD.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:_bottomHUD];
    
    width = _bottomHUD.bounds.size.width;
    
    _rewindButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rewindButton.frame = CGRectMake(width * 0.5 - 75, 8, 40, 40);
    _rewindButton.backgroundColor = [UIColor clearColor];
    _rewindButton.showsTouchWhenHighlighted = YES;
    [_rewindButton setImage:[UIImage imageNamed:@"avplayer.bundle/playback_prev"] forState:UIControlStateNormal];
    [_rewindButton addTarget:self action:@selector(rewindDidTouch:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomHUD addSubview:_rewindButton];
    
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playButton.frame = CGRectMake(width * 0.5 - 20, 8, 40, 40);
    _playButton.backgroundColor = [UIColor clearColor];
    _playButton.showsTouchWhenHighlighted = YES;
    [_playButton setImage:[UIImage imageNamed:@"avplayer.bundle/playback_play"] forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(playDidTouch:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomHUD addSubview:_playButton];
    
    _forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _forwardButton.frame = CGRectMake(width * 0.5 + 35, 8, 40, 40);
    _forwardButton.backgroundColor = [UIColor clearColor];
    _forwardButton.showsTouchWhenHighlighted = YES;
    [_forwardButton setImage:[UIImage imageNamed:@"avplayer.bundle/playback_ff"] forState:UIControlStateNormal];
    [_forwardButton addTarget:self action:@selector(forwardDidTouch:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomHUD addSubview:_forwardButton];
    
    _volumeSlider = [[MPVolumeView alloc] initWithFrame:CGRectMake(10, 55, width-(10 * 2), 20)];
    _volumeSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _volumeSlider.showsRouteButton = NO;
    _volumeSlider.showsVolumeSlider = YES;
    [_bottomHUD addSubview:_volumeSlider];
}

- (UIImageView *)coverImageView
{
    if (_coverImageView == nil) {
        // Cover image view
        CGRect r = self.view.bounds;
        UIImage *image = [UIImage imageNamed:@"avplayer.bundle/music_icon"];
        
        _coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        _coverImageView.hidden = YES;
        _coverImageView.contentMode = UIViewContentModeCenter;
        _coverImageView.backgroundColor = [UIColor clearColor];
        _coverImageView.image = image;
        _coverImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleLeftMargin;
        
        [self.view addSubview:_coverImageView];
        _coverImageView.center = CGPointMake(CGRectGetMidX(r), CGRectGetMidY(r));
    }
    
    return _coverImageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Build sub-views
    [self buildViews];
    
    // New and initialize AVPlayerController instance to prepare for playback
    _avplayController = [[AVPlayerController alloc] init];
    _avplayController.delegate = self;
    _avplayController.shouldPlayOnBackground = YES;
    _avplayController.shouldAutoPlay = (_getStartTime == nil ? YES:NO);
    
    void (^block)(BOOL) = ^(BOOL loaded) {
        if (loaded) {
            if ([_avplayController hasVideo]) {
                _glView = [_avplayController drawableView];
                _glView.frame = self.view.bounds;
                _glView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
                [self.view insertSubview:_glView atIndex:0];
                
                // Setup user interaction (gestures)
                [self setupUserInteraction:_glView];
            }
            else {
                // Setup user interaction (gestures)
                [self setupUserInteraction:self.view];
                
                if ([_avplayController hasAudio]) {
                    [self coverImageView].hidden = NO;
                }
            }
            
            if (_didLoadVideo) {
                _didLoadVideo(_avplayController);
            }
            
            if (_getStartTime) {
                NSNumber *initCurTime = _getStartTime(_avplayController, self.mediaPath);
                if (initCurTime.floatValue != CGFLOAT_MAX) {
                    [self startPlaybackAt:initCurTime];
                }
            }
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failed to load video!"
                                                                message:nil
                                                               delegate:nil
                                                      cancelButtonTitle:@"Close"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    };
    
    BOOL success = [_avplayController openMedia:self.mediaPath onFinishedHandler:block];
    
    if (!success) {
        block(NO);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:_prevStatusBarHidden withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:_prevStatusBarStyle animated:YES];
    
    // Notify user to save current playback progress
    if (_saveProgress) {
        _saveProgress(_avplayController);
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    float x = CGRectGetMidX(self.view.bounds);
    float y = CGRectGetMidY(self.view.bounds);
    
    _adjustSpeedView.center =
    _videoEffectView.center = CGPointMake(x, y);
}

#pragma mark - Device Interface Rotation Handler

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation != UIDeviceOrientationPortraitUpsideDown);
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll & (~UIInterfaceOrientationMaskPortraitUpsideDown);
}

#pragma mark - AVPlayerControllerDelegate

// AVPlayer state was changed
- (void)AVPlayerControllerDidStateChange:(AVPlayerController *)controller
{
    AVPlayerState state = [controller playerState];
    
    if (state == kAVPlayerStateFinishedPlayback) {
        
        // For local media file source
        // If playback reached to end, we return to begin of the media file,
        // and pause the palyer to prepare for next playback.
        
        if (![controller isNetworkFile]) {
            [controller seekto:0];
            [controller pause];
        }
        _progressSlider.value = 1.0f;
        
        if (_didFinishPlayback) {
            _didFinishPlayback(controller);
        }
    }
    
    // Enable or disable idle timer
    if (state == kAVPlayerStatePlaying) {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        [_playButton setImage:[UIImage imageNamed:@"avplayer.bundle/playback_pause"] forState:UIControlStateNormal];
        
        // Hide HUD(s) after 8 seconds
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideHUD) object:nil];
        [self performSelector:@selector(hideHUD) withObject:nil afterDelay:8.0f];
    }
    else {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        [_playButton setImage:[UIImage imageNamed:@"avplayer.bundle/playback_play"] forState:UIControlStateNormal];
    }
    
    // Notify user to save current playback progress
    if (state == kAVPlayerStatePaused ||
        state == kAVPlayerStateStoped ||
        state == kAVPlayerStateFinishedPlayback) {
        
        if (_saveProgress) {
            _saveProgress(controller);
        }
    }
}

// AVPlayer current play time was changed
- (void)AVPlayerControllerDidCurTimeChange:(AVPlayerController *)controller position:(NSTimeInterval)position
{
    [self updateProgressViewsWithTimePosition:position];
}

// Enter or exit full screen mode
- (void)AVPlayerControllerDidEnterFullscreenMode:(AVPlayerController *)controller
{
    // Update full screen bar button
    [_fullscreenButton setImage:[UIImage imageNamed:@"avplayer.bundle/zoomout"]];
}

- (void)AVPlayerControllerDidExitFullscreenMode:(AVPlayerController *)controller
{
    // Update full screen bar button
    [_fullscreenButton setImage:[UIImage imageNamed:@"avplayer.bundle/zoomin"]];
}

#pragma mark - Private

// Setup user interaction
// Add single tap gesture to video render view

- (void)setupUserInteraction:(UIView *)v
{
    UIView * view = v;
    view.userInteractionEnabled = YES;
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    _tapGestureRecognizer.numberOfTapsRequired = 1;
    
    [view addGestureRecognizer:_tapGestureRecognizer];
}

// Show or hide top and bottom HUDs

- (void)toggleHUD:(BOOL)hudVisible
{
    _hudVisible = hudVisible;
    
    [[UIApplication sharedApplication] setStatusBarHidden:!_hudVisible withAnimation:UIStatusBarAnimationNone];
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone
                     animations:^{
                         
                         _topBar.alpha =
                         _topHUD.alpha =
                         _bottomHUD.alpha = _hudVisible ? 1.0f:0;
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)hideHUD
{
    [self toggleHUD:NO];
}

// Update progress views with special time position
- (void)updateProgressViewsWithTimePosition:(NSTimeInterval)timePosition
{
    // Update time labels & progress slider
    NSTimeInterval duration = [_avplayController duration];
    
    _leftLabel.text = [AVPlayerController formatTimeInterval:duration-timePosition isLeft:YES];
    _progressLabel.text = [AVPlayerController formatTimeInterval:timePosition isLeft:NO];
    
    if (_progressSlider.state == UIControlStateNormal)
        _progressSlider.value = timePosition / duration;
}

#pragma mark - gesture recognizer

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    _adjustSpeedView.hidden =
    _videoEffectView.hidden = YES;
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (sender == _tapGestureRecognizer) {
            
            [self toggleHUD:!_hudVisible];
        }
    }
}

#pragma mark - Actions

- (void)doneDidTouch:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (_willDismiss) {
        _willDismiss();
    }
    
    _avplayController.delegate = nil;
    [_avplayController stop];
    
    [self dismissViewControllerAnimated:YES completion:^{
        _avplayController = nil;
    }];
}

- (void)fullscreenDidTouch:(id)sender
{
    if ([_avplayController hasVideo]) {
        BOOL isFullscreen = ![_avplayController isFullscreen];
        [_avplayController fullScreen:isFullscreen];
    }
}

- (void)progressSliderChanged:(id)sender
{
    [_avplayController seekto:_progressSlider.value];
    [self updateProgressViewsWithTimePosition:_progressSlider.value * [_avplayController duration]];
}

- (void)playDidTouch:(id)sender
{
    AVPlayerState playerState = [_avplayController playerState];
    
    if (playerState == kAVPlayerStatePlaying)
        [_avplayController pause];
    else
        [_avplayController resume];
}

- (void)forwardDidTouch:(id)sender
{
    NSTimeInterval current_time = [_avplayController currentTime];
    NSTimeInterval duration = [_avplayController duration];
    
    [_avplayController seekto:current_time / duration + 0.05];
}

- (void)rewindDidTouch:(id)sender
{
    NSTimeInterval current_time = [_avplayController currentTime];
    NSTimeInterval duration = [_avplayController duration];
    
    [_avplayController seekto:current_time / duration - 0.05];
}

- (void)adjustSpeedDidTouch:(id)sender
{
    if (!_adjustSpeedView) {
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"PlaybackSpeedView" owner:nil options:nil];
        _adjustSpeedView = views[0];
        
        [self.view addSubview:_adjustSpeedView];
        _adjustSpeedView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
        
        [_adjustSpeedView.speedStepper addTarget:self action:@selector(speedDidChange:) forControlEvents:UIControlEventValueChanged];
    }
    
    _adjustSpeedView.hidden = NO;
    _videoEffectView.hidden = YES;
}

- (void)speedDidChange:(UIStepper *)sender
{
    _avplayController.playbackSpeed = sender.value;
    _adjustSpeedView.speedLabel.text = [NSString stringWithFormat:@"%.1fx", sender.value];
}

- (void)selectAudioTrackDidTouch:(id)sender
{
    NSMutableArray *buttonTitles = [NSMutableArray array];
    
    NSCharacterSet *cs = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    [_avplayController.audioTracks enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSString *streamTitle = obj[@"title"];
        NSString *langCode = obj[@"language"];
        
        streamTitle = [streamTitle stringByTrimmingCharactersInSet:cs];
        langCode = [langCode stringByTrimmingCharactersInSet:cs];
        
        NSString *buttonTitle = @"Unknown";
        if ([streamTitle length] > 0) {
            buttonTitle = streamTitle;
        }
        else if ([langCode length] > 0) {
            NSString *enLangName = [AVPlayerController convertISO639LanguageCodeToEnName:langCode];
            buttonTitle = enLangName;
        }
        [buttonTitles addObject:[NSString stringWithFormat:@"Track %u - %@", idx+1, buttonTitle]];
    }];
    
    UIAlertView *alertView = [UIAlertView showWithTitle:@"Audio Trackers Picker"
                                                message:nil
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:buttonTitles
                                               tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                   NSInteger firstOBIndex = [alertView firstOtherButtonIndex];
                                                   NSInteger lastOBIndex = firstOBIndex+[buttonTitles count];
                                                   
                                                   if (buttonIndex >= firstOBIndex && buttonIndex < lastOBIndex) {
                                                       [_avplayController switchAudioTracker:(int)(buttonIndex-firstOBIndex)];
                                                   }
                                               }];
    [alertView show];
}

- (void)selectSubtitleDidTouch:(id)sender
{
    NSMutableArray *buttonTitles = [NSMutableArray array];
    
    NSCharacterSet *cs = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    [_avplayController.subtitleTracks enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSString *streamTitle = obj[@"title"];
        NSString *langCode = obj[@"language"];
        
        streamTitle = [streamTitle stringByTrimmingCharactersInSet:cs];
        langCode = [langCode stringByTrimmingCharactersInSet:cs];
        
        NSString *buttonTitle;
        if ([streamTitle length] > 0) {
            buttonTitle = streamTitle;
        }
        else {
            NSString *enLangName = [AVPlayerController convertISO639LanguageCodeToEnName:langCode];
            buttonTitle = enLangName;
        }
        [buttonTitles addObject:[NSString stringWithFormat:@"Subtitle %u - %@", idx+1, buttonTitle]];
    }];
    
    [buttonTitles addObject:@"External subtitle file"];
    
    UIAlertView *alertView = [UIAlertView showWithTitle:@"Subtitles Picker"
                                                message:nil
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:buttonTitles
                                               tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                   
                                                   NSInteger firstOBIndex = [alertView firstOtherButtonIndex];
                                                   NSInteger lastOBIndex = firstOBIndex+[buttonTitles count];
                                                   
                                                   if (buttonIndex == lastOBIndex-1) {
                                                       
                                                       NSString *subtitlePath;
                                                       subtitlePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"ass"];
                                                       if (![_avplayController openSubtitleFile:subtitlePath encoding:kCFStringEncodingGB_18030_2000]) {
                                                           NSLog(@"Open %@ subtitle file failed!", [subtitlePath lastPathComponent]);
                                                       }
                                                   }
                                                   else if (buttonIndex >= firstOBIndex && buttonIndex < lastOBIndex) {
                                                       [_avplayController switchSubtitleStream:(int)(buttonIndex-firstOBIndex)];
                                                   }
                                               }];
    [alertView show];
}

- (void)videoEffectDidTouch:(id)sender
{
    if (!_videoEffectView) {
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"VideoEffectView" owner:nil options:nil];
        _videoEffectView = views[0];
        
        [self.view addSubview:_videoEffectView];
        _videoEffectView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
        
        [_videoEffectView.brightnessSlider addTarget:self action:@selector(brightnessDidChange:) forControlEvents:UIControlEventValueChanged];
        [_videoEffectView.contrastSlider addTarget:self action:@selector(contrastDidChange:) forControlEvents:UIControlEventValueChanged];
        [_videoEffectView.saturationSlider addTarget:self action:@selector(saturationDidChange:) forControlEvents:UIControlEventValueChanged];
    }
    
    _videoEffectView.hidden = NO;
    _adjustSpeedView.hidden = YES;
}

- (void)brightnessDidChange:(UISlider *)sender
{
    _avplayController.brightness = sender.value;
}

- (void)contrastDidChange:(UISlider *)sender
{
    _avplayController.contrast = sender.value;
}

- (void)saturationDidChange:(UISlider *)sender
{
    _avplayController.saturation = sender.value;
}


#pragma mark - Public

// Start playback at special time position
- (void)startPlaybackAt:(NSNumber *)startTimePosition
{
    if (startTimePosition.floatValue == 0) {
        [_avplayController play:0];
    }
    else {
        NSTimeInterval duration = [_avplayController duration];
        
        double fact = 0;
        if (duration > 0) {
            fact = startTimePosition.floatValue/duration;
        }
        
        if (![_avplayController play:fact]) {
            [_avplayController play:0];
        }
    }
}


@end
