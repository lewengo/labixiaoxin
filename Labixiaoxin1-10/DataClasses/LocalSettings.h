//
//  LocalSettings.h
//  Three Hundred
//
//  Created by skye on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalSettings : NSObject {    
}

+ (NSDictionary *)loadSettings;
+ (void)saveSettings:(NSDictionary *)settings;

+ (NSDictionary *)loadVolumsStatus;
+ (void)saveVolumsStatus:(NSDictionary *)volumsStatus;

+ (NSArray *)loadBooks;
+ (void)saveBooks:(NSArray *)books;
@end
