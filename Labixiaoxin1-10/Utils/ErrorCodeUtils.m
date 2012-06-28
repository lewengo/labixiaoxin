//
//  ErrorCodeUtils.m
//  Three Hundred
//
//  Created by 郭雪 on 11-8-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ErrorCodeUtils.h"

@implementation ErrorCodeUtils

+ (NSString*)errorDetailFromErrorCode:(int)errorCode dict:(NSDictionary *)dict
{
    NSString* errorDetail = nil;
    switch (errorCode) {
        case -1:
        case -3:
            errorDetail = NSLocalizedString(@"Something wrong with the request, updating your client may solve it.", @"");
            break;
        case -2:
            errorDetail = NSLocalizedString(@"It looks that you are not logged in.", @"");
            break;
        case 1600:
            errorDetail = NSLocalizedString(@"Sina Weibo access is restricted by user, try re-connect it on Sina Weibo web.", @"");
            break;
        case 1001:
            errorDetail = NSLocalizedString(@"Server is absent, please try again later.", @"");
            break;
        case 1002:
        case 1003:
            errorDetail = NSLocalizedString(@"Server can't understand you, are you coming from future?", @"");
            break;
        case 1201:
            errorDetail = NSLocalizedString(@"User ID or password is absent.", @"");
            break;
        case 1202:
            errorDetail = NSLocalizedString(@"Email format is not valid.", @"");
            break;
        case 1204:
            errorDetail = NSLocalizedString(@"Login failed, password is incorrect.", @"");
            break;
        case 1205:
            errorDetail = NSLocalizedString(@"Login failed, user is not exist.", @"");
            break;
        case 1206:
            errorDetail = NSLocalizedString(@"Login failed, user is not exist.", @"");
            break;
        case 1207:
            errorDetail = NSLocalizedString(@"User ID already exist, please try another.", @"");
            break;
        case 1203:
        case 1208:
            errorDetail = NSLocalizedString(@"Email already exist, please use another email.", @"");
            break;
        case 1300:
            errorDetail = NSLocalizedString(@"Taobao session expired", @"");
            break;
        case 1301:
            errorDetail = NSLocalizedString(@"Bind failed, something important lost.", @"");
            break;
        case 1302:
            errorDetail = NSLocalizedString(@"Not Bind taobao", @"");
            break;
        case -1001:
            errorDetail = NSLocalizedString(@"Request failed due to timeout, please check your Internet connection.", @"");
            break;
        case -1002:
            errorDetail = NSLocalizedString(@"Request failed, unsupported URL.", @"");
            break;
        case -1004:
            errorDetail = NSLocalizedString(@"Request failed, can’t connect to server.", @"");
            break;
        case -1009:
            errorDetail = NSLocalizedString(@"The Internet connection appears to be offline.", @"");
            break;
        case 404:
            errorDetail = NSLocalizedString(@"Server page not found.", @"");
            break;
        case 500:
            errorDetail = NSLocalizedString(@"There is something wrong with the server, please contact us.", @"");
            break;
        default:
            errorDetail = NSLocalizedString(@"Unknown error.", @"");
            break;
    }
    
    return errorDetail;
}

@end
