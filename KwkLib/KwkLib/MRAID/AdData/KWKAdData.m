//
//  KWKAdData.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 26/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKAdData.h"
#import "KwkLibDefines.h"
#import "KWKGlobals.h"
#import "KWKUtils.h"
#import "KWKLib+Private.h"
#import "KWKGlobals.h"

#define KWK_RET_MACRO_UID       @"userID"
#define KWK_RET_MACRO_LAT       @"lat"
#define KWK_RET_MACRO_LNG       @"lng"

#define CLOSE_BTN_SIZE_SEPARATOR    @"x"
#define CLOSE_BTN_DEFAULT_SIZE      CGSizeZero

@interface KWKAdData()

@property (nonatomic, readwrite) NSTimeInterval ckt;
@property (nonatomic, readwrite) CGSize contentSize;
@property (nonatomic, readwrite) KWKADSizeStrategy sizeStrategy;
@property (nonatomic, strong)   NSDictionary* closeButtonInfo;

@end

KWKMraidOpenURLDestination GetOpenDestinationFromString(NSString* openDestination)
{
    KWKMraidOpenURLDestination dest = KWK_URL_OPEN_DESTINATION_SAFARI;
    
    if ([openDestination isEqualToString:KWK_AD_DATA_OPEN_URL_DEST_WEBVIEW])
    {
        dest = KWK_URL_OPEN_DESTINATION_UIWEBVIEV;
    }
    
    return dest;
}

NSString* StringFromOpenDestination(KWKMraidOpenURLDestination dest)
{
    static NSArray* openURLDestStrings;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        openURLDestStrings = [NSArray arrayWithObjects:KWK_AD_DATA_OPEN_URL_DEST_SAFARI,
                               KWK_AD_DATA_OPEN_URL_DEST_WEBVIEW,
                               nil];
        
    });
    
    return openURLDestStrings[(int) dest];
    
}

@implementation KWKAdData

- (instancetype) initWithData:(NSData*) data
{
    if (self = [super init])
    {
        NSError *e = nil;
        NSDictionary* jsonContents = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];

        if (e)
        {
            KWKLog(@"%s Error parsing jsoncontents: %@", __FUNCTION__, [e description]);
            return nil;
        }
        
        if([jsonContents count] == 0) {
            KWKLog(@"Error regarding jsoncontents: empty dictionary");
            return nil;
        }
        
        self.adID = ObjectOrNilFromJSONObject([jsonContents objectForKey:KWK_AD_DATA_JSON_KEY_ID]);
        self.adType = [jsonContents objectForKey:KWK_AD_DATA_JSON_KEY_TYPE];
        self.ck = [jsonContents objectForKey:KWK_AD_DATA_JSON_KEY_CK];
        self.ckt = [ObjectOrNilFromJSONObject([jsonContents objectForKey:KWK_AD_DATA_JSON_KEY_CKT]) doubleValue];
        self.pan = [jsonContents objectForKey:KWK_AD_DATA_JSON_KEY_PAN];
        
        id ret = [jsonContents objectForKey:KWK_AD_DATA_JSON_KEY_RET];
        if (IsValidJSONObject(ret))
        {
            self.html = [ret objectForKey:KWK_AD_DATA_JSON_KEY_RET_HTML];
            self.mraidTrackingParams = [ret objectForKey:KWK_AD_DATA_JSON_KEY_RET_MRAID_TRACKING];
            
            _urlOpenDestination = GetOpenDestinationFromString([jsonContents objectForKey:KWK_AD_DATA_JSON_KEY_URL_OPEN_DEST]);
            _forceGeoloc = [[jsonContents objectForKey:KWK_AD_DATA_JSON_KEY_FORCE_GEOLOC] boolValue];
            
            _ipGeolocFallbackCoord.latitude = FLT_MAX;
            _ipGeolocFallbackCoord.longitude = FLT_MAX;
            NSArray* ipGeolocFallbackArray = [jsonContents objectForKey:KWK_AD_DATA_JSON_KEY_IP_GEOLOC_FALLBACK];
            if (ipGeolocFallbackArray && (id)ipGeolocFallbackArray != [NSNull null])
            {
                float lat = [[ipGeolocFallbackArray objectAtIndex: 0] floatValue];
                float lng = [[ipGeolocFallbackArray objectAtIndex: 1] floatValue];

                _ipGeolocFallbackCoord.latitude = lat;
                _ipGeolocFallbackCoord.longitude = lng;
            }
            
            self.closeButtonInfo = [jsonContents objectForKey:KWK_AD_DATA_JSON_KEY_CLOSE_BTN];
            
            NSNumber* timeBeforeOverlay = [jsonContents objectForKey:KWK_AD_DATA_JSON_KEY_TIME_BEFORE_OVERLAY];
            if (timeBeforeOverlay && (id)timeBeforeOverlay != [NSNull null])
            {
                _timeBeforeOverlay = [timeBeforeOverlay floatValue];
            }
            
            NSNumber *overlayCountdown = [jsonContents objectForKey:KWK_AD_DATA_JSON_KEY_OVERLAY_COUNTDOWN];
            if (overlayCountdown && (id) overlayCountdown != [NSNull null])
            {
                _overlayCountdown = [overlayCountdown intValue];
            }
            
            [self replaceUIDMacro];
        }
        
        CGFloat contentWidth = [ObjectOrNilFromJSONObject([jsonContents objectForKey:KWK_AD_DATA_JSON_KEY_AD_WIDTH]) floatValue];
        CGFloat contentHeight = [ObjectOrNilFromJSONObject([jsonContents objectForKey:KWK_AD_DATA_JSON_KEY_AD_HEIGHT]) floatValue];
        self.contentSize = CGSizeMake(contentWidth, contentHeight);
        
        self.sizeStrategy = KWKAdSizeStrategyFromString(ObjectOrNilFromJSONObject([jsonContents objectForKey:KWK_AD_DATA_JSON_KEY_AD_SIZE_STRATEGY]));
    }
    
    return self;
}

- (void) replaceUIDMacro
{
    NSError *error = nil;
    
    NSString *pattern = [NSString stringWithFormat:@"(\\[|\\{|%%7B|%%5B)%@(\\}|\\]|%%7D|%%5D)", KWK_RET_MACRO_UID];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    if(error == nil) {
        self.html = [regex stringByReplacingMatchesInString:self.html options:0 range:NSMakeRange(0, [self.html length]) withTemplate:[KWKUtils IDFA]];
    }

}

- (void) replaceLatMacroWithFallbackCoord
{
    CLLocationCoordinate2D loc = self.ipGeolocFallbackCoord;
    [self replaceLatMacrowithCoord:loc];
}

- (void) replaceLatMacrowithCoord:(CLLocationCoordinate2D) coord
{
    if (coord.latitude != FLT_MAX && coord.longitude != FLT_MAX)
    {
        NSError *errorLat = nil;
        NSError *errorLng = nil;
        
        NSString *patternLat = [NSString stringWithFormat:@"(\\[|\\{|%%7B|%%5B)%@(\\}|\\]|%%7D|%%5D)", KWK_RET_MACRO_LAT];
        NSString *patternLng = [NSString stringWithFormat:@"(\\[|\\{|%%7B|%%5B)%@(\\}|\\]|%%7D|%%5D)", KWK_RET_MACRO_LNG];
        NSRegularExpression *regexLat = [NSRegularExpression regularExpressionWithPattern:patternLat options:NSRegularExpressionCaseInsensitive error:&errorLat];
        NSRegularExpression *regexLng = [NSRegularExpression regularExpressionWithPattern:patternLng options:NSRegularExpressionCaseInsensitive error:&errorLng];
        
        if(errorLat == nil && errorLng == nil) {
            self.html = [regexLat stringByReplacingMatchesInString:self.html options:0 range:NSMakeRange(0, [self.html length]) withTemplate:[NSString stringWithFormat:@"%.2f", coord.latitude]];
            self.html = [regexLng stringByReplacingMatchesInString:self.html options:0 range:NSMakeRange(0, [self.html length]) withTemplate:[NSString stringWithFormat:@"%.2f", coord.longitude]];
        }
    }
}

- (NSString*) closeButtonSRC
{
    return [self.closeButtonInfo objectForKey:KWK_AD_DATA_JSON_KEY_CLOSE_BTN_SRC];
}

- (float) closeButtonPadding
{
    return [[self.closeButtonInfo objectForKey:KWK_AD_DATA_JSON_KEY_CLOSE_BTN_PADDING] floatValue];
}

- (CGSize) closeButtonSize
{
    NSArray* comps = [[self.closeButtonInfo objectForKey:KWK_AD_DATA_JSON_KEY_CLOSE_BTN_SIZE] componentsSeparatedByString:CLOSE_BTN_SIZE_SEPARATOR];
    
    if ([comps count] == 2)
    {
        return CGSizeMake([comps[0] floatValue], [comps[1] floatValue]);
    }
    return CLOSE_BTN_DEFAULT_SIZE;
}



- (NSString*) description
{
    return [NSString stringWithFormat:@"(id: %@ t:%@ ck:%@ ckt:%f pan:%@ html:%@ mraidTrackingParals:%@ urlOpenDestination:%@ ipgeoloc: (%.2f,%.2f))", self.adID, self.adType, self.ck, self.ckt, self.pan, self.html, self.mraidTrackingParams, StringFromOpenDestination(self.urlOpenDestination), self.ipGeolocFallbackCoord.latitude, self.ipGeolocFallbackCoord.longitude];
}

@end
