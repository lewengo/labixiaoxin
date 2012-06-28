//
//  Book.m
//  Labixiaoxin1-5
//
//  Created by 晋辉 卫 on 5/5/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import "Book.h"

@implementation Book
@synthesize bookId;
@synthesize bookName;
@synthesize bookUrl;
@synthesize bookIcon;
@synthesize bookPrice;
@synthesize publishTime;
@synthesize isNew;
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.bookId = [aDecoder decodeObjectForKey:@"bookId"];
        self.bookName = [aDecoder decodeObjectForKey:@"bookName"];
        self.bookUrl = [aDecoder decodeObjectForKey:@"bookUrl"];
        self.bookIcon = [aDecoder decodeObjectForKey:@"bookIcon"];
        self.bookPrice = [aDecoder decodeObjectForKey:@"bookPrice"];
        self.publishTime = [aDecoder decodeObjectForKey:@"publishTime"];
        self.isNew = [aDecoder decodeBoolForKey:@"isNew"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.bookId forKey:@"bookId"];
    [aCoder encodeObject:self.bookName forKey:@"bookName"];
    [aCoder encodeObject:self.bookUrl forKey:@"bookUrl"];
    [aCoder encodeObject:self.bookIcon forKey:@"bookIcon"];
    [aCoder encodeObject:self.bookPrice forKey:@"bookPrice"];
    [aCoder encodeObject:self.publishTime forKey:@"publishTime"];
    [aCoder encodeBool:self.isNew forKey:@"isNew"];
}
@end
