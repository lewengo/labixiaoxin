//
//  MainViewController.m
//  Labixiaoxin1-5
//
//  Created by 晋辉 卫 on 5/2/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import "MainViewController.h"
#import "VolumViewControllerViewController.h"
#import "DataEngine.h"
#import "VolumImageView.h"
#import "Constants.h"
#import "CustomNavigationBar.h"
#import "Book.h"
#import "MoreAppsControllerViewController.h"
#import "FlipVolumViewController.h"
#import "RecommendedApps.h"
#import "MoreController.h"
#import "PhoneEngine.h"

#define kIphoneNumberPerLine 3
#define kIpadPortraitNumberPerline 3
#define kIpadLandscapeNumberPerline 4

#define kVolum1Tag 10001
#define kVolum2Tag 10002
#define kVolum3Tag 10003
#define kVolum4Tag 10004

#define kIPadLandscapeCellHeight 274
#define kIPadPortraitCellHeight 330
#define kIPhoneCellHeight 150

@interface MainViewController ()
- (void)clickImage:(id)sender;
- (void)showRightButton;
- (void)bookListResponse:(NSNotification *)notification;
- (void)bageCountChanged:(NSNotification *)notification;

- (IBAction)comment:(id)sender;
- (IBAction)moreBook:(id)sender;
@end

@implementation MainViewController

- (void)clickImage:(id)sender
{
    if (sender == nil) {
        return;
    }
    UITapGestureRecognizer *gesture = sender;
    VolumImageView *view = (VolumImageView *)[gesture view];
    
    AppDelegate *delegate = [AppDelegate theAppDelegate];
    
#ifndef Is_Only_Portrait
    if (IS_IPAD) {
        FlipVolumViewController *fliper = [[FlipVolumViewController alloc] initWithNibName:@"FlipVolumViewController" bundle:nil];
        fliper.volumStatus = view.volum;
        [[DataEngine sharedInstance] saveCurrentVolum:[view.volum.volumId intValue]];
        [delegate.appRootController pushViewController:fliper animated:YES];
    } else
#endif
    {
        VolumViewControllerViewController *controller = [[VolumViewControllerViewController alloc] initWithNibName:@"VolumViewControllerViewController" bundle:nil];
        controller.volumStatus = view.volum;
        [[DataEngine sharedInstance] saveCurrentVolum:[view.volum.volumId intValue]];
        [delegate.appRootController pushViewController:controller animated:YES];
    }
}

- (void)showRightButton
{
//    CustomNavigationBar *customNavigationBar =  (CustomNavigationBar*)self.navigationController.navigationBar;
//    if (_moreBookButton == nil) {
//        _moreBookButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_moreBookButton setBackgroundImage:[[UIImage retina4ImageNamed:@"button.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
//        // Set the title to use the same font and shadow as the standard back button
//        _moreBookButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
//        _moreBookButton.titleLabel.textColor = [UIColor whiteColor];
//        _moreBookButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
//        _moreBookButton.titleLabel.shadowColor = [UIColor darkGrayColor];
//        // Set the break mode to truncate at the end like the standard back button
//        _moreBookButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
//        // Inset the title on the left and right
//        _moreBookButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
//        // Make the button as high as the passed in image
//        _moreBookButton.frame = CGRectMake(0, 0, 56, 28);
//        [customNavigationBar setText:NSLocalizedString(@"More cartoon", nil) onBackButton:_moreBookButton leftCapWidth:10.0];
//        [_moreBookButton addTarget:self action:@selector(moreBook:) forControlEvents:UIControlEventTouchUpInside];
//        
//        UIImage *bageBg = [[UIImage retina4ImageNamed:@"notificaionBubble.png"] stretchableImageWithLeftCapWidth:12.0f topCapHeight:8.0f];
//        _baggeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_baggeButton setBackgroundImage:bageBg forState:UIControlStateNormal];
//        _baggeButton.titleEdgeInsets = UIEdgeInsetsMake(-1, 2, 0, 0);
//        _baggeButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
//        _baggeButton.titleLabel.textAlignment = UITextAlignmentCenter;
//        _baggeButton.titleLabel.textColor = [UIColor whiteColor];
//        _baggeButton.frame = CGRectMake(CGRectGetMaxX(_moreBookButton.frame) - bageBg.size.width - 2, 2, bageBg.size.width, bageBg.size.height);
//        _baggeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
//        [_moreBookButton addSubview:_baggeButton];
//        _baggeButton.hidden = YES;
//        _baggeButton.userInteractionEnabled = NO;
//
//    }
//    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
//        [_baggeButton setTitle:[NSString stringWithFormat:@"%d", [UIApplication sharedApplication].applicationIconBadgeNumber] forState:UIControlStateNormal];
//        _baggeButton.hidden = NO;
//        _moreBookButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 13.0);
//        [customNavigationBar setText:NSLocalizedString(@"More cartoon", nil) onBackButton:_moreBookButton leftCapWidth:20.0];
//    } else {
//        _baggeButton.hidden = YES;
//        _moreBookButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
//        [customNavigationBar setText:NSLocalizedString(@"More cartoon", nil) onBackButton:_moreBookButton leftCapWidth:10.0];
//    }
//    BOOL hasBook = NO;
//    DataEngine *dataEngine = [DataEngine sharedInstance];
//    for (Book *book in dataEngine.books) {
//        if (![book.bookId isEqualToString:BOOK_ID]) {
//            hasBook = YES;
//            break;
//        }
//    }
//    if (hasBook) {
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_moreBookButton];
//
//    } else {
//        self.navigationItem.leftBarButtonItem = nil;
//    }
}

- (IBAction)comment:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_RATING_URL]];
}

- (IBAction)moreApp:(id)sender
{
//    MoreController *more = [[MoreController alloc] initWithNibName:@"MoreController" bundle:nil];
//    [self.navigationController pushViewController:more animated:YES];
}

- (IBAction)moreBook:(id)sender
{
    MoreAppsControllerViewController *moreapps = [[MoreAppsControllerViewController alloc] initWithNibName:@"MoreAppsControllerViewController" bundle:nil];
    [self.navigationController pushViewController:moreapps animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)bookListResponse:(NSNotification *)notification
{
    [self showRightButton];
}

- (void)bageCountChanged:(NSNotification *)notification
{
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bookListResponse:)
                                                 name:GET_NEWBOOK_LIST
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bageCountChanged:)
                                                 name:kBadgeCountChangeNotification
                                               object:nil];
    self.title = NSLocalizedString(@"Book name", nil);
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage retina4ImageNamed:@"canvas.png"]];
    
#ifndef Is_Only_Portrait
    if (IS_IPAD) {
        self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage retina4ImageNamed:@"canvas.png"]];
    }
#endif
    if (IS_IPAD) {
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0.0f, 0.0f, 0.0f);
    }
    
#ifdef ADD_APPLIST
    CustomNavigationBar *customNavigationBar =  (CustomNavigationBar*)self.navigationController.navigationBar;
    UIButton *moreApp = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreApp setBackgroundImage:[[UIImage retina4ImageNamed:@"button.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
    // Set the title to use the same font and shadow as the standard back button
    moreApp.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    moreApp.titleLabel.textColor = [UIColor whiteColor];
    moreApp.titleLabel.shadowOffset = CGSizeMake(0,-1);
    moreApp.titleLabel.shadowColor = [UIColor darkGrayColor];
    // Set the break mode to truncate at the end like the standard back button
    moreApp.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    // Inset the title on the left and right
    moreApp.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
    // Make the button as high as the passed in image
    moreApp.frame = CGRectMake(0, 0, 56, 28);
    [customNavigationBar setText:NSLocalizedString(@"更 多", nil) onBackButton:moreApp leftCapWidth:15.0];
    [moreApp addTarget:self action:@selector(moreApp:) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreApp];
#endif
    [self showRightButton];
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
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
#ifndef Is_Only_Portrait
    if (IS_IPAD) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    } else 
#endif
    {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPAD) {
#ifdef Is_Only_Portrait
        return kIPadPortraitCellHeight;
#else
        return kIPadLandscapeCellHeight;
#endif
    } else {
        return kIPhoneCellHeight;
    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.

    if (IS_IPAD) {
#ifdef Is_Only_Portrait
        return kVolumNumber / kIpadPortraitNumberPerline + (kVolumNumber % kIpadPortraitNumberPerline == 0 ? 0 : 1);
#else
        return kVolumNumber / kIpadLandscapeNumberPerline + (kVolumNumber % kIpadLandscapeNumberPerline == 0 ? 0 : 1);
#endif
    } else {
        return kVolumNumber / kIphoneNumberPerLine + (kVolumNumber % kIphoneNumberPerLine == 0 ? 0 : 1);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *stand = nil;
        if (IS_IPAD) {
#ifdef Is_Only_Portrait
            stand = [[UIImageView alloc] initWithImage:[UIImage retina4ImageNamed:@"volumStand.png"]];
#else
            UIImage *immm = [UIImage retina4ImageNamed:@"volumStand.png"];
            immm = [immm stretchableImageWithLeftCapWidth:immm.size.width / 2 topCapHeight:immm.size.height];
            stand = [[UIImageView alloc] initWithImage:immm];
            stand.frame = CGRectMake(0, 0, 1024 - 80, stand.frame.size.height);
#endif
        } else {
            stand = [[UIImageView alloc] initWithImage:[UIImage retina4ImageNamed:@"volumStand.png"]];
        }
        stand.frame = CGRectMake((cell.contentView.frame.size.width - stand.frame.size.width) / 2, cell.contentView.frame.size.height - stand.frame.size.height, stand.frame.size.width, stand.frame.size.height);
        [cell.contentView addSubview:stand];
        stand.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    }
#ifdef Is_Only_Portrait
    NSInteger perline = IS_IPAD ? kIpadPortraitNumberPerline : kIphoneNumberPerLine;
    CGPoint ltPoint = IS_IPAD ? CGPointMake(35, 9) : CGPointMake(9, 7);
    CGSize volumSize = IS_IPAD ? CGSizeMake(206, 265) : CGSizeMake(94, 123);
    CGFloat widthInterval = IS_IPAD ? 40 : 10;
#else
    NSInteger perline = IS_IPAD ? kIpadLandscapeNumberPerline : kIphoneNumberPerLine;
    CGPoint ltPoint = IS_IPAD ? CGPointMake(85, 3) : CGPointMake(9, 7);
    CGSize volumSize = IS_IPAD ? CGSizeMake(162, 216) : CGSizeMake(94, 123);
    CGFloat widthInterval = IS_IPAD ? 50 : 10;
#endif
    
    if (indexPath.row < [self tableView:tableView numberOfRowsInSection:0]) {
        DataEngine *dataEngine = [DataEngine sharedInstance];
        VolumImageView *volum1 = (VolumImageView *)[cell viewWithTag:kVolum1Tag];
        VolumImageView *volum2 = (VolumImageView *)[cell viewWithTag:kVolum2Tag];
        VolumImageView *volum3 = (VolumImageView *)[cell viewWithTag:kVolum3Tag];
        VolumImageView *volum4 = (VolumImageView *)[cell viewWithTag:kVolum4Tag];

        if (volum1 == nil) {
            volum1 = [[VolumImageView alloc] initWithFrame:CGRectMake(ltPoint.x, ltPoint.y, volumSize.width, volumSize.height)];
            volum1.tag = kVolum1Tag;
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)];
            gesture.delegate = self;
            [volum1 addGestureRecognizer:gesture];
            [cell.contentView addSubview:volum1];
        }
        volum1.volum = [dataEngine getVolumStatus:indexPath.row * perline];
        volum1.isCurrent = dataEngine.currentVolumId && [volum1.volum.volumId intValue] == [dataEngine.currentVolumId intValue];
        
        if (indexPath.row * perline + 1 < kVolumNumber) {
            if (volum2 == nil) {
                volum2 = [[VolumImageView alloc] initWithFrame:CGRectMake(ltPoint.x + volumSize.width + widthInterval, ltPoint.y, volumSize.width, volumSize.height)];
                volum2.tag = kVolum2Tag;
                UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)];
                gesture.delegate = self;
                [volum2 addGestureRecognizer:gesture];
                [cell.contentView addSubview:volum2];
            }
            volum2.hidden = NO;
            volum2.volum = [dataEngine getVolumStatus:indexPath.row * perline + 1];
            volum2.isCurrent = dataEngine.currentVolumId && [volum2.volum.volumId intValue] == [dataEngine.currentVolumId intValue];
            
            if (indexPath.row * perline + 2 < kVolumNumber) {
                if (volum3 == nil) {
                    volum3 = [[VolumImageView alloc] initWithFrame:CGRectMake(ltPoint.x + volumSize.width * 2 + widthInterval * 2, ltPoint.y, volumSize.width, volumSize.height)];
                    volum3.tag = kVolum3Tag;
                    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)];
                    gesture.delegate = self;
                    [volum3 addGestureRecognizer:gesture];
                    [cell.contentView addSubview:volum3];
                }
                volum3.hidden = NO;
                volum3.volum = [dataEngine getVolumStatus:indexPath.row * perline + 2];
                volum3.isCurrent = dataEngine.currentVolumId && [volum3.volum.volumId intValue] == [dataEngine.currentVolumId intValue];
#ifndef Is_Only_Portrait
                if (IS_IPAD && indexPath.row * perline + 3 < kVolumNumber) {
                    if (volum4 == nil) {
                        volum4 = [[VolumImageView alloc] initWithFrame:CGRectMake(ltPoint.x + volumSize.width * 3 + widthInterval * 3, ltPoint.y, volumSize.width, volumSize.height)];
                        volum4.tag = kVolum4Tag;
                        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage:)];
                        gesture.delegate = self;
                        [volum4 addGestureRecognizer:gesture];
                        [cell.contentView addSubview:volum4];
                    }
                    volum4.hidden = NO;
                    volum4.volum = [dataEngine getVolumStatus:indexPath.row * perline + 3];
                    volum4.isCurrent = dataEngine.currentVolumId && [volum4.volum.volumId intValue] == [dataEngine.currentVolumId intValue];
                } else {
                    volum4.hidden = YES;
                }
#endif
            } else {
                volum3.hidden = YES;
                volum4.hidden = YES;
            }
        } else {
            volum2.hidden = YES;
            volum3.hidden = YES;
            volum4.hidden = YES;
        }
    }
    
    return cell;
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
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
@end
