//
//  BIDSecondViewController.h
//  TabBarController
//
//  Created by gtcc on 2/19/14.
//  Copyright (c) 2014 xc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkController.h"

@class FtpServer;
@class HTTPServer;

@interface BIDSecondViewController : UIViewController {
	FtpServer	*theServer;
    HTTPServer  *theHTTPServer;
    NSDictionary *addresses;
	NSString *baseDir;
}

@property (nonatomic, retain) FtpServer *theServer;
@property (nonatomic, copy) NSString *baseDir;
@property (retain, nonatomic) IBOutlet UITextView *ServerInfoView;
@property (retain, nonatomic) IBOutlet UILabel *ServerTitleLabel;
@property (retain, nonatomic) IBOutlet UIButton *btnControlServer;

@property (nonatomic, retain) HTTPServer *theHTTPServer;

@property (retain, nonatomic) IBOutlet UIButton *btnControlHTTPServer;

@property (retain, nonatomic) IBOutlet UILabel *httpURL;

-(void)didReceiveFileListChanged;
- (void)stopFtpServer;
- (void)startHTTPServer;
- (void)stopHTTPServer;

@end