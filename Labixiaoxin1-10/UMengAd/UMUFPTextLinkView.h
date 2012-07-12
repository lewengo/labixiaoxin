//
//  UMUFPTextLinkView.h
//  UFP
//
//  Created by liu yu on 2/20/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UMUFPTextLinkInternal;

@protocol UMUFPTextLinkViewDelegate;

@interface UMUFPTextLinkView : UIView {
@private
    float     _mIntervalDuration; 
    NSString *_mKeywords;

    id<UMUFPTextLinkViewDelegate> _delegate;
    UIViewController *_mCurrentViewController;   
    
    UMUFPTextLinkInternal *_mTextLinkInternal;
}

@property (nonatomic, copy)   NSString *mKeywords; 
@property (nonatomic, retain) UIColor *mBackgroundColor;   //background color for label
@property (nonatomic, assign) id<UMUFPTextLinkViewDelegate> delegate; 
@property (nonatomic) float   mIntervalDuration;           //duration for the promoter present time，default is 15s 

/** 
 
 This method create and return a UMUFPTextLinkView object
 
 @param  frame frame for the UMUFPTextLinkView 
 @param  appkey appkey get from www.umeng.com, if you want use ufp service only, set this parameter empty
 @param  slotId slotId get from ufp.umeng.com
 @param  controller view controller releated to the view that the textlink view added into
 
 @return a UMUFPTextLinkView object
 
 */

- (id)initWithFrame:(CGRect)frame appKey:(NSString *)appkey slotId:(NSString *)slotId currentViewController:(UIViewController *)controller;

/** 
 
 This method start the promoter data load in background, promoter data will be load until this method called
 
 */

- (void)requestPromoterDataInBackground;

/** 
 
 This method set channel for this app, the default channel is App Store, call this method if you want to set channel for another value, don't need to call this method among different views, only once is enough
 
 */

+ (void)setAppChannel:(NSString *)channel;

@end

@protocol UMUFPTextLinkViewDelegate <NSObject>

@optional

- (void)UMUFPTextLinkView:(UMUFPTextLinkView *)textLinkView didLoadDataFinish:(NSInteger)promotersAmount; 
- (void)UMUFPTextLinkView:(UMUFPTextLinkView *)textLinkView didLoadDataFailWithError:(NSError *)error; 
- (void)UMUFPTextLinkView:(UMUFPTextLinkView *)textLinkView didClickPromoterForUrl:(NSURL *)url; 
- (void)UMUFPTextLinkView:(UMUFPTextLinkView *)textLinkView didClickedPromoterAtIndex:(NSInteger)index;   

@end
