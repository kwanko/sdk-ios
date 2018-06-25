//
//  KWKMediatedInterstitial.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 09/05/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KWKAdData.h"
#import "KWKOverlayAdRequest.h"

@class KWKMediatedInterstitial;

@protocol KWKMediatedInterstitialProtocol <NSObject>

#pragma mark -
@required
- (UIViewController*) rootViewController;

#pragma mark Ad Events -
@optional
- (void) didLoadMediatedInterstitial:(KWKMediatedInterstitial*) interstitial;
- (void) didFailToLoadMediatedInterstitial:(KWKMediatedInterstitial*) overlay error:(NSError*) error;
- (void) didDisplayMediatedInterstitial:(KWKMediatedInterstitial*) overlay;
- (void) didFailToDisplayMediatedInterstitial:(KWKMediatedInterstitial*) overlay;

- (void) didCloseKwankoMediatedInterstitial; 




@end

/*
 * Base for mediated interstitials.
 * After server response is processed into addata, an instance of a derivate of this class
 * will use the data to display an interstitial or forward the interstitial credentials to a mediatator
 */

@interface KWKMediatedInterstitial : NSObject

@property (nonatomic, weak) id<KWKMediatedInterstitialProtocol> interstitialDelegate;

@property (nonatomic, strong) KWKOverlayAdRequest* originalRequest;
@property (nonatomic, strong) KWKAdData* adData;

- (instancetype) initWithAdData:(KWKAdData*) data;
- (void) loadAd;
- (void) launchInterstitial;


+(id) mediatedInterstitialFromData:(KWKAdData*) data; //note: can return nil if data.adType is not recognized

@end
