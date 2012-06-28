//
//  DataEngine.h
//  Labixiaoxin1-5
//
//  Created by 晋辉 卫 on 5/1/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VolumStatus.h"

@class HttpEngine;

@interface DataEngine : NSObject
{
    BOOL hasRetinaDisplay;
    NSString *imageExtension;
    NSMutableDictionary *sourceDict;
    HttpEngine *httpEngine;
}

+ (DataEngine *)sharedInstance;

@property (copy, nonatomic) NSNumber *currentVolumId;
@property (strong, nonatomic) NSMutableDictionary *volumsStatus;
@property (strong, nonatomic) NSMutableArray *books;

- (NSInteger)volumImageCount:(NSNumber *)index;
- (void)saveVolumsStatus;
- (void)saveCurrentVolum:(NSInteger)index;

- (VolumStatus *)getVolumStatus:(NSInteger)index;

- (void)getNewBooks:(NSString *)source;
- (void)downloadBookIcon:(NSString *)icon withSource:(NSString *)source;

- (void)verifyPurchaseComplete:(SKPaymentTransaction *)receipt from:(NSString *)from;
- (void)verifyPurchaseRestore:(SKPaymentTransaction *)receipt from:(NSString *)from;

- (void)saveSomething;
@end
