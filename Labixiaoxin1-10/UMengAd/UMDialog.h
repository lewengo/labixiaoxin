//
//  UMDialog.h
//  UFP
//
//  Created by liu yu on 4/23/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UMUFPDialogDelegate;

typedef enum {
    SizeTypeSmall  = 0, 
    SizeTypeMiddle,     
    SizeTypeLarge,
    SizeTypeDefault = SizeTypeMiddle,
} SizeType;

@interface UMDialog : UIView {
    
@private
    UIButton  *_mCloseBtn;
    UIWebView *_mWebView;
    UIWindow  *_mTempFullscreenWindow;
    
    UIView    *_mLoadingWaitView;
    UIActivityIndicatorView *_mActivityIndicator; 
    
    NSString *_mAppkey;
    NSString *_mSlotId;
    
    SizeType _mSizeType;
        
    id<UMUFPDialogDelegate> _delegate;
}

@property (nonatomic, retain) UIButton  *mCloseBtn;
@property (nonatomic, retain) UIWebView *mWebView;
@property (nonatomic, assign) id<UMUFPDialogDelegate> delegate; 

/** 
 
 This method return a UMDialog object
 
 @param  appkey appkey get from www.umeng.com
 @param  slotId slotId get from www.ufp.umeng.com
 
 @return a UMDialog object
 */

- (id)initWithAppkey:(NSString *)appkey slotId:(NSString *)slotId;

/** 
 
 Dialog will show Asynchronous， after all the releated data loaded
 
 */

- (void)showAlertView;

/** 
 
 This method set channel for this app, the default channel is App Store, call this method if you want to set channel for another value, don't need to call this method among different views, only once is enough
 
 */

+ (void)setAppChannel:(NSString *)channel;

@end

@protocol UMUFPDialogDelegate <NSObject>

@optional

- (void)dialogWillShow:(UMDialog *)dialog;      //called when will appear the 1st time, implement this mothod if you want to change animation for the dialog appear or do something else before dialog appear
- (void)dialogWillDisappear:(UMDialog *)dialog; //called before dialog will disappear
- (void)dialog:(UMDialog *)dialog didLoadDataFinish:(NSURL *)targetUrl;      //called when promoter list loaded from the server
- (void)dialog:(UMDialog *)dialog didLoadDataFailWithError:(NSError *)error; //called when promoter list loaded failed for some reason, for example network problem or the promoter list is empty

@end
