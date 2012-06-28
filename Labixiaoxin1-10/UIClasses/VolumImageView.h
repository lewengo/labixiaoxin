//
//  VolumImageView.h
//  Labixiaoxin1-5
//
//  Created by 晋辉 卫 on 5/3/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VolumStatus;
@interface VolumImageView : UIView
{
    UIImageView *coverImage;
    UIImageView *bookMark;
    UILabel *volumName;
}
@property (strong, nonatomic) VolumStatus *volum;
@property (assign, nonatomic) BOOL isCurrent;
@end
