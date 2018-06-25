//
//  KWKUtils.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 02/03/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKUtils.h"
#import <AdSupport/AdSupport.h>



#define KWK_NSU_DEF_KEY_IDFA   @"KWK_NSU_DEF_KEY_IDFA"

#define KWK_IDFA_NULL_STRING   @"00000000-0000-0000-0000-000000000000"


@implementation KWKUtils

+ (KWKDeviceType)getKWKDeviceType
{
    KWKDeviceType deviceType = KWK_DEVICE_TYPE_UNKNOWN;
    
    switch (UI_USER_INTERFACE_IDIOM())
    {
        case UIUserInterfaceIdiomPhone:
            deviceType = KWK_DEVICE_TYPE_SMARTPHONE;
            break;
        case UIUserInterfaceIdiomPad:
            deviceType = KWK_DEVICE_TYPE_TABLET;
            break;
        case UIUserInterfaceIdiomTV:
            deviceType = KWK_DEVICE_TYPE_TV;
            break;
            
        default:
            break;
    }
    
    return deviceType;
}

+ (CGSize) getScreenSize
{
    return [[UIScreen mainScreen] bounds].size;
}

+ (CGSize) getMaxSize
{
    CGSize screenSize = [self getScreenSize];
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    
    CGSize maxSize = CGSizeMake(screenSize.width, screenSize.height - statusBarSize.height);
    return maxSize;
}

+ (CGSize)getNativeScreenSize
{
    CGRect nativeBounds = [UIScreen mainScreen].nativeBounds;
    return CGSizeMake(nativeBounds.size.width, nativeBounds.size.height);
}

+ (BOOL)isTrackingForAdvertisingEnabled
{
    BOOL isEnabled = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
    return isEnabled;
}

+ (NSString*) IDFA
{
    NSString* IDFAString = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    return IDFAString;
}

+ (NSString *) savedIDFA
{
    NSString* savedIDFAString = [[NSUserDefaults standardUserDefaults] objectForKey:KWK_NSU_DEF_KEY_IDFA];
    return savedIDFAString;
}

+ (BOOL) saveIDFA
{
    if (![self isTrackingForAdvertisingEnabled])
    {
        return NO;
    }
    
    NSString* idfa = [self IDFA];
    [[NSUserDefaults standardUserDefaults] setObject:idfa forKey:KWK_NSU_DEF_KEY_IDFA];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}

+ (NSString *)getDocumentsDirPath
{
    NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDirPath = [dirPaths objectAtIndex:0];
    
    return docsDirPath;
}

@end

BOOL IsValidJSONObject(id object)
{
    return object && object != [NSNull null];
}

id ObjectOrNilFromJSONObject(id object)
{
    return object == [NSNull null] ? nil : object;
}

#pragma mark -

//TODO logger class
static BOOL s_bKWKLoggingEnabled = NO;

void KWKEnableLogging(BOOL bVal)
{
    s_bKWKLoggingEnabled = bVal;
}

void KWKLog(NSString *format, ...)
{
    if (s_bKWKLoggingEnabled)
    {
        va_list args;
        va_start(args, format);
        NSLogv(format, args);
        va_end(args);
    }
}


void KWKJSLog(NSString *format, ...)
{
    if (s_bKWKLoggingEnabled)
    {
        NSString *newFormat = [NSString stringWithFormat:@"[KwankoAds][JS] %@", format];
        va_list args;
        va_start(args, newFormat);
        NSLogv(newFormat, args);
        va_end(args);
    }
}

void KWKNativeLog(NSString *format, ...)
{
    if (s_bKWKLoggingEnabled)
    {
        NSString *newFormat = [NSString stringWithFormat:@"Native Log: %@", format];
        va_list args;
        va_start(args, newFormat);
        NSLogv(newFormat, args);
        va_end(args);
    }
}

