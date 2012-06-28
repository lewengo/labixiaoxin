//
//  UserGuideView.h
//  ThreeHundred
//
//  Created by Levin on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UserGuideFinishDelegate;

enum {
    kUserGuideTypeFirst,
    kUserGuideTypeSeconde,
    kUserGuideTypeLast
};

@interface UserGuideView : NSObject <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    NSInteger _currentType;
    __unsafe_unretained id<UserGuideFinishDelegate> _delegate;
    UIView *_superView;
    UIView *_backgroundView;
}
- (id)initWithDelegate:(id<UserGuideFinishDelegate>)delegate;
- (void)showGuide:(NSInteger)type withSuperView:(UIView *)superView;
@end

@protocol UserGuideFinishDelegate <NSObject>
- (void)UserGuideFinished:(NSInteger) finishedType;
@end