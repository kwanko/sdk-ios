//
//  KWKParallaxTableViewCell.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 06/04/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKParallaxTableViewCell.h"
#import "KWKParallaxBannerView.h"

@interface KWKParallaxTableViewCell()

@property (nonatomic, strong) KWKParallaxBannerView* banner;


@end

@implementation KWKParallaxTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self setupBanner];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    //this type of cell cannot be selected.
}

- (void) setupBanner
{
    if (_banner == nil)
    {
        _banner = [[KWKParallaxBannerView alloc] init];
        [_banner setBackgroundColor:[UIColor clearColor]];
        [_banner setAutoresizingMask: UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [_banner setFrame:self.contentView.frame];
        
        [self.contentView addSubview:_banner];
        [self.contentView bringSubviewToFront:_banner];
        
    }
};

- (void) setParentScrollView:(__weak UIScrollView*) parentScrollView
{
    [self setupBanner];
    [_banner setParentScrollView:parentScrollView];
}

- (void)loadAdForRequest:(KWKParallaxBannerAdRequest *)adRequest;
{
    [self setupBanner];
    [_banner loadAdForRequest:adRequest];
}

@end
