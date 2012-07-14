//
//  AFKPageFlipper.h
//  AFKPageFlipper
//
//  Created by Marco Tabini on 10-10-11.
//  Copyright 2010 AFK Studio Partnership. All rights reserved.
//
//  Modified by Reefaq Mohammed on 16/07/11.
 

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@class AFKPageFlipper;

@protocol AFKPageFlipperDataSource
- (NSInteger)numberOfPagesForPageFlipper:(AFKPageFlipper *)pageFlipper;
- (UIView *)viewForPage:(NSInteger)page inFlipper:(AFKPageFlipper *)pageFlipper;

- (void)pageShowed:(NSInteger)page inFlipper:(AFKPageFlipper *)pageFlipper;
@end


typedef enum {
	AFKPageFlipperDirectionLeft,
	AFKPageFlipperDirectionRight,
} AFKPageFlipperDirection;



@interface AFKPageFlipper : UIView {
	// shadows
	CALayer *frontLayerShadow;
	CALayer *backLayerShadow;
	CALayer *leftLayerShadow;
	CALayer *rightLayerShadow;
    
	// shadows
	CALayer *backgroundAnimationLayer;
	CALayer *flipAnimationLayer;
	CALayer *blankFlipAnimationLayerOnLeft1;
	CALayer *blankFlipAnimationLayerOnRight1;
	
	CALayer *blankFlipAnimationLayerOnLeft2;
	CALayer *blankFlipAnimationLayerOnRight2;	
	
	AFKPageFlipperDirection flipDirection;
	float startFlipAngle;
	float endFlipAngle;
	float currentAngle;
	
    CGPoint _initialPoint;
    CGPoint _lastPoint;
    BOOL needReverse;
    
	BOOL setNewViewOnCompletion;
    
	UIImage *flipIllusionPortrait;
	UIImage *flipIllusionLandscape;
}

@property (nonatomic, unsafe_unretained) NSObject<AFKPageFlipperDataSource> *dataSource;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger numberOfPages;

@property (nonatomic, assign) NSInteger pageDifference;

@property (nonatomic, assign) BOOL disabled;

@property (nonatomic, strong) UIView *currentView;
@property (nonatomic, strong) UIView *postView;

@property (nonatomic, readonly) BOOL animating;

- (void)setCurrentPage:(NSInteger)value animated:(BOOL)animated;

@end
