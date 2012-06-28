//
//  ImageCacheEngine.m
//  Three Hundred
//
//  Created by skye on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageCacheEngine.h"
#import "NSString+MD5.h"

#define kIconImagePath              @"icon"

static ImageCacheEngine *_imageEngine = nil;

@interface ImageCacheEngine (Private)

- (void)createDirectory;

// store image to local storage
- (NSString *)storeImagetoLocal:(NSData *)data filePath:(NSString *)filePath;
// delete image
- (void)deleteImage:(NSString *)imageFile;

@end

@implementation ImageCacheEngine

+ (ImageCacheEngine *)sharedInstance
{
	@synchronized(_imageEngine) {
		if (!_imageEngine) {
			_imageEngine = [[ImageCacheEngine alloc] init];
		}
	}
	return _imageEngine;	
}

- (ImageCacheEngine *)init
{
    self = [super init];
	if (self) {        
		NSArray *doumenetPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
		documentDir = [doumenetPaths objectAtIndex:0];
		fileManager = [NSFileManager defaultManager];
        [self createDirectory];
	}
	return self;
}

- (void)createDirectory
{
    NSString *imagePath = [documentDir stringByAppendingPathComponent:kIconImagePath];
	if (![fileManager fileExistsAtPath:imagePath])
		[fileManager createDirectoryAtPath:imagePath withIntermediateDirectories:NO attributes:nil error:nil];
}

#pragma mark -
#pragma mark getImage

- (NSString *)getIconImagePath:(NSString *)_id
{
    NSString *imageFile = [[[documentDir stringByAppendingPathComponent:kIconImagePath] stringByAppendingPathComponent:_id] stringByAppendingPathExtension:@"png"];
    if ([fileManager fileExistsAtPath:imageFile] == YES) {
        return imageFile;
    } else {
        return nil;
    }
}

- (NSString *)setIconImagePath:(NSData *)data forId:(NSString *)_id
{
    if ((!_id) || (!data)) {
        return nil;
    }
    
    NSString *imageFile = [[[documentDir stringByAppendingPathComponent:kIconImagePath] stringByAppendingPathComponent:_id] stringByAppendingPathExtension:@"png"];
    return [self storeImagetoLocal:data filePath:imageFile];
}

- (NSString *)storeImagetoLocal:(NSData *)data filePath:(NSString *)filePath
{
    if ((!data) || (!filePath)) {
        return nil;
    }
    
    [self deleteImage:filePath];
    if ([data writeToFile:filePath options:NSAtomicWrite error:nil]) {
        return filePath;
    }
    return nil;
}


#pragma mark -
#pragma mark remove image
- (void)removeAllImagesInLocal
{
    NSError *error = nil;
    NSString *directory = [documentDir stringByAppendingPathComponent:kIconImagePath];
    for (NSString *file in [fileManager contentsOfDirectoryAtPath:directory error:&error]) {
        [fileManager removeItemAtPath:[directory stringByAppendingPathComponent:file] error:&error];
    }
}

- (void)deleteImage:(NSString *)imageFile
{
    if ([fileManager fileExistsAtPath:imageFile] == YES) {
		[fileManager removeItemAtPath:imageFile error:nil];
	}
}


#pragma mark -
#pragma mark rename image
- (void)renameFileTo:(NSString *)newId from:(NSString *)oldId inDir:(NSString *)dir
{
    if ((!newId) || (!oldId) || (!dir)) {
        return;
    }
    NSString *to = [[[documentDir stringByAppendingPathComponent:dir] stringByAppendingPathComponent:newId] stringByAppendingPathExtension:@"png"];
    NSString *from = [[[documentDir stringByAppendingPathComponent:dir] stringByAppendingPathComponent:oldId] stringByAppendingPathExtension:@"png"];
    
    if ([fileManager fileExistsAtPath:from] == YES) {
		[fileManager moveItemAtPath:from toPath:to error:nil];
	}
}
@end
