//
//  Constants.h
//  Three Hundred
//
//  Created by skye on 8/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//#define TEST_SERVER 1

#define URL_REQUEST_TIMEOUT     120
#define REQUEST_SOURCE_KEY      @"_source"

#define GET_NEWBOOK_LIST        @"NewBookList"
#define REQUEST_DOWNLOADIMAGE   @"RequestDownloadImage"
#define DOWNLOAD_IMAGE_TYPE     @"DownloadImageType"
#define IMAGE_BOOKICON_TYPE     @"ImageBookIconType"
#define IMAGE_BOOKICON_ID       @"ImageBookIconId"

#define Transaction_Key         @"TransactionResponseKey"
#define VERIFY_PURCHASE_COMPLETE @"VerifyPurchaseComplete"
#define VERIFY_PURCHASE_RESTORE  @"VerifyPurchaseRestore"

#define kPurchasedProducts            @"PurchasedProducts"
#define kRemoveAdInAppPurchaseChanged @"RemoveAdInAppPurchaseChanged"
#define kBadgeCountChangeNotification @"BadgeCountChangeNotification"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

