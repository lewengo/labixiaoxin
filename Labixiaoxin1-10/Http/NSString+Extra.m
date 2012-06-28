//
//  NSString+Extra.m
//  Roosher
//
//  Created by shenjianguo on 10-9-27.
//  Copyright 2010 Roosher inc. All rights reserved.
//

#import "NSString+Extra.h"


@implementation NSString (Extra)


+ (NSString*)stringWithNewUUID {
    // Create a new UUID
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    
    // Get the string representation of the UUID
//    NSString *newUUID = [(NSString*)CFUUIDCreateString(nil, uuidObj) autorelease];
//    CFRelease(uuidObj);
//    return newUUID;
    
//    NSString *uuid = nil;
//    CFUUID theUUID = CFUUIDCreate(kCFAllocatorDefault);
//    if (theUUID) {
//        uuid = NSMakeCollectable(CFUUIDCreateString(kCFAllocatorDefault, theUUID);
//        CFRelease(theUUID);
//    }
                                 
    CFStringRef uuidString = CFUUIDCreateString(nil, uuidObj);
    NSString *result = (__bridge_transfer NSString *)CFStringCreateCopy( NULL, uuidString);
    CFRelease(uuidObj);
    CFRelease(uuidString);
    
//    return [result autorelease];
    
//    return [[NSProcessInfo processInfo] globallyUniqueString];
    return result;
}

- (NSString *)URLEncodedString {
    NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (__bridge CFStringRef)self,
                                                                           NULL,
																		   CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);
//    [result autorelease];
	return result;
}

- (NSString*)URLDecodedString {
	NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (__bridge CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8);
//    [result autorelease];
	return result;	
}

//字符串转换为:距离目前时间的间隔
- (NSString *)stringToTimeInterval {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    NSDate *date = [formatter dateFromString:self];
	NSTimeInterval timeInterval = [date timeIntervalSinceNow];
	NSInteger minute = fabs(timeInterval / 60);
	
	if (minute == 0) {
		
		return [NSString stringWithFormat:NSLocalizedString(@"%d mins ago",nil), 1];
		
	}else if (minute >= 60) {
		
		NSInteger hour = (minute / 60);
		
		if (hour >= 24) {
			//NSInteger day = (hour / 24);
			//return [NSString stringWithFormat:NSLocalizedString(@"%d days ago",nil), day];
			NSRange range = {5,11};
			return [[date description] substringWithRange:range];
		}else {
			return [NSString stringWithFormat:NSLocalizedString(@"%d hours ago",nil), hour];
		}	
	}else {
		return [NSString stringWithFormat:NSLocalizedString(@"%d mins ago",nil), minute];
	}
}

//字符串转换为TimeInterval
- (NSString *)stringToDateTimeInterval {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	NSDate *date = [formatter dateFromString:self];
	NSTimeInterval timeInterval = [date timeIntervalSince1970];
	
	return [NSString stringWithFormat:@"%d", (NSInteger)timeInterval];
}

@end
