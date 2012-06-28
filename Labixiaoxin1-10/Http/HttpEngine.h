//
//  HttpEngine.h
//  TestAsiHttp
//
//  Created by shenjianguo on 10-9-26.
//  Copyright 2010 Roosher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpRequest.h"


@interface HttpEngine : NSObject 
{
    dispatch_queue_t serialQueue;
}

// Constructors
+ (HttpEngine *)createHttpEngine;
- (HttpEngine *)init;

- (void) suspend;
- (void) resume;
- (void) removeAllOperations;

- (NSString *)doHttpPost:(NSString *)url 
                 timeOut:(NSInteger)timeOut 
                  header:(NSDictionary *)headerField 
                    body:(NSDictionary *)body
                   error:(HttpErrorHandler)errorHandler
                complete:(HttpCompleteHandler)completeHandler;

- (NSString *)doHttpPost:(NSString *)url 
                 timeOut:(NSInteger)timeOut 
                  header:(NSDictionary *)headerField
           notParamsBody:(NSData *)body
                   error:(HttpErrorHandler)errorHandler
                complete:(HttpCompleteHandler)completeHandler;

- (NSString *)doHttpGet:(NSString *)url
                timeOut:(NSInteger)timeOut
                 header:(NSDictionary *)headerField
                  error:(HttpErrorHandler)errorHandler
               complete:(HttpCompleteHandler)completeHandler;

- (NSString *)doHttpGet:(NSString *)url
                timeOut:(NSInteger)timeOut
                 header:(NSDictionary *)headerField
                   body:(NSDictionary *)body
                  error:(HttpErrorHandler)errorHandler
               complete:(HttpCompleteHandler)completeHandler;

- (NSString *)doUploadImage:(NSString *)url
                    timeOut:(NSInteger)timeOut
                     params:(NSDictionary *)params
                 uploadData:(NSDictionary *)uploadData
                      error:(HttpErrorHandler)errorHandler
                   complete:(HttpCompleteHandler)completeHandler;

@end
