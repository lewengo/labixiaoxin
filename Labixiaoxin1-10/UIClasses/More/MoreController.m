//
//  MoreController.m
//  Labixiaoxin1-10
//
//  Created by Levin on 8/22/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import "MoreController.h"
#import "CustomNavigationBar.h"
#import "RecommendedApps.h"
#import "PhoneEngine.h"
#import "AboutController.h"

@interface MoreController ()

@end

@implementation MoreController

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
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage retina4ImageNamed:@"canvas.png"]];
    
//    CustomNavigationBar *customNavigationBar =  (CustomNavigationBar*)self.navigationController.navigationBar;
//    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [backButton setBackgroundImage:[[UIImage retina4ImageNamed:@"back.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
//    // Set the title to use the same font and shadow as the standard back button
//    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
//    backButton.titleLabel.textColor = [UIColor whiteColor];
//    backButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
//    backButton.titleLabel.shadowColor = [UIColor darkGrayColor];
//    // Set the break mode to truncate at the end like the standard back button
//    backButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
//    // Inset the title on the left and right
//    backButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
//    // Make the button as high as the passed in image
//    backButton.frame = CGRectMake(0, 0, 56, 28);
//    [customNavigationBar setText:[NSString stringWithFormat:@" %@", NSLocalizedString(@"Back", nil)] onBackButton:backButton leftCapWidth:10.0];
//    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.title = NSLocalizedString(@"更 多", nil);
    
    [shareButton setTitle:NSLocalizedString(@"分享给好友", nil)
                 forState:UIControlStateNormal];
    [recommendbutton setTitle:NSLocalizedString(@"精彩应用推荐", nil)
                     forState:UIControlStateNormal];
    [feedbackButton setTitle:NSLocalizedString(@"意见反馈", nil)
                    forState:UIControlStateNormal];
    [aboutButton setTitle:NSLocalizedString(@"关于漫画", nil)
                 forState:UIControlStateNormal];
    
    if (IS_IPAD) {
        UIImage *buttonBg = [UIImage retina4ImageNamed:@"moreButtonBg.png"];
        shareButton.frame = CGRectMake((CGRectGetWidth(self.view.frame) - buttonBg.size.width) / 2, 80, buttonBg.size.width, buttonBg.size.height);
        
        recommendbutton.frame = CGRectMake((CGRectGetWidth(self.view.frame) - buttonBg.size.width) / 2, 230, buttonBg.size.width, buttonBg.size.height);

        feedbackButton.frame = CGRectMake((CGRectGetWidth(self.view.frame) - buttonBg.size.width) / 2, 320, buttonBg.size.width, buttonBg.size.height);
        
        aboutButton.frame = CGRectMake((CGRectGetWidth(self.view.frame) - buttonBg.size.width) / 2, 410, buttonBg.size.width, buttonBg.size.height);
        
        [shareButton.titleLabel setFont:[UIFont boldSystemFontOfSize:35]];
        [recommendbutton.titleLabel setFont:[UIFont boldSystemFontOfSize:35]];
        [feedbackButton.titleLabel setFont:[UIFont boldSystemFontOfSize:35]];
        [aboutButton.titleLabel setFont:[UIFont boldSystemFontOfSize:35]];
    }
}

- (void)viewDidUnload
{
    recommendbutton = nil;
    feedbackButton = nil;
    aboutButton = nil;
    shareButton = nil;
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

- (IBAction)share:(id)sender {
    [[PhoneEngine sharedInstance] sendSMS:nil
                                     text:[NSString stringWithFormat:@"快来看%@吧，免费的应用 %@",
                                           NSLocalizedString(@"Book name", nil), APP_URL]];
}

- (IBAction)recommend:(id)sender
{
    RecommendedApps *recommended = [[RecommendedApps alloc] initWithNibName:@"RecommendedApps"
                                                                     bundle:nil];
    [self.navigationController pushViewController:recommended
                                         animated:YES];
}

- (IBAction)feedback:(id)sender
{
    [[PhoneEngine sharedInstance] showMail:@"manhualover@sina.cn"
                                   subject:NSLocalizedString(@"意见反馈", nil)
                                   content:nil];
}

- (IBAction)about:(id)sender
{
    AboutController *about = [[AboutController alloc] initWithNibName:@"AboutController" bundle:nil];
    [self.navigationController pushViewController:about animated:YES];
}
@end
