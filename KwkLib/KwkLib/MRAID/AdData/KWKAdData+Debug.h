//
//  KWKAdData+Debug.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 01/03/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKAdData.h"

@interface KWKAdData ()

@property (nonatomic, copy) NSString* customURL;


- (void) setTimeBeforeOverlay:(float) timeBeforeOverlay;
- (void) setOverlayCountdown:(int) overlayCountdown;
- (void) setContentSize:(CGSize) contentSize;
- (void) setSizeStrategy:(KWKADSizeStrategy) strategy;
@end
