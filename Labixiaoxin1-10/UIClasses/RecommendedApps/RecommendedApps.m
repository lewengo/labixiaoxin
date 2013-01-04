//
//  RecommendedApps.m
//  ComicLover
//
//  Created by levin wei on 9/3/12.
//  Copyright (c) 2012 MobileWoo. All rights reserved.
//

#import "RecommendedApps.h"
#import "CustomNavigationBar.h"
#import "UMTableViewCell.h"
#import "AppDelegate.h"

@interface RecommendedApps ()

@end

@implementation RecommendedApps

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
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];;
    [delegate hideActivityView:_thePromptView];
    
    _mTableView.dataLoadDelegate = nil;
    [_mTableView removeFromSuperview];
    _mTableView = nil;
    _mLoadingStatusLabel = nil;
    _mLoadingActivityIndicator = nil;
    _mNoNetworkImageView = nil;
    [_mLoadingWaitView removeFromSuperview];
    _mLoadingWaitView = nil;
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (_controllerId == nil) {
        _controllerId = [NSString stringWithFormat:@"%p", self];
    }
    _thePromptView = self.navigationController.view;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage retina4ImageNamed:@"canvas.png"]];
    self.title = NSLocalizedString(@"精彩推荐", nil);
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (IS_IPAD) {
        [backButton setBackgroundImage:[[UIImage retina4ImageNamed:@"back2.png"] stretchableImageWithLeftCapWidth:14.0 topCapHeight:15.0] forState:UIControlStateNormal];
        backButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    } else {
        [backButton setBackgroundImage:[[UIImage retina4ImageNamed:@"back.png"] stretchableImageWithLeftCapWidth:14.0 topCapHeight:15.0] forState:UIControlStateNormal];
        backButton.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
    }    // Set the title to use the same font and shadow as the standard back button
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
    [(CustomNavigationBar *)self.navigationController.navigationBar setText:[NSString stringWithFormat:@" %@", NSLocalizedString(@"返回", nil)] onBackButton:backButton leftCapWidth:13.0];
    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    _mTableView = [[UMUFPTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain appkey:UMeng_ID slotId:nil currentViewController:self];
    _mTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _mTableView.delegate = self;
    _mTableView.dataSource = self;
    _mTableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage retina4ImageNamed:@"canvas.png"]];
    _mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mTableView.dataLoadDelegate = (id<UMUFPTableViewDataLoadDelegate>)self;
    [self.view addSubview:_mTableView];
    
    //如果设置了tableview的dataLoadDelegate，请在viewController销毁时将tableview的dataLoadDelegate置空，这样可以避免一些可能的delegate问题，虽然我有在tableview的dealloc方法中将其置空
    
    _mLoadingWaitView = [[UIView alloc] initWithFrame:self.view.bounds];
    _mLoadingWaitView.backgroundColor = [UIColor colorWithPatternImage:[UIImage retina4ImageNamed:@"canvas.png"]];
    _mLoadingWaitView.autoresizesSubviews = YES;
    _mLoadingWaitView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    _mLoadingStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 300) / 2, 210, 300, 21)];
    _mLoadingStatusLabel.backgroundColor = [UIColor clearColor];
    _mLoadingStatusLabel.textColor = [UIColor blackColor];
    _mLoadingStatusLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
    _mLoadingStatusLabel.text = NSLocalizedString(@"获取数据中，请稍等...", nil);
    _mLoadingStatusLabel.textAlignment = UITextAlignmentCenter;
    _mLoadingStatusLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [_mLoadingWaitView addSubview:_mLoadingStatusLabel];
    
    _mLoadingActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _mLoadingActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    _mLoadingActivityIndicator.backgroundColor = [UIColor clearColor];
    _mLoadingActivityIndicator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _mLoadingActivityIndicator.frame = CGRectMake((self.view.bounds.size.width - 30) / 2, 170, 30, 30);
    [_mLoadingWaitView addSubview:_mLoadingActivityIndicator];
    
    [_mLoadingActivityIndicator startAnimating];
    
    [self.view insertSubview:_mLoadingWaitView aboveSubview:_mTableView];
    
    [_mTableView requestPromoterDataInBackground];
}

- (void)viewDidUnload
{
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

#pragma mark - UITableViewDataSource Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (!_mTableView.mIsAllLoaded && [_mTableView.mPromoterDatas count] > 0)
    {
        return [_mTableView.mPromoterDatas count] + 1;
    }
    else if (_mTableView.mIsAllLoaded && [_mTableView.mPromoterDatas count] > 0)
    {
        return [_mTableView.mPromoterDatas count];
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UMUFPTableViewCell";
    
    if (indexPath.row < [_mTableView.mPromoterDatas count]) {
        UMTableViewCell *cell = (UMTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UMTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        if (indexPath.row % 2 == 0) {
            cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage retina4ImageNamed:@"moreAppsBg1.png"] stretchableImageWithLeftCapWidth:160 topCapHeight:35]];
        } else {
            cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage retina4ImageNamed:@"moreAppsBg2.png"] stretchableImageWithLeftCapWidth:160 topCapHeight:35]];
        }
        
        NSDictionary *promoter = [_mTableView.mPromoterDatas objectAtIndex:indexPath.row];
        cell.textLabel.text = [promoter valueForKey:@"title"];
        cell.detailTextLabel.text = [promoter valueForKey:@"ad_words"];
        [cell setImageURL:[promoter valueForKey:@"icon"]];
        
        return cell;
    } else {
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"UMUFPTableViewCell2"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UMUFPTableViewCell2"];
            UIView *bgimageSel = [[UIView alloc] initWithFrame:cell.bounds];
            bgimageSel.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.4];
            cell.selectedBackgroundView = bgimageSel;
        }
        
        for (UIView *view in cell.subviews)
        {
            [view removeFromSuperview];
        }
        
        UILabel *addMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake((_mTableView.frame.size.width - 120) / 2, 20, 120, 30)];
        addMoreLabel.backgroundColor = [UIColor clearColor];
        addMoreLabel.textAlignment = UITextAlignmentCenter;
        addMoreLabel.font = [UIFont boldSystemFontOfSize:14];
        addMoreLabel.textColor = [UIColor blackColor];
        addMoreLabel.text = NSLocalizedString(@"加载中...", nil);
        [cell addSubview:addMoreLabel];
        
        UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingIndicator.backgroundColor = [UIColor clearColor];
        loadingIndicator.frame = CGRectMake(CGRectGetMinX(addMoreLabel.frame) - 30, 20, 30, 30);
        [loadingIndicator startAnimating];
        [cell addSubview:loadingIndicator];
        
        return cell;
    }    
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 71.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < [_mTableView.mPromoterDatas count])
    {
        NSDictionary *promoter = [_mTableView.mPromoterDatas objectAtIndex:indexPath.row];
        [_mTableView didClickPromoterAtIndex:promoter index:indexPath.row];
    }
}

#pragma mark - UMTableViewDataLoadDelegate methods

- (void)removeLoadingMaskView
{
    if ([_mLoadingWaitView superview]) {        
        [_mLoadingWaitView removeFromSuperview];
    }
}

- (void)loadDataFailed
{
    _mLoadingActivityIndicator.hidden = YES;
    
    if (!_mNoNetworkImageView) {
        UIImage *image = [UIImage retina4ImageNamed:@"um_nonetwork.png"];
        CGSize imageSize = image.size;
        _mNoNetworkImageView = [[UIImageView alloc] initWithFrame:CGRectMake((_mLoadingWaitView.bounds.size.width - imageSize.width) / 2, 80, imageSize.width, imageSize.height)];
        _mNoNetworkImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _mNoNetworkImageView.image = image;
    }
    
    if (![_mNoNetworkImageView superview]) {
        [_mLoadingWaitView addSubview:_mNoNetworkImageView];
    }
    
    _mLoadingStatusLabel.text = NSLocalizedString(@"抱歉，网络连接不畅，请稍后再试！", nil);
}

- (void)UMUFPTableViewDidLoadDataFinish:(UMUFPTableView *)tableview
                              promoters:(NSArray *)promoters
{
    if ([promoters count] > 0) {
        [self removeLoadingMaskView];
        [_mTableView reloadData];
    } else if ([_mTableView.mPromoterDatas count]) {
        [_mTableView reloadData];
    } else {
        [self loadDataFailed];
    }    
}

- (void)UMUFPTableView:(UMUFPTableView *)tableview
didLoadDataFailWithError:(NSError *)error
{
    if ([_mTableView.mPromoterDatas count]) {
        [_mTableView reloadData];
    } else {
        [self loadDataFailed];
    }
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint contentOffset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize contentSize = scrollView.contentSize;
    UIEdgeInsets contentInset = scrollView.contentInset;
    
    float y = contentOffset.y + bounds.size.height - contentInset.bottom;
    if (y > contentSize.height - 30) {
        if (!_mTableView.mIsAllLoaded && !_mTableView.mIsLoadingMore) {
            [_mTableView requestMorePromoterInBackground];
        }
    }    
}

@end
