//
//  KWKAdRequest+Private.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 13/04/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKAdRequest.h"

@interface KWKAdRequest()

@property (nonatomic, readwrite) KWKADSizeStrategy sizeStrategy; //defaults to pixels
@property (nonatomic, readwrite) CGSize size;

- (KWKAdFormat) adFormat;


- (NSMutableDictionary*) userInfos;
- (NSMutableDictionary*) sdkInfos;

@end
