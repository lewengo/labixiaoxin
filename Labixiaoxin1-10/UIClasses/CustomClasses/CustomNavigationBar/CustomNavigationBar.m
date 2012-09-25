//
//  CustomNavigationBar.m
//  CustomBackButton
//
//  Created by Peter Boctor on 1/11/11.
//
//  Copyright (c) 2011 Peter Boctor
// 
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
// 
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
// 
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE

#import "CustomNavigationBar.h"

#define MAX_BACK_BUTTON_WIDTH 160.0

@implementation CustomNavigationBar
@synthesize navigationBarBackgroundImage, navigationController;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        navigationBarBackgroundImage = [[UIImageView alloc] initWithFrame:self.frame];
        navigationBarBackgroundImage.image = [UIImage retina4ImageNamed:@"navigationBarBackground.png"];
    }
    return self;
}

// If we have a custom background image, then draw it, othwerwise call super and draw the standard nav bar
- (void)drawRect:(CGRect)rect
{
  if (navigationBarBackgroundImage)
    [navigationBarBackgroundImage.image drawInRect:rect];
  else
    [super drawRect:rect];
}

// Save the background image and call setNeedsDisplay to force a redraw
-(void) setBackgroundWith:(UIImage*)backgroundImage
{
  self.navigationBarBackgroundImage = [[UIImageView alloc] initWithFrame:self.frame];
  navigationBarBackgroundImage.image = backgroundImage;
  [self setNeedsDisplay];
}

// clear the background image and call setNeedsDisplay to force a redraw
-(void) clearBackground
{
  self.navigationBarBackgroundImage = nil;
  [self setNeedsDisplay];
}

// Set the text on the custom back button
-(void) setText:(NSString*)text onBackButton:(UIButton*)backButton leftCapWidth:(CGFloat)capWidth
{
  // Measure the width of the text
  CGSize textSize = [text sizeWithFont:backButton.titleLabel.font];
  // Change the button's frame. The width is either the width of the new text or the max width
  backButton.frame = CGRectMake(backButton.frame.origin.x, backButton.frame.origin.y, (NSInteger)((textSize.width + (capWidth * 1.5)) > MAX_BACK_BUTTON_WIDTH ? MAX_BACK_BUTTON_WIDTH : (textSize.width + (capWidth * 1.5))), backButton.frame.size.height);

  // Set the text on the button
  [backButton setTitle:text forState:UIControlStateNormal];
}

-(NSString*) backButtonText
{
    return [NSString stringWithFormat:@" %@", self.topItem.title ? self.topItem.title : NSLocalizedString(@"Back", @"")];
}

@end
