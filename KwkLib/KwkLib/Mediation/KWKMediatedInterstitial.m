//
//  KWKMediatedInterstitial.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 09/05/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKMediatedInterstitial.h"

NSString* const kMraidInterstitialIdentifier = @"E";
NSString* const kAdMobInterstitialIdentifier = @"admob";

@implementation KWKMediatedInterstitial

- (instancetype) initWithAdData:(KWKAdData*) data
{
   if (self = [super init])
   {
       self.adData = data;
   }
    
   return self;
}


- (void) loadAd
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void) launchInterstitial
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

+ (id)mediatedInterstitialFromData:(KWKAdData *)data
{
    //TODO static
    NSDictionary* interstitialAssoc = @{
                                        kMraidInterstitialIdentifier : @"KWKMraidMediatedInterstitial",
                                        kAdMobInterstitialIdentifier : @"KWKAdMobMediatedInterstitial"
                                        };
    
    Class mediatedInterstitialClass = NSClassFromString([interstitialAssoc objectForKey:data.adType]);
    id mediatedobj = nil;
    if (mediatedInterstitialClass)
    {
        mediatedobj = [[mediatedInterstitialClass alloc] initWithAdData:data];
    }
    
    return mediatedobj;
}


@end
