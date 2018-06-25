//
//  KWKAdProvider.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 27/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "KWKAdRequest.h"
#import "KWKNativeAdRequest.h"

@class KWKAdData;
@class KWKNativeAdData;



typedef void (^KWKAdProviderResult)(KWKAdData* adData, NSError* error);
typedef void (^KWKAdProviderNativeAdResult)(KWKNativeAdData* adData, NSError* error);

@interface KWKAdProvider : NSObject


- (void) loadAdForRequestWithRequest:(KWKAdRequest*) adRequest completion:(KWKAdProviderResult) completionBlock;
- (void) loadNativeAdForRequestWithRequest:(KWKNativeAdRequest*) adRequest completion:(KWKAdProviderNativeAdResult) completionBlock;


@end
