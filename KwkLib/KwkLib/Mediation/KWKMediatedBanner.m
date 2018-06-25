//
//  KWKMediatedBanner.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 09/05/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKMediatedBanner.h"
#import "KWKMraidMediatedBanner.h"
#import "KWKAdMobMediatedBanner.h"

NSString* const kMraidBannerIdentifier = @"E";
NSString* const kAdMobBannerIdentifier = @"admob";

@implementation KWKMediatedBanner

- (instancetype) initWithAdData:(KWKAdData*) data
{
    if (self = [super init])
    {
        self.adData = data;
    }
    
    return self;
}

- (void) loadAdInView:(UIView *)container
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

+(id) mediatedBannerFromData:(KWKAdData*) data
{
    static NSDictionary* bannerAssoc = nil;
    static dispatch_once_t bannerAssocToken;
    dispatch_once(&bannerAssocToken, ^{
        bannerAssoc = @{
                        kMraidBannerIdentifier : @"KWKMraidMediatedBanner",
                        kAdMobBannerIdentifier : @"KWKAdMobMediatedBanner"
                        };
        
    });
    
    Class mediatedBannerClass = NSClassFromString([bannerAssoc objectForKey:data.adType]);
    id mediatedobj = nil;
    if (mediatedBannerClass)
    {
        mediatedobj = [[mediatedBannerClass alloc] initWithAdData:data];
    }
        
   
    
    return mediatedobj;
}

@end
