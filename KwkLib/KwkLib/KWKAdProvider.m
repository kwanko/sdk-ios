//
//  KWKAdProvider.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 27/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKAdProvider.h"
#import "KWKRestService.h"
#import "KWKAdRequest.h"

#import "KWKAdBaseView.h"
#import "KWKMraidAdView.h"
#import "KWKHtmlAdView.h"

#import "KwkLibDefines.h"
#import "KWKGlobals.h"
#import "KwkLibConsts.h"
#import "KwkLib.h"
#import "KWKLib+Private.h"
#import "KWKConnectivityManager.h"
#import "KWKUtils.h"


#import "KWKNativeAdData.h"

typedef void (^KWKAdInternalResult)(NSData* adData, NSError* error);

@implementation KWKAdProvider

- (void) queueAdLoadWithRequest:(KWKAdRequest*) adRequest
                completionBlock:(KWKAdInternalResult) completionBlock
{
    NSAssert(adRequest && adRequest.slotID, @"Cannot load ad without slot");
    
    
    //TODO move this into a url builder
    NSString* url = KWK_AD_SERVER_URL;
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];

    NSDictionary* requestInfos = [adRequest buildServerParams];

    NSData* postData = [NSData requestDataFromParamsDictionary:requestInfos];
    
    NSString *jsonString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    KWKLog( @"%@", jsonString);

    [req setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postData length]] forHTTPHeaderField:@"Content-Length"];

    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:postData];

    [KWKRestService queueAdRequest:req completion:
     ^(NSData * _Nullable data, NSError * _Nullable error)
     {
         if (completionBlock)
         {
             completionBlock(data, error);
         }
         else
         {
             KWKLog(@"%s Error: no completion block provided!", __PRETTY_FUNCTION__);
         }
     }];
}

- (void) loadAdForRequestWithRequest:(KWKAdRequest*) adRequest completion:(KWKAdProviderResult) completionBlock;
{
    
    void (^bl)(KWKAdData*) = ^(KWKAdData* data)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            //replace lat macro
            if ([[KwkLib getInstance] getCurrentLocation] && ![[KwkLib getInstance] isGeoLocFromPrefs])
            {
                CLLocationCoordinate2D coord = [[KwkLib getInstance] getCurrentLocation].coordinate;
                [data replaceLatMacrowithCoord:coord];
            }
            else
            {
                [data replaceLatMacroWithFallbackCoord];
            }
            
            if (completionBlock)
            {
                completionBlock(data, nil);
            }
        });
    };
    
    [self queueAdLoadWithRequest:adRequest completionBlock:^(NSData *data, NSError *error)
    {
        if (error == nil && data != nil)
        {
            NSString* stringifiedData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            KWKLog( @"%@", stringifiedData);
            
            KWKAdData* adData = [[KWKAdData alloc] initWithData:data];
            
            if (adData.forceGeoloc)
            {
                CLLocation *lastKnownLocation = [[KwkLib getInstance] getCurrentLocation];
                if (lastKnownLocation && ![[KwkLib getInstance] isGeoLocFromPrefs])
                {
                    bl(adData);
                }
                else
                {
                    [[KwkLib getInstance] forceGeolocWithBlock:^{
                        bl(adData);
                    }];
                }
            }
            else
            {
                bl(adData);
            }
        }
        else
        {
            if (completionBlock)
            {
                completionBlock(nil, error);
            }
        }
    }];
}

- (void) loadNativeAdForRequestWithRequest:(KWKNativeAdRequest*) adRequest completion:(KWKAdProviderNativeAdResult) completionBlock;
{
    [self queueAdLoadWithRequest:adRequest completionBlock:^(NSData *data, NSError *error)
    {
        KWKNativeAdData* adData = nil;
        if (!error)
        {
            adData = [[KWKNativeAdData alloc] initWithData:data];
        }
        
        if (completionBlock)
        {
            completionBlock(adData, error);
        }
    }];
}

@end
