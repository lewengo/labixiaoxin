//
//  ;
//  Labixiaoxin1-5
//
//  Created by 晋辉 卫 on 5/1/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import "VolumStatus.h"

@implementation VolumStatus
@synthesize volumId = _volumId;
@synthesize index = _index;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.volumId = [aDecoder decodeObjectForKey:@"volumId"];
        self.index = [aDecoder decodeInt32ForKey:@"index"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.volumId forKey:@"volumId"];
    [aCoder encodeInt32:self.index forKey:@"index"];
}
@end
