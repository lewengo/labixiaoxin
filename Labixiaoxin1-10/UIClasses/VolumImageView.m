//
//  VolumImageView.m
//  Labixiaoxin1-5
//
//  Created by 晋辉 卫 on 5/3/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import "VolumImageView.h"
#import "VolumStatus.h"
#import "Constants.h"

@implementation VolumImageView
@synthesize volum = _volum;
@synthesize isCurrent = _isCurrent;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage retina4ImageNamed:@"bookBg.png"]];
        
        UIImageView *bgView = nil;
        if (IS_IPAD) {
#ifdef Is_Only_Portrait
            bgView = [[UIImageView alloc] initWithImage:[UIImage retina4ImageNamed:@"bookBg.png"]];
#else
            bgView = [[UIImageView alloc] initWithImage:[UIImage retina4ImageNamed:@"bookBgLandscape.png"]];
#endif
        } else {
            bgView = [[UIImageView alloc] initWithImage:[UIImage retina4ImageNamed:@"bookBg.png"]];
        }
        
        [self addSubview:bgView];
        
        if (IS_IPAD) {
#ifdef Is_Only_Portrait
            coverImage = [[UIImageView alloc] initWithFrame:CGRectMake(29, 13, 160, 180)];
#else
            coverImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 15, 133, 150)];
#endif
        } else {
            coverImage = [[UIImageView alloc] initWithFrame:CGRectMake(13, 8, 73, 82)];
        }
        [self addSubview:coverImage];
        
        bookMark = [[UIImageView alloc] initWithImage:[UIImage retina4ImageNamed:@"currentBookmark.png"]];
        if (IS_IPAD) {
#ifdef Is_Only_Portrait
            bookMark.frame = CGRectMake(150, 2, bookMark.frame.size.width, bookMark.frame.size.height);
#else
            bookMark.frame = CGRectMake(120, 0, bookMark.frame.size.width, bookMark.frame.size.height);
#endif
        } else {
            bookMark.frame = CGRectMake(72, 2, bookMark.frame.size.width, bookMark.frame.size.height);
        }
        bookMark.hidden = YES;
        [self addSubview:bookMark];
        
        if (IS_IPAD) {
#ifdef Is_Only_Portrait
            volumName = [[UILabel alloc] initWithFrame:CGRectMake(0, 206, self.frame.size.width, 40)];
            volumName.font = [UIFont boldSystemFontOfSize:38];
#else
            volumName = [[UILabel alloc] initWithFrame:CGRectMake(0, 173, self.frame.size.width, 32)];
            volumName.font = [UIFont boldSystemFontOfSize:30];
#endif
        } else {
            volumName = [[UILabel alloc] initWithFrame:CGRectMake(0, 94, self.frame.size.width, 20)];
            volumName.font = [UIFont boldSystemFontOfSize:17];
        }
        volumName.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:volumName];
        volumName.backgroundColor = [UIColor clearColor];
        volumName.textAlignment = UITextAlignmentCenter;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setVolum:(VolumStatus *)volum
{
    _volum = volum;
    coverImage.image = [UIImage retina4ImageNamed:[NSString stringWithFormat:@"cover%d.jpg", [_volum.volumId intValue] + 1 + CURRENTBOOK_START]];
    volumName.text = [NSString stringWithFormat:NSLocalizedString(@"%d Volum", nil), [_volum.volumId intValue] + 1 + CURRENTBOOK_START];
}

- (void)setIsCurrent:(BOOL)isCurrent
{
    _isCurrent = isCurrent;
    bookMark.hidden = !_isCurrent;
}
@end
