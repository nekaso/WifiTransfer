//
//  VideoListTableViewController.m
//  TabBarController
//
//  Created by gtcc on 2/19/14.
//  Copyright (c) 2014 xc. All rights reserved.
//

#import "VideoListTableViewController.h"
#import "AVPlayerViewController.h"
@interface VideoListTableViewController ()
@end

@implementation VideoListTableViewController
@synthesize FileList, moviePlayerController,moviePlayViewController;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.FileList = [self GetAllFiles];
    
    [self viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.FileList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = self.FileList[indexPath.row];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75.f;
}



-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* filename = self.FileList[indexPath.row];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentDir = [documentPaths objectAtIndex:0];
    NSString* fullname = [documentDir stringByAppendingFormat:@"/%@",filename];
    
    AVPlayerViewController*tmpMoviePlayViewController=[[AVPlayerViewController alloc] init];
    tmpMoviePlayViewController.mediaPath = fullname;
    if(tmpMoviePlayViewController)
    {
        [self presentViewController:tmpMoviePlayViewController animated:true completion:nil];
    }
    [tmpMoviePlayViewController release];
}


- (NSMutableArray*) GetAllFiles
{
    // get all the files under this folder
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentDir = [documentPaths objectAtIndex:0];
    NSError *error = nil;
    NSArray *fileList = [[NSArray alloc] init];
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
    
    //Convert NSArray to NSMutableArray
    NSMutableArray *_fileList = [[NSMutableArray alloc] init];
    _fileList = [NSMutableArray arrayWithArray:fileList];
    
    return _fileList;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
}

-(NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Delete";
}


//Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Prepare for deleting file on disk.
        NSString *DeleteFileName = self.FileList[indexPath.row];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *DeleteDocumentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *DeleteDocumentDir = [DeleteDocumentPaths objectAtIndex:0];
        NSString *FullDeleteFilePath =[DeleteDocumentDir stringByAppendingPathComponent:DeleteFileName];
        NSError *error = nil;
        
        // Delete the row from the data source
        [FileList  removeObjectAtIndex:[indexPath row]];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
       
        [fileManager removeItemAtPath:FullDeleteFilePath error:&error];
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
