//
//  VolumViewControllerViewController.m
//  Labixiaoxin1-5
//
//  Created by 晋辉 卫 on 5/1/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import "VolumViewControllerViewController.h"
#import "DataEngine.h"
#import "VolumStatus.h"
#import "GADBannerView.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "YouMiView.h"
#import "AdTypes.h"
#import "ComicInfos.h"

#define PADDING 5

@interface VolumViewControllerViewController ()
- (void)performLayout;
- (void)performLayoutWithoutResize;

// Paging
- (void)tilePages;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (ZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index;
- (ZoomingScrollView *)dequeueRecycledPage;
- (void)configurePage:(ZoomingScrollView *)page forIndex:(NSUInteger)index;

// Frames
- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;
- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index;
- (CGRect)frameForNavigationBarAtOrientation:(UIInterfaceOrientation)orientation;
- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation;

// Navigation
- (void)jumpToPageAtIndex:(NSUInteger)index;
- (void)gotoPreviousPage;
- (void)gotoNextPage;
- (void)savePhoto;

// Controls
- (void)cancelControlHiding;
- (void)hideControlsAfterDelay;
- (void)setControlsHidden:(BOOL)hidden;
- (void)toggleControls;

- (void)updateSlide;

- (void)showAd;
- (void)hideAd;
- (void)reloadAd;

- (void)updateIndex;

- (void)relayoutMenuButton;
@end

@implementation VolumViewControllerViewController
@synthesize pagingScrollView = _pagingScrollView;
@synthesize volumStatus = _volumStatus;

- (CGFloat)adViewHeight
{
    CGFloat barHeight = CGRectGetHeight(_bannerView.frame);
    barHeight = MAX(barHeight, CGRectGetHeight(_youmiView.frame));
    barHeight = MAX(barHeight, CGRectGetHeight(_MobWINView.frame));
    barHeight = MAX(barHeight, CGRectGetHeight(_DMView.frame));
    barHeight = MAX(barHeight, CGRectGetHeight(_UMengView.frame));
    return barHeight;
}

- (void)relayoutMenuButton
{
    if (_adShowing) {
        CGFloat barHeight = MAX(CGRectGetHeight(toolbar.frame), [self adViewHeight]);
        menuButton.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - CGRectGetHeight(menuButton.frame) - barHeight, CGRectGetWidth(menuButton.frame), CGRectGetHeight(menuButton.frame));
    } else {
        menuButton.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - CGRectGetHeight(menuButton.frame) - CGRectGetHeight(toolbar.frame), CGRectGetWidth(menuButton.frame), CGRectGetHeight(menuButton.frame));
    }
}

- (void)cleanAdViews
{
    _bannerView.delegate = nil;
    _bannerView.rootViewController = nil;
    [_bannerView removeFromSuperview];
    _bannerView = nil;
    
    _youmiView.delegate = nil;
    [_youmiView removeFromSuperview];
    _youmiView = nil;
    
    _MobWINView.delegate = nil;
    _MobWINView.rootViewController = nil;
    [_MobWINView stopRequest];
    [_MobWINView removeFromSuperview];
    _MobWINView = nil;
    
    _DMView.delegate = nil;
    _DMView.rootViewController = nil;
    [_DMView removeFromSuperview];
    _DMView = nil;
    
    _UMengView.delegate = nil;
    [_UMengView removeFromSuperview];
    _UMengView = nil;
}

- (void)relayoutRemoveAdButton
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([delegate adRemoved]) {
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        UIButton *removeAd = [UIButton buttonWithType:UIButtonTypeCustom];
        [removeAd setBackgroundImage:[[UIImage retina4ImageNamed:@"button.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
        //        [_moreBookButton setBackgroundImage:[[UIImage retina4ImageNamed:@"button_selected.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
        // Set the title to use the same font and shadow as the standard back button
        removeAd.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
        removeAd.titleLabel.textColor = [UIColor whiteColor];
        removeAd.titleLabel.shadowOffset = CGSizeMake(0,-1);
        removeAd.titleLabel.shadowColor = [UIColor darkGrayColor];
        // Set the break mode to truncate at the end like the standard back button
        removeAd.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        // Inset the title on the left and right
        removeAd.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
        // Make the button as high as the passed in image
        removeAd.frame = CGRectMake(0, 0, 56, 28);
        [naviBar setText:NSLocalizedString(@"移除广告", nil) onBackButton:removeAd leftCapWidth:10.0];
        [removeAd addTarget:self action:@selector(removeAd:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:removeAd];
    }
}

- (IBAction)back:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)removeAd:(id)sender
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate purchase];
}

- (void)updateIndex
{
    DataEngine *dataEngine = [DataEngine sharedInstance];
    self.volumStatus.index = currentPageIndex;
    [dataEngine.volumsStatus setObject:self.volumStatus forKey:self.volumStatus.volumId];
    [dataEngine saveVolumsStatus];
}

- (IBAction)slideChanged:(id)sender
{
    currentPageIndex = pageSlider.value;
    [self updateIndex];
    [self performLayout];
    [self tilePages];
    [self hideControlsAfterDelay];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.wantsFullScreenLayout = YES;
        self.hidesBottomBarWhenPushed = YES;
		currentPageIndex = 0;
		performingLayout = NO;
		rotating = NO;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [recycledPages removeAllObjects];
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)responsePurchase:(NSNotification *)notification
{
    [self relayoutRemoveAdButton];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (delegate.adRemoved) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadAd) object:nil];
        _adShowing = NO;
        [self cleanAdViews];
        [self performLayoutWithoutResize];
        [self relayoutMenuButton];
    }
}

- (void)dealloc
{
    _bannerView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responsePurchase:)
                                                 name:kRemoveAdInAppPurchaseChanged
                                               object:nil];
    
    // View
	self.view.backgroundColor = [UIColor blackColor];
	self.title = [NSString stringWithFormat:NSLocalizedString(@"%d Volum", nil), [self.volumStatus.volumId intValue] + 1 + CURRENTBOOK_START];
    
    viewedCount = 0;
    DataEngine *dataEngine = [DataEngine sharedInstance];
    
    count = [ComicInfos volumImageCount:self.volumStatus.volumId];
    currentPageIndex = self.volumStatus.index;
    if (currentPageIndex > count - 1) {
        currentPageIndex = 0;
        self.volumStatus.index = 0;
        [dataEngine.volumsStatus setObject:self.volumStatus forKey:self.volumStatus.volumId];
        [dataEngine saveVolumsStatus];
    }
    
	// Setup paging scrolling view
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
	self.pagingScrollView.frame = pagingScrollViewFrame;
	self.pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.pagingScrollView.pagingEnabled = YES;
    self.pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
	self.pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:currentPageIndex];
    
    // Setup pages
	visiblePages = [[NSMutableSet alloc] init];
	recycledPages = [[NSMutableSet alloc] init];
	[self tilePages];
    
    [naviBar pushNavigationItem:self.navigationItem animated:YES];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[[UIImage retina4ImageNamed:@"back.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
    //    [commentButton setBackgroundImage:[[UIImage retina4ImageNamed:@"button_selected.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
    // Set the title to use the same font and shadow as the standard back button
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    backButton.titleLabel.textColor = [UIColor whiteColor];
    backButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
    backButton.titleLabel.shadowColor = [UIColor darkGrayColor];
    // Set the break mode to truncate at the end like the standard back button
    backButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    // Inset the title on the left and right
    backButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
    // Make the button as high as the passed in image
    backButton.frame = CGRectMake(0, 0, 56, 28);
    [naviBar setText:[NSString stringWithFormat:@" %@", NSLocalizedString(@"Back", nil)] onBackButton:backButton leftCapWidth:10.0];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    [self relayoutRemoveAdButton];
    
    // Toolbar
    toolbar.frame = [self frameForToolbarAtOrientation:self.interfaceOrientation];
    toolbar.tintColor = nil;
    
    menuButton.delegate = self;
    UIImage *menuImage = [UIImage retina4ImageNamed:@"menuBg.png"];
    menuButton.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - menuImage.size.height, menuImage.size.width, menuImage.size.height);
    [menuButton setBackgroundImage:menuImage forState:UIControlStateNormal];
    [self relayoutMenuButton];
    
    pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 60, toolbar.frame.size.height - 10)];
    pageLabel.textAlignment = UITextAlignmentCenter;
    pageLabel.backgroundColor = [UIColor clearColor];
    pageLabel.font = [UIFont systemFontOfSize:15];
    pageLabel.text = @"0/0";
    pageLabel.textColor = [UIColor whiteColor];
    [toolbar addSubview:pageLabel];
    
    pageSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(pageLabel.frame) + 5, 0, CGRectGetWidth(self.view.frame) - CGRectGetMaxX(pageLabel.frame) - 10, CGRectGetHeight(toolbar.frame))];
    [self updateSlide];
    [toolbar addSubview:pageSlider];
    [pageSlider addTarget:self action:@selector(slideChanged:) forControlEvents:UIControlEventValueChanged];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (!delegate.adRemoved) {
        switch ([dataEngine.adTypes.prime integerValue]) {
            case 1:
                if (IS_IPAD) {
                    _bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeLeaderboard];
                } else {
                    _bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
                }
                _bannerView.adUnitID = ADMOB_ID;
                _bannerView.rootViewController = self;
                _bannerView.delegate = self;
                [secondView addSubview:_bannerView];
                _bannerView.frame = CGRectMake((CGRectGetWidth(secondView.frame) - CGRectGetWidth(_bannerView.frame)) / 2, CGRectGetHeight(secondView.frame) - CGRectGetHeight(_bannerView.frame), CGRectGetWidth(_bannerView.frame), CGRectGetHeight(_bannerView.frame));
                [_bannerView loadRequest:[GADRequest request]];
                break;
            case 2:
                _MobWINView = [[MobWinBannerView alloc] initMobWinBannerSizeIdentifier:MobWINBannerSizeIdentifier320x50];
                _MobWINView.rootViewController = self.navigationController;
                _MobWINView.adUnitID = MobWIN_ID;
                _MobWINView.delegate = self;
                [secondView addSubview:_MobWINView];
                _MobWINView.frame = CGRectMake((CGRectGetWidth(secondView.frame) - CGRectGetWidth(_MobWINView.frame)) / 2, CGRectGetHeight(secondView.frame) - CGRectGetHeight(_MobWINView.frame), CGRectGetWidth(_MobWINView.frame), CGRectGetHeight(_MobWINView.frame));
                _MobWINView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
                _MobWINView.adAlpha = 0.5;
                [_MobWINView startRequest];
                break;
            case 3:
                _DMView = [[DMAdView alloc] initWithPublisherId:Domob_ID
                                                           size:DOMOB_AD_SIZE_320x50
                                                    autorefresh:YES];
                _DMView.delegate = self;
                _DMView.rootViewController = self.navigationController;
                [secondView addSubview:_DMView];
                _DMView.frame = CGRectMake((CGRectGetWidth(secondView.frame) - CGRectGetWidth(_DMView.frame)) / 2, CGRectGetHeight(secondView.frame) - CGRectGetHeight(_DMView.frame), CGRectGetWidth(_DMView.frame), CGRectGetHeight(_DMView.frame));
                _DMView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
                [_DMView loadAd];
                break;
            case 4:
                _youmiView = [[YouMiView alloc] initWithContentSizeIdentifier:YouMiBannerContentSizeIdentifier320x50 delegate:self];
                _youmiView.appID = Youmi_Ad_Id;
                _youmiView.appSecret = Youmi_Ad_Secret;
                [secondView addSubview:_youmiView];
                _youmiView.frame = CGRectMake((CGRectGetWidth(secondView.frame) - CGRectGetWidth(_youmiView.frame)) / 2, CGRectGetHeight(secondView.frame) - CGRectGetHeight(_youmiView.frame), CGRectGetWidth(_youmiView.frame), CGRectGetHeight(_youmiView.frame));
                _youmiView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
                [_youmiView start];
                break;
                
            case 0:
            default:
                _UMengView = [[UMUFPBannerView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(secondView.frame) - 50, 320, 50)
                                                             appKey:UMeng_ID
                                                             slotId:nil
                                              currentViewController:self.navigationController];
                _UMengView.mBackgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
                _UMengView.mTextColor = [UIColor colorWithRed:0.9
                                                        green:0.9
                                                         blue:0.9
                                                        alpha:1.0];
                _UMengView.delegate = self;
                [secondView addSubview:_UMengView];
                [_UMengView requestPromoterDataInBackground];
                break;
        }
    }
}

- (void)viewDidUnload
{
    [self setPagingScrollView:nil];
    secondView = nil;
    menuButton = nil;
    [self cleanAdViews];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
	// Super
	[super viewWillAppear:animated];
	
    naviBar.tintColor = nil;
    naviBar.barStyle = UIBarStyleBlackTranslucent;
    
	// Layout
	[self performLayout];
    
    // Set status bar style to black translucent
//	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    
	// Navigation
    [self updateSlide];
	[self hideControlsAfterDelay];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate showUserGuide:delegate.window];
}

- (void)viewWillDisappear:(BOOL)animated {
	
	// Super
	[super viewWillDisappear:animated];
    
    naviBar.tintColor = nil;
    naviBar.barStyle = UIBarStyleBlackOpaque;
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    self.wantsFullScreenLayout = NO;
    naviBar.alpha = 1.0;
	// Cancel any hiding timers
	[self cancelControlHiding];
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadAd) object:nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
	// Remember page index before rotation
	pageIndexBeforeRotation = currentPageIndex;
	rotating = YES;
	
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	// Perform layout
	currentPageIndex = pageIndexBeforeRotation;
    [self updateSlide];
	[self performLayout];
	
	// Delay control holding
	[self hideControlsAfterDelay];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	rotating = NO;
}


- (CGRect)frameForPagingScrollView {
    CGRect frame = self.view.bounds;// [[UIScreen mainScreen] bounds];
    if (_adShowing) {
        frame.size.height -= [self adViewHeight];
    }
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}

- (CGSize)contentSizeForPagingScrollView {
    // We have to use the paging scroll view's bounds to calculate the contentSize, for the same reason outlined above.
    CGRect bounds = self.pagingScrollView.bounds;
    if (_adShowing) {
        bounds.size.height -= [self adViewHeight];
    }
    return CGSizeMake(bounds.size.width * count, bounds.size.height);
}

- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index {
	CGFloat pageWidth = self.pagingScrollView.bounds.size.width;
	CGFloat newOffset = index * pageWidth;
	return CGPointMake(newOffset, 0);
}

- (void)tilePages {
	
	// Calculate which pages should be visible
	// Ignore padding as paging bounces encroach on that
	// and lead to false page loads
	CGRect visibleBounds = self.pagingScrollView.bounds;
	int iFirstIndex = (int)floorf((CGRectGetMinX(visibleBounds) + PADDING*2) / CGRectGetWidth(visibleBounds));
	int iLastIndex  = (int)floorf((CGRectGetMaxX(visibleBounds) - PADDING*2 - 1) / CGRectGetWidth(visibleBounds));
    if (iFirstIndex < 0) iFirstIndex = 0;
    if (iFirstIndex > count - 1) iFirstIndex = count - 1;
    if (iLastIndex < 0) iLastIndex = 0;
    if (iLastIndex > count - 1) iLastIndex = count - 1;
	
	// Recycle no longer needed pages
	for (ZoomingScrollView *page in visiblePages) {
		if (page.index < (NSUInteger)iFirstIndex || page.index > (NSUInteger)iLastIndex) {
			[recycledPages addObject:page];
			page.index = NSNotFound; // empty
			[page removeFromSuperview];
		}
	}
	[visiblePages minusSet:recycledPages];
	
	// Add missing pages
	for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index++) {
		if (![self isDisplayingPageForIndex:index]) {
			ZoomingScrollView *page = [self dequeueRecycledPage];
			if (!page) {
				page = [[ZoomingScrollView alloc] init];
                page.zoomingDelegate = self;
			}
			[self configurePage:page forIndex:index];
			[visiblePages addObject:page];
			[self.pagingScrollView addSubview:page];
		}
	}
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
	for (ZoomingScrollView *page in visiblePages)
		if (page.index == index) return YES;
	return NO;
}

- (ZoomingScrollView *)dequeueRecycledPage {
	ZoomingScrollView *page = [recycledPages anyObject];
	if (page) {
		[recycledPages removeObject:page];
	}
	return page;
}

- (ZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index {
	ZoomingScrollView *thePage = nil;
	for (ZoomingScrollView *page in visiblePages) {
		if (page.index == index) {
			thePage = page; break;
		}
	}
	return thePage;
}

- (void)configurePage:(ZoomingScrollView *)page forIndex:(NSUInteger)index {
	page.frame = [self frameForPageAtIndex:index];
	page.index = index;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
    // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
    // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
    // because it has a rotation transform applied.
    CGRect bounds = self.pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * PADDING);
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return pageFrame;
}

- (CGRect)frameForNavigationBarAtOrientation:(UIInterfaceOrientation)orientation {
	CGFloat height = UIInterfaceOrientationIsPortrait(orientation) ? 44 : 32;
	return CGRectMake(0, 20, self.view.bounds.size.width, height);
}

- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation {
	CGFloat height = UIInterfaceOrientationIsPortrait(orientation) ? 44 : 32;
	return CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height);
}

// Layout subviews
- (void)performLayout {
	
	// Flag
	performingLayout = YES;
	
	// Toolbar
	toolbar.frame = [self frameForToolbarAtOrientation:self.interfaceOrientation];
	
	// Remember index
	NSUInteger indexPriorToLayout = currentPageIndex;
	
	// Get paging scroll view frame to determine if anything needs changing
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    
	// Frame needs changing
	self.pagingScrollView.frame = pagingScrollViewFrame;
	
	// Recalculate contentSize based on current orientation
	self.pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
	
	// Adjust frames and configuration of each visible page
	for (ZoomingScrollView *page in visiblePages) {
		page.frame = [self frameForPageAtIndex:page.index];
		[page setMaxMinZoomScalesForCurrentBounds:YES];
	}
	
	// Adjust contentOffset to preserve page location based on values collected prior to location
	self.pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
	
	// Reset
	currentPageIndex = indexPriorToLayout;
    [self updateSlide];
	performingLayout = NO;
}

- (void)performLayoutWithoutResize
{
	
	// Flag
	performingLayout = YES;
	
	// Toolbar
	toolbar.frame = [self frameForToolbarAtOrientation:self.interfaceOrientation];
	
	// Remember index
	NSUInteger indexPriorToLayout = currentPageIndex;
	
	// Get paging scroll view frame to determine if anything needs changing
	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    
	// Frame needs changing
	self.pagingScrollView.frame = pagingScrollViewFrame;
	
	// Recalculate contentSize based on current orientation
	self.pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
	
	// Adjust frames and configuration of each visible page
	for (ZoomingScrollView *page in visiblePages) {
		page.frame = [self frameForPageAtIndex:page.index];
		[page setMaxMinZoomScalesForCurrentBounds:NO];
	}
	
	// Adjust contentOffset to preserve page location based on values collected prior to location
	self.pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
	
	// Reset
	currentPageIndex = indexPriorToLayout;
    [self updateSlide];
	performingLayout = NO;
}

// Enable/disable control visiblity timer
- (void)hideControlsAfterDelay {
	[self cancelControlHiding];
	if (![UIApplication sharedApplication].isStatusBarHidden) {
		controlVisibilityTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideControls) userInfo:nil repeats:NO];
	}
}

- (void)cancelControlHiding {
	// If a timer exists then cancel and release
	if (controlVisibilityTimer) {
		[controlVisibilityTimer invalidate];
		controlVisibilityTimer = nil;
	}
}

- (void)reloadMenuBg
{
    if (naviBar.alpha == 0.0) {
        [menuButton setBackgroundImage:[UIImage retina4ImageNamed:@"menuBgShow.png"] forState:UIControlStateNormal];
    } else {
        [menuButton setBackgroundImage:[UIImage retina4ImageNamed:@"menuBg.png"] forState:UIControlStateNormal];
    }
}

- (void)setControlsHidden:(BOOL)hidden {
	
	// Get status bar height if visible
	CGFloat statusBarHeight = 0;
	if (![UIApplication sharedApplication].statusBarHidden) {
		CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
		statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
	}
	
	[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
	
	// Get status bar height if visible
	if (![UIApplication sharedApplication].statusBarHidden) {
		CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
		statusBarHeight = MIN(statusBarFrame.size.height, statusBarFrame.size.width);
	}
	
	// Set navigation bar frame
	CGRect navBarFrame = naviBar.frame;
	navBarFrame.origin.y = statusBarHeight;
	naviBar.frame = navBarFrame;
	
	// Bars
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.35];
	[naviBar setAlpha:hidden ? 0 : 1];
	[toolbar setAlpha:hidden ? 0 : 1];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(reloadMenuBg)];
	[UIView commitAnimations];
	
	// Control hiding timer
	// Will cancel existing timer but only begin hiding if
	// they are visible
	[self hideControlsAfterDelay];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	if (performingLayout || rotating) return;
	
	// Tile pages
	[self tilePages];
	
	// Calculate current page
	CGRect visibleBounds = self.pagingScrollView.bounds;
	int index = (int)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    if (index < 0) index = 0;
	if (index > count - 1) index = count - 1;
	NSUInteger previousCurrentPage = currentPageIndex;
	currentPageIndex = index;
	if (currentPageIndex != previousCurrentPage) {
        viewedCount ++;
        if (viewedCount == 5) {
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [delegate promptComment];
        }
        [self updateIndex];
        [self updateSlide];
    }
	
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	// Hide controls when dragging begins
	[self setControlsHidden:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	// Update nav when page changes
    [self updateSlide];
}

- (void)jumpToPageAtIndex:(NSUInteger)index {
	
	// Change page
	if (index < count) {
		CGRect pageFrame = [self frameForPageAtIndex:index];
		self.pagingScrollView.contentOffset = CGPointMake(pageFrame.origin.x - PADDING, 0);
        currentPageIndex = index;
        [self updateIndex];
        [self updateSlide];
	}
	
	// Update timer to give more time
	[self hideControlsAfterDelay];
}

- (void)gotoPreviousPage { [self jumpToPageAtIndex:currentPageIndex-1]; }
- (void)gotoNextPage { [self jumpToPageAtIndex:currentPageIndex+1]; }

- (void)savePhoto {
    UIImageWriteToSavedPhotosAlbum([self getImage:currentPageIndex], self, nil, nil);
}


// Enable/disable control visiblity timer
- (void)hideControls { [self setControlsHidden:YES]; }
- (void)toggleControls { [self setControlsHidden:![UIApplication sharedApplication].isStatusBarHidden]; }

- (void)updateSlide
{
    pageSlider.minimumValue = 0.0;
    pageSlider.maximumValue = count - 1;
    pageSlider.value = currentPageIndex;
    pageLabel.text = [NSString stringWithFormat:@"%d/%d", currentPageIndex + 1, count];
}

- (UIImage *)getImage:(NSInteger)index
{
    return [UIImage retina4ImageNamed:[NSString stringWithFormat:@"%d-%d.jpg", [self.volumStatus.volumId intValue] + 1 + CURRENTBOOK_START, index + 1]];
}

- (void)handleSingleTap:(CGPoint)touchPoint
{
    if (![UIApplication sharedApplication].isStatusBarHidden) {
        [self performSelector:@selector(toggleControls) withObject:nil afterDelay:0.0];
    }
}

- (void)cancelSingleTap
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(toggleControls) object:nil];
    [self hideControlsAfterDelay];
}

- (UIView *)realHitView:(UIView *)button
{
    return button;
}

- (void)showAd
{
    if (!_adShowing) {
        _adShowing = YES;
        [self performLayoutWithoutResize];
        [self relayoutMenuButton];
    }
}

- (void)hideAd
{
    if (_adShowing) {
        _adShowing = NO;
        [self performLayoutWithoutResize];
        [self relayoutMenuButton];
    }
}

- (void)reloadAd
{
    [_bannerView loadRequest:[GADRequest request]];
}

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    [self showAd];
}

// Sent when an ad request failed.  Normally this is because no network
// connection was available or no ads were available (i.e. no fill).  If the
// error was received as a part of the server-side auto refreshing, you can
// examine the hasAutoRefreshed property of the view.
- (void)adView:(GADBannerView *)view
didFailToReceiveAdWithError:(GADRequestError *)error
{
    [self hideAd];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadAd) object:nil];
    [self performSelector:@selector(reloadAd) withObject:nil afterDelay:5.0];
}
- (IBAction)hideMenu:(id)sender {
    [self performSelector:@selector(toggleControls) withObject:nil afterDelay:0.0];
}

#pragma youmi
- (void)didReceiveAd:(YouMiView *)adView
{
    _youmiView.frame = CGRectMake((CGRectGetWidth(secondView.frame) - CGRectGetWidth(_youmiView.frame)) / 2, CGRectGetHeight(secondView.frame) - CGRectGetHeight(_youmiView.frame), CGRectGetWidth(_youmiView.frame), CGRectGetHeight(_youmiView.frame));
    [self showAd];
}

// Send after fail to receive ad data from server
// p.s. send after the first failed request and every following failed request
//
// 请求广告条数据失败后调用
// 
// 详解:
//      当接收服务器返回的广告数据失败后调用该方法
// 补充:
//      第一次和接下来每次如果请求失败都会调用该方法
// 
- (void)didFailToReceiveAd:(YouMiView *)adView  error:(NSError *)error
{
    _youmiView.hidden = YES;
    [self hideAd];
}


#pragma mobwin
// 请求广告条数据成功后调用
//
// 详解:当接收服务器返回的广告数据成功后调用该函数
- (void)bannerViewDidReceived
{
    _MobWINView.frame = CGRectMake((CGRectGetWidth(secondView.frame) - CGRectGetWidth(_MobWINView.frame)) / 2, CGRectGetHeight(secondView.frame) - CGRectGetHeight(_MobWINView.frame), CGRectGetWidth(_MobWINView.frame), CGRectGetHeight(_MobWINView.frame));
    [self showAd];
}

// 请求广告条数据失败后调用
//
// 详解:当接收服务器返回的广告数据失败后调用该函数
- (void)bannerViewFailToReceived
{
    _MobWINView.hidden = YES;
    [self hideAd];
}

#pragma domob
// 成功加载广告后，回调该方法
- (void)dmAdViewSuccessToLoadAd:(DMAdView *)adView
{
    _DMView.frame = CGRectMake((CGRectGetWidth(secondView.frame) - CGRectGetWidth(_DMView.frame)) / 2, CGRectGetHeight(secondView.frame) - CGRectGetHeight(_DMView.frame), CGRectGetWidth(_DMView.frame), CGRectGetHeight(_DMView.frame));
    [self showAd];
}

// 加载广告失败后，回调该方法
- (void)dmAdViewFailToLoadAd:(DMAdView *)adView withError:(NSError *)error
{
    _DMView.hidden = YES;
    [self hideAd];
}

#pragma umeng ad view
- (void)UMUFPBannerView:(UMUFPBannerView *)banner
      didLoadDataFinish:(NSInteger)promotersAmount
{
    _UMengView.frame = CGRectMake(0, CGRectGetHeight(secondView.frame) - 50, 320, 50);
    [self showAd];
}
- (void)UMUFPBannerView:(UMUFPBannerView *)banner
didLoadDataFailWithError:(NSError *)error
{
    _UMengView.hidden = YES;
    [self hideAd];
}
@end
