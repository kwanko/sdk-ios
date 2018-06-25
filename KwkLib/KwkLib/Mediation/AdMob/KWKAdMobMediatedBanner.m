//
//  KWKAdMobMediatedBanner.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 15/05/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKAdMobMediatedBanner.h"
#import "KWKAdMobMediator.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UIKit/UIGeometry.h>
#import "KWKGlobals.h"

NSString* const kKWKAdMobCredentialBannerUnitID   = @"unitID";
//TODO key for array of test devices(see ad request below)

@interface KWKAdMobMediatedBanner()<GADBannerViewDelegate>

@property (nonatomic, strong) GADBannerView* bannerView;

@end

@implementation KWKAdMobMediatedBanner

- (void) loadAdInView:(UIView *)container
{
    KWKAdMobMediator *adMediator = [KWKAdMobMediator getInstance];
    if (![adMediator isInitialised])
    {
        NSString* appID = [self.adData.adInfo objectForKey:kKWKAdMobCredentialAppID];
        [adMediator setAppID:appID];
    }
    
    if ([adMediator isInitialised])
    {
        NSString* unitID = [self.adData.adInfo objectForKey: kKWKAdMobCredentialBannerUnitID];
        if ([unitID length] > 0)
        {
            if (self.bannerView)
            {
                [self.bannerView removeFromSuperview];
            }
            
            self.bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0, 0, container.frame.size.width, container.frame.size.height)];
            self.bannerView.autoresizingMask = container.autoresizingMask;
            [container addSubview:self.bannerView];
            
            self.bannerView.adUnitID = unitID;
            self.bannerView.rootViewController = [self.bannerDelegate rootViewController];
            self.bannerView.delegate = self;
            
            GADRequest *request = [GADRequest request];
            [self.bannerView loadRequest:request];
        }
        else
        {
            NSError *err = [NSError errorWithDomain:kKWKADMobErrorDomain
                                               code:0
                                           userInfo:@{NSLocalizedDescriptionKey : @"Could not load adMob Interstitial",
                                                      NSLocalizedFailureReasonErrorKey : @"Admob unit ID not provided"}];
            
            KWKLog(@"Could not load admob banner. Error: %@",err);
            if ([self.bannerDelegate respondsToSelector:@selector(didFailToLoadMediatedBanner:error:)])
            {
                [self.bannerDelegate didFailToLoadMediatedBanner:self error:err];
            }
        }
    }
    else
    {
        NSError *err = [NSError errorWithDomain:kKWKADMobErrorDomain
                                           code:0
                                       userInfo:@{NSLocalizedDescriptionKey : @"Could not load adMob banner. Lib not initialised",
                                                  NSLocalizedFailureReasonErrorKey : @"Admob Mediator not initialised"}];
      
        KWKLog(@"Could not load admob banner. Error: %@",err);
        
        if ([self.bannerDelegate respondsToSelector:@selector(didFailToLoadMediatedBanner:error:)])
        {
            [self.bannerDelegate didFailToLoadMediatedBanner:self error:err];
        }
    }
}

#pragma mark - GADBannerViewDelegate

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    if ([self.bannerDelegate respondsToSelector:@selector(didLoadMediatedBanner:)])
    {
        [self.bannerDelegate didLoadMediatedBanner:self];
    }
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    if ([self.bannerDelegate respondsToSelector:@selector(didFailToLoadMediatedBanner:error:)])
    {
        [self.bannerDelegate didFailToLoadMediatedBanner:self error:error];
    }
}

@end
