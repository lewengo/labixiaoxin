//
//  CustomHitButton.m
//  Labixiaoxin1-10
//
//  Created by 晋辉 卫 on 5/19/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import "CustomHitButton.h"

@implementation CustomHitButton
@synthesize delegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *theView = [super hitTest:point withEvent:event];
    if ([delegate respondsToSelector:@selector(realHitView:)]) {
        return [delegate realHitView:theView];
    } else {
        return theView;
    }
}

@end
