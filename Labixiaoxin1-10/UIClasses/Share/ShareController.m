//
//  ShareController.m
//  ComicLover
//
//  Created by Levin on 11/9/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import "ShareController.h"
#import "CustomNavigationBar.h"
#import "ErrorCodeUtils.h"
#import "HttpConstants.h"
#import "RIButtonItem.h"
#import "UIAlertView+Blocks.h"
#import "CustomNavigationBar.h"

#define TEXTLENGTH 140

@interface ShareController ()

@end

@implementation ShareController
- (NSInteger)weiboLenth:(NSString *)text
{
    int i = 0, n = [text length], l = 0, a = 0, b = 0;
    unichar c;
    for(i = 0; i < n; i++) {
        c = [text characterAtIndex:i];
        if (isblank(c)) {
            b++;
        } else if(isascii(c)){
            a++;
        } else {
            l++;
        }
    }
    if (a==0 && l==0) return 0;
    return l + (int)ceilf((float)(a+b)/2.0);
}

- (BOOL)canDoNextDetect
{
    int leftCharCount = TEXTLENGTH - [self weiboLenth:detailField.text];
    charCountLabel.text = [NSString stringWithFormat:@"%d", leftCharCount];
    if (leftCharCount < 0) {
        charCountLabel.textColor = [UIColor redColor];
    } else {
        charCountLabel.textColor = [UIColor darkGrayColor];
    }
    
    if ([detailField.text length] > 0 && [detailField.text length] <= TEXTLENGTH) {
        self.navigationItem.rightBarButtonItem.enabled = TRUE;
        return TRUE;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = FALSE;
        return FALSE;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    AppDelegate *delegate = [AppDelegate theAppDelegate];
    [delegate hideActivityView:_thePromptView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (_controllerId == nil) {
        _controllerId = [NSString stringWithFormat:@"%p", self];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sinaOauthSuccess:)
                                                 name:NOTIFICATION_OAUTH_WEIBO_BIND_SUCCESS
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sinaOauthFailed:)
                                                 name:NOTIFICATION_OAUTH_WEIBO_BIND_FAILED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(weiboUpdateResponse:)
                                                 name:HTTP_NOTIFICATION_W_UPDATE
                                               object:nil];
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(responseNewShare:)
//                                                 name:REQUEST_SHARETOWEB
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(weiboFriendsSelected:)
//                                                 name:WEIBO_FRIENDS_SELECTION_NOTIFY
//                                               object:nil];
    
    self.title = NSLocalizedString(@"分享", nil);
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage retina4ImageNamed:@"canvas.png"]];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage retina4ImageNamed:@"canvas.png"]];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([AppDelegate theAppDelegate].isIpad) {
        [backButton setBackgroundImage:[[UIImage retina4ImageNamed:@"button2.png"] stretchableImageWithLeftCapWidth:14.0 topCapHeight:15.0] forState:UIControlStateNormal];
    } else {
        [backButton setBackgroundImage:[[UIImage retina4ImageNamed:@"button.png"] stretchableImageWithLeftCapWidth:14.0 topCapHeight:15.0] forState:UIControlStateNormal];
    }
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
    backButton.frame = CGRectMake(0, 0, 56, 30);
    [(CustomNavigationBar *)self.navigationController.navigationBar setText:NSLocalizedString(@"取消", nil)
                                        onBackButton:backButton
                                        leftCapWidth:11.0];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([AppDelegate theAppDelegate].isIpad) {
        [doneButton setBackgroundImage:[[UIImage retina4ImageNamed:@"button2.png"] stretchableImageWithLeftCapWidth:14.0 topCapHeight:13.0] forState:UIControlStateNormal];
    } else {
        [doneButton setBackgroundImage:[[UIImage retina4ImageNamed:@"button.png"] stretchableImageWithLeftCapWidth:14.0 topCapHeight:13.0] forState:UIControlStateNormal];
    }
    // Set the title to use the same font and shadow as the standard back button
    doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    doneButton.titleLabel.textColor = [UIColor whiteColor];
    doneButton.titleLabel.shadowOffset = CGSizeMake(0,-1);
    doneButton.titleLabel.shadowColor = [UIColor darkGrayColor];
    // Set the break mode to truncate at the end like the standard back button
    doneButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
    // Inset the title on the left and right
    doneButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
    // Make the button as high as the passed in image
    doneButton.frame = CGRectMake(0, 0, 48, 28);
    [(CustomNavigationBar *)self.navigationController.navigationBar setText:NSLocalizedString(@"完成", @"")
                                        onBackButton:doneButton
                                        leftCapWidth:11.0];
    [doneButton addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:doneButton];
    
    detailField = [[UITextView alloc] initWithFrame:CGRectMake(8, 0, self.view.frame.size.width - 16 - 14, 110)];
    detailField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    detailField.delegate = self;
    detailField.scrollEnabled = YES;
    detailField.contentInset = UIEdgeInsetsZero;
    detailField.showsHorizontalScrollIndicator = NO;
    [detailField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [detailField setAutocorrectionType:UITextAutocorrectionTypeNo];
    detailField.font = [UIFont boldSystemFontOfSize:16.0f];
    NSString *format = NSLocalizedString(@"我正在用追漫画看《%@》，很方便，你们也来用吧", nil);
    if (self.shareType == ComicShareTypeVolum) {
        format = [NSString stringWithFormat:format, [NSString stringWithFormat:@"%@ %@", self.comicName, self.volumName]];
        detailField.text = format;
    } else {
        format = [NSString stringWithFormat:format, self.comicName];
        detailField.text = format;
    }
//    detailField.selectedRange = NSMakeRange(0, detailField.text.length);
    [detailField setBackgroundColor:[UIColor clearColor]];
//    atFriendButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [atFriendButton setImage:[UIImage imageNamed:@"atIcon.png"] forState:UIControlStateNormal];
//    [atFriendButton addTarget:self action:@selector(at:) forControlEvents:UIControlEventTouchUpInside];
//    atFriendButton.frame = CGRectMake(218, 115, 30, 30);
    
//    seperatorImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"seperator.png"]];
//    seperatorImage.frame = CGRectMake(253, 115, 2, 30);
    
    charCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(255, 115, 40, 30)];
    charCountLabel.textAlignment = UITextAlignmentCenter;
    charCountLabel.backgroundColor = [UIColor clearColor];
    charCountLabel.font = [UIFont systemFontOfSize:16.0];
    int leftCharCount = TEXTLENGTH - detailField.text.length;
    if (leftCharCount < 0) {
        charCountLabel.textColor = [UIColor redColor];
    } else {
        charCountLabel.textColor = [UIColor darkGrayColor];
    }
    [self canDoNextDetect];
    [detailField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([AppDelegate theAppDelegate].isIpad) {
        [MobClick beginLogPageView:@"iPad_分享"];
    } else {
        [MobClick beginLogPageView:@"iPhone_分享"];
    }
    
//    for (UIView *subView in self.testBar.subviews) {
//        if ([subView isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
//            [subView removeFromSuperview];
//        } else if ([subView isKindOfClass:NSClassFromString(@"UISegmentedControl")]) {
//            subView.hidden = YES;
//        } else if ([subView isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
//            for (UIView *sub in subView.subviews) {
//                sub.backgroundColor = [UIColor clearColor];
//                if ([sub isKindOfClass:NSClassFromString(@"UITextFieldBorderView")]) {
//                    [sub removeFromSuperview];
//                }
//            }
//        }
//    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([AppDelegate theAppDelegate].isIpad) {
        [MobClick endLogPageView:@"iPad_分享"];
    } else {
        [MobClick endLogPageView:@"iPhone_分享"];
    }
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([AppDelegate theAppDelegate].isIpad) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

- (IBAction)done:(id)sender
{
    [detailField resignFirstResponder];
    if ([[DataEngine sharedInstance].weibo isLoggedIn]) {
        [self sendShare];
    } else {
        [self startOauth];
    }
}

- (void)startOauth
{
    [[DataEngine sharedInstance].weibo logOut];
    [[DataEngine sharedInstance].weibo logIn];
}

- (void)sendShare
{
//    NSString *string = detailField.text;
//    NSString *url = [NSString stringWithFormat:@" %@", APP_URL];
//    if ([self weiboLenth:[string stringByAppendingString:url]] <= TEXTLENGTH) {
//        string = [string stringByAppendingString:url];
//    }
//    [[AppDelegate theAppDelegate] showActivityView:NSLocalizedString(@"发送中...", nil)
//                                            inView:[AppDelegate theAppDelegate].window];
//    [[DataEngine sharedInstance] updateWeibo:string
//                                      source:_controllerId];
}

- (IBAction)back:(id)sender
{
    if (self.backTarget && self.backSelector && [self.backTarget respondsToSelector:self.backSelector]) {
        [self.backTarget performSelector:self.backSelector];
    } else {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    [detailField removeFromSuperview];
    [charCountLabel removeFromSuperview];
//    [cell.contentView addSubview:atFriendButton];
//    [cell.contentView addSubview:seperatorImage];
    [cell.contentView addSubview:detailField];
    [cell.contentView addSubview:charCountLabel];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [detailField becomeFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (!_edited) {
        _edited = YES;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(canDoNextDetect) object:nil];
    [self performSelector:@selector(canDoNextDetect) withObject:nil afterDelay:0.1];
    
    return TRUE;
}


#pragma mark - UMSNSDataSendDelegate method

- (void)weiboUpdateResponse:(NSNotification *)notification
{
//    NSDictionary *dict = notification.object;
//    if (![[dict objectForKey:HTTP_KEYNAME_SOURCE_KEYS] containsObject:_controllerId]) {
//        return;
//    }
//    NSString *httpError = [ErrorCodeUtils getHttpError:dict];
//    
//    if (httpError && httpError.length > 0) {
//        [[AppDelegate theAppDelegate] showFinishActivityView:httpError
//                                                    interval:INTERVAL_SHOW_FAIL_MESSAGE
//                                                      inView:[AppDelegate theAppDelegate].window];
//    } else {
//        NSData *data = [dict objectForKey:Http_ReturnData];
//        NSDictionary *result = [JsonUtils JSONObjectWithData:data];
//        if (result) {
//            NSInteger error_code = [[result objectForKey:@"error_code"] intValue];
//            if (error_code == 21314     //Token已经被使用
//                || error_code == 21315  //Token已经过期
//                || error_code == 21316  //Token不合法
//                || error_code == 21317  //Token不合法
//                || error_code == 21327  //token过期
//                || error_code == 21332  //access_token 无效
//                || error_code == 21319) {
//                [[AppDelegate theAppDelegate] hideActivityView:[AppDelegate theAppDelegate].window];
//                
//                RIButtonItem *cancelItem = [RIButtonItem item];
//                cancelItem.label = NSLocalizedString(@"取消", nil);
//                cancelItem.action = ^{
//                };
//                
//                RIButtonItem *okItem = [RIButtonItem item];
//                okItem.label = NSLocalizedString(@"重新授权", nil);
//                okItem.action = ^{
//                    [self startOauth];
//                };
//                
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"您的新浪微博授权已过期，请重新授权😄", nil)
//                                                                message:nil
//                                                       cancelButtonItem:cancelItem
//                                                       otherButtonItems:okItem, nil];
//                
//                [alert show];
//            } else {
//                [self back:nil];
//                [[AppDelegate theAppDelegate] showFinishActivityView:NSLocalizedString(@"分享成功😄", nil)
//                                                            interval:INTERVAL_SHOW_FAIL_MESSAGE
//                                                              inView:[AppDelegate theAppDelegate].window];
//            }
//        } else {
//            [[AppDelegate theAppDelegate] showFinishActivityView:NSLocalizedString(@"分享失败😭", nil)
//                                                        interval:INTERVAL_SHOW_FAIL_MESSAGE
//                                                          inView:[AppDelegate theAppDelegate].window];
//        }
//    }
}

#pragma oauthDelegate
- (void)sinaOauthSuccess:(NSNotification *)notification
{
    [self sendShare];
}

- (void)sinaOauthFailed:(NSNotification *)notification
{
    [[AppDelegate theAppDelegate] showFailedActivityView:NSLocalizedString(@"新浪授权失败，请重试...", nil)
                                                interval:INTERVAL_SHOW_FAIL_MESSAGE
                                                  inView:[AppDelegate theAppDelegate].window];
}
@end
