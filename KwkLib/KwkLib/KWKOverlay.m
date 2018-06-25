//
//  KWKOverlay.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 09/05/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKOverlay.h"
#import "KwkOverlayViewController.h"
#import "KWKAdProvider.h"
#import "KWKAdData.h"
#import "KWKUtils.h"

#import "KwkLibDefines.h"

#import "KWKMediatedInterstitial.h"

@interface KWKOverlay() <KWKMediatedInterstitialProtocol>

@property (nonatomic, readwrite) BOOL isLoadingAd;
@property (nonatomic, strong) KWKMediatedInterstitial* mediatedInterstitial;
@property (nonatomic, weak) UIViewController* presentingViewController;

@end

@implementation KWKOverlay

- (void) loadRequest:(KWKOverlayAdRequest *) adRequest
{
    if (self.isLoadingAd)
    {
        KWKLog(@"%s: already loading ad", __PRETTY_FUNCTION__);
        return;
    }
    
    self.isLoadingAd = YES;
    
    __weak __typeof__(self) weakSelf = self;
    
    KWKAdProvider* overlayAdProvider = [[KWKAdProvider alloc] init];
    [overlayAdProvider loadAdForRequestWithRequest:adRequest completion:^(KWKAdData *adData, NSError *error)
     {
         if (!error)
         {
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, adData.timeBeforeOverlay * NSEC_PER_SEC),
                            dispatch_get_main_queue(),
                            ^{
                                self.mediatedInterstitial = [KWKMediatedInterstitial mediatedInterstitialFromData:adData];
                                self.mediatedInterstitial.originalRequest = adRequest;
                                self.mediatedInterstitial.interstitialDelegate = self;
                                
                                if (nil == self.mediatedInterstitial)
                                {
                                    if ([weakSelf.delegate respondsToSelector:@selector(didFailToLoadOverlay:error:)])
                                    {
                                        KWKLog(@"%s: %@" , __PRETTY_FUNCTION__, @"failed to display. Ad data did not recognized a good ad type");
                                        [weakSelf.delegate didFailToLoadOverlay:self error:nil]; //TODO: error
                                    }
                                }
                                else
                                {
                                    [self.mediatedInterstitial loadAd];
                                }
                            
                            });
         }
         else
         {
             KWKLog(@"interstital for slot:%@ failed to load with error:%@", adRequest.slotID, error);
             if ([self.delegate respondsToSelector:@selector(didFailToLoadOverlay:error:)])
             {
                 [self.delegate didFailToLoadOverlay:self error:error];
             }
         }
     }];
}

#pragma mark KWKMediatedInterstitialProtocol

- (UIViewController*) rootViewController
{
    if ([self.delegate respondsToSelector:@selector(rootViewController)])
    {
        return [self.delegate rootViewController];
    }
    return nil;
}

- (void) didLoadMediatedInterstitial:(KWKMediatedInterstitial*) interstitial
{
    if ([self.delegate respondsToSelector:@selector(didLoadOverlay:)])
    {
        [self.delegate didLoadOverlay:self];
    }
    
    self.isLoadingAd = NO;
    
    
    UIViewController* topmostViewController = [[UIApplication sharedApplication] topMostViewController];
    UIViewController* presentingViewController = [self.delegate rootViewController];
    
    //add should now show as per #6040 showOverlay - implement same strategy as on Android
    if (topmostViewController == presentingViewController)
    {
        [self.mediatedInterstitial launchInterstitial];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(didFailToDisplayOverlay:)])
        {
            KWKLog(@"%@" , @"Failed to display. Please provide a rootviewcontroller for interstitial");
            [self.delegate didFailToDisplayOverlay:self];
        }
    }
}

- (void) didFailToLoadMediatedInterstitial:(KWKMediatedInterstitial*) overlay error:(NSError*) error
{
    if ([self.delegate respondsToSelector:@selector(didFailToLoadOverlay:error:)])
    {
        [self.delegate didFailToLoadOverlay:self error:error];
    }
    
    self.isLoadingAd = NO;
}

- (void) didDisplayMediatedInterstitial:(KWKMediatedInterstitial*) overlay
{
    if ([self.delegate respondsToSelector:@selector(didDisplayOverlay:)])
    {
        [self.delegate didDisplayOverlay:self];
    }
}

- (void) didFailToDisplayMediatedInterstitial:(KWKMediatedInterstitial*) overlay
{
    if ([self.delegate respondsToSelector:@selector(didFailToDisplayOverlay:)])
    {
        [self.delegate didFailToDisplayOverlay:self];
    }
}

- (void) didCloseKwankoMediatedInterstitial
{
    if ([self.delegate respondsToSelector:@selector(didCloseKwankoOverlay)])
    {
        [self.delegate didCloseKwankoOverlay];
    }
}

@end


