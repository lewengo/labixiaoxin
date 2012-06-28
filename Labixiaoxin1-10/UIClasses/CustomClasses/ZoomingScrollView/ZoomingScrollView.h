//
//  ZoomingScrollView.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageViewTap.h"
#import "UIViewTap.h"

@protocol ZoomingScrollViewDelegate;

@interface ZoomingScrollView : UIScrollView <UIScrollViewDelegate, UIImageViewTapDelegate, UIViewTapDelegate> {
	// Views
	UIViewTap *tapView; // for background taps
	UIImageViewTap *photoImageView;
}

@property (unsafe_unretained, nonatomic) id <ZoomingScrollViewDelegate> zoomingDelegate;
@property (assign, nonatomic) NSInteger index;

// Methods
- (void)displayImage:(UIImage *)image;
- (void)setMaxMinZoomScalesForCurrentBounds:(BOOL)relayout;

@end

@protocol ZoomingScrollViewDelegate <NSObject>

- (void)handleSingleTap:(CGPoint)touchPoint;
- (void)cancelSingleTap;
- (UIImage *)getImage:(NSInteger)index;

@end

