//
//  FlipVolumViewController.m
//  Labixiaoxin1-10
//
//  Created by 晋辉 卫 on 5/24/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import "FlipVolumViewController.h"
#import "DataEngine.h"
#import "VolumStatus.h"
#import "GADBannerView.h"
#import "CustomNavigationBar.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "YouMiView.h"

#define PADDING 5

@interface FlipVolumViewController ()
- (void)performLayout;
- (void)tilePage:(BOOL)animate;

// Frames
- (CGRect)frameForFliperView;

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

- (void)cleanAdViews;
@end

@implementation FlipVolumViewController
@synthesize volumStatus = _volumStatus;

- (void)relayoutMenuButton
{
    if (_adShowing) {
        CGFloat barHeight = MAX(CGRectGetHeight(bottomBar.frame), CGRectGetHeight(_bannerView.frame));
        menuButton.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - CGRectGetHeight(menuButton.frame) - barHeight, CGRectGetWidth(menuButton.frame), CGRectGetHeight(menuButton.frame));
    } else {
        menuButton.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - CGRectGetHeight(menuButton.frame) - CGRectGetHeight(bottomBar.frame), CGRectGetWidth(menuButton.frame), CGRectGetHeight(menuButton.frame));
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
}

- (void)relayoutRemoveAdButton
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if ([delegate adRemoved]) {
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        CustomNavigationBar *customNavigationBar =  (CustomNavigationBar*)self.navigationController.navigationBar;
        UIButton *removeAd = [UIButton buttonWithType:UIButtonTypeCustom];
        [removeAd setBackgroundImage:[[UIImage imageNamed:@"button.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
        //        [_moreBookButton setBackgroundImage:[[UIImage imageNamed:@"button_selected.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
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
        [customNavigationBar setText:NSLocalizedString(@"移除广告", nil) onBackButton:removeAd leftCapWidth:10.0];
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
    [self tilePage:NO];
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

- (void)responsePurchase:(NSNotification *)notification
{
    [self relayoutRemoveAdButton];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (delegate.adRemoved) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadAd) object:nil];
        _adShowing = NO;
        [self cleanAdViews];
        [self performLayout];
    }
}

- (void)dealloc
{
    [self cleanAdViews];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(responsePurchase:)
                                                 name:kRemoveAdInAppPurchaseChanged
                                               object:nil];
    
    // Do any additional setup after loading the view from its nib.
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.title = [NSString stringWithFormat:NSLocalizedString(@"%d Volum", nil), [self.volumStatus.volumId intValue] + 1 + CURRENTBOOK_START];
    
    viewedCount = 0;
    DataEngine *dataEngine = [DataEngine sharedInstance];
    count = [dataEngine volumImageCount:self.volumStatus.volumId];
    currentPageIndex = self.volumStatus.index;
    if (currentPageIndex > count - 1) {
        currentPageIndex = 0;
        self.volumStatus.index = 0;
        [dataEngine.volumsStatus setObject:self.volumStatus forKey:self.volumStatus.volumId];
        [dataEngine saveVolumsStatus];
    }
        
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    CustomNavigationBar *customNavigationBar =  (CustomNavigationBar*)self.navigationController.navigationBar;
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[[UIImage imageNamed:@"back.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
    //    [commentButton setBackgroundImage:[[UIImage imageNamed:@"button_selected.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
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
    [customNavigationBar setText:[NSString stringWithFormat:@" %@", NSLocalizedString(@"Back", nil)] onBackButton:backButton leftCapWidth:10.0];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    [self relayoutRemoveAdButton];
    
    UIImage *menuImage = [UIImage imageNamed:@"menuBg.png"];
    menuButton.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - menuImage.size.height, menuImage.size.width, menuImage.size.height);
    [menuButton setBackgroundImage:menuImage forState:UIControlStateNormal];
    pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 60, bottomBar.frame.size.height - 10)];
    pageLabel.textAlignment = UITextAlignmentCenter;
    pageLabel.backgroundColor = [UIColor clearColor];
    pageLabel.font = [UIFont systemFontOfSize:15];
    pageLabel.text = @"0/0";
    pageLabel.textColor = [UIColor whiteColor];
    pageLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [bottomBar addSubview:pageLabel];
    
    pageSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(pageLabel.frame) + 5, 0, 1024 - CGRectGetMaxX(pageLabel.frame) - 10, CGRectGetHeight(bottomBar.frame))];
    pageSlider.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self updateSlide];
    [bottomBar addSubview:pageSlider];
    [pageSlider addTarget:self action:@selector(slideChanged:) forControlEvents:UIControlEventValueChanged];
    
    flipView = [[AFKPageFlipper alloc] initWithFrame:frontView.bounds];
    flipView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    flipView.dataSource = self;
    [frontView addSubview:flipView];
    frontView.backgroundColor = [UIColor colorWithRed:200 / 255.0 green:200 / 255.0 blue:200 / 255.0 alpha:1.0];
    
    UITapGestureRecognizer *taper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    taper.delegate = self;
    [frontView addGestureRecognizer:taper];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (!delegate.adRemoved) {
        _bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        _bannerView.adUnitID = ADMOB_ID;
        _bannerView.rootViewController = self;
        _bannerView.delegate = self;
        [frontView addSubview:_bannerView];
        _bannerView.frame = CGRectMake(0, CGRectGetHeight(frontView.frame) - CGRectGetHeight(_bannerView.frame), CGRectGetWidth(_bannerView.frame), CGRectGetHeight(_bannerView.frame));
        [_bannerView loadRequest:[GADRequest request]];
        
        switch (dataEngine.adType) {
            case 1:
                _youmiView = [[YouMiView alloc] initWithContentSizeIdentifier:YouMiBannerContentSizeIdentifier320x50 delegate:self];
                _youmiView.appID = Youmi_Ad_Id;
                _youmiView.appSecret = Youmi_Ad_Secret;
                [frontView addSubview:_youmiView];
                _youmiView.frame = CGRectMake(CGRectGetWidth(frontView.frame) - CGRectGetWidth(_youmiView.frame), CGRectGetHeight(frontView.frame) - CGRectGetHeight(_youmiView.frame), CGRectGetWidth(_youmiView.frame), CGRectGetHeight(_youmiView.frame));
                _youmiView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
                [_youmiView start];
                break;
                
            case 0:
            default:
                _MobWINView = [[MobWinBannerView alloc] initMobWinBannerSizeIdentifier:MobWINBannerSizeIdentifier320x50];
                _MobWINView.rootViewController = self.navigationController;
                _MobWINView.adUnitID = MobWIN_ID;
                _MobWINView.delegate = self;
                [frontView addSubview:_MobWINView];
                _MobWINView.frame = CGRectMake(CGRectGetWidth(frontView.frame) - CGRectGetWidth(_MobWINView.frame), CGRectGetHeight(frontView.frame) - CGRectGetHeight(_MobWINView.frame) + 10, CGRectGetWidth(_MobWINView.frame), CGRectGetHeight(_MobWINView.frame));
                _MobWINView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
                _MobWINView.adAlpha = 0.5;
                [_MobWINView startRequest];
                break;
        }
    }
}

- (void)viewDidUnload
{
    flipView = nil;
    frontView = nil;
    menuButton = nil;
    bottomBar = nil;
    [self cleanAdViews];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
	// Super
	[super viewWillAppear:animated];
	
	// Layout
	[self performLayout];
    // Set status bar style to black translucent
    //	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
    
	// Navigation
    [self updateSlide];
	[self hideControlsAfterDelay];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate showUserGuide:self.navigationController.view];
}

- (void)viewWillDisappear:(BOOL)animated {
	
	// Super
	[super viewWillDisappear:animated];
    
    //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
	// Cancel any hiding timers
	[self cancelControlHiding];
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reloadAd) object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (flipView && flipView.animating) {
		return NO;
	}
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
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

- (CGRect)frameForFliperView {
    CGRect frame = CGRectMake(0, 0, 1024, 768);// [[UIScreen mainScreen] bounds];
    if (0 && _adShowing) {
        CGFloat subHeight = CGRectGetHeight(_bannerView.frame) / 2;
        CGSize newSize = CGSizeMake(1004 * (768 - subHeight) / 768, 768 - subHeight);
        frame.origin.x = (1024 - newSize.width) / 2;
        frame.size = newSize;
    }
    return frame;
}

- (CGRect)frameForNavigationBarAtOrientation:(UIInterfaceOrientation)orientation {
	CGFloat height = UIInterfaceOrientationIsPortrait(orientation) ? 44 : 44;
	return CGRectMake(0, 20, self.view.bounds.size.width, height);
}

- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation {
	CGFloat height = UIInterfaceOrientationIsPortrait(orientation) ? 44 : 44;
	return CGRectMake(0, self.view.bounds.size.height - height, self.view.bounds.size.width, height);
}

// Layout subviews
- (void)performLayout {
	
	// Flag
	performingLayout = YES;
	
	// Toolbar
	bottomBar.frame = [self frameForToolbarAtOrientation:self.interfaceOrientation];
	[self relayoutMenuButton];
    
	// Remember index
	NSUInteger indexPriorToLayout = currentPageIndex;
	
	// Get paging scroll view frame to determine if anything needs changing
	CGRect flipViewFrame = [self frameForFliperView];
    
	// Frame needs changing
	flipView.frame = flipViewFrame;
	
	// Adjust contentOffset to preserve page location based on values collected prior to location
    [self tilePage:NO];
	
	// Reset
	currentPageIndex = indexPriorToLayout;
    [self updateSlide];
	performingLayout = NO;
}

- (void)tilePage:(BOOL)animate
{
    if (flipView.currentPage != currentPageIndex / 2 + 1) {
        [flipView setCurrentPage:currentPageIndex / 2 + 1 animated:animate];
    }
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
    if (self.navigationController.navigationBar.alpha == 0.0) {
        [menuButton setBackgroundImage:[UIImage imageNamed:@"menuBgShow.png"] forState:UIControlStateNormal];
    } else {
        [menuButton setBackgroundImage:[UIImage imageNamed:@"menuBg.png"] forState:UIControlStateNormal];
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
	CGRect navBarFrame = self.navigationController.navigationBar.frame;
	navBarFrame.origin.y = statusBarHeight;
	self.navigationController.navigationBar.frame = navBarFrame;
	
	// Bars
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.35];
	[self.navigationController.navigationBar setAlpha:hidden ? 0 : 1];
	[bottomBar setAlpha:hidden ? 0 : 1];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(reloadMenuBg)];
	[UIView commitAnimations];
	
	// Control hiding timer
	// Will cancel existing timer but only begin hiding if
	// they are visible
	[self hideControlsAfterDelay];
}

- (void)jumpToPageAtIndex:(NSUInteger)index {
	
	// Change page
	if (index < count) {
        currentPageIndex = index;
        [self updateIndex];
        [self updateSlide];
	}
	
	// Update timer to give more time
	[self hideControlsAfterDelay];
}

- (void)gotoPreviousPage { [self jumpToPageAtIndex:currentPageIndex - 1]; }
- (void)gotoNextPage { [self jumpToPageAtIndex:currentPageIndex + 1]; }

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
    return [UIImage imageNamed:[NSString stringWithFormat:@"%d-%d.jpg", [self.volumStatus.volumId intValue] + 1 + CURRENTBOOK_START, index + 1]];
}

// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:frontView];
    if (_bannerView && CGRectContainsPoint(_bannerView.frame, point)) {
        return NO;
    }
    if (_youmiView && CGRectContainsPoint(_youmiView.frame, point)) {
        return NO;
    }
    if (_MobWINView && CGRectContainsPoint(_MobWINView.frame, point)) {
        return NO;
    }
    return YES;
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self.view];
    [self handleSingleTap:point];
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

- (void)showAd
{
    if (!_adShowing) {
        _adShowing = YES;
        _bannerView.frame = CGRectMake(0, CGRectGetHeight(frontView.frame) - CGRectGetHeight(_bannerView.frame), CGRectGetWidth(_bannerView.frame), CGRectGetHeight(_bannerView.frame));
        [self performLayout];
    }
}

- (void)hideAd
{
    if (_adShowing) {
        _adShowing = NO;
        [self performLayout];
    }
}

- (void)reloadAd
{
    [_bannerView loadRequest:[GADRequest request]];
}

- (NSInteger)numberOfPagesForPageFlipper:(AFKPageFlipper *)pageFlipper
{
    return count / 2 + (count % 2 == 0 ? 0 : 1);
}

- (UIView *)viewForPage:(NSInteger)page inFlipper:(AFKPageFlipper *)pageFlipper
{
    CGRect rect = self.frameForFliperView;
    rect.origin = CGPointMake(0, 0);
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.clipsToBounds = YES;
    view.backgroundColor = [UIColor colorWithRed:254 / 255.0 green:254 / 255.0 blue:254 / 255.0 alpha:1.0];
    
    CGRect realRect = rect;
    realRect.size.height -= 50;
    NSInteger firstIndex = (page - 1) * 2;
    UIImageView *firstView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d-%d.jpg", [self.volumStatus.volumId intValue] + 1 + CURRENTBOOK_START, firstIndex + 1]]];
    firstView.frame = CGRectMake(0, 0, CGRectGetWidth(firstView.frame) * realRect.size.height / CGRectGetHeight(firstView.frame), realRect.size.height);
    
    UIImageView *secondView = nil;
    if (firstIndex + 1 < count) {
        secondView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d-%d.jpg", [self.volumStatus.volumId intValue] + 1 + CURRENTBOOK_START, firstIndex + 2]]];
    } else {
        secondView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(firstView.frame), CGRectGetHeight(firstView.frame))];
    }
    secondView.frame = CGRectMake(0, 0, CGRectGetWidth(secondView.frame) * realRect.size.height / CGRectGetHeight(secondView.frame), realRect.size.height);
#ifdef Sequence_From_Left
    firstView.frame = CGRectMake((realRect.size.width - CGRectGetWidth(firstView.frame) - CGRectGetWidth(secondView.frame)) / 2, 0, CGRectGetWidth(firstView.frame), CGRectGetHeight(firstView.frame));
    firstView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    secondView.frame = CGRectMake(CGRectGetMaxX(firstView.frame), 0, CGRectGetWidth(secondView.frame), CGRectGetHeight(secondView.frame));
    secondView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
#else
    secondView.frame = CGRectMake((realRect.size.width - CGRectGetWidth(firstView.frame) - CGRectGetWidth(secondView.frame)) / 2, 0, CGRectGetWidth(secondView.frame), CGRectGetHeight(secondView.frame));
    secondView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    firstView.frame = CGRectMake(CGRectGetMaxX(secondView.frame), 0, CGRectGetWidth(firstView.frame), CGRectGetHeight(firstView.frame));
    firstView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
#endif
    
    [view addSubview:firstView];
    [view addSubview:secondView];
    return view;
}

- (void)pageShowed:(NSInteger)page inFlipper:(AFKPageFlipper *)pageFlipper
{
    currentPageIndex = (page - 1) * 2;
    [self updateIndex];
    [self updateSlide];
    viewedCount ++;
    if (viewedCount == 5) {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate promptComment];
    }
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

- (IBAction)hideMenu:(id)sender
{
    [self performSelector:@selector(toggleControls) withObject:nil afterDelay:0.0];
}


#pragma youmi
- (void)didReceiveAd:(YouMiView *)adView
{
    _youmiView.frame = CGRectMake(CGRectGetWidth(frontView.frame) - CGRectGetWidth(_youmiView.frame), CGRectGetHeight(frontView.frame) - CGRectGetHeight(_youmiView.frame), CGRectGetWidth(_youmiView.frame), CGRectGetHeight(_youmiView.frame));
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
    int a = 10;
    a ++;
}


#pragma mobwin
// 请求广告条数据成功后调用
//
// 详解:当接收服务器返回的广告数据成功后调用该函数
- (void)bannerViewDidReceived
{
    _MobWINView.frame = CGRectMake(CGRectGetWidth(frontView.frame) - CGRectGetWidth(_MobWINView.frame), CGRectGetHeight(frontView.frame) - CGRectGetHeight(_MobWINView.frame) + 10, CGRectGetWidth(_MobWINView.frame), CGRectGetHeight(_MobWINView.frame));
}

// 请求广告条数据失败后调用
//
// 详解:当接收服务器返回的广告数据失败后调用该函数
- (void)bannerViewFailToReceived
{
    int a = 10;
    a ++;
}

// 全屏广告弹出时调用
//
// 详解:当广告栏被点击，弹出内嵌全屏广告时调用
- (void)bannerViewDidPresentScreen
{
    
}

// 全屏广告关闭时调用
//
// 详解:当弹出内嵌全屏广告关闭，返回广告栏界面时调用
- (void)bannerViewDidDismissScreen
{
    
}
@end
