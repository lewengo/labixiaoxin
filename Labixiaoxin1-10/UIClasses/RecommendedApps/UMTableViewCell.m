//
//  UMUFPTableViewCell.m
//  UFP
//
//  Created by liu yu on 2/13/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import "UMTableViewCell.h"
#import "UMUFPImageView.h"
#import <QuartzCore/QuartzCore.h>

#define kIconWidth 57.0f

@implementation UMTableViewCell

@synthesize mImageView = _mImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor blackColor];
        
        self.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.textColor = [UIColor blackColor];
        
        _mImageView = [[UMUFPImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"appIconEmpty.png"]];
		self.mImageView.frame = CGRectMake(20.0f, 6.0f, kIconWidth, kIconWidth);
		[self.contentView addSubview:self.mImageView];
    }
    return self;
}

- (void)setImageURL:(NSString*)urlStr
{    
	self.mImageView.imageURL = [NSURL URLWithString:urlStr];
}

- (void)dealloc
{
    _mImageView = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float topMargin = (self.bounds.size.height - kIconWidth) / 2;
    
    self.mImageView.frame = CGRectMake(15, topMargin, kIconWidth, kIconWidth);
    CGRect imageViewFrame = self.mImageView.frame;
    self.mImageView.layer.cornerRadius = 9.0;
    self.mImageView.layer.masksToBounds = YES;
    
    if ([self.mImageView.layer respondsToSelector:@selector(setShouldRasterize:)]) 
    {
        [self.mImageView.layer setShouldRasterize:YES]; 
        self.mImageView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    }
    
    if ([self.layer respondsToSelector:@selector(setShouldRasterize:)]) 
    {
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        [self.layer setShouldRasterize:YES];        
    }
    
    CGFloat leftMargin = imageViewFrame.origin.x + imageViewFrame.size.width + 15;
    
    self.textLabel.frame = CGRectMake(leftMargin, 
                                      topMargin + 8, 
                                      self.bounds.size.width - 110, 17);
    
    CGRect textLableFrame = self.textLabel.frame;
    self.detailTextLabel.numberOfLines = 0;
    self.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    
    CGFloat width = self.bounds.size.width - 90;
    self.detailTextLabel.frame = CGRectMake(leftMargin, 
                                            textLableFrame.origin.y + textLableFrame.size.height + 4, 
                                            width, 28);
}

@end