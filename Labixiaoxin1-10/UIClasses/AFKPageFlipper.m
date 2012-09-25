//
//  AFKPageFlipper.m
//  AFKPageFlipper
//
//  Created by Marco Tabini on 10-10-12.
//  Copyright 2010 AFK Studio Partnership. All rights reserved.
//
//  Modified by Reefaq Mohammed on 16/07/11.
 
//
#import "AFKPageFlipper.h"
#import "ColorHelper.h"

#pragma mark -
#pragma mark UIView helpers


@interface UIView(Extended) 

- (UIImage *) imageByRenderingView;

@end


@implementation UIView(Extended)


- (UIImage *)imageByRenderingView {
	CGFloat oldAlpha = self.alpha;
	
	self.alpha = 1;
	UIGraphicsBeginImageContext(self.bounds.size);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	self.alpha = oldAlpha;
	
	return resultingImage;
}

@end


#pragma mark -
#pragma mark Private interface

@interface AFKPageFlipper()

- (float)currentProgress:(CGPoint)currentPoint
            initialPoint:(CGPoint)theInitialPoint;

@end

@implementation AFKPageFlipper

#pragma mark -
#pragma mark Flip functionality

@synthesize pageDifference, numberOfPages, animating;

- (void)initFlip {
	// Create screenshots of view
	UIImage *currentImage = [self.currentView imageByRenderingView];
	UIImage *postImage = [self.postView imageByRenderingView];
	
	// Hide existing views
	[self.currentView setHidden:TRUE];
	[self.postView setHidden:TRUE];
	self.currentView.alpha = 0;
	self.postView.alpha = 0;
	
	// Create representational layers
	
	CGRect rect = self.bounds;
	rect.size.width /= 2;
	
	backgroundAnimationLayer = [CALayer layer];
	backgroundAnimationLayer.frame = self.bounds;
	backgroundAnimationLayer.zPosition = -300000;
	
	CALayer *leftLayer = [CALayer layer];
	leftLayer.frame = rect;
	leftLayer.masksToBounds = YES;
	leftLayer.contentsGravity = kCAGravityLeft;
	
	[backgroundAnimationLayer addSublayer:leftLayer];
	
	rect.origin.x = rect.size.width;
	
	CALayer *rightLayer = [CALayer layer];
	rightLayer.frame = rect;
	rightLayer.masksToBounds = YES;
	rightLayer.contentsGravity = kCAGravityRight;
	
	[backgroundAnimationLayer addSublayer:rightLayer];
	
	if (flipDirection == AFKPageFlipperDirectionRight) {
		leftLayer.contents = (id) [postImage CGImage];
		rightLayer.contents = (id) [currentImage CGImage];
	} else {
		leftLayer.contents = (id) [currentImage CGImage];
		rightLayer.contents = (id) [postImage CGImage];
	}
	
	[self.layer addSublayer:backgroundAnimationLayer];
	
	rect.origin.x = 0;
	
	flipAnimationLayer = [CATransformLayer layer];
	flipAnimationLayer.anchorPoint = CGPointMake(1.0, 0.5);
	flipAnimationLayer.frame = rect;
	
	blankFlipAnimationLayerOnLeft1 = [CATransformLayer layer];
	blankFlipAnimationLayerOnLeft1.anchorPoint = CGPointMake(1.0, 0.5);
	blankFlipAnimationLayerOnLeft1.frame = rect;
	blankFlipAnimationLayerOnLeft1.zPosition = -250000;
	
	blankFlipAnimationLayerOnRight1 = [CATransformLayer layer];
	blankFlipAnimationLayerOnRight1.anchorPoint = CGPointMake(1.0, 0.5);
	blankFlipAnimationLayerOnRight1.frame = rect;
	blankFlipAnimationLayerOnRight1.zPosition = 250000;
	
	
	blankFlipAnimationLayerOnLeft2 = [CATransformLayer layer];
	blankFlipAnimationLayerOnLeft2.anchorPoint = CGPointMake(1.0, 0.5);
	blankFlipAnimationLayerOnLeft2.frame = rect;
	blankFlipAnimationLayerOnLeft2.zPosition = -260000;
	
	blankFlipAnimationLayerOnRight2 = [CATransformLayer layer];
	blankFlipAnimationLayerOnRight2.anchorPoint = CGPointMake(1.0, 0.5);
	blankFlipAnimationLayerOnRight2.frame = rect;
	blankFlipAnimationLayerOnRight2.zPosition = 350000;
	
	[self.layer addSublayer:flipAnimationLayer];
	if (pageDifference > 1) {
		[self.layer addSublayer:blankFlipAnimationLayerOnLeft1];
		[self.layer addSublayer:blankFlipAnimationLayerOnRight1];
		if (pageDifference > 2) {
			[self.layer addSublayer:blankFlipAnimationLayerOnLeft2];
			[self.layer addSublayer:blankFlipAnimationLayerOnRight2];
		}
	}
	
	// start
	CALayer *blankBackLayerForLayerLeft = [CALayer layer];
	blankBackLayerForLayerLeft.frame = blankFlipAnimationLayerOnLeft1.bounds;
	blankBackLayerForLayerLeft.doubleSided = NO;
	blankBackLayerForLayerLeft.masksToBounds = YES;
	[blankFlipAnimationLayerOnLeft1 addSublayer:blankBackLayerForLayerLeft];
	
	CALayer *blankFrontLayerForLayerLeft = [CALayer layer];
	blankFrontLayerForLayerLeft.frame = blankFlipAnimationLayerOnLeft1.bounds;
	blankFrontLayerForLayerLeft.doubleSided = NO;
	blankFrontLayerForLayerLeft.masksToBounds = YES;
	blankFrontLayerForLayerLeft.transform = CATransform3DMakeRotation(M_PI, 0, 1.0, 0);
	[blankFlipAnimationLayerOnLeft1 addSublayer:blankFrontLayerForLayerLeft];
	
	
	CALayer *blankBackLayerForLayerRight = [CALayer layer];
	blankBackLayerForLayerRight.frame = blankFlipAnimationLayerOnRight1.bounds;
	blankBackLayerForLayerRight.doubleSided = NO;
	blankBackLayerForLayerRight.masksToBounds = YES;
	[blankFlipAnimationLayerOnRight1 addSublayer:blankBackLayerForLayerRight];
	
	CALayer *blankFrontLayerForLayerRight = [CALayer layer];
	blankFrontLayerForLayerRight.frame = blankFlipAnimationLayerOnRight1.bounds;
	blankFrontLayerForLayerRight.doubleSided = NO;
	blankFrontLayerForLayerRight.masksToBounds = YES;
	blankFrontLayerForLayerRight.transform = CATransform3DMakeRotation(M_PI, 0, 1.0, 0);
	[blankFlipAnimationLayerOnRight1 addSublayer:blankFrontLayerForLayerRight];
	// end	
	
	// start
	CALayer *blankBackLayerForLayerLeft2 = [CALayer layer];
	blankBackLayerForLayerLeft2.frame = blankFlipAnimationLayerOnLeft2.bounds;
	blankBackLayerForLayerLeft2.doubleSided = NO;
	blankBackLayerForLayerLeft2.masksToBounds = YES;
	[blankFlipAnimationLayerOnLeft2 addSublayer:blankBackLayerForLayerLeft2];
	
	CALayer *blankFrontLayerForLayerLeft2 = [CALayer layer];
	blankFrontLayerForLayerLeft2.frame = blankFlipAnimationLayerOnLeft2.bounds;
	blankFrontLayerForLayerLeft2.doubleSided = NO;
	blankFrontLayerForLayerLeft2.masksToBounds = YES;
	blankFrontLayerForLayerLeft2.transform = CATransform3DMakeRotation(M_PI, 0, 1.0, 0);
	[blankFlipAnimationLayerOnLeft2 addSublayer:blankFrontLayerForLayerLeft2];
	
	
	CALayer *blankBackLayerForLayerRight2 = [CALayer layer];
	blankBackLayerForLayerRight2.frame = blankFlipAnimationLayerOnRight2.bounds;
	blankBackLayerForLayerRight2.doubleSided = NO;
	blankBackLayerForLayerRight2.masksToBounds = YES;
	[blankFlipAnimationLayerOnRight2 addSublayer:blankBackLayerForLayerRight2];
	
	CALayer *blankFrontLayerForLayerRight2 = [CALayer layer];
	blankFrontLayerForLayerRight2.frame = blankFlipAnimationLayerOnRight2.bounds;
	blankFrontLayerForLayerRight2.doubleSided = NO;
	blankFrontLayerForLayerRight2.masksToBounds = YES;
	blankFrontLayerForLayerRight2.transform = CATransform3DMakeRotation(M_PI, 0, 1.0, 0);
	[blankFlipAnimationLayerOnRight2 addSublayer:blankFrontLayerForLayerRight2];
	// end	
	
	CALayer *backLayer = [CALayer layer];
	backLayer.frame = flipAnimationLayer.bounds;
	backLayer.doubleSided = NO;
	backLayer.masksToBounds = YES;
	[flipAnimationLayer addSublayer:backLayer];
	
	CALayer *frontLayer = [CALayer layer];
	frontLayer.frame = flipAnimationLayer.bounds;
	frontLayer.doubleSided = NO;
	frontLayer.masksToBounds = YES;
	frontLayer.transform = CATransform3DMakeRotation(M_PI, 0, 1.0, 0);
	[flipAnimationLayer addSublayer:frontLayer];
	

	// shadows
	frontLayerShadow = [CALayer layer];
	frontLayerShadow.frame = frontLayer.bounds;
	frontLayerShadow.doubleSided = NO;
	frontLayerShadow.masksToBounds = YES;
	frontLayerShadow.opacity = 0;
	frontLayerShadow.backgroundColor = [UIColor blackColor].CGColor;
	[frontLayer addSublayer:frontLayerShadow];

	backLayerShadow = [CALayer layer];
	backLayerShadow.frame = backLayer.bounds;
	backLayerShadow.doubleSided = NO;
	backLayerShadow.masksToBounds = YES;
	backLayerShadow.opacity = 0;
	backLayerShadow.backgroundColor = [UIColor blackColor].CGColor;
	[backLayer addSublayer:backLayerShadow];
	
	
	leftLayerShadow = [CALayer layer];
	leftLayerShadow.frame = leftLayer.bounds;
	leftLayerShadow.doubleSided = NO;
	leftLayerShadow.masksToBounds = YES;
	leftLayerShadow.opacity = 0.0;
	leftLayerShadow.backgroundColor = [UIColor blackColor].CGColor;
	[leftLayer addSublayer:leftLayerShadow];
	
	rightLayerShadow = [CALayer layer];
	rightLayerShadow.frame = rightLayer.bounds;
	rightLayerShadow.doubleSided = NO;
	rightLayerShadow.masksToBounds = YES;
	rightLayerShadow.opacity = 0.0;
	rightLayerShadow.backgroundColor = [UIColor blackColor].CGColor;
	[rightLayer addSublayer:rightLayerShadow];
	// shadows

	
	UIInterfaceOrientation orient = [UIApplication sharedApplication].statusBarOrientation;
	
	UIImage *flipImage;
	
	if (orient == UIInterfaceOrientationPortrait || orient == UIInterfaceOrientationPortraitUpsideDown) {
		flipImage = flipIllusionPortrait;
	} else if (orient == UIInterfaceOrientationLandscapeLeft || orient == UIInterfaceOrientationLandscapeRight) {
		flipImage = flipIllusionLandscape;
	}
	
	
	if (flipDirection == AFKPageFlipperDirectionRight) {
		
		backLayer.contents = (id) [currentImage CGImage];
		backLayer.contentsGravity = kCAGravityLeft;
		
		frontLayer.contents = (id) [postImage CGImage];
		frontLayer.contentsGravity = kCAGravityRight;
		
		CATransform3D transform = CATransform3DMakeRotation(0.0, 0.0, 1.0, 0.0);
		transform.m34 = 1.0f / 2500.0f;
		
		flipAnimationLayer.transform = transform;
		transform.m34 = 1.0f / 1500.0f;
		
		if (pageDifference > 1) {
			
			//start forlayer left
			UIImage* blankImgBLeft = flipImage;
			blankBackLayerForLayerLeft.contents = (id) [blankImgBLeft CGImage];
			blankBackLayerForLayerLeft.contentsGravity = kCAGravityLeft;
			
			UIView* blankViewFLeft = [[UIView alloc] initWithFrame:blankFlipAnimationLayerOnLeft1.bounds];
			[blankViewFLeft setBackgroundColor:RGBACOLOR(0,0,0,0)];
			UIImage* blankImgFLeft =  [blankViewFLeft imageByRenderingView];
			blankFrontLayerForLayerLeft.contents = (id) [blankImgFLeft CGImage];
			blankFrontLayerForLayerLeft.contentsGravity = kCAGravityRight;
			
			//start forlayer right
			UIView* blankViewBRight = [[UIView alloc] initWithFrame:blankFlipAnimationLayerOnRight1.bounds];
			[blankViewBRight setBackgroundColor:RGBACOLOR(0,0,0,0)];
			UIImage* blankImgBRight =  [blankViewBRight imageByRenderingView];
			blankBackLayerForLayerRight.contents = (id) [blankImgBRight CGImage];
			blankBackLayerForLayerRight.contentsGravity = kCAGravityLeft;
			
			UIImage* blankImgFRight = flipImage;
			frontLayer.contents = (id) [blankImgFRight CGImage];
			blankFrontLayerForLayerRight.contents = (id) [postImage CGImage];
			blankFrontLayerForLayerRight.contentsGravity = kCAGravityRight;
			
			
			CATransform3D transformblank = CATransform3DMakeRotation(0.0, 0.0, 1.0, 0.0);
			transformblank.m34 = 1.0f / 2500.0f;
			
			blankFlipAnimationLayerOnLeft1.transform = transformblank;
			blankFlipAnimationLayerOnRight1.transform = transformblank;
			transformblank.m34 = 1.0f / 1500.0f;
			
			//end
			
		}
		
		if (pageDifference > 2) {
			
			//start forlayer left
			UIImage* blankImgBLeft = flipImage;
			blankBackLayerForLayerLeft.contents = (id) [blankImgBLeft CGImage];
			blankBackLayerForLayerLeft.contentsGravity = kCAGravityLeft;
			
			UIView* blankViewFLeft = [[UIView alloc] initWithFrame:blankFlipAnimationLayerOnLeft1.bounds];
			[blankViewFLeft setBackgroundColor:RGBACOLOR(0,0,0,0)];
			UIImage* blankImgFLeft =  [blankViewFLeft imageByRenderingView];
			blankFrontLayerForLayerLeft.contents = (id) [blankImgFLeft CGImage];
			blankFrontLayerForLayerLeft.contentsGravity = kCAGravityRight;
			
			//start forlayer right
			UIView* blankViewBRight = [[UIView alloc] initWithFrame:blankFlipAnimationLayerOnRight1.bounds];
			[blankViewBRight setBackgroundColor:RGBACOLOR(0,0,0,0)];
			UIImage* blankImgBRight =  [blankViewBRight imageByRenderingView];
			blankBackLayerForLayerRight.contents = (id) [blankImgBRight CGImage];
			blankBackLayerForLayerRight.contentsGravity = kCAGravityLeft;
			
			UIImage* blankImgFRight = flipImage;
			blankFrontLayerForLayerRight.contents = (id) [blankImgFRight CGImage];
			blankFrontLayerForLayerRight.contentsGravity = kCAGravityRight;
			
			
			CATransform3D transformblank = CATransform3DMakeRotation(0.0, 0.0, 1.0, 0.0);
			transformblank.m34 = 1.0f / 2500.0f;
			
			blankFlipAnimationLayerOnLeft1.transform = transformblank;
			blankFlipAnimationLayerOnRight1.transform = transformblank;
			transformblank.m34 = 1.0f / 1500.0f;
			
			//end	
			
			//start forlayer left2
			UIImage* blankImgBLeft2 = flipImage;
			blankBackLayerForLayerLeft2.contents = (id) [blankImgBLeft2 CGImage];
			blankBackLayerForLayerLeft2.contentsGravity = kCAGravityLeft;
			
			UIView* blankViewFLeft2 = [[UIView alloc] initWithFrame:blankFlipAnimationLayerOnLeft2.bounds];
			[blankViewFLeft2 setBackgroundColor:RGBACOLOR(0, 0, 0, 0)];
			UIImage* blankImgFLeft2 =  [blankViewFLeft2 imageByRenderingView];
			blankFrontLayerForLayerLeft2.contents = (id) [blankImgFLeft2 CGImage];
			blankFrontLayerForLayerLeft2.contentsGravity = kCAGravityRight;
			
			//start forlayer right2
			UIView* blankViewBRight2 = [[UIView alloc] initWithFrame:blankFlipAnimationLayerOnRight2.bounds];
			[blankViewBRight2 setBackgroundColor:RGBACOLOR(0, 0, 0, 0)];
			UIImage* blankImgBRight2 =  [blankViewBRight2 imageByRenderingView];
			blankBackLayerForLayerRight2.contents = (id) [blankImgBRight2 CGImage];
			blankBackLayerForLayerRight2.contentsGravity = kCAGravityLeft;
			
			UIImage* blankImgFRight2 = flipImage;
			blankFrontLayerForLayerRight2.contents = (id) [postImage CGImage];
			frontLayer.contents = (id) [blankImgFRight2 CGImage];
			blankFrontLayerForLayerRight2.contentsGravity = kCAGravityRight;
			
			
			CATransform3D transformblank2 = CATransform3DMakeRotation(0.0, 0.0, 1.0, 0.0);
			transformblank2.m34 = 1.0f / 2500.0f;
			
			blankFlipAnimationLayerOnLeft2.transform = transformblank2;
			blankFlipAnimationLayerOnRight2.transform = transformblank2;
			transformblank2.m34 = 1.0f / 1500.0f;
			
			//end
			
		}
		
		currentAngle = startFlipAngle = 0;
		endFlipAngle = -M_PI;
	} else {
		
		backLayer.contentsGravity = kCAGravityLeft;
		backLayer.contents = (id) [postImage CGImage];
		
		frontLayer.contents = (id) [currentImage CGImage];
		frontLayer.contentsGravity = kCAGravityRight;
		
		CATransform3D transform = CATransform3DMakeRotation(-M_PI / 1.1 , 0.0, 1.0, 0.0);
		transform.m34 = -1.0f / 2500.0f;
		
		flipAnimationLayer.transform = transform;
		transform.m34 = -1.0f / 1500.0f;
		
		if (pageDifference > 1) {
			//start forlayer left
			UIView* blankViewBLeft = [[UIView alloc] initWithFrame:blankFlipAnimationLayerOnLeft1.frame];
			[blankViewBLeft setBackgroundColor:RGBACOLOR(0,0,0,0)];
			UIImage* blankImgBLeft =  [blankViewBLeft imageByRenderingView];
			blankBackLayerForLayerLeft.contents = (id) [blankImgBLeft CGImage];
			blankBackLayerForLayerLeft.contentsGravity = kCAGravityLeft;
			
			UIImage* blankImgFLeft = flipImage;
			blankFrontLayerForLayerLeft.contents = (id) [blankImgFLeft CGImage];
			blankFrontLayerForLayerLeft.contentsGravity = kCAGravityRight;
			
			//start forlayer right
			UIImage* blankImgBRight = flipImage;
			blankBackLayerForLayerRight.contents = (id) [postImage CGImage];
			backLayer.contents = (id) [blankImgBRight CGImage];
			blankBackLayerForLayerRight.contentsGravity = kCAGravityLeft;
			
			UIView* blankViewFRight = [[UIView alloc] initWithFrame:blankFlipAnimationLayerOnRight1.frame];
			[blankViewFRight setBackgroundColor:RGBACOLOR(0,0,0,0)];
			UIImage* blankImgFRight =  [blankViewFRight imageByRenderingView];
			blankFrontLayerForLayerRight.contents = (id) [blankImgFRight CGImage];
			blankFrontLayerForLayerRight.contentsGravity = kCAGravityLeft;
			
			CATransform3D transformblank = CATransform3DMakeRotation(-M_PI / 1.1, 0.0, 1.0, 0.0);
			transformblank.m34 = -1.0f / 2500.0f;
			
			blankFlipAnimationLayerOnLeft1.transform = transformblank;
			blankFlipAnimationLayerOnRight1.transform = transformblank;
			
			//end
			
		}
		
		if (pageDifference > 2) {
			
			//start forlayer left
			UIView* blankViewBLeft = [[UIView alloc] initWithFrame:blankFlipAnimationLayerOnLeft1.frame];
			[blankViewBLeft setBackgroundColor:RGBACOLOR(0,0,0,0)];
			UIImage* blankImgBLeft =  [blankViewBLeft imageByRenderingView];
			blankBackLayerForLayerLeft.contents = (id) [blankImgBLeft CGImage];
			blankBackLayerForLayerLeft.contentsGravity = kCAGravityLeft;
			
			UIImage* blankImgFLeft = flipImage;
			blankFrontLayerForLayerLeft.contents = (id) [blankImgFLeft CGImage];
			blankFrontLayerForLayerLeft.contentsGravity = kCAGravityRight;
			
			//start forlayer right
			UIImage* blankImgBRight = flipImage;
			blankBackLayerForLayerRight.contents = (id) [blankImgBRight CGImage];
			blankBackLayerForLayerRight.contentsGravity = kCAGravityLeft;
			
			UIView* blankViewFRight = [[UIView alloc] initWithFrame:blankFlipAnimationLayerOnRight1.frame];
			[blankViewFRight setBackgroundColor:RGBACOLOR(0,0,0,0)];
			UIImage* blankImgFRight =  [blankViewFRight imageByRenderingView];
			blankFrontLayerForLayerRight.contents = (id) [blankImgFRight CGImage];
			blankFrontLayerForLayerRight.contentsGravity = kCAGravityLeft;
			
			CATransform3D transformblank = CATransform3DMakeRotation(-M_PI / 1.1, 0.0, 1.0, 0.0);
			transformblank.m34 = -1.0f / 2500.0f;
			
			blankFlipAnimationLayerOnLeft1.transform = transformblank;
			blankFlipAnimationLayerOnRight1.transform = transformblank;
			
			//end
			
			//start2 forlayer left2
			UIView* blankViewBLeft2 = [[UIView alloc] initWithFrame:blankFlipAnimationLayerOnLeft2.frame];
			[blankViewBLeft2 setBackgroundColor:RGBACOLOR(255,255,255,0)];
			UIImage* blankImgBLeft2 =  [blankViewBLeft2 imageByRenderingView];
			blankBackLayerForLayerLeft2.contents = (id) [blankImgBLeft2 CGImage];
			blankBackLayerForLayerLeft2.contentsGravity = kCAGravityLeft;
			
			UIImage* blankImgFLeft2 = flipImage;
			blankFrontLayerForLayerLeft2.contents = (id) [blankImgFLeft2 CGImage];
			blankFrontLayerForLayerLeft2.contentsGravity = kCAGravityRight;
			
			//start forlayer right2
			UIImage* blankImgBRight2 = flipImage;
			blankBackLayerForLayerRight2.contents = (id) [postImage CGImage];
			backLayer.contents = (id) [blankImgBRight2 CGImage];
			blankBackLayerForLayerRight2.contentsGravity = kCAGravityLeft;
			
			UIView* blankViewFRight2 = [[UIView alloc] initWithFrame:blankFlipAnimationLayerOnRight2.frame];
			[blankViewFRight2 setBackgroundColor:RGBACOLOR(252,252,252,0)];
			UIImage* blankImgFRight2 =  [blankViewFRight2 imageByRenderingView];
			blankFrontLayerForLayerRight2.contents = (id) [blankImgFRight2 CGImage];
			blankFrontLayerForLayerRight2.contentsGravity = kCAGravityLeft;
			
			CATransform3D transformblank2 = CATransform3DMakeRotation(-M_PI / 1.1, 0.0, 1.0, 0.0);
			transformblank2.m34 = -1.0f / 2500.0f;
			
			blankFlipAnimationLayerOnLeft2.transform = transformblank2;
			blankFlipAnimationLayerOnRight2.transform = transformblank2;
			
			//end2			
		}
		
		currentAngle = startFlipAngle = -M_PI ;
		endFlipAngle = 0;
	}
}


- (void)cleanupFlip {
	[backgroundAnimationLayer removeFromSuperlayer];
	[flipAnimationLayer removeFromSuperlayer];
	if (pageDifference > 1) {
		[blankFlipAnimationLayerOnLeft1 removeFromSuperlayer];
		[blankFlipAnimationLayerOnRight1 removeFromSuperlayer];
		blankFlipAnimationLayerOnLeft1 = Nil;
		blankFlipAnimationLayerOnRight1 = Nil;
		
		if (pageDifference > 2) {
			[blankFlipAnimationLayerOnLeft2 removeFromSuperlayer];
			[blankFlipAnimationLayerOnRight2 removeFromSuperlayer];
			blankFlipAnimationLayerOnLeft2 = Nil;
			blankFlipAnimationLayerOnRight2 = Nil;
		}
	}
	backgroundAnimationLayer = Nil;
	flipAnimationLayer = Nil;
	
	animating = NO;
	
	if (setNewViewOnCompletion) {
		[self.currentView removeFromSuperview];
		self.currentView = self.postView;
		self.postView = Nil;
	} else {
		[self.postView removeFromSuperview];
		self.postView = Nil;
	}
	
	setNewViewOnCompletion = NO;
	[self.currentView setHidden:FALSE];
	self.currentView.alpha = 1;
	[self setDisabled:FALSE];
}



- (void)setFlipProgress3:(NSDictionary*)dict{
	
	float progress =[[dict objectForKey:@"PROGRESS"] floatValue];
	BOOL setDelegate = [[dict objectForKey:@"DELEGATE"] boolValue];
	BOOL animate = [[dict objectForKey:@"ANIMATE"] boolValue];
	
	
	float newAngle = startFlipAngle + progress * (endFlipAngle - startFlipAngle);
	float duration = animate ? 0.5 * fabs((newAngle - currentAngle) / (endFlipAngle - startFlipAngle)) : 0;
	
	duration = 0.5;
	
	CATransform3D endTransform = CATransform3DIdentity;
	endTransform.m34 = 1.0f / 2500.0f;
	endTransform = CATransform3DRotate(endTransform, newAngle, 0.0, 1.0, 0.0);	
	
	
	[blankFlipAnimationLayerOnLeft2 removeAllAnimations];
	
	[blankFlipAnimationLayerOnRight2 removeAllAnimations];
	
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:duration];
	blankFlipAnimationLayerOnLeft2.transform = endTransform;
	blankFlipAnimationLayerOnRight2.transform = endTransform;
	[UIView commitAnimations];
	
	if (setDelegate) {
		[self performSelector:@selector(cleanupFlip) withObject:Nil afterDelay:duration];
	}
}

- (void)setFlipProgress2:(NSDictionary*)dict{
	
	float progress =[[dict objectForKey:@"PROGRESS"] floatValue];
	BOOL setDelegate = [[dict objectForKey:@"DELEGATE"] boolValue];
	BOOL animate = [[dict objectForKey:@"ANIMATE"] boolValue];
	
	
	float newAngle = startFlipAngle + progress * (endFlipAngle - startFlipAngle);
	float duration = animate ? 0.5 * fabs((newAngle - currentAngle) / (endFlipAngle - startFlipAngle)) : 0;
	
	duration = 0.5;
	
	CATransform3D endTransform = CATransform3DIdentity;
	endTransform.m34 = 1.0f / 2500.0f;
	endTransform = CATransform3DRotate(endTransform, newAngle, 0.0, 1.0, 0.0);	
	
	
	[blankFlipAnimationLayerOnLeft1 removeAllAnimations];
	
	[blankFlipAnimationLayerOnRight1 removeAllAnimations];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:duration];
	blankFlipAnimationLayerOnLeft1.transform = endTransform;	
	blankFlipAnimationLayerOnRight1.transform = endTransform;
	[UIView commitAnimations];
	
	
	if (pageDifference > 2) {
		
		NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
		[dictionary setObject:[NSString stringWithFormat:@"%f",progress] forKey:@"PROGRESS"];
		[dictionary setObject:[NSString stringWithFormat:@"%d",setDelegate] forKey:@"DELEGATE"];
		[dictionary setObject:[NSString stringWithFormat:@"%d",animate] forKey:@"ANIMATE"];	
		
		[self performSelector:@selector(setFlipProgress3:) withObject:dictionary afterDelay:0.12];
	} else {
		if (setDelegate) {
			[self performSelector:@selector(cleanupFlip) withObject:Nil afterDelay:duration];
		}
	}
}

- (void)setFlipProgress:(float)progress setDelegate:(BOOL)setDelegate animate:(BOOL)animate {
#ifdef DEBUG
	NSLog(@"%f", progress);
#endif
	float newAngle = startFlipAngle + progress * (endFlipAngle - startFlipAngle);
	float duration = animate ? 0.5 * fabs((newAngle - currentAngle) / (endFlipAngle - startFlipAngle)) : 0;
	
	currentAngle = newAngle;
	
	CATransform3D endTransform = CATransform3DIdentity;
	endTransform.m34 = 1.0f / 2500.0f;
	endTransform = CATransform3DRotate(endTransform, newAngle, 0.0, 1.0, 0.0);	
	
	[flipAnimationLayer removeAllAnimations];
	
	// shadows
	CGFloat newShadowOpacity = progress;
	if (endFlipAngle > startFlipAngle) newShadowOpacity = 1.0 - progress;
	// shadows

	if (duration < 0.35) {
		duration = 0.35;
	}
	
	[UIView beginAnimations:@"FLIP1" context:nil];
	[UIView setAnimationDuration:duration];
	flipAnimationLayer.transform =  endTransform;
	
	// shadows
	frontLayerShadow.opacity = 1.0 - newShadowOpacity;
	backLayerShadow.opacity = newShadowOpacity;
	leftLayerShadow.opacity = 0.5 - newShadowOpacity;
	rightLayerShadow.opacity = newShadowOpacity - 0.5;
	// shadows
	[UIView commitAnimations];
	
	if (pageDifference > 1) {
		NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
		[dict setObject:[NSString stringWithFormat:@"%f",progress] forKey:@"PROGRESS"];
		[dict setObject:[NSString stringWithFormat:@"%d",setDelegate] forKey:@"DELEGATE"];
		[dict setObject:[NSString stringWithFormat:@"%d",animate] forKey:@"ANIMATE"];	
		
		[self performSelector:@selector(setFlipProgress2:) withObject:dict afterDelay:0.12];
	} else {
		if (setDelegate) {
			[self performSelector:@selector(cleanupFlip) withObject:Nil afterDelay:duration];
		}
	}
}

- (void)flipPage {
	[self setFlipProgress:1.0 setDelegate:YES animate:YES];
}


#pragma mark -
#pragma mark Animation management


- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[self cleanupFlip];
}


#pragma mark -
#pragma mark Properties

@synthesize currentView;
@synthesize postView;
@synthesize currentPage;


- (BOOL)doSetCurrentPage:(NSInteger)value {
	if (value == currentPage) {
		return FALSE;
	}
	
	flipDirection = value < currentPage ? AFKPageFlipperDirectionRight : AFKPageFlipperDirectionLeft;
	
	currentPage = value;
	
    if (self.postView) {
        [self.postView removeFromSuperview];
    }
	self.postView = [self.dataSource viewForPage:value inFlipper:self];
	
	[self addSubview:self.postView];
	
	return TRUE;
}	

- (void)setCurrentPage:(NSInteger)value {
    if (value > numberOfPages || value < 1) {
        return;
    }
	if (![self doSetCurrentPage:value]) {
		return;
	}
	
	setNewViewOnCompletion = YES;
	animating = NO;
	
	[self.postView setHidden:TRUE];
	self.postView.alpha = 0;
	
	[UIView beginAnimations:@"" context:Nil];
	[UIView setAnimationDuration:0.1];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	[self.postView setHidden:FALSE];	
	self.postView.alpha = 1;
	
	[UIView commitAnimations];
}


- (void)setCurrentPage:(NSInteger)value animated:(BOOL)animated {
    if (value > numberOfPages || value < 1) {
        return;
    }
	NSInteger tempPageDifference = fabs(value - currentPage);
	
	if (![self doSetCurrentPage:value]) {
		return;
	}
	
    pageDifference = tempPageDifference;
	setNewViewOnCompletion = YES;
	animating = YES;
	
	if (animated) {
		[self setDisabled:TRUE];
		[self initFlip];
        [self setFlipProgress:0.01 setDelegate:NO animate:NO];
		
		if (pageDifference > 1) {
			NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
			[dictionary setObject:[NSString stringWithFormat:@"%f",0.01] forKey:@"PROGRESS"];
			[dictionary setObject:[NSString stringWithFormat:@"%d",NO] forKey:@"DELEGATE"];
			[dictionary setObject:[NSString stringWithFormat:@"%d",NO] forKey:@"ANIMATE"];	
			
			//multi-flip-for 2
			[self setFlipProgress2:dictionary];
			
			if (pageDifference > 2) {
				//multi flip-for more than 2
				[self setFlipProgress3:dictionary];
			}
        }
		[self performSelector:@selector(flipPage) withObject:Nil afterDelay:0.000];
	} else {
		[self animationDidStop:Nil finished:[NSNumber numberWithBool:NO] context:Nil];
	}
	
}

@synthesize dataSource;

- (void)setDataSource:(NSObject <AFKPageFlipperDataSource>*)value {
	dataSource = value;
	numberOfPages = [dataSource numberOfPagesForPageFlipper:self];
    if (numberOfPages == 0) {
        [self cleanupFlip];
    }
	self.currentPage = 1;
}

@synthesize disabled;

- (void)setDisabled:(BOOL)value {
	disabled = value;
	self.userInteractionEnabled = !value;
	for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
		recognizer.enabled = !value;
	}
}

- (float)currentProgress:(CGPoint)currentPoint
            initialPoint:(CGPoint)theInitialPoint
{
    if (flipDirection == AFKPageFlipperDirectionLeft) {
        if (currentPoint.x >= theInitialPoint.x) {
            return 0.0;
        }
        float realRadius = fmax(theInitialPoint.x - CGRectGetWidth(self.frame) / 2, CGRectGetWidth(self.frame) / 2 * cos(M_PI_2 * 4 / 5));
        float offset = fmin(theInitialPoint.x - currentPoint.x, realRadius * 2);
        float angle = acos((realRadius - offset) / realRadius);
        return angle / M_PI;
    } else if (flipDirection == AFKPageFlipperDirectionRight) {
        if (currentPoint.x <= theInitialPoint.x) {
            return 0.0;
        }
        float realRadius = fmax(CGRectGetWidth(self.frame) / 2 - theInitialPoint.x, CGRectGetWidth(self.frame) / 2 * cos(M_PI_2 * 4 / 5));
        float offset = fmin(currentPoint.x - theInitialPoint.x, realRadius * 2);
        float angle = acos((realRadius - offset) / realRadius);
        return angle / M_PI;
    }
    return 0.0;
}

#pragma mark -
#pragma mark Touch management

- (void)panned:(UIPanGestureRecognizer *)recognizer {
	static BOOL hasFailed;
	static BOOL initialized;
	
	static NSInteger oldPage;
	
    CGPoint traslatOffset = [recognizer translationInView:self];
    float translation = traslatOffset.x;
    CGPoint currentPoint = [recognizer locationInView:self];
    
	pageDifference = 1;
	
	switch (recognizer.state) {
		case UIGestureRecognizerStateBegan:
			if (!animating) {
				hasFailed = FALSE;
				initialized = FALSE;
				animating = NO;
				setNewViewOnCompletion = NO;
                needReverse = NO;
			}
			break;
			
		case UIGestureRecognizerStateChanged:
			if (hasFailed) {
				return;
			}
			
            if (!initialized && traslatOffset.x == 0) {
                return;
            }
            
			if (!initialized) {
				oldPage = self.currentPage;
				
				if (translation > 0) {
					if (self.currentPage > 1) {
						[self doSetCurrentPage:self.currentPage - 1];
					} else {
						hasFailed = TRUE;
						return;
					}
				} else {
					if (self.currentPage < numberOfPages) {
						[self doSetCurrentPage:self.currentPage + 1];
					} else {
						hasFailed = TRUE;
						return;
					}
				}
				
				hasFailed = NO;
				initialized = TRUE;
				animating = YES;
				setNewViewOnCompletion = NO;
				
                _initialPoint = currentPoint;
                _initialPoint.x -= translation;
                
				[self initFlip];
			} else {
                if (flipDirection == AFKPageFlipperDirectionRight) {
                    if (currentPoint.x < _initialPoint.x) {
                        _initialPoint = currentPoint;
                    }
                    if (currentPoint.x < _lastPoint.x) {
                        needReverse = YES;
                    }
                } else if (flipDirection == AFKPageFlipperDirectionLeft) {
                    if (currentPoint.x > _initialPoint.x) {
                        _initialPoint = currentPoint;
                    }
                    if (currentPoint.x > _lastPoint.x) {
                        needReverse = YES;
                    }
                }
            }
			_lastPoint = currentPoint;
			[self setFlipProgress:fabs([self currentProgress:currentPoint initialPoint:_initialPoint]) setDelegate:NO animate:YES];
			break;
			
		case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
			[self setDisabled:TRUE];
			[self setFlipProgress:0.0 setDelegate:YES animate:YES];
			currentPage = oldPage;
			break;
			
		case UIGestureRecognizerStateRecognized:
			if (initialized) {
                BOOL reverse = NO;
                if (fabs([self currentProgress:currentPoint initialPoint:_initialPoint]) <= 0.5) {
                    reverse = needReverse;
                }
                
				if (hasFailed || reverse) {
					[self setDisabled:TRUE];
					[self setFlipProgress:0.0 setDelegate:YES animate:YES];
					currentPage = oldPage;
					return;
				}
				[self setDisabled:TRUE];
				setNewViewOnCompletion = YES;
				[self setFlipProgress:1.0 setDelegate:YES animate:YES];
                [dataSource pageShowed:currentPage inFlipper:self];
			}
			break;
        case UIGestureRecognizerStatePossible:
        default:
            break;
	}
}


#pragma mark -
#pragma mark Frame management


- (void)setFrame:(CGRect)value {
	super.frame = value;
    for (UIView *subview in self.subviews) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.10];
        subview.frame = self.bounds;
        [UIView commitAnimations];
    }
	numberOfPages = [dataSource numberOfPagesForPageFlipper:self];
	
	if (self.currentPage > numberOfPages) {
		self.currentPage = numberOfPages;
	}
}


#pragma mark -
#pragma mark Initialization and memory management


+ (Class)layerClass {
	return [CATransformLayer class];
}


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
		[panRecognizer setMaximumNumberOfTouches:1];
		[self addGestureRecognizer:panRecognizer];
		
		flipIllusionPortrait = [UIImage retina4ImageNamed:@"flip-illusion-oriented.jpg"];
		flipIllusionLandscape = [UIImage retina4ImageNamed:@"flip-illusion.png"];
		
		animating = FALSE;
    }
    return self;
}


- (void)dealloc {
	self.dataSource = Nil;
	self.currentView = Nil;
	self.postView = Nil;
}
@end
