//
//  AppDelegate.m
//  Labixiaoxin1-5
//
//  Created by 晋辉 卫 on 5/1/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "DataEngine.h"
#import "RIButtonItem.h"
#import "UIAlertView+Blocks.h"
#import "Constants.h"
#import "Book.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize appRootController = _appRootController;
@synthesize viewController = _viewController;
@synthesize guideView = _guideView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    /*
     if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
     SEL selector = NSSelectorFromString(@"setOrientation:");
     NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
     [invocation setSelector:selector];
     [invocation setTarget:[UIDevice currentDevice]];
     int val = UIInterfaceOrientationLandscapeRight;
     [invocation setArgument:&val atIndex:2];
     [invocation invoke];
     }
     */
    if (_controllerId == nil) {
        _controllerId = [NSString stringWithFormat:@"%p", self];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(completePurchaseResponse:)
                                                 name:VERIFY_PURCHASE_COMPLETE
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(restorePurchaseResponse:)
                                                 name:VERIFY_PURCHASE_RESTORE
                                               object:nil];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    application.statusBarStyle = UIStatusBarStyleBlackOpaque;
    DataEngine *dataEngine = [DataEngine sharedInstance];
    [dataEngine getNewBooks:nil];
    // Override point for customization after application launch.
    self.appRootController = [[[NSBundle mainBundle] loadNibNamed:@"CustomNavigationController" owner:self options:nil] objectAtIndex:0];
    self.viewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    [self.appRootController pushViewController:self.viewController animated:NO];
    self.window.rootViewController = self.appRootController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[DataEngine sharedInstance] saveSomething];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)adRemoved
{
    NSArray *products = [[NSUserDefaults standardUserDefaults] objectForKey:kPurchasedProducts];
    if ([products containsObject:REMOVE_AD_IDENTIFIER]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)recordTransaction:(NSString *)identifier
{
    if (identifier == nil || ![identifier isKindOfClass:[NSString class]] || identifier.length == 0) {
        return;
    }
    NSArray *products = [[NSUserDefaults standardUserDefaults] objectForKey:kPurchasedProducts];
    if ([products containsObject:identifier]) {
        return;
    } else {
        NSMutableArray *mutableProd = [NSMutableArray arrayWithArray:products];
        [mutableProd addObject:identifier];
        [[NSUserDefaults standardUserDefaults] setObject:mutableProd forKey:kPurchasedProducts];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)provideContent:(NSString *)identifier
{
    if (identifier == nil || ![identifier isKindOfClass:[NSString class]] || identifier.length == 0) {
        return;
    }
    if ([identifier isEqualToString:REMOVE_AD_IDENTIFIER]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRemoveAdInAppPurchaseChanged object:nil];
    }
}

- (void)completePurchaseResponse:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    if (![[dict objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_controllerId]) {
        return;
    }
    SKPaymentTransaction *transaction = [dict objectForKey:Transaction_Key];
    if (transaction && [transaction isKindOfClass:[SKPaymentTransaction class]]) {
        NSNumber *number = [dict objectForKey:@"status"];
        if (number && [number intValue] == 0) {
            [self completeTransaction:transaction];
        } else {
            [self failedTransaction:transaction];
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    // Your application should implement these two methods.
    [self recordTransaction:transaction.payment.productIdentifier];
    [self provideContent:transaction.payment.productIdentifier];
    
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"购买成功", nil) message:NSLocalizedString(@"广告已移除,请继续欣赏~~", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"I know", nil) otherButtonTitles:nil];
    [alertView show];
}

- (void)restorePurchaseResponse:(NSNotification *)notification
{
    NSDictionary *dict = notification.object;
    if (![[dict objectForKey:REQUEST_SOURCE_KEY] isEqualToString:_controllerId]) {
        return;
    }
    SKPaymentTransaction *transaction = [dict objectForKey:Transaction_Key];
    if (transaction && [transaction isKindOfClass:[SKPaymentTransaction class]]) {
        NSNumber *number = [dict objectForKey:@"status"];
        if (number && [number intValue] == 0) {
            [self completeTransaction:transaction];
        } else {
            [self failedTransaction:transaction];
        }
    }
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction.payment.productIdentifier];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"购买成功", nil) message:NSLocalizedString(@"广告已移除,请继续欣赏~~", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"I know", nil) otherButtonTitles:nil];
    [alertView show];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"抱歉", nil) message:NSLocalizedString(@"添加功能失败,可能是网络不给力喔～～", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"I know", nil) otherButtonTitles:nil];
        [alertView show];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                if (transaction.transactionReceipt && transaction.transactionReceipt.length > 0) {
                    [[DataEngine sharedInstance] verifyPurchaseComplete:transaction from:_controllerId];
                } else {
                    [self completeTransaction:transaction];
                }
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                if (transaction.transactionReceipt && transaction.transactionReceipt.length > 0) {
                    [[DataEngine sharedInstance] verifyPurchaseRestore:transaction from:_controllerId];
                } else {
                    [self restoreTransaction:transaction];
                }
            default:
                break;
        }
    }
}

- (BOOL)showUserGuide:(UIView *)inView
{
    BOOL userGuide = [[NSUserDefaults standardUserDefaults] boolForKey:@"UserGuide_v1.0.0"];
    if (!userGuide) {
        if (_guideView == nil) {
            _guideView = [[UserGuideView alloc] initWithDelegate:self];
        }
        [_guideView showGuide:kUserGuideTypeFirst withSuperView:inView];
    }
    return userGuide;
}

- (void)UserGuideFinished:(NSInteger)finishedType
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"UserGuide_v1.0.0"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.guideView = nil;
}

- (void)promptComment
{
    BOOL has = NO;
    for (Book *book in [DataEngine sharedInstance].books) {
        if ([book.bookId isEqualToString:BOOK_ID]) {
            has = YES;
            break;
        }
    }
    if (!has) {
        return;
    }
    BOOL commented = [[NSUserDefaults standardUserDefaults] boolForKey:@"commented"];
    NSInteger dissCommentCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"dissCommentCount"];
    if (commented || dissCommentCount >= 3) {
        return;
    } else {
        NSDate *lastDissDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastDissDate"];
        if (lastDissDate != nil) {
            NSDate *date = [NSDate date];
            NSTimeInterval interval = [date timeIntervalSinceDate:lastDissDate];
            if (interval <= 0) {
                [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"lastDissDate"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                return;
            } else if (interval < 172800) {
                return;
            }
        }
        NSDate *now = [NSDate date];
        [[NSUserDefaults standardUserDefaults] setObject:now forKey:@"lastDissDate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        RIButtonItem *cancelItem = [RIButtonItem item];
        cancelItem.label = NSLocalizedString(@"忍痛拒绝", nil);
        cancelItem.action = ^{
            [[NSUserDefaults standardUserDefaults] setInteger:dissCommentCount + 1 forKey:@"dissCommentCount"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        };
        
        RIButtonItem *okItem = [RIButtonItem item];
        okItem.label = NSLocalizedString(@"欢喜评分", nil);
        okItem.action = ^{
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"commented"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_RATING_URL]];
        };
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"如果喜欢就帮忙评价一下把～嘿嘿", nil)
                                                        message:nil
                                               cancelButtonItem:cancelItem
                                               otherButtonItems:okItem, nil];
        
        [alert show];
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if (response.products.count > 0) {
        SKProduct *selectedProduct = [response.products objectAtIndex:0];
        if (selectedProduct && [selectedProduct isKindOfClass:[SKProduct class]]) {
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
            SKPayment *payment = [SKPayment paymentWithProduct:selectedProduct];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
        }
    }
    // Populate your UI from the products list.
    // Save a reference to the products list.
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    if (error.code != SKErrorPaymentCancelled) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"抱歉", nil) message:NSLocalizedString(@"添加功能失败,可能是网络不给力喔～～", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"I know", nil) otherButtonTitles:nil];
        [alertView show];
    }
}

// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    BOOL purchased = NO;
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        NSString *productID = transaction.payment.productIdentifier;
        if (productID.length > 0 && [productID isEqualToString:REMOVE_AD_IDENTIFIER]) {
            purchased = YES;
            break;
        }
    }
    if (!purchased) {
        SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:REMOVE_AD_IDENTIFIER]];
        request.delegate = self;
        [request start];
    }
}

- (void)purchase
{
    if ([SKPaymentQueue canMakePayments]) {
        RIButtonItem *cancelItem = [RIButtonItem item];
        cancelItem.label = NSLocalizedString(@"取消", nil);
        cancelItem.action = ^{
        };
        
        RIButtonItem *buyItem = [RIButtonItem item];
        buyItem.label = NSLocalizedString(@"购买该功能", nil);
        buyItem.action = ^{
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
            [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
        };
        
        RIButtonItem *restoreItem = [RIButtonItem item];
        restoreItem.label = NSLocalizedString(@"恢复该功能", nil);
        restoreItem.action = ^{
            [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
            [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
        };
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"移除广告", nil)
                                                        message:nil
                                               cancelButtonItem:cancelItem
                                               otherButtonItems:buyItem, restoreItem, nil];
        
        [alert show];
    } else {
        //cann't purchase
    }
}
@end
