//
//  KWKAdMobMediatedInterstitial.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 10/05/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKAdMobMediatedInterstitial.h"
#import "KWKAdMobMediator.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "KWKGlobals.h"

NSString* const kKWKAdMobCredentialInterstitialUnitID   = @"unitID";
//TODO key for array of test devices(see ad request below)

@interface KWKAdMobMediatedInterstitial()<GADInterstitialDelegate>

@property (nonatomic, strong) GADInterstitial* interstitial;

@end

@implementation KWKAdMobMediatedInterstitial

- (void) loadAd
{
    KWKAdMobMediator *adMediator = [KWKAdMobMediator getInstance];
    if (![adMediator isInitialised])
    {
        NSString* appID = [self.adData.adInfo objectForKey:kKWKAdMobCredentialAppID];
        [adMediator setAppID:appID];
    }
    
    if ([adMediator isInitialised])
    {
        NSString* unitID = [self.adData.adInfo objectForKey:kKWKAdMobCredentialInterstitialUnitID];
        if ([unitID length] > 0)
        {
            self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:unitID];
            self.interstitial.delegate = self;
            
            GADRequest *request = [GADRequest request];
            [self.interstitial loadRequest:request];
        }
        else
        {
            NSError *err = [NSError errorWithDomain:kKWKADMobErrorDomain
                                               code:0
                                           userInfo:@{NSLocalizedDescriptionKey : @"Could not load adMob Interstitial",
                                                      NSLocalizedFailureReasonErrorKey : @"Admob unit ID not provided"}];
            if ([self.interstitialDelegate respondsToSelector:@selector(didFailToLoadMediatedInterstitial:error:)])
            {
                [self.interstitialDelegate didFailToLoadMediatedInterstitial:self error:err];
            }
            
            KWKLog(@"Could not load admob interstitial. Error: %@",err);
        }
    }
    else
    {
        NSError *err = [NSError errorWithDomain:kKWKADMobErrorDomain
                                           code:0
                                       userInfo:@{NSLocalizedDescriptionKey : @"Could not load adMob Interstitial. Lib not initialised",
                                                  NSLocalizedFailureReasonErrorKey : @"Admob Mediator not initialised"}];
        if ([self.interstitialDelegate respondsToSelector:@selector(didFailToLoadMediatedInterstitial:error:)])
        {
            [self.interstitialDelegate didFailToLoadMediatedInterstitial:self error:err];
        }
        
        KWKLog(@"Could not load admob interstitial. Error: %@",err);
    }
}

- (void) launchInterstitial
{
    UIViewController* rootViewController = [self.interstitialDelegate rootViewController];
    if (rootViewController)
    {
        [self.interstitial presentFromRootViewController:rootViewController];
        //notifying ad display here since ad mob does not supply a protocol method for diddisplay
        if ([self.interstitialDelegate respondsToSelector:@selector(didDisplayMediatedInterstitial:)])
        {
            [self.interstitialDelegate didDisplayMediatedInterstitial:self];
        }
    }
    else
    {
        KWKLog(@"Could not display adMob Interstitial. RootViewController not provided");
        
        if ([self.interstitialDelegate respondsToSelector:@selector(didFailToDisplayMediatedInterstitial:)])
        {
            [self.interstitialDelegate didFailToDisplayMediatedInterstitial:self];
        }
    }
}

#pragma mark - GADInterstitialDelegate
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    if ([self.interstitialDelegate respondsToSelector:@selector(didLoadMediatedInterstitial:)])
    {
        [self.interstitialDelegate didLoadMediatedInterstitial:self];
    }
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    if ([self.interstitialDelegate respondsToSelector:@selector(didFailToLoadMediatedInterstitial:error:)])
    {
        [self.interstitialDelegate didFailToLoadMediatedInterstitial:self error:error];
    }
    
    KWKLog(@"%s: Could not load admob interstitial. Error: %@", __PRETTY_FUNCTION__, error);
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad
{
    //TODO
}


- (void)interstitialDidFailToPresentScreen:(GADInterstitial *)ad
{
    KWKLog(@"Could not display ad mob interstitial.");
    
    if ([self.interstitialDelegate respondsToSelector:@selector(didFailToDisplayMediatedInterstitial:)])
    {
        [self.interstitialDelegate didFailToDisplayMediatedInterstitial:self];
    }
}


- (void)interstitialWillDismissScreen:(GADInterstitial *)ad
{
    //TODO
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    //TODO
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad
{
    //TODO
}


@end
