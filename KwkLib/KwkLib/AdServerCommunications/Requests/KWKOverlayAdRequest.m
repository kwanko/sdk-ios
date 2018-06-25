//
//  KWKOverlayAdRequest.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 13/04/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKAdRequest+Private.h"
#import "KWKOverlayAdRequest.h"

#define KWK_COLLECTED_PARAMS_POSITION           @"adPosition"

@implementation KWKOverlayAdRequest

@dynamic size;
@dynamic sizeStrategy;

- (KWKAdFormat) adFormat
{
    return KWK_AD_FORMAT_INTERSTITIAL;
}


- (NSMutableDictionary*) userInfos
{
    NSMutableDictionary *user_infos = [super userInfos];
    
    //#4947 [iOS] Params Collected: position
    if (self.adPosition != KWK_AD_POSITION_CENTERED)
    {
        NSString* vPosIdentifier = StringFromAdPosition(self.adPosition);
        [user_infos setObject:vPosIdentifier forKey:KWK_COLLECTED_PARAMS_POSITION];
    }
    
    return user_infos;
}

@end

NSString* const kKWKAdPositionUnknown = @"unknown";
NSString* const kKWKAdPositionTop = @"top";
NSString* const kKWKAdPositionBottom = @"bottom";
NSString* StringFromAdPosition(KWKAdPosition pos)
{
    static NSArray* positionStrings;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        positionStrings = [NSArray arrayWithObjects:kKWKAdPositionUnknown,
                           kKWKAdPositionTop,
                           kKWKAdPositionBottom,
                           nil];
        
    });
    
    return positionStrings[(int) pos];
}
