//
//  BIDSecondViewController.m
//  TabBarController
//
//  Created by gtcc on 2/19/14.
//  Copyright (c) 2014 xc. All rights reserved.
//

#import "BIDSecondViewController.h"
#import "FtpServer.h"
#import "HTTPServer.h"
#import "MyHTTPConnection.h"
#import "localhostAddresses.h"


#define FTP_PORT 20000
@interface BIDSecondViewController ()
@property BOOL isServerRunning;
@end

@implementation BIDSecondViewController
@synthesize theServer, theHTTPServer, baseDir,ServerInfoView, ServerTitleLabel,btnControlServer,isServerRunning;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self startServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) startServer
{
	NSString *localIPAddress = [ NetworkController localWifiIPAddress ];
    
	NSArray *docFolders = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES );
	self.baseDir =  [docFolders lastObject];
    
	
	FtpServer *aServer = [[ FtpServer alloc ] initWithPort:20000 withDir:baseDir notifyObject:self ];
	self.theServer = aServer;
    [aServer release];
    
    
    theHTTPServer = [HTTPServer new];
	[theHTTPServer setType:@"_http._tcp."];
	[theHTTPServer setConnectionClass:[MyHTTPConnection class]];
	[theHTTPServer setDocumentRoot:[NSURL fileURLWithPath:self.baseDir]];

    NSError *error;
    if(![theHTTPServer start:&error])
    {
        NSLog(@"Error starting HTTP Server: %@", error);
    }

    self.ServerTitleLabel.text = [NSString stringWithFormat:@"%@ %@ %@",
                                  @"ftp://",localIPAddress, @": 20000"];

    UInt16 theHTTPServerPort = [theHTTPServer port];

    self.httpURL.text =[NSString stringWithFormat:@"%@ %@ %@ %d",
        @"http://",localIPAddress, @":", theHTTPServerPort];
    
    self.ServerInfoView.text = @"The FTP Server has been enabled, please use FTP client software to transfer any import/export data to or from this device.\nPress the \"Stop Server\" button once all data transfers have been completed.";
    //self.ServerInfoView.hidden = false;

    self.isServerRunning = TRUE;
    [self.btnControlServer setTitle:@"Stop Server" forState:UIControlStateNormal] ;
}

- (void) startHTTPServer
{
    /*
    ///	NSString *localIPAddress = [ NetworkController localIPAddress ];
	NSString *localIPAddress = [ NetworkController localWifiIPAddress ];
	
    self.ServerTitleLabel.text = [NSString stringWithFormat:@"%@ %@ %@", @"Connect to", localIPAddress, @"port 20000"];
    self.ServerTitleLabel.hidden = false;
    
    self.ServerInfoView.text = @"The FTP Server has been enabled, please use FTP client software to transfer any import/export data to or from this device.\nPress the \"Stop Server\" button once all data transfers have been completed.";
    self.ServerInfoView.hidden = false;
    
	NSArray *docFolders = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES );
	self.baseDir =  [docFolders lastObject];
    
	
	FtpServer *aServer = [[ FtpServer alloc ] initWithPort:20000 withDir:baseDir notifyObject:self ];
	self.theServer = aServer;
    [aServer release];
    
    self.isServerRunning = TRUE;
    [self.btnControlServer setTitle:@"Stop Server" forState:UIControlStateNormal] ;
     */
    
    NSString *root = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    
    theHTTPServer = [HTTPServer new];
	[theHTTPServer setType:@"_http._tcp."];
	[theHTTPServer setConnectionClass:[MyHTTPConnection class]];
	[theHTTPServer setDocumentRoot:[NSURL fileURLWithPath:root]];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayInfoUpdate:) name:@"LocalhostAdressesResolved" object:nil];
	[localhostAddresses performSelectorInBackground:@selector(list) withObject:nil];
}

- (void)displayInfoUpdate:(NSNotification *) notification
{
	NSLog(@"displayInfoUpdate:");
    
	if(notification)
	{
		[addresses release];
		addresses = [[notification object] copy];
		NSLog(@"addresses: %@", addresses);
	}
    
	if(addresses == nil)
	{
		return;
	}
	
	NSString *info;
	//UInt16 port = [theHTTPServer port];
	
	NSString *localIP = nil;
	
	localIP = [addresses objectForKey:@"en0"];
	
	if (!localIP)
	{
		localIP = [addresses objectForKey:@"en1"];
	}
    
	if (!localIP)
		info = @"Wifi: No Connection!\n";
}


// ----------------------------------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex {
    // ----------------------------------------------------------------------------------------------------------
	if (buttonIndex == 0) {
		[alert dismissWithClickedButtonIndex:0 animated:YES];
		[self stopFtpServer];
	}
}

// This is a method that will shut down the server cleanly, it calles the stopFtpServer method of FtpServer class.
// ----------------------------------------------------------------------------------------------------------
- (void)stopFtpServer {
    // ----------------------------------------------------------------------------------------------------------
	NSLog(@"Stopping the FTP server");
    
    self.isServerRunning = FALSE;
    [self.btnControlServer setTitle:@"Start Server" forState:UIControlStateNormal] ;
    self.ServerTitleLabel.hidden = true;
    self.ServerInfoView.hidden = true;
    
	if(theServer)
	{
		[theServer stopFtpServer];
        [theServer release];
		theServer=nil;
	}
}

- (void)stopHTTPServer {
    // ----------------------------------------------------------------------------------------------------------
	NSLog(@"Stopping the FTP server");
    
    self.isServerRunning = FALSE;
    [self.btnControlHTTPServer setTitle:@"Start HTTP Server" forState:UIControlStateNormal] ;
    [self.ServerTitleLabel setText:@"HTTP is stopped!"];
    self.ServerInfoView.hidden = true;
    
	if(theServer)
	{
		[theServer stopFtpServer];
        [theServer release];
		theServer=nil;
	}
}

-(void)didReceiveFileListChanged
// ----------------------------------------------------------------------------------------------------------
{
	NSLog(@"didReceiveFileListChanged");
}

- (void)dealloc {
    [self.ServerInfoView release];
    [self.ServerTitleLabel release];
    [self.btnControlServer release];
    [_btnControlHTTPServer release];
    [_httpURL release];
    [super dealloc];
}
- (IBAction)ToggleServer:(id)sender {
    if(self.isServerRunning)
    {
        [self stopFtpServer];
    }else
    {
        [self startServer];
    }
}

@end
