//
//  LocalSettings.m
//  Three Hundred
//
//  Created by skye on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LocalSettings.h"


#define kSettingPath @"setting"

static NSString *settingPath = nil;

@interface LocalSettings (Private)

+ (void)createDirectory;
+ (NSString *)settingPath;

@end

@implementation LocalSettings

+ (void)createDirectory {
	if (![[NSFileManager defaultManager] fileExistsAtPath:settingPath])
		[[NSFileManager defaultManager] createDirectoryAtPath:settingPath withIntermediateDirectories:NO attributes:nil error:nil];
}

+ (NSString *)settingPath
{
    if(!settingPath) {
        NSArray *doumenetPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
        settingPath = [[doumenetPaths objectAtIndex:0] stringByAppendingPathComponent:kSettingPath];
        [self createDirectory];
    }
    return settingPath;
}

+ (NSDictionary *)loadSettings {
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:@"setting.plist"];
	NSDictionary *settings = nil;
	if ([[NSFileManager defaultManager] fileExistsAtPath:appFile] == YES) {
		settings = [NSDictionary dictionaryWithContentsOfFile:appFile];
	}
	return settings;
}

+ (void)saveSettings:(NSDictionary *)settings {
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:@"setting.plist"];
	[settings writeToFile:appFile atomically:YES];
}

+ (NSDictionary *)loadVolumsStatus;
{
    NSDictionary *status = nil;
	NSString *file = [[self settingPath] stringByAppendingPathComponent:@"volumsStatus.txt"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file] == YES) {
        status = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
    }
    return status;
}

+ (void)saveVolumsStatus:(NSDictionary *)volumsStatus
{
    if (!volumsStatus) {
        return;
    }
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:@"volumsStatus.txt"];
    [NSKeyedArchiver archiveRootObject:volumsStatus toFile:appFile];
}

+ (NSArray *)loadBooks
{
    NSArray *status = nil;
	NSString *file = [[self settingPath] stringByAppendingPathComponent:@"books.txt"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:file] == YES) {
        status = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
    }
    return status;
}

+ (void)saveBooks:(NSArray *)books
{
    if (!books) {
        return;
    }
	NSString *appFile = [[self settingPath] stringByAppendingPathComponent:@"books.txt"];
    [NSKeyedArchiver archiveRootObject:books toFile:appFile];
}
@end
