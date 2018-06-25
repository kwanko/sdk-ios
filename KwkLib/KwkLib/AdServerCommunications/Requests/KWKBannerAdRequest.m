//
//  KWKBannerAdRequest.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 13/04/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKBannerAdRequest.h"

#define KWK_DEFAULT_REFRESH_RATE            5 * 60

NSString* const kKWKBannerCustomParamsRefreshRate = @"adRefresh";

@implementation KWKBannerAdRequest

- (KWKAdFormat) adFormat
{
    return KWK_AD_FORMAT_INLINE;
}

- (NSTimeInterval) refreshRate
{
    NSTimeInterval t = [[self.customParams objectForKey:kKWKBannerCustomParamsRefreshRate] doubleValue];
    if (t <= 0)
    {
        return KWK_DEFAULT_REFRESH_RATE;
    }
    
    return t;
}

@end
