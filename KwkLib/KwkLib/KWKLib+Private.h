//
//  KWKLib+Private.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 14/02/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//
#import "KwkLib.h"

typedef void(^locationRecievedBlock)();


@interface KwkLib ()

@property (nonatomic, readonly) BOOL isGeoLocFromPrefs;

- (void) forceGeolocWithBlock:(locationRecievedBlock) block;

- (BOOL) supportsSMS;
- (BOOL) supportsTel;
- (BOOL) supportsPhotos;
- (BOOL) supportsCalendar;

//todo move to utils

- (CLLocation *) getCurrentLocation;

@end
