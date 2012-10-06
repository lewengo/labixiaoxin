//
//  CTTabbarControl.m
//  Tabbar
//
//  Created by 晋辉 卫 on 10/27/11.
//  Copyright (c) 2011 MobileWoo. All rights reserved.
//

#import "CTTabbarControl.h"
#import "AppDelegate.h"
#import "Constants.h"

@interface CTTabbarControl ()

@property (strong, nonatomic) NSMutableDictionary *controllers;
@property (strong, nonatomic) NSMutableArray *labels;
@property (strong, nonatomic) NSMutableArray *buttons;
@property (strong, nonatomic) NSMutableArray *bageButtons;

- (void)buttonHighlighted:(id)sender;
- (void)buttonSelected:(id)sender;
- (void)buttonOutside:(id)sender;

- (void)initTabbar;
- (void)deselectItemExcept:(NSInteger)selectedIndex highlightIndex:(NSInteger)highlightIndex;
- (void)hideTitle:(NSNumber *)animation;
- (void)showTitle:(NSInteger)theIndex;
- (void)scrollArrowTo:(NSInteger)theIndex animation:(BOOL)animation;
- (void)scrollEnd;
- (void)resetViewRect:(UIViewController *)controller;
- (void)resetCurrentViewRect;

@end

@implementation CTTabbarControl
@synthesize controllers = _controllers;
@synthesize labels = _labels;
@synthesize buttons = _buttons;
@synthesize notShow = _notShow;
@synthesize bageButtons = _bageButtons;

@synthesize orientationType = _orientationType;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)theFrame
       withDelegate:(id<CTTabbarControlDelegate>)theDelegate
          withCount:(NSInteger)theCount
    withOrientation:(CTTabbarOrientationType)orientationType
{
    self = [super initWithFrame:theFrame];
    if (self) {
        [self addObserver:self forKeyPath:@"notShow" options:0 context:nil];
        self.backgroundColor = [UIColor clearColor];
        _delegate = theDelegate;
        _count = theCount;
        _selected = -1;
        UIImage *bgImage = [_delegate tabbarBgImage:self];
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.bounds];
        bgView.image = bgImage;
        [self addSubview:bgView];
        _orientationType = orientationType;
        if (_orientationType == CTTabbarOrientationHorizontal) {
            bgView.contentMode = UIViewContentModeBottom;
        } else {
            bgView.contentMode = UIViewContentModeLeft;
        }
        [self initTabbar];
        UIImage *arrow = nil;
        if (_delegate && [_delegate respondsToSelector:@selector(arrowImage:)]) {
            arrow = [_delegate arrowImage:self];
        }
        if (arrow) {
            _arrow = [[UIImageView alloc] initWithImage:arrow];
            if (_orientationType == CTTabbarOrientationHorizontal) {
                _arrow.frame = CGRectMake(-100, CGRectGetHeight(self.frame) - arrow.size.height, arrow.size.width, arrow.size.height);
            } else {
                _arrow.frame = CGRectMake(CGRectGetWidth(self.frame) - arrow.size.width, -100, arrow.size.width, arrow.size.height);
            }

            [self addSubview:_arrow];
        }
        
        [[_delegate superView:self] addSubview:self];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"notShow"];
    _delegate = nil;
}

- (void)setSelectedIndex:(NSInteger)theIndex
{
    if (theIndex != _selected) {
        [_delegate willSelect:self atIndex:theIndex];
    }
    
    if (![_delegate canselect:self atIndex:theIndex]) {
        [self scrollEnd];
        return;
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *preXibName = [_delegate xibName:self atIndex:_selected];
    NSString *postXibName = [_delegate xibName:self atIndex:theIndex];
    if ([_delegate isNavigation:self atIndex:theIndex]) {
        if (_selected >= 0 && _selected < _count && _selected != theIndex) {
            [self scrollArrowTo:theIndex animation:YES];
        } else {
            [self scrollArrowTo:theIndex animation:NO];
        }
        [self showTitle:theIndex];
        [self deselectItemExcept:theIndex highlightIndex:theIndex];
        UIViewController *preController = [_controllers objectForKey:preXibName];
        if (theIndex == _selected) {
            if (preController != nil && preController != (UIViewController *)[NSNull null] && [preController isKindOfClass:[UINavigationController class]]) {
                [(UINavigationController *)preController popToRootViewControllerAnimated:YES];
            }
        } else {
            if (preController != (UIViewController *)[NSNull null] && preController != nil) {
                [preController.view removeFromSuperview];
                if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
                    [preController viewWillDisappear:NO];
                    [preController viewDidDisappear:NO];
                }
            }
            _selected = theIndex;
            UIViewController *postController = [_controllers objectForKey:postXibName];
            if (postController == nil || postController == (UIViewController *)[NSNull null]) {
                postController = [[[NSBundle mainBundle] loadNibNamed:@"CustomNavigationController" owner:self options:nil] objectAtIndex:0];
                UIViewController *first = nil;
                Class controllerClass = NSClassFromString(postXibName);
                if([[NSBundle mainBundle] pathForResource:postXibName ofType:@"nib"]) {
                    first = [[controllerClass alloc] initWithNibName:postXibName bundle:nil];
                } else {
                    first = [[controllerClass alloc] init];
                }
                [(UINavigationController *)postController pushViewController:first animated:NO];
                if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
                    [self performSelectorOnMainThread:@selector(resetViewRect:)
                                           withObject:postController
                                        waitUntilDone:NO];
                }
                [_controllers setObject:postController forKey:postXibName];
            }
            [self resetViewRect:postController];
            [[_delegate superView:self] insertSubview:postController.view belowSubview:self];
            if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
                [postController viewWillAppear:NO];
                [postController viewDidAppear:NO];
            }
        }
    } else {
        [self deselectItemExcept:_selected highlightIndex:-1];
        if (_selected != theIndex) {
            Class controllerClass = NSClassFromString(postXibName);
            UIViewController *first = nil;
            if([[NSBundle mainBundle] pathForResource:postXibName ofType:@"nib"]) {
                first = [[controllerClass alloc] initWithNibName:postXibName bundle:nil];
            } else {
                first = [[controllerClass alloc] init];
            }
            [delegate presentModalViewController:first animated:YES];
        }
    }
    [[_delegate superView:self] bringSubviewToFront:self];
    [_delegate selectDone:self atIndex:_selected];
}

- (UIViewController *)selectedController
{
    return [_controllers objectForKey:[_delegate xibName:self atIndex:_selected]];
}

- (UIViewController *)targetController:(int) theIndex
{
    return [_controllers objectForKey:[_delegate xibName:self atIndex:theIndex]];
}

- (NSInteger)selectedIndex
{
    return _selected;
}

- (NSInteger)tabCount
{
    return self.buttons.count;
}

- (void)setBadge:(NSInteger)badge index:(NSInteger)index
{
    if (index >= _count || index < 0) {
        return;
    }
    
    if (badge <= 0) {
        UIButton *bageButton = [self.bageButtons objectAtIndex:index];
        if (!bageButton.hidden) {
            bageButton.hidden = YES;
        }
    }
    else{
        UIButton *bageButton = [self.bageButtons objectAtIndex:index];
        if (bageButton.hidden) {
            bageButton.hidden = NO;
        } 
        [bageButton setTitle:[NSString stringWithFormat:@"%d", badge] forState:UIControlStateNormal];
    }
}

- (void)resetTab:(NSInteger)index
{
    if (![_delegate isNavigation:self atIndex:index]) {
        return;
    }
    UIViewController *controller = [_controllers objectForKey:[_delegate xibName:self atIndex:index]];
    if (controller != (UIViewController *)[NSNull null] && controller != nil && [controller isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController *)controller popToRootViewControllerAnimated:YES];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
//    CGRect middleFrame = [_delegate tabbarButtonRect:self atIndex:1];
//    if (_orientationType == CTTabbarOrientationHorizontal) {
//        if (point.y >= 0 && point.y < [_delegate realHeightMargin:self] && ((point.x >= 0 && point.x < middleFrame.origin.x) || (point.x >= middleFrame.origin.x + middleFrame.size.width && point.x < self.frame.size.width))) {
//            return nil;
//        }
//    } else {
//        if (point.x >= (CGRectGetWidth(self.frame) - [_delegate realHeightMargin:self]) && point.x < CGRectGetWidth(self.frame) && ((point.y >= 0 && point.y < middleFrame.origin.y) || (point.y >= middleFrame.origin.y + middleFrame.size.height && point.y < self.frame.size.height))) {
//            return nil;
//        }
//    }
    return [super hitTest:point withEvent:event];
}

- (void)initTabbar
{
    if (_controllers) {
        NSEnumerator *enumerator = [_controllers objectEnumerator];
        UIViewController *controller;
        while (controller = [enumerator nextObject]) {
            if (controller != (UIViewController *)[NSNull null]) {
                [controller.view removeFromSuperview];
            }
        }
        self.controllers = nil;
    }
    _controllers = [[NSMutableDictionary alloc] initWithCapacity:_count];
    if (_labels) {
        self.labels = nil;
    }
    _labels = [[NSMutableArray alloc] initWithCapacity:_count];
    
    if (_bageButtons) {
        self.bageButtons = nil;
    }
    _bageButtons = [[NSMutableArray alloc] initWithCapacity:_count];
    
    if (_buttons) {
        for (int ii = 0; ii < _buttons.count; ii++) {
            [(UIButton *)[_buttons objectAtIndex:ii] removeFromSuperview];
        }
        self.buttons = nil;
    }
    
    _buttons = [[NSMutableArray alloc] initWithCapacity:_count];
    for (int ii = 0; ii < _count; ii++) {
        [_controllers setObject:[NSNull null] forKey:[_delegate xibName:self atIndex:ii]];
        NSString *title = [_delegate tabbarItemTitle:self atIndex:ii];
        if (title) {
            [_labels addObject:[_delegate tabbarItemTitle:self atIndex:ii]];
        } else {
            [_labels addObject:[NSNull null]];
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttons addObject:button];
        CGRect rect = [_delegate tabbarButtonRect:self atIndex:ii];
        button.frame = rect;
        [button setBackgroundImage:[_delegate tabbarItemIcon:self atIndex:ii] forState:UIControlStateNormal];
        [button setBackgroundImage:[_delegate tabbarItemIconHighlight:self atIndex:ii] forState:UIControlStateHighlighted];
        [button setBackgroundImage:[_delegate tabbarItemIconSelected:self atIndex:ii] forState:UIControlStateSelected];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[_delegate tabbarItemTitleColorNormal:self atIndex:ii] forState:UIControlStateNormal];
        if ([_delegate respondsToSelector:@selector(tabbarItemTitleColorSelected:atIndex:)]) {
            [button setTitleColor:[_delegate tabbarItemTitleColorSelected:self atIndex:ii] forState:UIControlStateSelected];
        }
        button.titleLabel.font = [_delegate tabbarItemTitleFont:self atIndex:ii];
        button.titleLabel.textAlignment = UITextAlignmentCenter;
//        button.titleLabel.alpha = 0.0;
        
        [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(buttonHighlighted:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(buttonHighlighted:) forControlEvents:UIControlEventTouchDragInside];
        [button addTarget:self action:@selector(buttonOutside:) forControlEvents:UIControlEventTouchCancel];
        [button addTarget:self action:@selector(buttonOutside:) forControlEvents:UIControlEventTouchUpOutside];
        button.titleEdgeInsets = [_delegate titleInset:self atIndex:ii];
        [self addSubview:button];
        
        UIImage *bageBg = [[UIImage retina4ImageNamed:@"notificaionBubble.png"] stretchableImageWithLeftCapWidth:12.0f topCapHeight:8.0f];
        UIButton *bageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_bageButtons addObject:bageButton];
        [bageButton setBackgroundImage:bageBg forState:UIControlStateNormal];
        bageButton.titleEdgeInsets = UIEdgeInsetsMake(-1, 2, 0, 0);
        bageButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
        bageButton.titleLabel.textAlignment = UITextAlignmentCenter;
        bageButton.titleLabel.textColor = [UIColor whiteColor];
        //[bageButton setTitle:[NSString stringWithFormat:@"%d", 5] forState:UIControlStateNormal];
        [self addSubview:bageButton];
        bageButton.frame = CGRectMake(rect.origin.x + rect.size.width / 2 + 8, rect.origin.y + rect.size.height / 6, bageBg.size.width, bageBg.size.height);
        bageButton.hidden = YES;
        bageButton.userInteractionEnabled = NO;
    }
}

- (void)deselectItemExcept:(NSInteger)selectedIndex
            highlightIndex:(NSInteger)highlightIndex
{
    for (int ii = 0; ii < _count; ii++) {
        UIButton *button = [_buttons objectAtIndex:ii];
        if (ii == selectedIndex) {
            if (button) {
                button.selected = YES;
                button.highlighted = NO;
            }
        } else if (ii == highlightIndex) {
            if (button) {
                button.selected = NO;
                button.highlighted = YES;
            }
        } else {
            if (button) {
                button.selected = NO;
                button.highlighted = NO;
            }
        }
    }
}

- (void)showTitle:(NSInteger)theIndex
{
    for (int ii = 0; ii < _count; ii++) {
        if ([_delegate isNavigation:self atIndex:ii]) {
//            UIButton *button= [_buttons objectAtIndex:ii];
//            button.titleLabel.alpha = (ii == theIndex) ? 1.0 : 0.0;
        }
    }
}

- (void)scrollArrowTo:(NSInteger)theIndex animation:(BOOL)animation
{
    if (animation) {
        [UIView beginAnimations:@"arrow" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(scrollEnd)];
    }
    UIButton *button = [_buttons objectAtIndex:theIndex];
    if (_orientationType == CTTabbarOrientationHorizontal) {
        _arrow.frame = CGRectMake(button.frame.origin.x + (button.frame.size.width - _arrow.frame.size.width) / 2, _arrow.frame.origin.y, _arrow.frame.size.width, _arrow.frame.size.height);
    } else {
        _arrow.frame = CGRectMake(_arrow.frame.origin.x, button.frame.origin.y + (button.frame.size.height - _arrow.frame.size.height) / 2, _arrow.frame.size.width, _arrow.frame.size.height);
    }

    if (animation) {
        [UIView commitAnimations];
    }
    
//    UIButton *button = [_buttons objectAtIndex:theIndex];
//    _arrow.frame = CGRectMake(button.frame.origin.x + (button.frame.size.width - _arrow.frame.size.width) / 2, button.frame.origin.y, _arrow.frame.size.width, _arrow.frame.size.height);
//    _arrow.alpha = 0.0;
//    if (animation) {
//        [UIView beginAnimations:@"arrow" context:nil];
//        [UIView setAnimationDuration:0.3];
//        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
//        [UIView setAnimationDelegate:self];
//        [UIView setAnimationDidStopSelector:@selector(scrollEnd)];
//    }
//    _arrow.alpha = 1.0;
//    if (animation) {
//        [UIView commitAnimations];
//    }
}

- (void)scrollEnd
{
    //[self performSelector:@selector(hideTitle:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.3];
}

- (void)resetViewRect:(UIViewController *)controller
{
    CGRect rect = [_delegate superView:self].bounds;
    if (_notShow) {
        controller.view.frame = rect;
    } else {
        if (_orientationType == CTTabbarOrientationHorizontal) {
            controller.view.frame = CGRectMake(0, 0, CGRectGetWidth([_delegate superView:self].frame), [_delegate superView:self].frame.size.height - CGRectGetHeight(self.frame) + [_delegate realHeightMargin:self]);
        }
        else {
            controller.view.frame = CGRectMake(CGRectGetWidth(self.frame) - [_delegate realHeightMargin:self], 0, CGRectGetWidth([_delegate superView:self].frame) - CGRectGetWidth(self.frame) + [_delegate realHeightMargin:self], [_delegate superView:self].frame.size.height);
        }
    }
    if ([controller isKindOfClass:[UINavigationController class]]) {
        if (![(UINavigationController *)controller isNavigationBarHidden]) {
            [(UINavigationController *)controller navigationBar].frame = CGRectMake(0, 0, [(UINavigationController *)controller navigationBar].frame.size.width, [(UINavigationController *)controller navigationBar].frame.size.height);
        }
    }
}

- (void)resetCurrentViewRect
{
    if (_selected >= 0 && _selected < _count) {
        UIViewController *postController = [_controllers objectForKey:[_delegate xibName:self atIndex:_selected]];
        if (postController != nil && postController != (UIViewController *)[NSNull null]) {
            [self resetViewRect:postController];
        }
    }
}

- (void)hideTitle:(NSNumber *)animation
{
    if ([animation boolValue]) {
        [UIView beginAnimations:@"title" context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    }
    for (UIButton *button in _buttons) {
//        button.titleLabel.alpha = 0.0;
    }
    if ([animation boolValue]) {
        [UIView commitAnimations];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"notShow"]) {
        if (_selected >= 0 && _selected < _count) {
            UIViewController *postController = [_controllers objectForKey:[_delegate xibName:self atIndex:_selected]];
            if (postController != nil && postController != (UIViewController *)[NSNull null]) {
                [self resetViewRect:postController];
            }
        }
    }
}

- (void)buttonHighlighted:(id)sender
{
    NSInteger index = [_buttons indexOfObject:sender];
    if (index >= 0 && index < _count) {
        //[self showTitle:index];
        [self deselectItemExcept:_selected highlightIndex:index];
    }
}

- (void)buttonSelected:(id)sender
{
    NSInteger index = [_buttons indexOfObject:sender];
    if (index >= 0 && index < _count) {
        [self setSelectedIndex:index];
    }
}

- (void)buttonOutside:(id)sender
{
    [self hideTitle:[NSNumber numberWithBool:YES]];
}
@end
