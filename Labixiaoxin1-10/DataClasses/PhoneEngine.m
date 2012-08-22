//
//  PhoneEngine.m
//  ThreeHundred
//
//  Created by 郭雪 on 11-11-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "PhoneEngine.h"
#import "AppDelegate.h"
#import <Foundation/Foundation.h>

@implementation PhoneEngine

static PhoneEngine * _sharedInstance = nil;

+ (PhoneEngine *)sharedInstance
{
	if ( _sharedInstance == nil ) {
		_sharedInstance = [[PhoneEngine alloc] init];
	}
	return _sharedInstance;
}

- (id)init
{
	self = [super init];
	return self;
}

- (BOOL)doesStringContain:(NSString*)string charactor:(NSString*)charcter
{
    for (int i=0; i<[string length]; i++) {
        NSString* chr = [string substringWithRange:NSMakeRange(i, 1)];
        if([chr isEqualToString:charcter])
            return TRUE;
    }
    return FALSE;
}

- (BOOL)dial:(NSString*)phoneNumber
{
    if (![[UIDevice currentDevice].model isEqualToString:@"iPhone"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unable to make phone call", @"")
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"\"%@\" can't use Phone app.", @""), [UIDevice currentDevice].model]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return FALSE;
    }
    
    if(phoneNumber && ![phoneNumber isEqualToString:@""]) {
        NSString* telNumber = @"";
        for (int i=0; i<[phoneNumber length]; i++) {
            NSString* chr = [phoneNumber substringWithRange:NSMakeRange(i, 1)];
            if([self doesStringContain:@"0123456789" charactor:chr]) {
                telNumber = [telNumber stringByAppendingFormat:@"%@", chr];
            }
        }
        telNumber = [NSString stringWithFormat:@"tel:%@", telNumber]; 
        [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:telNumber]];	
        return TRUE;
    }	
    return FALSE;
}

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	switch (result) {
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			break;
		case MFMailComposeResultFailed:
			break;
		default:
			break;
	}
    
    AppDelegate *delegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[delegate.appRootController dismissModalViewControllerAnimated:YES];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultFailed:
            break;
        case MessageComposeResultSent:            
            break;
        default:
            break;
    }
    if (presentedController) {
        [presentedController dismissModalViewControllerAnimated:YES];
        presentedController = nil;
    } else {
        AppDelegate *delegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.appRootController dismissModalViewControllerAnimated:YES];
    }
}

- (void)displayComposerSheet:(NSString*)recipient subject:(NSString*)subject content:(NSString*)content
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    if (recipient != nil) {
        [picker setToRecipients:[NSArray arrayWithObject:recipient]];
    }
	picker.title = subject;
	picker.mailComposeDelegate = self;
    [picker setSubject:subject];
	[picker setMessageBody:content isHTML:YES];
    AppDelegate *delegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[delegate.appRootController presentModalViewController:picker animated:YES];
}

- (void)launchMailAppOnDevice:(NSString*)recipient subject:(NSString*)subject content:(NSString*)content
{
	NSString *email = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", recipient ? recipient : @"", subject, content];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

- (void)showMail:(NSString*)recipient subject:(NSString*)subject content:(NSString*)content
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet:recipient subject:subject content:content];
        }
        else
        {
            [self launchMailAppOnDevice:recipient subject:subject content:content];
        }
    }
    else
    {
        [self launchMailAppOnDevice:recipient subject:subject content:content];
    }
}

- (BOOL)sendSMS:(NSString*)phoneNumber text:(NSString*)text
{
    if (![[UIDevice currentDevice].model isEqualToString:@"iPhone"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unable to send sms", @"")
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"\"%@\" can't use Message app.", @""), [UIDevice currentDevice].model]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return FALSE;
    }
    
    NSString* telNumber = @"";
    if(phoneNumber && ![phoneNumber isEqualToString:@""]) {
        for (int i=0; i<[phoneNumber length]; i++) {
            NSString* chr = [phoneNumber substringWithRange:NSMakeRange(i, 1)];
            if([self doesStringContain:@"0123456789" charactor:chr]) {
                telNumber = [telNumber stringByAppendingFormat:@"%@", chr];
            }
        }
    }
    
    Class newMessage = NSClassFromString(@"MFMessageComposeViewController");
    if (newMessage) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText])
        {
            controller.messageComposeDelegate = self;
            controller.recipients = [NSArray arrayWithObject:telNumber];
            controller.navigationBar.barStyle = UIBarStyleBlack;
            controller.body = text;
            AppDelegate *delegate= (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [delegate.appRootController presentModalViewController:controller animated:YES];
            return TRUE;
        }
    }
    return FALSE;    
}

- (BOOL)sendSMS:(NSString*)phoneNumber text:(NSString*)text inController:(UIViewController *)theController
{
    if (![[UIDevice currentDevice].model isEqualToString:@"iPhone"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unable to send sms", @"")
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"\"%@\" can't use Message app.", @""), [UIDevice currentDevice].model]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return FALSE;
    }
    
    NSString* telNumber = @"";
    if(phoneNumber && ![phoneNumber isEqualToString:@""]) {
        for (int i=0; i<[phoneNumber length]; i++) {
            NSString* chr = [phoneNumber substringWithRange:NSMakeRange(i, 1)];
            if([self doesStringContain:@"0123456789" charactor:chr]) {
                telNumber = [telNumber stringByAppendingFormat:@"%@", chr];
            }
        }
    }
    
    Class newMessage = NSClassFromString(@"MFMessageComposeViewController");
    if (newMessage) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText])
        {
            controller.messageComposeDelegate = self;
            controller.recipients = [NSArray arrayWithObject:telNumber];
            controller.navigationBar.barStyle = UIBarStyleBlack;
            controller.body = text;
            presentedController = theController;
            [presentedController presentModalViewController:controller animated:YES];
            return TRUE;
        }
    }
    return FALSE;    
}

@end
