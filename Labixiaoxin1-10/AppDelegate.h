//
//  AppDelegate.h
//  Labixiaoxin1-5
//
//  Created by 晋辉 卫 on 5/1/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserGuideView.h"
#import "MBProgressHUD.h"

@class CustomTabbarViewController;
@class MainViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UserGuideFinishDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver, MBProgressHUDDelegate>
{
    NSString *_controllerId;
}

@property (nonatomic, assign) BOOL isIpad;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *appRootController;
@property (nonatomic, retain) CustomTabbarViewController *tabBarController;

@property (nonatomic, strong) UserGuideView *guideView;

+ (AppDelegate *)theAppDelegate;

- (BOOL)showUserGuide:(UIView *)inView;

//first show hud with text in view
- (void)showActivityView:(NSString *)text
                  inView:(UIView *)view;
//hide prevoiusly showed hud
- (void)hideActivityView:(UIView *)view;
//first showe hud with succeed text and image for time seconds in view
- (void)showFinishActivityView:(NSString *)text
                      interval:(NSTimeInterval)time
                        inView:(UIView *)view;
//first showe hud with failed text and image for time seconds in view
- (void)showFailedActivityView:(NSString *)text
                      interval:(NSTimeInterval)time
                        inView:(UIView *)view;

- (void)promptComment;
- (void)purchase;
- (BOOL)adRemoved;

- (void)presentModalViewController:(UIViewController *)rootViewController animated:(BOOL)animated;
@end
