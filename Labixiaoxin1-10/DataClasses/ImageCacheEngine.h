//
//  ImageCacheEngine.h
//  Three Hundred
//
//  Created by skye on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImageCacheEngine : NSObject {
    BOOL hasRetinaDisplay;    
    NSString *documentDir;
	NSFileManager *fileManager;
}

+ (ImageCacheEngine *)sharedInstance;
- (ImageCacheEngine *)init;

// get image from disk.
- (NSString *)getIconImagePath:(NSString *)_id;

// store image to local storage.
- (NSString *)setIconImagePath:(NSData *)data forId:(NSString *)_id;

// clear local storage
- (void)removeAllImagesInLocal;

@end
