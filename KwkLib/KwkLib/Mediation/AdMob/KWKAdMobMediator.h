//
//  KWKAdMobMediator.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 05/05/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KWKMediatedInterstitial.h"

extern NSString* const kKWKADMobErrorDomain;
extern NSString* const kKWKAdMobCredentialAppID;

@interface KWKAdMobMediator : NSObject
@property (nonatomic, readonly) BOOL isInitialised;

+(instancetype) getInstance;
- (void) setAppID:(NSString*) appID;

@end
