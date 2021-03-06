//
//  DataEngine.m
//  Labixiaoxin1-5
//
//  Created by 晋辉 卫 on 5/1/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import "DataEngine.h"
#import "LocalSettings.h"
#import "HttpEngine.h"
#import "Constants.h"
#import "HTTPConstants.h"
#import "DeviceHardware.h"
#import "JsonUtils.h"
#import "Book.h"
#import "ImageCacheEngine.h"
#import "GTMBase64.h"
#import "AdTypes.h"

#define NOTIFICATION_NAME   @"NotificationName"
#define REQUEST_IMAGE_URL   @"RequestImageRealUrl"

#define REQUEST_ADTYPE_URL  @"http://comiclover.sinaapp.com/adType.php"

#ifdef TEST_SERVER
#define REQUEST_URL         @"http://testcomiclover.sinaapp.com/books.php"
#else
#define REQUEST_URL         @"http://comiclover.sinaapp.com/books.php"
#endif
#define REQUEST_IMAGE_PREURL       @"http://comiclover-comicimages.stor.sinaapp.com/appIcons/"

static DataEngine *dataEngineInstance = nil;

@interface DataEngine ()

- (void)requestFaild:(NSError *)error with:(NSString *)identifier;

- (void)newBooksReceived:(NSDictionary *)dictionary with:(NSString *)identifier;

- (void)bookIconReceived:(NSDictionary *)dictionary with:(NSString *)identifier;

- (void)callBack:(NSDictionary *)dict 
      forRequest:(NSString *)identifier;
@end

@implementation DataEngine
@synthesize currentVolumId = _currentVolumId;
@synthesize volumsStatus = _volumsStatus;
@synthesize books = _books;
@synthesize adType = _adType;
@synthesize adTypes = _adTypes;

+ (DataEngine *)sharedInstance
{
    if (dataEngineInstance == nil) {
        dataEngineInstance = [[DataEngine alloc] init];
    }
    return dataEngineInstance;
}

- (id)init
{
    if (self = [super init]) {
        self.weibo = [[SinaWeibo alloc] initWithAppKey:Sina_AppKey
                                             appSecret:Sina_AppSecret
                                        appRedirectURI:Sina_AppRedirectURI
                                     ssoCallbackScheme:Oauth_Scheme_Weibo
                                           andDelegate:self];
        
        self.currentVolumId = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentVolumId"];
        self.volumsStatus = [NSMutableDictionary dictionaryWithDictionary:[LocalSettings loadVolumsStatus]];
        self.books = [NSMutableArray arrayWithArray:[LocalSettings loadBooks]];
        self.adType = [[LocalSettings loadAdType] integerValue];
        self.adTypes = [LocalSettings loadAdTypes];
        if (self.adTypes == nil) {
            self.adTypes = [[AdTypes alloc] init];
            self.adTypes.prime = [NSNumber numberWithInteger:0];
            self.adTypes.secondary = [NSNumber numberWithInteger:1];
        }
        hasRetinaDisplay = [[UIDevice currentDevice] hasRetinaDisplay];
        if (hasRetinaDisplay) {
            imageExtension = @"_2x";
        }
        else {
            imageExtension = @"";
        }
        sourceDict = [NSMutableDictionary dictionaryWithCapacity:5];
        httpEngine = [[HttpEngine alloc] init];
        [self getAdType];
    }
    return self;
}

- (void)saveVolumsStatus
{
    [LocalSettings saveVolumsStatus:self.volumsStatus];
}

- (void)saveCurrentVolum:(NSInteger)index
{
    self.currentVolumId = [NSNumber numberWithInt:index];
    [[NSUserDefaults standardUserDefaults] setObject:self.currentVolumId forKey:@"currentVolumId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (VolumStatus *)getVolumStatus:(NSInteger)index
{
    VolumStatus *status = [self.volumsStatus objectForKey:[NSNumber numberWithInt:index]];
    if (status == nil) {
        status = [[VolumStatus alloc] init];
        status.volumId = [NSNumber numberWithInt:index];
        status.index = 0;
        [self.volumsStatus setObject:status forKey:status.volumId];
        [self saveVolumsStatus];
    }
    return status;
}

- (void)requestFaild:(NSError *)error with:(NSString *)identifier
{
#ifdef DEBUG
    NSLog(@"requestFaild : %@", error);
#endif
    NSDictionary *targetDict = [sourceDict objectForKey:identifier];
    if (targetDict != nil) {
		NSString *name = [targetDict objectForKey:NOTIFICATION_NAME];
        if (name != nil) {
            NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithDictionary:targetDict];
            [tmpDict setObject:[NSNumber numberWithInt:[error code]] forKey:RETURN_CODE];
            [tmpDict addEntriesFromDictionary:targetDict];
            [[NSNotificationCenter defaultCenter] postNotificationName:name object:tmpDict];
		}
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"network_error" object:error];
    }
    
    [sourceDict removeObjectForKey:identifier];
}

- (void)callBack:(NSDictionary *)dict forRequest:(NSString *)identifier
{
    NSDictionary *targetDict = [sourceDict objectForKey:identifier];
    if (targetDict != nil) {
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
        [tmpDict addEntriesFromDictionary:targetDict];
        
        NSString *source = [targetDict objectForKey:REQUEST_SOURCE_KEY];
        if (source != nil && [source length] > 0) {
			[tmpDict setObject:source forKey:REQUEST_SOURCE_KEY];
		}
		
		NSString *name = [targetDict objectForKey:NOTIFICATION_NAME];
        if (name != nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:name object:tmpDict];	
		}
    }
    
    [sourceDict removeObjectForKey:identifier];
}

- (void)newBooksReceived:(NSDictionary *)dictionary with:(NSString *)identifier
{
    NSData *data = [dictionary objectForKey:@"data"];
    NSArray *dict = [JsonUtils JSONObjectWithData:data];
    NSMutableArray *currentList = [NSMutableArray arrayWithCapacity:5];
    if (dict && [dict isKindOfClass:[NSArray class]]) {
        NSInteger notHasBook = 0;
        NSInteger newBook = 0;
        for (NSDictionary *bookDic in dict) {
            NSString *bookId = [bookDic objectForKey:@"id"];
            BOOL has = NO;
            for (Book *book in self.books) {
                if ([book.bookId isEqualToString:bookId]) {
                    has = YES;
                    break;
                }
            }
            Book *book = [[Book alloc] init];
            book.bookId = bookId;
            book.bookName = [bookDic objectForKey:@"name"];
            book.bookUrl = [bookDic objectForKey:@"itunes"];
            book.bookIcon = [bookDic objectForKey:@"icon"];
            book.bookPrice = [bookDic objectForKey:@"price"];
            book.publishTime = [bookDic objectForKey:@"posttime"];
            book.isNew = [[bookDic objectForKey:@"isnew"] boolValue];
            [currentList addObject:book];
            
            if (!has && ![bookId isEqualToString:BOOK_ID]) {
                if (book.isNew) {
                    newBook ++;
                } else {
                    notHasBook ++;
                }
            }
        }
        NSInteger preBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;
        if (self.books.count == 0) {
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            notHasBook = 0;
        }
        [UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + newBook + notHasBook;
        if (preBadgeNumber != [UIApplication sharedApplication].applicationIconBadgeNumber) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kBadgeCountChangeNotification object:nil];
        }
    }
    self.books = currentList;
    [LocalSettings saveBooks:self.books];
    if (dict && [dict isKindOfClass:[NSArray class]]) {
        [self callBack:[NSDictionary dictionaryWithObject:dict forKey:@"books"] forRequest:identifier];
    } else {
        [self callBack:nil forRequest:identifier];
    }
}

- (void)getNewBooks:(NSString *)source
{
    NSString *identifier = [httpEngine doHttpGet:REQUEST_URL
                                         timeOut:URL_REQUEST_TIMEOUT
                                          header:nil
                                           error:^(NSError *error, NSString *identifier) {
                                               [self requestFaild:error with:identifier];
                                           }
                                        complete:^(NSDictionary *dictionary, NSString *identifier) {
                                            [self newBooksReceived:dictionary with:identifier];
                                        }];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          GET_NEWBOOK_LIST,        NOTIFICATION_NAME,
                          source,                   REQUEST_SOURCE_KEY,
                          nil];
    [sourceDict setObject:dict forKey:identifier];
}

- (void)bookIconReceived:(NSDictionary *)dictionary with:(NSString *)identifier
{
    NSData *imageData = [dictionary objectForKey:@"data"]; 
    
    NSDictionary *targetDict = [sourceDict objectForKey:identifier];
    if (targetDict != nil) {
		NSString *name = [targetDict objectForKey:NOTIFICATION_NAME];
		NSString *source = [targetDict objectForKey:REQUEST_SOURCE_KEY];
        NSString *imageId = [targetDict objectForKey:IMAGE_BOOKICON_ID];
        NSString *type = [targetDict objectForKey:DOWNLOAD_IMAGE_TYPE];
        
        NSString *imagePath = nil;
        if (type == nil) {
            return;
        }
        
        //保存下载的图片
        if ([type isEqualToString:IMAGE_BOOKICON_TYPE]) {
            imagePath = [[ImageCacheEngine sharedInstance] setIconImagePath:imageData forId:imageId];
        }
        NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] init];
		if (source != nil) {
			[tmpDict setObject:source forKey:REQUEST_SOURCE_KEY];
            if (imagePath) {
                [tmpDict setObject:imagePath forKey:@"imagepath"];
            }
            [tmpDict setObject:imageId forKey:@"imageid"];
            [tmpDict setObject:type forKey:DOWNLOAD_IMAGE_TYPE];
		}
		
        if (name != nil) {
            [[NSNotificationCenter defaultCenter] postNotificationName:name object:tmpDict];	
		} 
    }
    
    [sourceDict removeObjectForKey:identifier];
}

- (void)downloadBookIcon:(NSString *)icon withSource:(NSString *)source
{
    if (icon && icon.length > 0) {
        NSString *imageUrl = [NSString stringWithFormat:@"%@%@%@.png", REQUEST_IMAGE_PREURL, icon, imageExtension];
        for (NSString *key in sourceDict) {
            NSDictionary *dict = [sourceDict objectForKey:key];
            NSString *imageRealUrl = [dict objectForKey:REQUEST_IMAGE_URL];
            if ([imageUrl isEqualToString:imageRealUrl]) {
                return;
            }
        }
        NSString *identifier = [httpEngine doHttpGet:imageUrl
                                             timeOut:URL_REQUEST_TIMEOUT
                                              header:nil
                                               error:^(NSError *error, NSString *identifier) {
                                                   [self requestFaild:error with:identifier];
                                               }
                                            complete:^(NSDictionary *dictionary, NSString *identifier) {
                                                [self bookIconReceived:dictionary with:identifier];
                                            }];
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              REQUEST_DOWNLOADIMAGE, NOTIFICATION_NAME,
                              source,                REQUEST_SOURCE_KEY,
                              imageUrl,              REQUEST_IMAGE_URL,
                              IMAGE_BOOKICON_TYPE,   DOWNLOAD_IMAGE_TYPE,
                              icon,                  IMAGE_BOOKICON_ID,
                              nil];
        [sourceDict setObject:dict forKey:identifier];
    }
}

- (void)adTypeReceived:(NSDictionary *)dictionary
                  with:(NSString *)identifier
{
    NSData *data = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:data];
    NSNumber *type = [dict objectForKey:@"adType"];
    if ([type isKindOfClass:[NSNumber class]]) {
        self.adType = type.integerValue;
    } else {
        self.adType = 0;
    }
//    self.adType = 1;
    NSNumber *prime = [dict objectForKey:@"primeType"];
    if ([prime isKindOfClass:[NSNumber class]]) {
        self.adTypes.prime = prime;
    }
    
    NSNumber *secondary = [dict objectForKey:@"secondaryType"];
    if ([secondary isKindOfClass:[NSNumber class]]) {
        self.adTypes.secondary = secondary;
    }
    [LocalSettings saveAdTypes:self.adTypes];
    [LocalSettings saveAdType:[NSNumber numberWithInteger:self.adType]];
}

- (void)getAdType
{
    NSString *identifier = [httpEngine doHttpGet:REQUEST_ADTYPE_URL
                                         timeOut:URL_REQUEST_TIMEOUT
                                          header:nil
                                           error:^(NSError *error, NSString *identifier) {
                                               [self requestFaild:error with:identifier];
                                           }
                                        complete:^(NSDictionary *dictionary, NSString *identifier) {
                                            [self adTypeReceived:dictionary with:identifier];
                                        }];
    NSDictionary *dict = [NSDictionary dictionary];
    [sourceDict setObject:dict forKey:identifier];
}

- (void)verifyPurchaseCompleteReceived:(NSDictionary *)dictionary with:(NSString *)identifier
{
    NSData *data = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:data];
    [self callBack:dict forRequest:identifier];
}

- (void)verifyPurchaseComplete:(SKPaymentTransaction *)receipt from:(NSString *)from
{
    NSString *receiptString = [GTMBase64 stringByEncodingData:receipt.transactionReceipt];
    NSDictionary *receiptData = [NSDictionary dictionaryWithObject:receiptString forKey:@"receipt-data"];
    NSString *body = [JsonUtils DataWithJSONObject:receiptData];
    NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *identifier = [httpEngine doHttpPost:@"https://buy.itunes.apple.com/verifyReceipt"
                                          timeOut:URL_REQUEST_TIMEOUT
                                           header:nil
                                    notParamsBody:bodyData
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self verifyPurchaseCompleteReceived:dictionary with:identifier];
                                         }];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          VERIFY_PURCHASE_COMPLETE, NOTIFICATION_NAME,
                          from, REQUEST_SOURCE_KEY,
                          receipt, Transaction_Key,
                          nil];
    [sourceDict setObject:dict forKey:identifier];
}

- (void)verifyPurchaseRestoreReceived:(NSDictionary *)dictionary with:(NSString *)identifier
{
    NSData *data = [dictionary objectForKey:@"data"];
    NSDictionary *dict = [JsonUtils JSONObjectWithData:data];
    [self callBack:dict forRequest:identifier];
}

- (void)verifyPurchaseRestore:(SKPaymentTransaction *)receipt from:(NSString *)from
{
    NSString *receiptString = [GTMBase64 stringByEncodingData:receipt.transactionReceipt];
    NSDictionary *receiptData = [NSDictionary dictionaryWithObject:receiptString forKey:@"receipt-data"];
    NSString *body = [JsonUtils DataWithJSONObject:receiptData];
    NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *identifier = [httpEngine doHttpPost:@"https://buy.itunes.apple.com/verifyReceipt"
                                          timeOut:URL_REQUEST_TIMEOUT
                                           header:nil
                                    notParamsBody:bodyData
                                            error:^(NSError *error, NSString *identifier) {
                                                [self requestFaild:error with:identifier];
                                            }
                                         complete:^(NSDictionary *dictionary, NSString *identifier) {
                                             [self verifyPurchaseRestoreReceived:dictionary with:identifier];
                                         }];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          VERIFY_PURCHASE_RESTORE, NOTIFICATION_NAME,
                          from, REQUEST_SOURCE_KEY,
                          receipt, Transaction_Key,
                          nil];
    [sourceDict setObject:dict forKey:identifier];
}

- (void)saveSomething
{
    [LocalSettings saveBooks:self.books];
    [LocalSettings saveVolumsStatus:self.volumsStatus];
    
}

#pragma mark - SinaWeiboDelegate delegate
- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
//    Oauth *oauth = [CoreDataHelper getOauthByOauthType:OpenPlatformTypeWeibo];
//    if (oauth == nil) {
//        oauth = [NSEntityDescription insertNewObjectForEntityForName:kEntities_Oauth
//                                              inManagedObjectContext:[CoreDataEngine objectContext]];
//        oauth.oauth_type = [NSNumber numberWithInteger:OpenPlatformTypeWeibo];
//    }
//    
//    oauth.oauth_uid = sinaweibo.userID;
//    oauth.oauth_token = sinaweibo.accessToken;
//    oauth.oauth_expireTime = sinaweibo.expirationDate;
//    [CoreDataHelper save:@"33"];
    
//    [self bindPlatform:OpenPlatformTypeWeibo
//       withPlatformUid:sinaweibo.userID
//     withPlatformToken:sinaweibo.accessToken
//       withExpiredTime:[sinaweibo.expirationDate timeIntervalSince1970]
//            withSource:nil];
//    [self followWUser:Zhuimanhua_WeiboId
//               source:nil];
//    if (![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:kUserDefaults_FirstShareWeibo, self.version]]) {
//        [self performSelector:@selector(shareLoginWeibo)
//                   withObject:nil
//                   afterDelay:10];
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:kUserDefaults_FirstShareWeibo, self.version]];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_OAUTH_WEIBO_BIND_SUCCESS
                                                        object:nil];
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    int a = 10;
    a ++;
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    int a = 10;
    a ++;
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo
logInDidFailWithError:(NSError *)error
{
    int a = 10;
    a ++;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_OAUTH_WEIBO_BIND_FAILED
                                                        object:error];
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo
accessTokenInvalidOrExpired:(NSError *)error
{
    int a = 10;
    a ++;
}
@end
