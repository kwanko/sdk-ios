//
//  KWKAdData.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 26/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

/*
 * For a list of params see https://kwanko.tpondemand.com/restui/board.aspx?acid=36631ab62e1651a92d45d88cc700d366#page=userstory/4153
 * Note: List is incomplete. Missing details on what params can contain. For example the T param
 */

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIGeometry.h>
#import "KWKAdRequest.h" //TODO move size strategy so that this does not need to be imported

#define KWK_AD_DATA_JSON_KEY_ID                     @"id"
#define KWK_AD_DATA_JSON_KEY_TYPE                   @"t"
#define KWK_AD_DATA_JSON_KEY_CK                     @"ck"
#define KWK_AD_DATA_JSON_KEY_CKT                    @"ckt"
#define KWK_AD_DATA_JSON_KEY_PAN                    @"pan"
#define KWK_AD_DATA_JSON_KEY_RET                    @"ret"
#define KWK_AD_DATA_JSON_KEY_RET_HTML               @"html"
#define KWK_AD_DATA_JSON_KEY_AD_WIDTH               @"adWidth"
#define KWK_AD_DATA_JSON_KEY_AD_HEIGHT              @"adHeight"
#define KWK_AD_DATA_JSON_KEY_AD_SIZE_STRATEGY       @"adSizeStrategy"

#define KWK_AD_DATA_JSON_KEY_CLOSE_BTN              @"closeButton"
#define KWK_AD_DATA_JSON_KEY_CLOSE_BTN_SRC          @"src"
#define KWK_AD_DATA_JSON_KEY_CLOSE_BTN_PADDING      @"padding"
#define KWK_AD_DATA_JSON_KEY_CLOSE_BTN_SIZE         @"size"

#define KWK_AD_DATA_JSON_KEY_RET_MRAID_TRACKING     @"mraidEvents"
#define KWK_AD_DATA_JSON_KEY_URL_OPEN_DEST          @"openStrategy"
#define KWK_AD_DATA_JSON_KEY_FORCE_GEOLOC           @"forceGeoloc"
#define KWK_AD_DATA_JSON_KEY_IP_GEOLOC_FALLBACK     @"ipGeoFallback"
#define KWK_AD_DATA_JSON_KEY_IP_GEOLOC_LAT          @"lat"
#define KWK_AD_DATA_JSON_KEY_IP_GEOLOC_LONG         @"long"
#define KWK_AD_DATA_JSON_KEY_TIME_BEFORE_OVERLAY    @"timeBeforeOverlay"
#define KWK_AD_DATA_JSON_KEY_OVERLAY_COUNTDOWN      @"overlayCountdown"

#define KWK_AD_DATA_AD_TYPE_MRAID           @"S"

#define KWK_AD_DATA_OPEN_URL_DEST_SAFARI    @"browser"
#define KWK_AD_DATA_OPEN_URL_DEST_WEBVIEW   @"webview"

typedef enum
{
    KWK_AD_TYPE_UNKNOWN = 0,
    KWK_AD_TYPE_MRAID
}KwkAdType;

typedef enum
{
    KWK_URL_OPEN_DESTINATION_SAFARI,
    KWK_URL_OPEN_DESTINATION_UIWEBVIEV
}KWKMraidOpenURLDestination;

KWKMraidOpenURLDestination GetOpenDestinationFromString(NSString* openDestination);
NSString* StringFromOpenDestination(KWKMraidOpenURLDestination dest);

@interface KWKAdData : NSObject

@property (nonatomic, strong)   id adID;
@property (nonatomic, strong)   NSString* adType; //S,U,D,T,E,admob - dk what they are yet
@property (nonatomic, strong)   NSString* ck;// cookie ?
@property (nonatomic, readonly) NSTimeInterval ckt;// cookie timestamp ??
@property (nonatomic, strong)   NSString* pan; //tracking pixels URL
@property (nonatomic, strong)   NSString* html; //html content
@property (nonatomic, strong)   NSDictionary* mraidTrackingParams;
@property (nonatomic, readonly) KWKMraidOpenURLDestination urlOpenDestination; //destination for mraid open command
@property (nonatomic, readonly) CGSize contentSize;
@property (nonatomic, readonly) KWKADSizeStrategy sizeStrategy;
@property (nonatomic, readonly) BOOL forceGeoloc;
@property (nonatomic, readonly) CLLocationCoordinate2D ipGeolocFallbackCoord;
@property (nonatomic, readonly) float timeBeforeOverlay;
@property (nonatomic, readonly) int overlayCountdown;
@property (nonatomic, readonly) NSString* closeButtonSRC;
@property (nonatomic, readonly) float closeButtonPadding;
@property (nonatomic, readwrite) CGSize closeButtonSize;

@property (nonatomic, readwrite) NSDictionary* adInfo; //todo make readonly

- (instancetype) initWithData:(NSData*) data;

- (void) replaceUIDMacro;
- (void) replaceLatMacroWithFallbackCoord;
- (void) replaceLatMacrowithCoord:(CLLocationCoordinate2D) coord;

@end
