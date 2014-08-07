//
//  VideoListTableViewController.h
//  TabBarController
//
//  Created by gtcc on 2/19/14.
//  Copyright (c) 2014 xc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MPMoviePlayerViewController.h>
#import <MediaPlayer/MPMoviePlayerController.h>
@interface VideoListTableViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, copy) NSArray* FileList;
@property (nonatomic,retain) UIViewController* moviePlayViewController;
@property (nonatomic,retain) MPMoviePlayerController* moviePlayerController;
@end
