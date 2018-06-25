//
//  KWKAdRequest.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 13/04/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKAdRequest.h"
#import "KWKAdRequest+Private.h"

#import "KwkLibConsts.h"
#import "KWKLibDefines.h"
#import "KWKLib+Private.h"
#import "KWKUtils.h"
#import "KWKConnectivityManager.h"

#import <sys/utsname.h>

#define KWK_COLLECTED_PARAMS_TIMEZONE           @"timezone"
#define KWK_COLLECTED_PARAMS_LOC_LAT            @"lat"
#define KWK_COLLECTED_PARAMS_LOC_LONG           @"long"
#define KWK_COLLECTED_PARAMS_MAKE               @"make"
#define KWK_COLLECTED_PARAMS_OS                 @"os"
#define KWK_COLLECTED_PARAMS_OSV                @"osv"
#define KWK_COLLECTED_PARAMS_MODEL              @"model"
#define KWK_COLLECTED_PARAMS_DEVICETYPE         @"devicetype"
#define KWK_COLLECTED_PARAMS_LANGUAGE           @"language"
#define KWK_COLLECTED_PARAMS_SCREEN_HEIGHT      @"screenHeight"
#define KWK_COLLECTED_PARAMS_SCREEN_WIDTH       @"screenWidth"
#define KWK_COLLECTED_PARAMS_UA                 @"ua"
#define KWK_COLLECTED_PARAMS_DOMAIN             @"domain"
#define KWK_COLLECTED_PARAMS_UID                @"userId"
#define KWK_COLLECTED_PARAMS_AD_WIDTH           @"adWidth"
#define KWK_COLLECTED_PARAMS_AD_HEIGHT          @"adHeight"
#define KWK_COLLECTED_PARAMS_AD_SZ_STRATEGY     @"adSizeStrategy"
#define KWK_COLLECTED_PARAMS_AD_FORMAT          @"format"
#define KWK_COLLECTED_PARAMS_CUSTOM_PARAMS      @"customParams"
#define KWK_COLLECTED_PARAMS_CATEGORIES         @"categories"
#define KWK_COLLECTED_PARAMS_CONNECTIVITY       @"connectivity"
#define KWK_COLLECTED_PARAMS_CARRIER            @"carriers"
#define KWK_COLLECTED_PARAMS_HM_COUNTRY_CODE    @"homeMobileCountryCode"
#define KWK_COLLECTED_PARAMS_HM_NETWORK_CODE    @"homeMobileNetworkCode"
#define KWK_COLLECTED_PARAMS_RADIO_TYPE         @"radioType"

#define KWK_AD_REQUEST_JSON_KEY_SDK_INFOS       @"sdk_infos"
#define KWK_AD_REQUEST_JSON_KEY_USER_INFOS      @"user_infos"
#define KWK_AD_REQUEST_JSON_KEY_SLOT            @"emp"

NSString* deviceName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

@implementation KWKAdRequest

- (instancetype) init
{
    if (self = [super init])
    {
        self.size = CGSizeMake(0, 0);
        self.sizeStrategy = KWK_AD_SZ_STRATEGY_PIXELS;
    }
    
    return self;
}

- (KWKAdFormat) adFormat
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
    
    return 0;
}

- (NSMutableDictionary*) userInfos
{
    NSMutableDictionary* user_infos = [[NSMutableDictionary alloc] init];
    
    //#4944 & #4945 [iOS] Params Collected: adHeight & adWidth
    if(self.size.width > 0 && self.size.height > 0) {
        [user_infos setObject:[NSNumber numberWithInt:(int) self.size.width] forKey:KWK_COLLECTED_PARAMS_AD_WIDTH];
        [user_infos setObject:[NSNumber numberWithInt:(int) self.size.height] forKey:KWK_COLLECTED_PARAMS_AD_HEIGHT];
    }
    
    //#4946 [iOS] Params Collected: adSizeStrategy
    NSString* adSizeStragegy = StringFromAdSizeStrategy(self.sizeStrategy);
    [user_infos setObject:adSizeStragegy forKey:KWK_COLLECTED_PARAMS_AD_SZ_STRATEGY];
    
    //#4948 [iOS] Params Collected: customParams
    if ([[self.customParams allValues] count] > 0)
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.customParams
                                                           options:0
                                                             error:&error];

        if (jsonData)
        {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [user_infos setObject:jsonString forKey:KWK_COLLECTED_PARAMS_CUSTOM_PARAMS];
        }
    }
    
    //#4940 [iOS] Params Collected: categories
    if ([self.categories count] > 0)
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.categories
                                                           options:0
                                                             error:&error];
        
        if (jsonData)
        {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [user_infos setObject:jsonString forKey:KWK_COLLECTED_PARAMS_CATEGORIES];
        }
    }
    
    return user_infos;
}

- (NSMutableDictionary*) sdkInfos
{
    NSMutableDictionary* sdk_infos = [[NSMutableDictionary alloc] init];
    
    //try getting geoloc from lob -> see #5048
    if (![[KwkLib getInstance] isGeoLocFromPrefs]) //if it's from prefs it can be too old. Let server get it from ip
    {
        CLLocation* loc = [[KwkLib getInstance] getCurrentLocation];
        if (loc)
        {
            [sdk_infos setObject:[NSNumber numberWithFloat:loc.coordinate.latitude] forKey:KWK_COLLECTED_PARAMS_LOC_LAT];
            [sdk_infos setObject:[NSNumber numberWithFloat:loc.coordinate.longitude] forKey:KWK_COLLECTED_PARAMS_LOC_LONG];
        }
    }
    
    //#4899 [iOS] Params Collected: Timezone
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [sdk_infos setObject:[localTimeZone name] forKey:KWK_COLLECTED_PARAMS_TIMEZONE];
    
    //#4891 [iOS] Params collected: make
    [sdk_infos setObject:KWK_MAKE forKey:KWK_COLLECTED_PARAMS_MAKE];
    
    //#4893 [iOS] Params Collected: os
    [sdk_infos setObject:[[UIDevice currentDevice] systemName] forKey:KWK_COLLECTED_PARAMS_OS];
    
    //#4894 [iOS] Params Collected: osv
    [sdk_infos setObject:[[UIDevice currentDevice] systemVersion] forKey:KWK_COLLECTED_PARAMS_OSV];
    
    //#4892 [iOS] Params Collected: model
    [sdk_infos setObject:deviceName() forKey:KWK_COLLECTED_PARAMS_MODEL];

    //#7024 [iOS][update]Parameters collected: devicetype
    [sdk_infos setObject:[NSNumber numberWithInt:(int)[KWKUtils getKWKDeviceType]] forKey:KWK_COLLECTED_PARAMS_DEVICETYPE];
    
    //#4890 [iOS] Params collected: language
    [sdk_infos setObject:[[NSLocale preferredLanguages] objectAtIndex:0] forKey:KWK_COLLECTED_PARAMS_LANGUAGE];
    
    //#4897 [iOS] Params Collected: screenHeight & #4896 [iOS] Params Collected: screenWidth
    //#7487 Send screenWidth&screenHeight as dp to server
    CGSize screenSize = [KWKUtils getScreenSize];

    [sdk_infos setObject:[NSNumber numberWithInt:(int)screenSize.width] forKey:KWK_COLLECTED_PARAMS_SCREEN_WIDTH];
    [sdk_infos setObject:[NSNumber numberWithInt:(int)screenSize.height] forKey:KWK_COLLECTED_PARAMS_SCREEN_HEIGHT];
    
    //#4942 [iOS] Params Collected: ua
    NSString* ua = [UIWebView userAgent];
    [sdk_infos setObject:ua forKey:KWK_COLLECTED_PARAMS_UA];
    
    //#4943 [iOS] Params Collected: domain
    [sdk_infos setObject:[[UIApplication sharedApplication] appDisplayName] forKey:KWK_COLLECTED_PARAMS_DOMAIN];
    
    //#4949 [iOS] Params Collected: userId
    if ([KWKUtils isTrackingForAdvertisingEnabled])
    {
        [sdk_infos setObject:[KWKUtils IDFA] forKey:KWK_COLLECTED_PARAMS_UID];
    }
    
    //[iOS] [update] Params Collected: connectivity
    KWKWebConnectyvity connectivity = [[KWKConnectivityManager getInstance] getCurrentWebConnectivity];
    [sdk_infos setObject:[NSNumber numberWithInt:(int) connectivity] forKey:KWK_COLLECTED_PARAMS_CONNECTIVITY];
    
    //#5153 [iOS] Params Collected: Carriers
    NSString* carrier = [[KWKConnectivityManager getInstance] getCarrierName];
    if (carrier)
    {
        [sdk_infos setObject:carrier forKey:KWK_COLLECTED_PARAMS_CARRIER];
    }
    
    //#5483 [IOS] New features for geoloc
    NSString* hmCountryCode = [[KWKConnectivityManager getInstance] getHomeMobileCountryCode];
    if (hmCountryCode)
    {
        [sdk_infos setObject:hmCountryCode forKey:KWK_COLLECTED_PARAMS_HM_COUNTRY_CODE];
    }
    NSString* hmNetworkCode = [[KWKConnectivityManager getInstance] getHomeMobileNetworkCode];
    if (hmNetworkCode)
    {
        [sdk_infos setObject:hmNetworkCode forKey:KWK_COLLECTED_PARAMS_HM_NETWORK_CODE];
    }
    
    [sdk_infos setObject:[NSNumber numberWithInt:(int)[[KWKConnectivityManager getInstance] getCurrentNetworkRadioType]] forKey:KWK_COLLECTED_PARAMS_RADIO_TYPE];
    //end #5483 [IOS] New features for geoloc
    
    //#5493 Params collected: Format
    NSString* adContainerType = StringFromAdFormat([self adFormat]);
    [sdk_infos setObject:adContainerType forKey:KWK_COLLECTED_PARAMS_AD_FORMAT];
    
    return sdk_infos;
}


- (NSDictionary*) buildServerParams
{
    NSMutableDictionary* user_infos = [self userInfos];
    NSMutableDictionary* sdk_infos = [self sdkInfos];

    NSError *error;
    NSData *uiData = [NSJSONSerialization dataWithJSONObject:user_infos
                                                       options:0
                                                         error:&error];
    NSData *siData = [NSJSONSerialization dataWithJSONObject:sdk_infos
                                                     options:0
                                                       error:&error];
   
    NSString *uiString = [[NSString alloc] initWithData:uiData encoding:NSUTF8StringEncoding];
    NSString *siString = [[NSString alloc] initWithData:siData encoding:NSUTF8StringEncoding];

    NSDictionary* serverParams = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                  siString, KWK_AD_REQUEST_JSON_KEY_SDK_INFOS,
                                  uiString, KWK_AD_REQUEST_JSON_KEY_USER_INFOS,
                                  self.slotID, KWK_AD_REQUEST_JSON_KEY_SLOT,
                                  nil];
    return serverParams;
}

@end


NSString* const kKWKAdSizeStrategyStringPixels = @"pixel";
NSString* const kKWKAdSizeStrategyStringRatio = @"ratio";

NSArray* GetAdSizeStrategyStrings()
{
    static NSArray* sizeStrategyStrings;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sizeStrategyStrings = [NSArray arrayWithObjects:kKWKAdSizeStrategyStringPixels,
                                    kKWKAdSizeStrategyStringRatio,
                                    nil];
        
    });
    
    return sizeStrategyStrings;
}

NSString* StringFromAdSizeStrategy(KWKADSizeStrategy strategy)
{
    return GetAdSizeStrategyStrings()[(int) strategy];
}

KWKADSizeStrategy KWKAdSizeStrategyFromString(NSString* sizeStrategyString)
{
    return (KWKADSizeStrategy)[GetAdSizeStrategyStrings() indexOfObject:sizeStrategyString];
}


NSString* const kKWKAdFormatStringInline    = @"inline";
NSString* const kKWKAdFormatStringOverlay   = @"overlay";
NSString* const kKWKAdFormatNative          = @"native";
NSString* const kKWKAdFormatParallax        = @"parallax";


NSString* StringFromAdFormat(KWKAdFormat format)
{
    static NSArray* adContainerTypeStrings;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        adContainerTypeStrings = [NSArray arrayWithObjects: kKWKAdFormatStringInline,
                                  kKWKAdFormatStringOverlay,
                                  kKWKAdFormatNative,
                                  kKWKAdFormatParallax,
                                  nil];
    });
    
    return adContainerTypeStrings[(NSUInteger) format];
}
