//
//  UMTableViewDemo.m
//  UMAppNetwork
//
//  Created by liu yu on 12/17/11.
//  Copyright (c) 2011 Realcent. All rights reserved.
//

#import "UMTableViewDemo.h"
#import "UMTableViewCell.h"
#import "Constants.h"
#import "CustomNavigationBar.h"
    
@implementation UMTableViewDemo

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];    
}

#pragma mark - View lifecycle

- (IBAction)back:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)dealloc {
    _mTableView.dataLoadDelegate = nil;
    [_mTableView removeFromSuperview];
    _mTableView = nil;
    _mPromoterDatas = nil;
    _mLoadingStatusLabel = nil;
    _mLoadingActivityIndicator = nil;
    _mNoNetworkImageView = nil;
    [_mLoadingWaitView removeFromSuperview];
    _mLoadingWaitView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"精彩推荐";
    
    _mLoadingWaitView = [[UIView alloc] initWithFrame:self.view.bounds];
    _mLoadingWaitView.backgroundColor = [UIColor lightGrayColor];
    
    _mLoadingStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-300)/2, 240, 300, 21)];
    _mLoadingStatusLabel.backgroundColor = [UIColor clearColor];
    _mLoadingStatusLabel.textColor = [UIColor whiteColor];
    _mLoadingStatusLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15.0f];
    _mLoadingStatusLabel.text = @"正在加载数据，请稍等...";
    _mLoadingStatusLabel.textAlignment = UITextAlignmentCenter;
    [_mLoadingWaitView addSubview:_mLoadingStatusLabel];
    
    _mLoadingActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _mLoadingActivityIndicator.backgroundColor = [UIColor clearColor];
    _mLoadingActivityIndicator.frame = CGRectMake((self.view.bounds.size.width-30)/2, 190, 30, 30);
    [_mLoadingWaitView addSubview:_mLoadingActivityIndicator];
    
    [_mLoadingActivityIndicator startAnimating];
    
    _mPromoterDatas = [[NSMutableArray alloc] init];
    
    _mTableView =  [[UMUFPTableView alloc] initWithFrame:self.view.bounds
                                                   style:UITableViewStylePlain
                                                  appkey:UMeng_ID
                                                  slotId:nil
                                   currentViewController:self];
    _mTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _mTableView.delegate = self;
    _mTableView.dataSource = self;
    _mTableView.dataLoadDelegate = (id<UMUFPTableViewDataLoadDelegate>)self;
    _mTableView.backgroundColor = [UIColor colorWithRed:73 / 255.0
                                                  green:73 / 255.0
                                                   blue:73 / 255.0
                                                  alpha:1.0];
    [self.view addSubview:_mTableView];
    
    //如果设置了tableview的dataLoadDelegate，请在viewController销毁时将tableview的dataLoadDelegate置空，这样可以避免一些可能的delegate问题，虽然我有在tableview的dealloc方法中将其置空
    
    [self.view insertSubview:_mLoadingWaitView aboveSubview:_mTableView];
    
    [_mTableView requestPromoterDataInBackground];
    
    CustomNavigationBar *customNavigationBar =  (CustomNavigationBar*)self.navigationController.navigationBar;
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[[UIImage imageNamed:@"back.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateNormal];
    //    [commentButton setBackgroundImage:[[UIImage imageNamed:@"button_selected.png"] stretchableImageWithLeftCapWidth:20.0 topCapHeight:16.0] forState:UIControlStateHighlighted];
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
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource Delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (!_mTableView.mIsAllLoaded && [_mPromoterDatas count] > 0)
    {
        return [_mPromoterDatas count] + 1;
    }
    else if (_mTableView.mIsAllLoaded && [_mPromoterDatas count] > 0)
    {
        return [_mPromoterDatas count];
    }
    else 
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UMUFPTableViewCell";
    
    if (indexPath.row < [_mPromoterDatas count])
    {
        UMTableViewCell *cell = (UMTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UMTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        NSDictionary *promoter = [_mPromoterDatas objectAtIndex:indexPath.row];
        cell.textLabel.text = [promoter valueForKey:@"title"];
        cell.detailTextLabel.text = [promoter valueForKey:@"ad_words"];
        [cell setImageURL:[promoter valueForKey:@"icon"]];
        if (indexPath.row % 2 == 0) {
            cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"moreAppsBg1.png"] stretchableImageWithLeftCapWidth:160 topCapHeight:35]];
        } else {
            cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"moreAppsBg2.png"] stretchableImageWithLeftCapWidth:160 topCapHeight:35]];
        }
        return cell;
    }
    else
    {
        UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"UMUFPTableViewCell2"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UMUFPTableViewCell2"];
        }
        
        UILabel *addMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 20, 120, 30)];
        addMoreLabel.backgroundColor = [UIColor clearColor];
        addMoreLabel.textAlignment = UITextAlignmentCenter;
        addMoreLabel.font = [UIFont boldSystemFontOfSize:14];
        addMoreLabel.text = @"加载中...";
        [cell.contentView addSubview:addMoreLabel];
        
        UIActivityIndicatorView *loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadingIndicator.backgroundColor = [UIColor clearColor];
        loadingIndicator.frame = CGRectMake(115, 20, 30, 30);
        [loadingIndicator startAnimating];
        [cell.contentView addSubview:loadingIndicator];
        return cell;
    }    
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 70.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < [_mPromoterDatas count])
    {
        NSDictionary *promoter = [_mPromoterDatas objectAtIndex:indexPath.row];
        [_mTableView didClickPromoterAtIndex:promoter index:indexPath.row];
    }
}

#pragma mark - UMTableViewDataLoadDelegate methods

- (void)removeLoadingMaskView {
    
    if ([_mLoadingWaitView superview])
    {        
        [_mLoadingWaitView removeFromSuperview];
    }
}

- (void)loadDataFailed {
    
    _mLoadingActivityIndicator.hidden = YES;
    
    if (!_mNoNetworkImageView)
    {
        UIImage *image = [UIImage imageNamed:@"um_no_network.png"];
        CGSize imageSize = image.size;
        _mNoNetworkImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - imageSize.width) / 2, 100, imageSize.width, imageSize.height)];
        _mNoNetworkImageView.image = image;
    }
    
    if (![_mNoNetworkImageView superview])
    {
        [_mLoadingWaitView addSubview:_mNoNetworkImageView];
    }
    
    _mLoadingStatusLabel.text = @"抱歉，网络连接不畅，请稍后再试！";
}

- (void)UMUFPTableViewDidLoadDataFinish:(UMUFPTableView *)tableview promoters:(NSArray *)promoters {
    
    if ([promoters count] > 0)
    {
        [self removeLoadingMaskView];
        
        [_mPromoterDatas addObjectsFromArray:promoters];
        [_mTableView reloadData];
    }  
    else if ([_mPromoterDatas count])
    {
        [_mTableView reloadData];
    }
    else 
    {
        [self loadDataFailed];
    }    
}

- (void)UMUFPTableView:(UMUFPTableView *)tableview didLoadDataFailWithError:(NSError *)error {
    
    if ([_mPromoterDatas count])
    {
        [_mTableView reloadData];
    }
    else 
    {
        [self loadDataFailed];
    }
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint contentOffset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize contentSize = scrollView.contentSize;
    UIEdgeInsets contentInset = scrollView.contentInset;
    
    float y = contentOffset.y + bounds.size.height - contentInset.bottom;
    if (y > contentSize.height-30) 
    {
        if (!_mTableView.mIsAllLoaded && !_mTableView.mIsLoadingMore)
        {
            [_mTableView requestMorePromoterInBackground];
        }
    }    
}

@end