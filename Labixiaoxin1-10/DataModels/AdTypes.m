//
//  AdTypes.m
//  Labixiaoxin1-10
//
//  Created by levin wei on 8/22/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import "AdTypes.h"

@implementation AdTypes
@synthesize prime, secondary;
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.prime = [aDecoder decodeObjectForKey:@"prime"];
        self.secondary = [aDecoder decodeObjectForKey:@"secondary"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.prime forKey:@"prime"];
    [aCoder encodeObject:self.secondary forKey:@"secondary"];
}

@end
