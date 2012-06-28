//
//  CustomHitButton.h
//  Labixiaoxin1-10
//
//  Created by 晋辉 卫 on 5/19/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomHitButtonDelegate;

@interface CustomHitButton : UIButton
@property (unsafe_unretained, nonatomic) id<CustomHitButtonDelegate> delegate;
@end

@protocol CustomHitButtonDelegate <NSObject>

- (UIView *)realHitView:(UIView *)button;

@end
