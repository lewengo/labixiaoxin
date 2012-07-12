//
//  UMHeadlineView.h
//  UFP
//
//  Created by liu yu on 5/18/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UMHeadlineViewInternal;

@protocol UMHeadlineViewDelegate;

@interface UMHeadlineView : UIView {
@private
    BOOL     _mAutoFill;
    NSString *_mKeywords;
    float    _mIntervalDuration;
    
    UIView   *_mLoadingWaitView;
    UIViewController *_mCurrentViewController;
    UMHeadlineViewInternal *_mHeadlineViewInternal;
    
    id<UMHeadlineViewDelegate> _delegate;
}

@property (nonatomic) BOOL  mAutoFill;            //default is true
@property (nonatomic, copy) NSString *mKeywords;  //keywords for the promoters data, promoter list will return according to this property, default is @""
@property (nonatomic) float mIntervalDuration;    //duration for the promoter present time，default is 15s 
@property (nonatomic, assign) id<UMHeadlineViewDelegate> delegate;
@property (nonatomic, retain) UIView  *mLoadingWaitView; //view displayed when query promoter list from server, default is a picture named um_headview_placeholder.jgp 

/** 
 
 This method return a UMHeadlineView object
 
 @param  frame frame for the headView view
 @param  appkey appkey get from www.umeng.com
 @param  slotId slotId get from ufp.umeng.com
 @param  controller view controller releated to the view that the headView view added into
 
 @return a UMHeadlineView object
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

@protocol UMHeadlineViewDelegate <NSObject>

@optional

- (void)UMHeadlineView:(UMHeadlineView *)headView didLoadDataFinish:(NSInteger)promotersAmount; //called when promoter list loaded from the server
- (void)UMHeadlineView:(UMHeadlineView *)headView didLoadDataFailWithError:(NSError *)error; //called when promoter list loaded failed for some reason, for example network problem or the promoter list is empty
- (void)UMHeadlineView:(UMHeadlineView *)headView didClickPromoterForUrl:(NSURL *)url; //implement this method if you want to handle promoter click event for the case that should open an url in webview  
- (void)UMHeadlineView:(UMHeadlineView *)headView didClickedPromoterAtIndex:(NSInteger)index;   //called when headView clicked

@end
