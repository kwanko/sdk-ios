//
//  KWKAdRequest.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 13/04/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIGeometry.h>

#pragma mark KWKAdFormat -
typedef enum {
    KWK_AD_FORMAT_INLINE = 0,
    KWK_AD_FORMAT_INTERSTITIAL,
    KWK_AD_FORMAT_NATVE,
    KWK_AD_FORMAT_PARALLAX
}KWKAdFormat;

extern NSString* const kKWKAdFormatStringInline;
extern NSString* const kKWKAdFormatStringOverlay;
extern NSString* const kKWKAdFormatNative;
extern NSString* const kKWKAdFormatParallax;

NSString* StringFromAdFormat(KWKAdFormat type);

#pragma mark KWKADSizeStrategy -
typedef enum
{
    KWK_AD_SZ_STRATEGY_PIXELS = 0,
    KWK_AD_SZ_STRATEGY_RATIO,
}KWKADSizeStrategy;

extern NSString* const kKWKAdSizeStrategyStringUnknown;
extern NSString* const kKWKAdSizeStrategyStringPixels;
extern NSString* const kKWKAdSizeStrategyStringRatio;

NSString* StringFromAdSizeStrategy(KWKADSizeStrategy strategy);
KWKADSizeStrategy KWKAdSizeStrategyFromString(NSString* sizeStrategyString);

#pragma mark KWKAdRequest -
@interface KWKAdRequest : NSObject

@property (nonatomic, strong) NSString* slotID; //Slot Id From Kwanko Backoffice

@property (nonatomic, strong) NSArray* categories; // Categories of the ad Ex: @[IAB-25,IAB-24]
@property (nonatomic, strong) NSDictionary* customParams;

- (NSDictionary*) buildServerParams;

@end
