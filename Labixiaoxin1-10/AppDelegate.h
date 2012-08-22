//
//  AppDelegate.h
//  Labixiaoxin1-5
//
//  Created by 晋辉 卫 on 5/1/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserGuideView.h"

@class MainViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UserGuideFinishDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    NSString *_controllerId;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *appRootController;
@property (strong, nonatomic) MainViewController *viewController;

@property (nonatomic, strong) UserGuideView *guideView;
- (BOOL)showUserGuide:(UIView *)inView;

- (void)promptComment;
- (void)purchase;
- (BOOL)adRemoved;
@end
