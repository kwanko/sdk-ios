//
//  KWKConnectivityManager.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 13/02/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKConnectivityManager.h"
#import "KWKReachability.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@interface KWKConnectivityManager ()
{
    KWKReachability* reachability;
    CTTelephonyNetworkInfo* networkInfo;
}

@property(nonatomic, copy) NSString* currentRadioAccessTechnology;

@end

@implementation KWKConnectivityManager


#pragma mark -

+(instancetype) getInstance
{
    static dispatch_once_t once;
    
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
    
}

#pragma mark

- (instancetype) init
{
    if (self = [super init])
    {
        reachability = [KWKReachability reachabilityForInternetConnection];
        
        if ([CTTelephonyNetworkInfo class])
        {
            networkInfo = [[CTTelephonyNetworkInfo alloc] init];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(wwanConnectivityChanged:)
                                                         name:CTRadioAccessTechnologyDidChangeNotification object:nil];
        }
        
        
        return self;
    }
    
    return nil;
}

- (void)dealloc
{
    if ([CTTelephonyNetworkInfo class])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark -
- (void) wwanConnectivityChanged: (id) param
{
    self.currentRadioAccessTechnology = networkInfo.currentRadioAccessTechnology;
}

- (KWKWebConnectyvity)getCurrentWebConnectivity
{
    switch ([reachability currentReachabilityStatus])
    {
        case ReachableViaWiFi:
            return KWK_CONNECTIVITY_WIFI;
            break;
        case ReachableViaWWAN:
        {
            static NSDictionary* radioTypeDict;
            static dispatch_once_t once;
            
            dispatch_once(&once, ^{
                
                radioTypeDict = @{
                                  CTRadioAccessTechnologyCDMA1x: [NSNumber numberWithInt:KWK_CONNECTIVITY_2G],
                                  CTRadioAccessTechnologyEdge: [NSNumber numberWithInt:KWK_CONNECTIVITY_EDGE],
                                  CTRadioAccessTechnologyeHRPD:[NSNumber numberWithInt:KWK_CONNECTIVITY_HPLUS],
                                  CTRadioAccessTechnologyCDMAEVDORev0: [NSNumber numberWithInt:KWK_CONNECTIVITY_3G],
                                  CTRadioAccessTechnologyCDMAEVDORevA: [NSNumber numberWithInt:KWK_CONNECTIVITY_3G],
                                  CTRadioAccessTechnologyCDMAEVDORevB: [NSNumber numberWithInt:KWK_CONNECTIVITY_3G],
                                  CTRadioAccessTechnologyGPRS: [NSNumber numberWithInt:KWK_CONNECTIVITY_2G],
                                  CTRadioAccessTechnologyHSDPA: [NSNumber numberWithInt:KWK_CONNECTIVITY_3G],
                                  CTRadioAccessTechnologyHSUPA: [NSNumber numberWithInt:KWK_CONNECTIVITY_3G],
                                  CTRadioAccessTechnologyLTE: [NSNumber numberWithInt:KWK_CONNECTIVITY_4G],
                                  CTRadioAccessTechnologyWCDMA: [NSNumber numberWithInt:KWK_CONNECTIVITY_3G], //based on wikipedia. TODO check.
                                  };
            });
                        
            if (self.currentRadioAccessTechnology && [radioTypeDict objectForKey:self.currentRadioAccessTechnology])
            {
                return (KWKWebConnectyvity)[[radioTypeDict objectForKey:self.currentRadioAccessTechnology] intValue];
            }

        }
        break;
        
        default:
            break;
    }
    
    return KWK_CONNECTIVITY_UNKNOWN;
}

- (KWKNetworkRadioType) getCurrentNetworkRadioType
{
    static NSDictionary* radioTypeDict;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
    radioTypeDict = @{
                        CTRadioAccessTechnologyCDMA1x: [NSNumber numberWithInt:KWK_NETWORK_TYPE_1xRTT],
                        CTRadioAccessTechnologyEdge: [NSNumber numberWithInt:KWK_NETWORK_TYPE_EDGE],
                        CTRadioAccessTechnologyeHRPD:[NSNumber numberWithInt:KWK_NETWORK_TYPE_EHRPD],
                        CTRadioAccessTechnologyCDMAEVDORev0: [NSNumber numberWithInt:KWK_NETWORK_TYPE_EVDO_0],
                        CTRadioAccessTechnologyCDMAEVDORevA: [NSNumber numberWithInt:KWK_NETWORK_TYPE_EVDO_A],
                        CTRadioAccessTechnologyCDMAEVDORevB: [NSNumber numberWithInt:KWK_NETWORK_TYPE_EVDO_B],
                        CTRadioAccessTechnologyGPRS: [NSNumber numberWithInt:KWK_NETWORK_TYPE_GPRS],
                        CTRadioAccessTechnologyHSDPA: [NSNumber numberWithInt:KWK_NETWORK_TYPE_HSDPA],
                        CTRadioAccessTechnologyHSUPA: [NSNumber numberWithInt:KWK_NETWORK_TYPE_HSUPA],
                        CTRadioAccessTechnologyLTE: [NSNumber numberWithInt:KWK_NETWORK_TYPE_LTE],
                        CTRadioAccessTechnologyWCDMA: [NSNumber numberWithInt:KWK_NETWORK_TYPE_UMTS],
                    };
    });
    
    if (self.currentRadioAccessTechnology && [radioTypeDict objectForKey:self.currentRadioAccessTechnology])
    {
        return (KWKNetworkRadioType)[[radioTypeDict objectForKey:self.currentRadioAccessTechnology] intValue];
    }
    
    return KWK_NETWORK_TYPE_UNKNOWN;
}

- (NSString*) getCurrentRadioAccessTechnology
{
    return _currentRadioAccessTechnology;
}

- (NSString*) getCarrierName
{
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    if ([carrier mobileNetworkCode] == nil) //this will return nil if eithere there is no sim or the device is outside range.
    {
        return nil;
    }
    
    return [carrier carrierName];
}

- (NSString*) getHomeMobileCountryCode
{
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    return [carrier mobileCountryCode];
}

- (NSString*) getHomeMobileNetworkCode
{
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    return [carrier mobileNetworkCode];
}


@end
