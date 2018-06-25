//
//  KWKNativeAdRequest.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 13/04/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKNativeAdRequest.h"
#import "KWKNativeAdRequest+Private.h"
#import "KWKAdRequest+Private.h"

#define KWK_COLLECTED_PARAMS_NATIVE             @"nativeAd"

@implementation KWKNativeAdRequest

- (KWKAdFormat)adFormat
{
    return KWK_AD_FORMAT_NATVE;
}

- (NSMutableDictionary *)sdkInfos
{
    NSMutableDictionary* sdk_Infos = [super sdkInfos];
    
    if ([self.nativeAdComponents count] > 0)
    {
        [sdk_Infos setObject:self.nativeAdComponents forKey:KWK_COLLECTED_PARAMS_NATIVE];
    }
    
    return sdk_Infos;
}

@end
