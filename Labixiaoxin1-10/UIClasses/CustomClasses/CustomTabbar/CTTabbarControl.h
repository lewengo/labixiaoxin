//
//  CTTabbarControl.h
//  Tabbar
//
//  Created by 晋辉 卫 on 10/27/11.
//  Copyright (c) 2011 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CTTabbarControlDelegate;

typedef enum {
    CTTabbarOrientationHorizontal,
    CTTabbarOrientationVertical,
} CTTabbarOrientationType;

@interface CTTabbarControl : UIView
{
    __unsafe_unretained id<CTTabbarControlDelegate> _delegate;
    NSInteger _count;
    NSInteger _selected;
    UIImage *_bgImage;
    UIImageView *_arrow;
}
@property (nonatomic, assign) BOOL notShow;
@property (nonatomic, assign) CTTabbarOrientationType orientationType;

- (id)initWithFrame:(CGRect)theFrame
       withDelegate:(id<CTTabbarControlDelegate>)theDelegate
          withCount:(NSInteger)theCount
    withOrientation:(CTTabbarOrientationType)orientationType;

- (void)setSelectedIndex:(NSInteger)theIndex; //set the selected index from 0 on
- (UIViewController *)selectedController;
- (UIViewController *)targetController:(NSInteger)theIndex;
- (NSInteger)selectedIndex;
- (NSInteger)tabCount;
- (void)setBadge:(NSInteger)badge index:(NSInteger)index;

- (void)resetTab:(NSInteger)index;
@end

@protocol CTTabbarControlDelegate <NSObject>

- (UIView *)superView:(CTTabbarControl *)tabbar; //the tabbar's super view.
- (NSString *)xibName:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex;//the controllers' names
- (BOOL)isNavigation:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex;
- (UIImage *)tabbarBgImage:(CTTabbarControl *)tabbar;//tabbar's background image
- (CGRect)tabbarButtonRect:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex;//items' rects. you can set the rect by your self. not average
- (NSString *)tabbarItemTitle:(CTTabbarControl *)tabbar
                      atIndex:(NSInteger)theIndex;
- (UIColor *)tabbarItemTitleColorNormal:(CTTabbarControl *)tabbar
                                atIndex:(NSInteger)theIndex;
- (UIFont *)tabbarItemTitleFont:(CTTabbarControl *)tabbar
                       atIndex:(NSInteger)theIndex;

- (UIImage *)tabbarItemIcon:(CTTabbarControl *)tabbar
                    atIndex:(NSInteger)theIndex;//normal icon
- (UIImage *)tabbarItemIconHighlight:(CTTabbarControl *)tabbar
                             atIndex:(NSInteger)theIndex; //highlight icon, when you touch down the item
- (UIImage *)tabbarItemIconSelected:(CTTabbarControl *)tabbar
                             atIndex:(NSInteger)theIndex;//selected icon, then the item is selected
- (BOOL)canselect:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex;

- (void)willSelect:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex;

- (void)selectDone:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex;

- (UIImage *)arrowImage:(CTTabbarControl *)tabbar;

- (CGFloat)realHeightMargin:(CTTabbarControl *)tabbar;

- (UIEdgeInsets)titleInset:(CTTabbarControl *)tabbar atIndex:(NSInteger)theIndex;

@optional
- (UIColor *)tabbarItemTitleColorSelected:(CTTabbarControl *)tabbar
                                  atIndex:(NSInteger)theIndex;
@end