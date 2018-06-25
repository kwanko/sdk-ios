//
//  KWKMraidMediatedInterstitial.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 10/05/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKMraidMediatedInterstitial.h"
#import "KwkOverlayViewController.h"
#import "KWKGlobals.h"

NSString* const kKWKMraidInterstitialErrorDomain = @"kKWKMraidInterstitialErrorDomain";

@interface KWKMraidMediatedInterstitial()<KWKOverlayViewControllerProtocol>

@end

@implementation KWKMraidMediatedInterstitial

- (instancetype)initWithAdData:(KWKAdData *)data
{
    if (self = [super initWithAdData:data])
    {
        
    }
    
    return self;
}

- (void)setInterstitialDelegate:(id<KWKMediatedInterstitialProtocol>)interstitialDelegate
{
    [super setInterstitialDelegate:interstitialDelegate];
}

- (void) loadAd;
{
    if ([self.interstitialDelegate respondsToSelector:@selector(didLoadMediatedInterstitial:)])
    {
        [self.interstitialDelegate didLoadMediatedInterstitial:self];
    }
}

- (void) launchInterstitial
{
    UIViewController* presentingViewController = [self.interstitialDelegate rootViewController];
    if (presentingViewController)
    {
        KwkOverlayViewController *interstitialVC = [[KwkOverlayViewController alloc] init];
        interstitialVC.adRequest = self.originalRequest;
        interstitialVC.adData = self.adData;
        interstitialVC.delegate = self;
        
        [presentingViewController addChildViewController:interstitialVC];
        [presentingViewController.view addSubview:interstitialVC.view];
        [interstitialVC didMoveToParentViewController:presentingViewController];
        
        if ([self.interstitialDelegate respondsToSelector:@selector(didDisplayMediatedInterstitial:)])
        {
            [self.interstitialDelegate didDisplayMediatedInterstitial:self];
        }
    }
    else
    {
        KWKLog(@"%@", @"Could not display Interstitial. Please provide a root view controller");
        
        if ([self.interstitialDelegate respondsToSelector:@selector(didFailToDisplayMediatedInterstitial:)])
        {
            [self.interstitialDelegate didFailToDisplayMediatedInterstitial:self];
        }
    }
}

#pragma mark KWKOverlayViewControllerProtocol -
- (UIViewController*) rootViewController
{
    return [self.interstitialDelegate rootViewController];
}

- (void) didCloseOverlayViewController
{
    if ([self.interstitialDelegate respondsToSelector:@selector(didCloseKwankoMediatedInterstitial)])
    {
        [self.interstitialDelegate didCloseKwankoMediatedInterstitial];
    }
}


@end
