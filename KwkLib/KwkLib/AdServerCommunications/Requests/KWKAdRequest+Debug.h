//
//  KWKAdRequest+Debug.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 13/04/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKAdRequest.h"

@interface KWKAdRequest()

@property (nonatomic, readwrite) BOOL showRequest;
@property (nonatomic, readwrite) BOOL showResponse;

@property (nonatomic, copy) NSString* customHTML;
@property (nonatomic, copy) NSString* customURL;

@end
