//
//  FlipVolumViewController.h
//  Labixiaoxin1-10
//
//  Created by 晋辉 卫 on 5/24/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerViewDelegate.h"
#import "AFKPageFlipper.h"
#import "YouMiDelegateProtocol.h"
#import "MobWinBannerViewDelegate.h"
#import "MobWinBannerView.h"
#import "DMAdView.h"
#import "UMUFPBannerView.h"
#import "CustomNavigationBar.h"

@class GADBannerView;
@class VolumStatus;
@class YouMiView;

@interface FlipVolumViewController : UIViewController <GADBannerViewDelegate, AFKPageFlipperDataSource, UIGestureRecognizerDelegate, YouMiDelegate, MobWinBannerViewDelegate, DMAdViewDelegate, UMUFPBannerViewDelegate>
{
    NSInteger count;
    // Paging
	NSUInteger currentPageIndex;
	NSUInteger pageIndexBeforeRotation;
	
	// Navigation & controls
    IBOutlet CustomNavigationBar *naviBar;
    IBOutlet UIToolbar *bottomBar;
	NSTimer *controlVisibilityTimer;
    UISlider *pageSlider;
    UILabel *pageLabel;
    
    // Misc
	BOOL performingLayout;
	BOOL rotating;
    
    IBOutlet UIView *frontView;
    AFKPageFlipper *flipView;
    GADBannerView *_bannerView;
    YouMiView *_youmiView;
    MobWinBannerView *_MobWINView;
    DMAdView *_DMView;
    UMUFPBannerView *_UMengView;
    BOOL _adShowing;
    IBOutlet UIButton *menuButton;
    
    NSInteger viewedCount;
}

@property (strong, nonatomic) VolumStatus *volumStatus;

- (IBAction)hideMenu:(id)sender;

@end
