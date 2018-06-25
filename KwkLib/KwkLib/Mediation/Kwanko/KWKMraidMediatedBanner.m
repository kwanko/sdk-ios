//
//  KWKMraidMediatedBanner.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 12/05/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKMraidMediatedBanner.h"
#import "KWKMraidAdView.h"

@interface KWKMraidMediatedBanner()<KWKAdBaseViewDelegate>
@property (nonatomic, strong) KWKMraidAdView* adView;

@end

@implementation KWKMraidMediatedBanner

- (void)loadAdInView:(UIView *)container
{
    //internal banner does not load anything so delegate call is done directly
    if ([self.bannerDelegate respondsToSelector:@selector(didLoadMediatedBanner:)])
    {
        [self.bannerDelegate didLoadMediatedBanner:self];
    }
    
    [self.adView removeFromSuperview];
    
    if (container)
    {
        self.adView = [[KWKMraidAdView alloc] initWithFrame:CGRectMake(0, 0, container.frame.size.width, container.frame.size.height) andData:self.adData];
        self.adView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        [container addSubview:self.adView];
        self.adView.adDelegate = self;
        
        if ([self.bannerDelegate respondsToSelector:@selector(didDisplayMediatedBanner:)])
        {
            [self.bannerDelegate didDisplayMediatedBanner: self];
        }
    }
    else
    {
        if ([self.bannerDelegate respondsToSelector:@selector(didFailToDisplayMediatedBanner:)])
        {
            [self.bannerDelegate didFailToDisplayMediatedBanner:self];
        }
    }
}

#pragma mark KWKADBaseViewDelegate -

- (KWKAdContainerType)containerType
{
    return KWK_AD_CONTAINER_TYPE_BANNER;
}


- (void) containerDidClose
{
    [self.adView removeFromSuperview];
}


@end
