//
//  MoreAppsControllerViewController.m
//  Labixiaoxin1-5
//
//  Created by 晋辉 卫 on 5/6/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import "MoreAppsControllerViewController.h"
#import "CustomNavigationBar.h"
#import "Constants.h"
#import "Book.h"
#import "DataEngine.h"
#import "ImageCacheEngine.h"

#define kAppImageTag 10000
#define kAppNameTag 10001
#define kNewAppIconTag 10002

#define kIPadCellHeight 91
#define kIPhoneCellHeight 71

@interface MoreAppsControllerViewController ()
- (void)getImage:(NSString *)icon;
- (void)responseGetImage:(NSNotification *)notification;

- (IBAction)comment:(id)sender;
@end

@implementation MoreAppsControllerViewController

- (IBAction)back:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)comment:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_RATING_URL]];
}

- (void)showRightButton
{
//    DataEngine *dataEngine = [DataEngine sharedInstance];
//    BOOL has = NO;
//    for (Book *book in dataEngine.books) {
//        if ([book.bookId isEqualToString:BOOK_ID]) {
//            has = YES;
//            break;
//        }
//    }
//    if (has) {
//        CustomNavigationBar *customNavigationBar =  (CustomNavigationBar*)self.navigationController.navigationBar;
//        UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [commentButton setBackgroundImage:[[UIImage retina4ImageNamed:@"button.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
//        //    [commentButton setBackgroundImage:[[UIImage retina4ImageNamed:@"button_selected.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
//        // Set the title to use the same font and shadow as the standard back button
//        commentButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
//        commentButton.titleLabel.textColor = [UIColor whiteColor];
//        commentButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
//        commentButton.titleLabel.shadowColor = [UIColor darkGrayColor];
//        // Set the break mode to truncate at the end like the standard back button
//        commentButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
//        // Inset the title on the left and right
//        commentButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
//        // Make the button as high as the passed in image
//        commentButton.frame = CGRectMake(0, 0, 56, 28);
//        [customNavigationBar setText:NSLocalizedString(@"comment", nil) onBackButton:commentButton leftCapWidth:10.0];
//        [commentButton addTarget:self action:@selector(comment:) forControlEvents:UIControlEventTouchUpInside];
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:commentButton];
//    } else {
//        self.navigationItem.rightBarButtonItem = nil;
//    }
}

- (void)bookListResponse:(NSNotification *)notification
{
    [self.tableView reloadData];
    [self showRightButton];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getImage:(NSString *)icon
{
    [[DataEngine sharedInstance] downloadBookIcon:icon withSource:_controllerId];
}

- (void)responseGetImage:(NSNotification *)notification
{
    NSDictionary *dictionary = (NSDictionary *)[notification object];
    if (![[dictionary objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_controllerId]) {
        return;
    }
    
    NSString *imagePath = [dictionary objectForKey:@"imagepath"];
    if (imagePath) {
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"More cartoon", nil);
    if (_controllerId == nil) {
        _controllerId = [NSString stringWithFormat:@"%p", self];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bookListResponse:)
                                                 name:GET_NEWBOOK_LIST
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responseGetImage:)
                                                 name:REQUEST_DOWNLOADIMAGE
                                               object:nil];
    
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage retina4ImageNamed:@"canvas.png"]];
//    CustomNavigationBar *customNavigationBar =  (CustomNavigationBar*)self.navigationController.navigationBar;
//    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [backButton setBackgroundImage:[[UIImage retina4ImageNamed:@"back.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
//    //    [commentButton setBackgroundImage:[[UIImage retina4ImageNamed:@"button_selected.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
//    // Set the title to use the same font and shadow as the standard back button
//    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
//    backButton.titleLabel.textColor = [UIColor whiteColor];
//    backButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
//    backButton.titleLabel.shadowColor = [UIColor darkGrayColor];
//    // Set the break mode to truncate at the end like the standard back button
//    backButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
//    // Inset the title on the left and right
//    backButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
//    // Make the button as high as the passed in image
//    backButton.frame = CGRectMake(0, 0, 56, 28);
//    [customNavigationBar setText:[NSString stringWithFormat:@" %@", NSLocalizedString(@"Back", nil)] onBackButton:backButton leftCapWidth:10.0];
//    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    [self showRightButton];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:kBadgeCountChangeNotification object:nil];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (IS_IPAD) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    _bookArray = [NSMutableArray arrayWithCapacity:5];
    DataEngine *dataEngine = [DataEngine sharedInstance];
    for (Book *book in dataEngine.books) {
        if (![book.bookId isEqualToString:BOOK_ID]) {
            [_bookArray addObject:book];
        }
    }
    return _bookArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage retina4ImageNamed:@"moreAppsArrow.png"]];
        [cell.contentView addSubview:arrow];
        arrow.frame = CGRectMake(CGRectGetWidth(self.tableView.frame) - 10 - CGRectGetWidth(arrow.frame), ([self tableView:tableView heightForRowAtIndexPath:indexPath] - CGRectGetHeight(arrow.frame)) / 2, CGRectGetWidth(arrow.frame), CGRectGetHeight(arrow.frame));
    }
    if (indexPath.row < _bookArray.count) {
        if (indexPath.row % 2 == 0) {
            cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage retina4ImageNamed:@"moreAppsBg1.png"] stretchableImageWithLeftCapWidth:160 topCapHeight:35]];
        } else {
            cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage retina4ImageNamed:@"moreAppsBg2.png"] stretchableImageWithLeftCapWidth:160 topCapHeight:35]];
        }
        UIImageView *icon = (UIImageView *)[cell.contentView viewWithTag:kAppImageTag];
        if (icon == nil) {
            icon = [[UIImageView alloc] initWithFrame:CGRectMake(10, ([self tableView:tableView heightForRowAtIndexPath:indexPath] - 57) / 2, 57, 57)];
            icon.tag = kAppImageTag;
            [cell.contentView addSubview:icon];
        }
        Book *book = [_bookArray objectAtIndex:indexPath.row];
        if (book.bookIcon && book.bookIcon.length > 0) {
            NSString *path = [[ImageCacheEngine sharedInstance] getIconImagePath:book.bookIcon];
            if (path && path.length > 0) {
                icon.image = [UIImage imageWithContentsOfFile:path];
            } else {
                [self getImage:book.bookIcon];
                icon.image = [UIImage retina4ImageNamed:@"appIconEmpty.png"];
            }
        } else {
            icon.image = [UIImage retina4ImageNamed:@"appIconEmpty.png"];
        }
        
        UIImageView *newIcon = (UIImageView *)[cell.contentView viewWithTag:kNewAppIconTag];
        if (newIcon == nil) {
            newIcon = [[UIImageView alloc] initWithFrame:CGRectMake(55, ([self tableView:tableView heightForRowAtIndexPath:indexPath] - 57) / 2 - 4, 26, 18)];
            newIcon.tag = kNewAppIconTag;
            [cell.contentView addSubview:newIcon];
        }
        if (book.isNew) {
            newIcon.image = [UIImage retina4ImageNamed:@"newIcon.png"];
        } else {
            newIcon.image = nil;
        }
        
        UILabel *bookName = (UILabel *)[cell.contentView viewWithTag:kAppNameTag];
        if (bookName == nil) {
            bookName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(icon.frame) + 10, 0, 220, [self tableView:tableView heightForRowAtIndexPath:indexPath])];
            bookName.backgroundColor = [UIColor clearColor];
            bookName.font = [UIFont boldSystemFontOfSize:15.0];
            bookName.textColor = [UIColor blackColor];
            bookName.highlightedTextColor = [UIColor whiteColor];
            bookName.tag = kAppNameTag;
            [cell.contentView addSubview:bookName];
        }
        bookName.text = book.bookName;
    }    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD) {
        return kIPadCellHeight;
    } else {
        return kIPhoneCellHeight;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < _bookArray.count) {
        Book *book = [_bookArray objectAtIndex:indexPath.row];
        NSString *url = book.bookUrl;
        if (url && url.length > 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Be about to online", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"I know", nil) otherButtonTitles: nil];
            [alertView show];
        }
    }
}

@end
