//
//  KWKBannerView.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 13/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKBannerView.h"
#import "KWKAdProvider.h"
#import "KWKAdRequest+Private.h"
#import "KWKGlobals.h"
#import "KWKMraidAdView.h"
#import "KWKMediatedBanner.h"
#import "KwkLibDefines.h"

@interface KWKBannerView()<KWKMediatedBannerProtocol>
{
    KWKAdProvider* _adProvider;
}

@property (nonatomic, strong) KWKBannerAdRequest* adRequest;


@end

@implementation KWKBannerView


- (KWKAdProvider*) adProvider
{
    if (_adProvider == nil)
    {
        _adProvider = [[KWKAdProvider alloc] init];
    }
    
    return _adProvider;
}

- (void) loadAdForRequest:(KWKBannerAdRequest*) adRequest;
{
    self.adRequest = adRequest;
    self.adRequest.size = self.frame.size;
  
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self loadCurrentRequest];
}

- (void) loadCurrentRequest
{
    if (self.adRequest.refreshRate)
    {
        [self performSelector:@selector(loadCurrentRequest) withObject:nil afterDelay:self.adRequest.refreshRate];
    }
    
    __weak __typeof__(self) weakSelf = self;
    [self.adProvider loadAdForRequestWithRequest:self.adRequest completion:^(KWKAdData *adData, NSError *error)
     {
         //clear any other displayed ads
         [weakSelf removeSubvies];
         
         if (error == nil)
         {
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, /*adData.timeBeforeOverlay * NSEC_PER_SEC*/0), dispatch_get_main_queue(),
                            ^{
                                KWKMediatedBanner* bannerInstance = [KWKMediatedBanner mediatedBannerFromData:adData];
                                if (bannerInstance)
                                {
                                    bannerInstance.bannerDelegate = weakSelf;
                                    [bannerInstance loadAdInView:weakSelf];
                                }
                                else
                                {
                                    //TODO delegate
                                    KWKLog(@"BAnner failed. Mediator for %@ not found" , adData.adType);
                                }
                            });
             
         }
         else
         {
             //TODO delegate
             KWKLog(@"BAnner failed");
         }
     }];
}

#pragma mark KWKMediatedBannerDelegate -

- (UIViewController *)rootViewController
{
    return [self.delegate rootViewController];
}

- (void) didLoadMediatedBanner:(KWKMediatedBanner*) banner
{
    KWKLog(@"%s",__PRETTY_FUNCTION__);
    //TODO forward to delegate
}

- (void) didFailToLoadMediatedBanner:(KWKMediatedBanner*) banner error:(NSError*) error
{
    KWKLog(@"%s",__PRETTY_FUNCTION__);
    //TODO forward to delegate
}

- (void) didDisplayMediatedBanner:(KWKMediatedBanner*) banner
{
    KWKLog(@"%s",__PRETTY_FUNCTION__);
    //TODO forward to delegate
}

- (void) didFailToDisplayMediatedBanner:(KWKMediatedBanner*) banner
{
    KWKLog(@"%s",__PRETTY_FUNCTION__);
    //TODO forward to delegate
}

@end
