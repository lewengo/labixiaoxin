    //
//  CustomTabbarViewController.m
//  RaisedCenterTabBar
//
//  Created by Peter Boctor on 12/15/10.
//
// Copyright (c) 2011 Peter Boctor
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE
//

#import "CustomTabbarViewController.h"
#import "AppDelegate.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import "Constants.h"
#import "MoreController.h"
#import "CustomNavigationBar.h"

#define kTabbarHeight 44
#define kTabbarRealHeight 44

#define kTabbarWidth 61
#define kTabbarRealWidth 61

#define kIPhoneTabbarCount 3
#define kIPadTabbarCount 3

@interface CustomTabbarViewController ()
- (void)notificationCountChanged:(NSNotification *)notification;
@end

@implementation CustomTabbarViewController

@synthesize tabbarHidden;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (id)init
{
    self = [super init];
    if (self) {
        if (IS_IPAD) {
            _cttabbar = [[CTTabbarControl alloc] initWithFrame:CGRectMake(0, 0, kTabbarWidth, self.view.frame.size.height)
                                                  withDelegate:self
                                                     withCount:kIPadTabbarCount
                                               withOrientation:CTTabbarOrientationVertical];
            _cttabbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        } else {
            _cttabbar = [[CTTabbarControl alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height  - kTabbarHeight, self.view.bounds.size.width, kTabbarHeight)
                                                  withDelegate:self
                                                     withCount:kIPhoneTabbarCount
                                               withOrientation:CTTabbarOrientationHorizontal];
            _cttabbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        }
        [_cttabbar setSelectedIndex:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_controllerId == nil || [_controllerId length] == 0) {
        _controllerId = [[NSString alloc] initWithFormat:@"%p", self];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationCountChanged:) 
                                                 name:kBadgeCountChangeNotification 
                                               object:nil];
    [self notificationCountChanged:nil];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
        [self.selectedViewController viewWillAppear:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
        [self.selectedViewController viewDidAppear:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
        [self.selectedViewController viewWillDisappear:animated];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
        [self.selectedViewController viewDidDisappear:animated];
    }
}

- (void)setBadgeNumber:(int)number index:(int)index
{
    [_cttabbar setBadge:number index:index];
}

- (void)notificationCountChanged:(NSNotification *)notification
{
//    [self setBadgeNumber:[UIApplication sharedApplication].applicationIconBadgeNumber index:2];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (IS_IPAD) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    MSLog(@"willRotateToInterfaceOrientation   %d     %d", toInterfaceOrientation, self.interfaceOrientation);
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    MSLog(@"didRotateFromInterfaceOrientation   %d     %d", fromInterfaceOrientation, self.interfaceOrientation);
}

// Faster one-part variant, called from within a rotating animation block, for additional animations during rotation.
// A subclass may override this method, or the two-part variants below, but not both.
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    MSLog(@"willAnimateRotationToInterfaceOrientation   %d     %d", toInterfaceOrientation, self.interfaceOrientation);
}

- (UIViewController *)selectedViewController
{
    return [_cttabbar selectedController];
}
- (UIViewController *)targetController:(int)theIndex
{
    return [_cttabbar targetController:theIndex];
}

- (NSInteger)selectedIndex
{
    return [_cttabbar selectedIndex];
}

- (void)setSelectedIndex:(NSInteger)theIndex
{
    [_cttabbar setSelectedIndex:theIndex];
}

- (IBAction)hideMore:(id)sender
{
    popView.alpha = 0.0;
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0.0];
    opacityAnimation.removedOnCompletion = YES;
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:opacityAnimation,nil];
    animationgroup.duration = 0.5f;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.delegate = self;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:
                                     kCAMediaTimingFunctionLinear];
    animationgroup.removedOnCompletion = NO;
    
    [popView.layer addAnimation:animationgroup forKey:@"hide"];
}

- (void)animationDidStop:(CAAnimation *)anim
                finished:(BOOL)flag
{
    if (anim == [popView.layer animationForKey:@"show"]) {
        [popView.layer removeAnimationForKey:@"show"];
    } else if (anim == [popView.layer animationForKey:@"hide"]) {
        [popView removeFromSuperview];
        [popView.layer removeAnimationForKey:@"hide"];
    }
}

#pragma mark - CTTabbarControl Delegate
- (UIView *)superView:(CTTabbarControl *)tabbar
{
    return self.view;
}

- (NSString *)xibName:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex
{
    if (IS_IPAD) {
        if (theIndex == 0) {
            return @"MainViewController";
        } else if (theIndex == 1) {
            return @"MoreAppsControllerViewController";
        } else if (theIndex == 2) {
            return @"MoreController";
        } else {
            return nil;
        }
    } else {
        if (theIndex == 0) {
            return @"MainViewController";
        } else if (theIndex == 1) {
            return @"MoreAppsControllerViewController";
        } else if (theIndex == 2) {
            return @"MoreController";
        } else {
            return nil;
        }
    }
}

- (BOOL)isNavigation:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex
{
    return YES;
}

- (UIImage *)tabbarBgImage:(CTTabbarControl *)tabbar
{
    UIImage *image = [UIImage retina4ImageNamed:@"bottomBarBackground.png"];
    return [image stretchableImageWithLeftCapWidth:image.size.width / 2 topCapHeight:image.size.height / 2];
}

- (CGRect)tabbarButtonRect:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex
{
    if (IS_IPAD) {
        if (theIndex == 0) {
            return CGRectMake(0, 116, 61, 75);
        } else if (theIndex == 1) {
            return CGRectMake(0, 219, 61, 75);
        } else {
            return CGRectMake(0, 561, 61, 75);
        }
    } else {
        if (theIndex == 0) {
            return CGRectMake(0, 0, 107, 44);
        } else if (theIndex == 1) {
            return CGRectMake(107, 0, 106, 44);
        } else {
            return CGRectMake(213, 0, 107, 44);
        }
    }
}

- (NSString *)tabbarItemTitle:(CTTabbarControl *)tabbar
                      atIndex:(NSInteger)theIndex
{
    if (IS_IPAD) {
        if (theIndex == 0) {
            return NSLocalizedString(@"Book name", nil);
        } else if (theIndex == 1) {
            return NSLocalizedString(@"More cartoon", nil);
        } else if (theIndex == 2) {
            return NSLocalizedString(@"更 多", nil);
        } else {
            return nil;
        }
    } else {
        if (theIndex == 0) {
            return NSLocalizedString(@"Book name", nil);
        } else if (theIndex == 1) {
            return NSLocalizedString(@"More cartoon", nil);
        } else if (theIndex == 2) {
            return NSLocalizedString(@"更 多", nil);
        } else {
            return nil;
        }
    }
}

- (UIColor *)tabbarItemTitleColorNormal:(CTTabbarControl *)tabbar
                                atIndex:(NSInteger)theIndex
{
    return [UIColor purpleColor];
}

- (UIColor *)tabbarItemTitleColorSelected:(CTTabbarControl *)tabbar
                                  atIndex:(NSInteger)theIndex
{
    return [UIColor yellowColor];
}

- (UIFont *)tabbarItemTitleFont:(CTTabbarControl *)tabbar
                        atIndex:(NSInteger)theIndex
{
    return [UIFont boldSystemFontOfSize:11.0];
}

- (UIImage *)tabbarItemIcon:(CTTabbarControl *)tabbar
                    atIndex:(NSInteger)theIndex
{
    if (IS_IPAD) {
        if (theIndex == 0) {
            return [UIImage retina4ImageNamed:@"TabComic.png"];
        } else if (theIndex == 1) {
            return [UIImage retina4ImageNamed:@"TabRecommend.png"];
        } else if (theIndex == 2) {
            return [UIImage retina4ImageNamed:@"TabMore.png"];
        } else {
            return nil;
        }
    } else {
        if (theIndex == 0) {
            return [UIImage retina4ImageNamed:@"TabComic.png"];
        } else if (theIndex == 1) {
            return [UIImage retina4ImageNamed:@"TabRecommend.png"];
        } else if (theIndex == 2) {
            return [UIImage retina4ImageNamed:@"TabMore.png"];
        } else {
            return nil;
        }
    }
}

- (UIImage *)tabbarItemIconHighlight:(CTTabbarControl *)tabbar
                             atIndex:(NSInteger)theIndex
{
    return nil;
}

- (UIImage *)tabbarItemIconSelected:(CTTabbarControl *)tabbar
                            atIndex:(NSInteger)theIndex
{
    if (IS_IPAD) {
        if (theIndex == 0) {
            return [UIImage retina4ImageNamed:@"TabComic_select.png"];
        } else if (theIndex == 1) {
            return [UIImage retina4ImageNamed:@"TabRecommend_select.png"];
        } else if (theIndex == 2) {
            return [UIImage retina4ImageNamed:@"TabMore_select.png"];
        } else {
            return nil;
        }
    } else {
        if (theIndex == 0) {
            return [UIImage retina4ImageNamed:@"TabComic_select.png"];
        } else if (theIndex == 1) {
            return [UIImage retina4ImageNamed:@"TabRecommend_select.png"];
        } else if (theIndex == 2) {
            return [UIImage retina4ImageNamed:@"TabMore_select.png"];
        } else {
            return nil;
        }
    }
}

- (BOOL)canselect:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex
{
    if (IS_IPAD && theIndex == 3) {
        AppDelegate *delegate = [AppDelegate theAppDelegate];
        if (popView == nil) {
            popView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 1024, 748)];
            popView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
        }
        MoreController *more = [[MoreController alloc] initWithNibName:@"MoreController" bundle:nil];
        
        popNavi = [[[NSBundle mainBundle] loadNibNamed:@"CustomNavigationController" owner:self options:nil] objectAtIndex:0];
        [popNavi pushViewController:more animated:NO];
        [(CustomNavigationBar *)popNavi.navigationBar setBackgroundWith:[UIImage retina4ImageNamed:@"moreNaviBg.png"]];
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setBackgroundImage:[[UIImage retina4ImageNamed:@"button2.png"] stretchableImageWithLeftCapWidth:14.0 topCapHeight:15.0] forState:UIControlStateNormal];
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
        backButton.frame = CGRectMake(0, 0, 56, 30);
        [(CustomNavigationBar *)more.navigationController.navigationBar setText:NSLocalizedString(@"关闭", nil)
                                                                   onBackButton:backButton leftCapWidth:10.0];
        [backButton addTarget:self action:@selector(hideMore:) forControlEvents:UIControlEventTouchUpInside];
        more.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        popNavi.view.tag = 100001;
        UIView *naviView = [popView viewWithTag:100001];
        if (naviView != nil) {
            [naviView removeFromSuperview];
        }
        [popView addSubview:popNavi.view];
        popNavi.view.layer.cornerRadius = 5.0;
        popNavi.view.layer.masksToBounds = YES;
        popNavi.view.backgroundColor = [UIColor clearColor];
        popNavi.navigationBar.backgroundColor = [UIColor clearColor];
        [delegate.appRootController.view addSubview:popView];
        popNavi.view.frame = CGRectMake((1024 - 544) / 2, (748 - 600) / 2, 544, 600);
        popNavi.navigationBar.frame = CGRectMake(0, 0, CGRectGetWidth(popNavi.navigationBar.frame), CGRectGetHeight(popNavi.navigationBar.frame));
        popView.alpha = 1.0;
        
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = [NSNumber numberWithFloat:0.0];
        opacityAnimation.toValue = [NSNumber numberWithFloat:1.0];
        opacityAnimation.removedOnCompletion = YES;
        
        CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
        animationgroup.animations = [NSArray arrayWithObjects:opacityAnimation,nil];
        animationgroup.duration = 0.5f;
        animationgroup.fillMode = kCAFillModeForwards;
        animationgroup.delegate = self;
        animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:
                                         kCAMediaTimingFunctionLinear];
        animationgroup.removedOnCompletion = NO;
        
        [popView.layer addAnimation:animationgroup forKey:@"show"];
        return NO;
    }
    return YES;
}

- (void)willSelect:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex
{
    if ([self targetController:0] != (UIViewController *)[NSNull null]) {
//        NSArray *viewControllers = ((UINavigationController*) [self targetController:0]).viewControllers;
        // 判断第一个tab里的viewcontroller是否是hotpagecontroller
        // 如果不是的话不隐藏navigationbar
//        if (((UINavigationController*) [self targetController:0]).topViewController.class == [HotPageController class]) {
//            [(HotPageController*) [viewControllers objectAtIndex:0] setHideNavigationBar:TRUE];
//
//            [((UINavigationController*) [self targetController:0]) setNavigationBarHidden:TRUE];
//        }
//        if (theIndex == 0 && ((UINavigationController*) [self targetController:0]).topViewController.class == [CityViewController class]) {
//            // 选择的首页,同时正在选择城市,把城市隐藏掉
//            [((UINavigationController*) [self targetController:0]) popToRootViewControllerAnimated:FALSE];            
//            [((UINavigationController*) [self targetController:0]) setNavigationBarHidden:TRUE];
//        }
    }
    if (IS_IPAD) {
        switch (theIndex) {
            case 0:
            {
                [MobClick event:@"Tab页面" attributes:[NSDictionary dictionaryWithObject:@"iPad_点击漫画页面" forKey:UM_LabelName]];
            }
                break;
            case 1:
            {
                [MobClick event:@"Tab页面" attributes:[NSDictionary dictionaryWithObject:@"iPad_点击推荐页面" forKey:UM_LabelName]];
            }
                break;
            case 2:
            {
                [MobClick event:@"Tab页面" attributes:[NSDictionary dictionaryWithObject:@"iPad_点击更多页面" forKey:UM_LabelName]];
            }
                break;
            default:
                break;
        }
    } else {
        switch (theIndex) {
            case 0:
            {
                [MobClick event:@"Tab页面" attributes:[NSDictionary dictionaryWithObject:@"iPhone_点击漫画页面" forKey:UM_LabelName]];
            }
                break;
            case 1:
            {
                [MobClick event:@"Tab页面" attributes:[NSDictionary dictionaryWithObject:@"iPhone_点击推荐页面" forKey:UM_LabelName]];
            }
                break;
            case 2:
            {
                [MobClick event:@"Tab页面" attributes:[NSDictionary dictionaryWithObject:@"iPhone_点击更多页面" forKey:UM_LabelName]];
            }
                break;
            default:
                break;
        }
    }
}

- (void)selectDone:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex
{
    if (IS_IPAD && theIndex != 2) {
        if ([self targetController:theIndex] != (UIViewController *)[NSNull null]) {
            [((UINavigationController*) [self targetController:theIndex]) setNavigationBarHidden:YES];
        }
    }
}

- (UIImage *)arrowImage:(CTTabbarControl *)tabbar
{
    return nil;
}

- (CGFloat)realHeightMargin:(CTTabbarControl *)tabbar
{
    return 0;
}

- (UIEdgeInsets)titleInset:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex
{
    return UIEdgeInsetsMake(26, 0, 0, 0);
}

- (void)showAnimationDidStop
{
    _cttabbar.notShow = NO;
    tabbarHidden = NO;
}

- (void)hideAnimationDidStop
{
    tabbarHidden = YES;
}

- (void)showTabbar:(BOOL)leftToRight
{
    if (!tabbarHidden) {
        return;
    }
    if (leftToRight) {
        _cttabbar.frame = CGRectMake(-CGRectGetWidth(self.view.frame), _cttabbar.frame.origin.y, _cttabbar.frame.size.width, _cttabbar.frame.size.height);
    } else {
        _cttabbar.frame = CGRectMake(CGRectGetWidth(self.view.frame), _cttabbar.frame.origin.y, _cttabbar.frame.size.width, _cttabbar.frame.size.height);
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDidStopSelector:@selector(showAnimationDidStop)];
    
    _cttabbar.frame = CGRectMake(0, _cttabbar.frame.origin.y, _cttabbar.frame.size.width, _cttabbar.frame.size.height);
    
    [UIView commitAnimations];
}

- (void)hideTabbar:(BOOL)rightToLeft
{
    if (tabbarHidden) {
        return;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.35];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDidStopSelector:@selector(hideAnimationDidStop)];
    
    if (rightToLeft) {
        [_cttabbar setFrame:CGRectMake(-CGRectGetWidth(self.view.frame), _cttabbar.frame.origin.y, _cttabbar.frame.size.width, _cttabbar.frame.size.height)];
    } else {
        [_cttabbar setFrame:CGRectMake(CGRectGetWidth(self.view.frame), _cttabbar.frame.origin.y, _cttabbar.frame.size.width, _cttabbar.frame.size.height)];
    }
    
    [UIView commitAnimations];
    
    _cttabbar.notShow = YES;
}

- (void)resetTabbar
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.appRootController dismissModalViewControllerAnimated:NO];
    for (int ii = 0; ii < _cttabbar.tabCount; ii++) {
        [_cttabbar resetTab:ii];
    }
    [self showTabbar:YES];
    [self setSelectedIndex:0];
}

@end
