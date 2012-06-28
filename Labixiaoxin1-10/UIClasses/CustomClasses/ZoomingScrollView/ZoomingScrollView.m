//
//  ZoomingScrollView.m
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "ZoomingScrollView.h"

@interface ZoomingScrollView ()

- (void)handleSingleTap:(CGPoint)touchPoint;
- (void)handleDoubleTap:(CGPoint)touchPoint;

@end

@implementation ZoomingScrollView
@synthesize zoomingDelegate = _zoomingDelegate;
@synthesize index = _index;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
		// Tap view for background
		tapView = [[UIViewTap alloc] initWithFrame:frame];
		tapView.tapDelegate = self;
		tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		tapView.backgroundColor = [UIColor blackColor];
		[self addSubview:tapView];
		
		// Image view
		photoImageView = [[UIImageViewTap alloc] initWithFrame:CGRectZero];
		photoImageView.tapDelegate = self;
		photoImageView.contentMode = UIViewContentModeCenter;
		photoImageView.backgroundColor = [UIColor blackColor];
		[self addSubview:photoImageView];
		
		// Setup
		self.backgroundColor = [UIColor blackColor];
		self.delegate = self;
		self.showsHorizontalScrollIndicator = YES;
		self.showsVerticalScrollIndicator = YES;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		
	}
	return self;
}

- (void)setIndex:(NSInteger)value {
	if (value == NSNotFound) {
		// Release image
		photoImageView.image = nil;
		
	} else {
		// Reset for new page at index
		_index = value;
		UIImage *image = [_zoomingDelegate getImage:_index];
		// Display image
		[self displayImage:image];
		
	}
}

#pragma mark -
#pragma mark Image

// Get and display image
- (void)displayImage:(UIImage *)image {
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    self.contentSize = CGSizeMake(0, 0);
    photoImageView.image = image;
    
    // Setup photo frame
    CGRect photoImageViewFrame;
    photoImageViewFrame.origin = CGPointZero;
    photoImageViewFrame.size = image.size;
    photoImageView.frame = photoImageViewFrame;
    self.contentSize = photoImageViewFrame.size;
    
    // Set zoom to minimum zoom
    [self setMaxMinZoomScalesForCurrentBounds:YES];
}

#pragma mark -
#pragma mark Setup Content

- (void)setMaxMinZoomScalesForCurrentBounds:(BOOL)relayout {
	// Bail
    if (relayout) {
        self.maximumZoomScale = 1;
        self.minimumZoomScale = 1;
        self.zoomScale = 1;
    }
    
	if (photoImageView.image == nil) {
        return;
    }
	
	// Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = photoImageView.bounds.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MAX(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    minScale = xScale;
	
	// If image is smaller than the screen then ensure we show it at
	// min scale of 1
//	if (xScale > 1 && yScale > 1) {
//		minScale = 1.0;
//	}
    
	// Calculate Max
	CGFloat maxScale = 2.0; // Allow double scale
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the
    // maximum zoom scale to 0.5.
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		maxScale = maxScale / [[UIScreen mainScreen] scale];
	}
	maxScale = MAX(maxScale, minScale);
	// Set
	self.maximumZoomScale = maxScale;
	self.minimumZoomScale = minScale;
    if (relayout) {
        self.zoomScale = minScale;
    }
	
	// Reset position
	photoImageView.frame = CGRectMake(0, 0, photoImageView.frame.size.width, photoImageView.frame.size.height);
    if (relayout) {
        self.contentOffset = CGPointZero;
    }
	[self setNeedsLayout];
}

#pragma mark -
#pragma mark UIView Layout

- (void)layoutSubviews {
	
	// Update tap view frame
	tapView.frame = self.bounds;
	
	// Super
	[super layoutSubviews];
	
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = photoImageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
	} else {
        frameToCenter.origin.x = 0;
	}
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
	} else {
        frameToCenter.origin.y = 0;
	}
    
	// Center
	if (!CGRectEqualToRect(photoImageView.frame, frameToCenter))
		photoImageView.frame = frameToCenter;
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return photoImageView;
}

#pragma mark -
#pragma mark Tap Detection

- (void)handleSingleTap:(CGPoint)touchPoint {
    if ([_zoomingDelegate respondsToSelector:@selector(handleSingleTap:)]) {
        [_zoomingDelegate handleSingleTap:touchPoint];
    }
}

- (void)handleDoubleTap:(CGPoint)touchPoint {
	// Zoom
    if ([_zoomingDelegate respondsToSelector:@selector(cancelSingleTap)]) {
        [_zoomingDelegate cancelSingleTap];
    }
	if (self.zoomScale == self.maximumZoomScale) {
		// Zoom out
		[self setZoomScale:self.minimumZoomScale animated:YES];
	} else {
		// Zoom in
		[self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
	}
}

// Image View
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch { [self handleSingleTap:[touch locationInView:imageView]]; }
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch { [self handleDoubleTap:[touch locationInView:imageView]]; }

// Background View
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch { [self handleSingleTap:[touch locationInView:view]]; }
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch { [self handleDoubleTap:[touch locationInView:view]]; }

@end
