//
//  RecommendedApps.h
//  ComicLover
//
//  Created by levin wei on 9/3/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMUFPTableView.h"

@interface RecommendedApps : UIViewController <UITableViewDelegate, UITableViewDataSource, UMUFPTableViewDataLoadDelegate>
{
    UIView *_thePromptView;
    NSString *_controllerId;
    
    UMUFPTableView *_mTableView;
    
    UIView *_mLoadingWaitView;
    UILabel *_mLoadingStatusLabel;
    UIImageView *_mNoNetworkImageView;
    UIActivityIndicatorView *_mLoadingActivityIndicator;
}
@end
