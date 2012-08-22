//
//  PhoneEngine.h
//  ThreeHundred
//
//  Created by 郭雪 on 11-11-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface PhoneEngine : NSObject <MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>
{
    UIViewController *presentedController;
}
+ (PhoneEngine *)sharedInstance;
- (void)showMail:(NSString*)recipient subject:(NSString*)subject content:(NSString*)content;
- (BOOL)dial:(NSString*)phoneNumber;
- (BOOL)sendSMS:(NSString*)phoneNumber text:(NSString*)text;
- (BOOL)sendSMS:(NSString*)phoneNumber text:(NSString*)text inController:(UIViewController *)theController;

@end
