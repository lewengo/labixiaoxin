//
//  VolumViewControllerViewController.h
//  Labixiaoxin1-5
//
//  Created by 晋辉 卫 on 5/1/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZoomingScrollView.h"
#import "GADBannerViewDelegate.h"
#import "CustomHitButton.h"
@class GADBannerView;
@class VolumStatus;

@interface VolumViewControllerViewController : UIViewController <UIScrollViewDelegate, ZoomingScrollViewDelegate, GADBannerViewDelegate, CustomHitButtonDelegate>
{
    NSInteger count;
    // Paging
	NSMutableSet *visiblePages, *recycledPages;
	NSUInteger currentPageIndex;
	NSUInteger pageIndexBeforeRotation;
	
	// Navigation & controls
	IBOutlet UIToolbar *toolbar;
	NSTimer *controlVisibilityTimer;
    UISlider *pageSlider;
    UILabel *pageLabel;
    
    // Misc
	BOOL performingLayout;
	BOOL rotating;
    
    IBOutlet UIView *secondView;
    GADBannerView *_bannerView;
    BOOL _adShowing;
    IBOutlet CustomHitButton *menuButton;
    
    NSInteger viewedCount;
}
@property (strong, nonatomic) IBOutlet UIScrollView *pagingScrollView;
@property (strong, nonatomic) VolumStatus *volumStatus;

- (IBAction)hideMenu:(id)sender;

@end
