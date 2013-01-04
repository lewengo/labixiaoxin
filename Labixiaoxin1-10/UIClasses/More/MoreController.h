//
//  MoreController.h
//  Labixiaoxin1-10
//
//  Created by Levin on 8/22/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreController : UIViewController
{
    
    IBOutlet UIButton *shareButton;
    IBOutlet UIButton *recommendbutton;
    IBOutlet UIButton *feedbackButton;
    IBOutlet UIButton *aboutButton;
    
}

- (IBAction)share:(id)sender;
- (IBAction)recommend:(id)sender;
- (IBAction)feedback:(id)sender;
- (IBAction)about:(id)sender;

@end
