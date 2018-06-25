//
//  KWKAdMobMediator.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 05/05/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKAdMobMediator.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "KWKAdData.h"
#import "KWKUtils.h"

NSString* const kKWKAdMobCredentialAppID  = @"applicationID";
NSString* const kKWKADMobErrorDomain = @"KWKADMobErrorDomain";

@interface KWKAdMobMediator()
@property (nonatomic, readwrite) BOOL isInitialised;

@end

@implementation KWKAdMobMediator

+ (instancetype) getInstance
{
    static KWKAdMobMediator* instance = nil;
    static dispatch_once_t instanceToken;
    dispatch_once(&instanceToken, ^{
        instance = [[KWKAdMobMediator alloc] init];
    });
    
    return instance;
}

- (instancetype) init
{
    if (self = [super init])
    {
        self.isInitialised = NO;
    }
    
    return self;
}

- (void) setAppID: (NSString*) appID;
{
    if ([appID length] == 0)
    {
        KWKLog(@"AdMob appID is null or empty. Cannot start mediator");
        return;
    }
    
    static dispatch_once_t appIDToken;
    dispatch_once(&appIDToken, ^
    {
        [GADMobileAds configureWithApplicationID:appID];
        //KWKLog(@"%s: configurig AdMob Mediator with appID:%@", __PRETTY_FUNCTION__, appID);
        self.isInitialised = YES;
    });
};




@end
