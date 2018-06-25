//
//  KWKConnectivityManager.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 13/02/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    KWK_CONNECTIVITY_UNKNOWN = 0,
    KWK_CONNECTIVITY_WIFI,
    KWK_CONNECTIVITY_4G,
    KWK_CONNECTIVITY_3G,
    KWK_CONNECTIVITY_EDGE,
    KWK_CONNECTIVITY_HPLUS,
	KWK_CONNECTIVITY_2G
}KWKWebConnectyvity;


typedef enum
{
    KWK_NETWORK_TYPE_1xRTT = 7,
    KWK_NETWORK_TYPE_CDMA = 4,
    KWK_NETWORK_TYPE_EDGE = 2,
    KWK_NETWORK_TYPE_EHRPD = 14,
    KWK_NETWORK_TYPE_EVDO_0 = 5,
    KWK_NETWORK_TYPE_EVDO_A = 6,
    KWK_NETWORK_TYPE_EVDO_B = 12,
    KWK_NETWORK_TYPE_GPRS = 1,
    KWK_NETWORK_TYPE_GSM = 16,
    KWK_NETWORK_TYPE_HSDPA = 8,
    KWK_NETWORK_TYPE_HSPA = 10,
    KWK_NETWORK_TYPE_HSPAP = 15,
    KWK_NETWORK_TYPE_HSUPA = 9,
    KWK_NETWORK_TYPE_IDEN = 11,
    KWK_NETWORK_TYPE_IWLAN = 18,
    KWK_NETWORK_TYPE_LTE = 13,
    KWK_NETWORK_TYPE_TD_SCDMA = 17,
    KWK_NETWORK_TYPE_UMTS = 3,
    KWK_NETWORK_TYPE_UNKNOWN = 0,
}KWKNetworkRadioType; //taken from android NETWORK_TYPE constants

@interface KWKConnectivityManager : NSObject

+ (instancetype) getInstance;

- (KWKWebConnectyvity) getCurrentWebConnectivity;
- (KWKNetworkRadioType) getCurrentNetworkRadioType;

- (NSString*) getCurrentRadioAccessTechnology;
- (NSString*) getCarrierName;
- (NSString*) getHomeMobileCountryCode;
- (NSString*) getHomeMobileNetworkCode;

@end
