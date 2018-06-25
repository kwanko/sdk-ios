//
//  KWKBannerAdRequest.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 13/04/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKAdRequest.h"

extern NSString* const kKWKBannerCustomParamsRefreshRate;

@interface KWKBannerAdRequest : KWKAdRequest

@property (nonatomic, readonly) NSTimeInterval refreshRate;

@end
