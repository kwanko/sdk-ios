//
//  KWKUtils.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 02/03/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KWKGlobals.h"

@interface KWKUtils : NSObject

typedef enum
{
    KWK_DEVICE_TYPE_UNKNOWN = 0,
    KWK_DEVICE_TYPE_DESKTOP,
    KWK_DEVICE_TYPE_SMARTPHONE,
    KWK_DEVICE_TYPE_TABLET,
    KWK_DEVICE_TYPE_FEATURE_PHONE,
    KWK_DEVICE_TYPE_CONSOLE,
    KWK_DEVICE_TYPE_TV,
    KWK_DEVICE_TYPE_CAR_BROWSER,
    KWK_DEVICE_TYPE_SMART_DISPLAY,
    KWK_DEVICE_TYPE_CAMERA,
    KWK_DEVICE_TYPE_PORTABLE_MEDIA_PLAYER,
    KWK_DEVICE_TYPE_PHABLET
} KWKDeviceType;
+ (KWKDeviceType) getKWKDeviceType;

+ (CGSize) getScreenSize;
+ (CGSize) getMaxSize;
+ (CGSize) getNativeScreenSize;

+ (BOOL) isTrackingForAdvertisingEnabled;
+ (NSString*) IDFA;
+ (NSString*) savedIDFA;
+ (BOOL) saveIDFA;

+ (NSString*) getDocumentsDirPath;

@end

BOOL IsValidJSONObject(id object);
id ObjectOrNilFromJSONObject(id objert); //if object = nsnull null returns nil;
