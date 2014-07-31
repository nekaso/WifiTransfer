/*
 *  AVParser.h
 *  This file is part of AVPlayerTouch framework.
 *
 *  AV parser & thumbnail generating obj-c wrapper class.
 *
 *  Created by iMoreApps on 2/25/2014.
 *  Copyright (C) 2014 iMoreApps Inc. All rights reserved.
 *  Author: imoreapps <imoreapps@gmail.com>
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AVParser : NSObject

@property (nonatomic, readonly) NSString *path;
@property (readonly, nonatomic) NSTimeInterval duration;
@property (readonly, nonatomic) NSUInteger frameWidth;
@property (readonly, nonatomic) NSUInteger frameHeight;

/*
 * open av source
 * return YES if success, otherwise return NO.
 */
- (BOOL)open:(NSString *)path;

/*
 * determine whether or not has audio and video stream.
 * return YES or NO.
 */
- (BOOL)hasAudio;
- (BOOL)hasVideo;

/*
 * generate thumbnail at specified timestamp
 * return an UIImage object if success, otherwise return nil.
 */
- (UIImage *)thumbnailAtTime:(NSTimeInterval)seconds;

@end
