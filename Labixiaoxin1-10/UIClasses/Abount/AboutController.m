//
//  AboutController.m
//  Labixiaoxin1-10
//
//  Created by levin wei on 8/23/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import "AboutController.h"
#import "CustomNavigationBar.h"

@interface AboutController ()

@end

@implementation AboutController
@synthesize aboutLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)back:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage retina4ImageNamed:@"canvas.png"]];
    // Do any additional setup after loading the view from its nib.
    CustomNavigationBar *customNavigationBar =  (CustomNavigationBar*)self.navigationController.navigationBar;
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[[UIImage retina4ImageNamed:@"back.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
    //    [commentButton setBackgroundImage:[[UIImage retina4ImageNamed:@"button_selected.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
    // Set the title to use the same font and shadow as the standard back button
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    backButton.titleLabel.textColor = [UIColor whiteColor];
    backButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
    backButton.titleLabel.shadowColor = [UIColor darkGrayColor];
    // Set the break mode to truncate at the end like the standard back button
    backButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    // Inset the title on the left and right
    backButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
    // Make the button as high as the passed in image
    backButton.frame = CGRectMake(0, 0, 56, 28);
    [customNavigationBar setText:[NSString stringWithFormat:@" %@", NSLocalizedString(@"Back", nil)] onBackButton:backButton leftCapWidth:10.0];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.title = NSLocalizedString(@"关于漫画", nil);
    
    aboutLabel.text = NSLocalizedString(@"    本漫画内容均来自于互联网，所有图片资料只供学习交流试看，本App与内容的出处无关，如有侵犯到您的权益，请联系zhuimanhua@sina.com，我们会马上处理。", nil);
    
    if (IS_IPAD) {
        aboutLabel.font = [UIFont systemFontOfSize:25];
        aboutLabel.frame = CGRectMake(20, 40, CGRectGetWidth(self.view.frame) - 40, CGRectGetHeight(aboutLabel.frame));
    }
    CGSize opSize = [aboutLabel.text sizeWithFont:aboutLabel.font constrainedToSize:CGSizeMake(CGRectGetWidth(aboutLabel.frame), MAXFLOAT)];
    aboutLabel.frame = CGRectMake(CGRectGetMinX(aboutLabel.frame), CGRectGetMinY(aboutLabel.frame), CGRectGetWidth(aboutLabel.frame), opSize.height);
}

- (void)viewDidUnload
{
    [self setAboutLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (IS_IPAD) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

@end
