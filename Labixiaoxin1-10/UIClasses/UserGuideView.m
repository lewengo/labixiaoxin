//
//  UserGuideView.m
//  ThreeHundred
//
//  Created by Levin on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UserGuideView.h"

#define SCROLLVIEWTAG 9999

#define USERGUIDEIMAGECOUNT 4
#define USERGUIDEPAGECONTROLTAG 10000

#define FLOATGUIDEIMAGECOUNT 3
#define FLOATICONTAG 10001

@interface UserGuideView ()
{
    NSArray *pointArray;
}
- (IBAction)clickOk:(id)sender;
- (void)arrangeGuides;
- (void)arrangeFloatGuides;

- (void)calFloatViewPosition;
@end

@implementation UserGuideView

- (id)initWithDelegate:(id<UserGuideFinishDelegate>)delegate
{
    if (self = [super init]) {
        _currentType = -1;
        _delegate = delegate;
    }
    return self;
}

- (IBAction)clickOk:(id)sender
{
    if (_currentType >= kUserGuideTypeFirst && _currentType < kUserGuideTypeLast) {
        if (![sender isKindOfClass:[UITapGestureRecognizer class]]) {
            return;
        }
        UITapGestureRecognizer *reco = (UITapGestureRecognizer *)sender;
        if ([reco view].tag == 1) {
            [[reco view] removeFromSuperview];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userGuide2.png"]];
            imageView.tag = 2;
            imageView.frame = _backgroundView.bounds;
            [_backgroundView addSubview:imageView];
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickOk:)];
            tapGesture.delegate = self;
            [imageView addGestureRecognizer:tapGesture];
            imageView.userInteractionEnabled = YES;
        } else {
            [_backgroundView removeFromSuperview];
            [_delegate UserGuideFinished:_currentType];
            _currentType = -1;
        }
    }
}

- (void)dealloc
{
    _delegate = nil;
}

- (void)showGuide:(NSInteger)type withSuperView:(UIView *)superView
{
    _currentType = type;
    switch (type) {
        case kUserGuideTypeFirst:
        {
            if (_backgroundView == nil) {
                _backgroundView = [[UIView alloc] initWithFrame:superView.bounds];
            }
            [_backgroundView removeFromSuperview];
            _superView = superView;
            [self arrangeGuides];
            break;
        }
        case kUserGuideTypeSeconde:
        {
            if (_backgroundView == nil) {
                _backgroundView = [[UIView alloc] initWithFrame:superView.bounds];
            }
            [_backgroundView removeFromSuperview];
            _superView = superView;
            [self arrangeFloatGuides];
        }
        default:
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)thisScroll
{
//    NSInteger roundedValue = (NSInteger)round(thisScroll.contentOffset.x / thisScroll.frame.size.width);
//    PageControl *imageDot = (PageControl *)[_backgroundView viewWithTag:USERGUIDEPAGECONTROLTAG];
//    if (imageDot.currentPage != roundedValue && roundedValue >= 0 && roundedValue < imageDot.numberOfPages) {
//        imageDot.currentPage = roundedValue;
//    }
//    
//    if (_currentType == kUserGuideTypeSeconde) {
//        [self calFloatViewPosition];
//    }
}

- (void)arrangeGuides
{
    if (IS_IPAD) {
#ifdef Is_Only_Portrait
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userGuide2.png"]];
#else
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userGuide2-Landscape.png"]];
#endif
        imageView.tag = 2;
        imageView.frame = _backgroundView.bounds;
        [_backgroundView addSubview:imageView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickOk:)];
        tapGesture.delegate = self;
        [imageView addGestureRecognizer:tapGesture];
        imageView.userInteractionEnabled = YES;
    } else {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userGuide1.png"]];
        imageView.tag = 1;
        imageView.frame = _backgroundView.bounds;
        [_backgroundView addSubview:imageView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickOk:)];
        tapGesture.delegate = self;
        [imageView addGestureRecognizer:tapGesture];
        imageView.userInteractionEnabled = YES;
    }
    
    [_superView addSubview:_backgroundView];
    [_superView bringSubviewToFront:_backgroundView];
}

- (void)arrangeFloatGuides
{
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userGuideBackground.jpg"]];
    [_backgroundView addSubview:backgroundImage];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.delegate = self;
    scrollView.tag = SCROLLVIEWTAG;
    scrollView.contentSize = CGSizeMake(FLOATGUIDEIMAGECOUNT * 320, 460);
    for (int ii = 0; ii < FLOATGUIDEIMAGECOUNT; ii++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(ii * 320, 0, 320, 460)];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"floatUserGuide%d.jpg", ii]];
        imageView.tag = ii;
        [scrollView addSubview:imageView];
    }
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton addTarget:self action:@selector(clickOk:) forControlEvents:UIControlEventTouchUpInside];
    closeButton.frame = CGRectMake((FLOATGUIDEIMAGECOUNT - 1) * 320 + 82, 359, 156, 56);
    [scrollView addSubview:closeButton];
    
    [_backgroundView addSubview:scrollView];
    
    UIImageView *floatView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"floatIcon.png"]];
    floatView.tag = FLOATICONTAG;
    floatView.frame = CGRectMake(floatView.frame.origin.x, floatView.frame.origin.y, floatView.frame.size.width / 2, floatView.frame.size.height / 2);
    [_backgroundView addSubview:floatView];
    
    pointArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:CGPointMake(20, 20)], [NSValue valueWithCGPoint:CGPointMake(200, 200)], [NSValue valueWithCGPoint:CGPointMake(100, 100)], nil];
    
//    PageControl *imageDot = [[PageControl alloc] initWithFrame:CGRectMake(0, 410, 320, 36)];
//    imageDot.numberOfPages = USERGUIDEIMAGECOUNT;
//    imageDot.currentPage = 0;
//    imageDot.tag = USERGUIDEPAGECONTROLTAG;
//    imageDot.image = [UIImage imageNamed:@"userGuide_off.png"];
//    imageDot.selectedImage = [UIImage imageNamed:@"userGuide_on.png"];
//    imageDot.padding = 5;
    
//    [_backgroundView addSubview:imageDot];   
    
    [_superView addSubview:_backgroundView];
    [_superView bringSubviewToFront:_backgroundView];
    
    [self calFloatViewPosition];
}

- (void)calFloatViewPosition
{
    if (_currentType == kUserGuideTypeSeconde) {
        UIScrollView *view = (UIScrollView *)[_backgroundView viewWithTag:SCROLLVIEWTAG];
        if (view == nil) {
            return;
        }
        if (pointArray.count < FLOATGUIDEIMAGECOUNT) {
            return;
        }
        UIImageView *floatView = (UIImageView *)[_backgroundView viewWithTag:FLOATICONTAG];
        if (floatView == nil) {
            return;
        }
        CGPoint offset = view.contentOffset;
        CGPoint resultPosistion = CGPointZero;
        if (offset.x <= 0) {
            resultPosistion = [[pointArray objectAtIndex:0] CGPointValue];
        } else if (offset.x >= (FLOATGUIDEIMAGECOUNT - 1) * 320) {
            resultPosistion = [[pointArray objectAtIndex:FLOATGUIDEIMAGECOUNT - 1] CGPointValue];
        } else {
            NSInteger index = offset.x / 320;
            CGPoint prePoint = [[pointArray objectAtIndex:index] CGPointValue];
            CGPoint postPoint = [[pointArray objectAtIndex:index + 1] CGPointValue];
            CGFloat delta = ((NSInteger)offset.x) % 320;
            resultPosistion = CGPointMake(delta * (postPoint.x - prePoint.x) / 320 + prePoint.x, delta * (postPoint.y - prePoint.y) / 320 + prePoint.y);
            
        }
        floatView.center = CGPointMake((resultPosistion.x + floatView.frame.size.width) / 2, (resultPosistion.y + floatView.frame.size.height) / 2);
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
@end
