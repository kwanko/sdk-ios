//
//  KWKOverlayAdRequest+Debug.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 13/04/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKOverlayAdRequest.h"

@interface KWKOverlayAdRequest()

@property (nonatomic, readwrite) float timeBeforeOverlay;
@property (nonatomic, readwrite) int overlayCountdown;
@property (nonatomic, readwrite) BOOL shouldOverrideFormatSize;

@end
