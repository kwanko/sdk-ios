# Kwanko iOS SDK


## Requirements

* iOS 8.0 or later,
* Your slot UID from Kwanko

## SDK Installation

After you have cloned the SDK source code into your local machine you may want to build it and import it (.a files and headers from your products folder) in your xCode Project.
You can also import it as it is.
You will also have to add the necessary frameworks (see the list of used frameworks)

### Used frameworks/libraries

* Foundation - required
* JavaScriptCore - required
* AdSupport - required
* CoreTelephony - optional - used for collecting 2g/3g
* sqllite - required. used for Conversion
* AVFoundation, AVKit - mraid play
* EventKit, EventKitUI - optional - mraid createcalendarevent

Cocoa keys (permissions)
* NSLocationWhenInUseUsageDescription
* NSPhotoLibraryUsageDescription - used for mraid store picture
* NSCalendarsUsageDescription - used for mraid create calendar

## Displaying ads

Loading ads is done with the help of AdRequest and derivates.
* Ad Request(Base):
* slotID: Slot id form backend
* KWKAdPosition adPosition;// top, bottom.
* categories : Ex: @["IAB-25", @"IAB26"]
* customParams: Custom parameters passed to ad server;

Derivates:
* BannerAdRequest;
* OverlayAdRequest
* size : CGSize representing the size you want the overlay to have. Leave it CGSizeZero for full screen;
* sizeStrategy. Pixels or ratio. In case of ratio, use the size param to specify it. Ex: for ratio 1:5 set the size CGSizeMake(1,5) and the sizeStrategy to ratio;
* adPosition: vertical position you want to use for the overlay. Possible values: Centered/Top/Bottom. Default is centered
* NativeAdRequest;
* (Not available yet) ParallaxAdRequest;

### Banner ads

In order to show  a Banner Ad into an application you will have to follow these steps:
* instantiate adview (KWKBannerView object) programatically or via storyboard/xib
* instantiate bannerAdRequest(KWKBannerAdRequest object) and fill necessarry params. Slot is mandatory!
* [adView loadAdForRequest:bannerAdRequest]

Example:
```
#import "KWKBannerAdRequest.h"
#import "KWKBannerView.h"
... 

KWKBannerView *adView = [[KWKBannerView alloc] initWithFrame:CGRectMake(X, Y, W, H)];
//Alternatively, you can use interface builder and add a KWKBannerView to your view hierarchy

KWKBannerAdRequest* bannerRequest = [[KWKBannerAdRequest alloc] init];
bannerRequest.slotID = @"slotID";

[adView loadAdForRequest:bannerRequest];

```
**Banner customParams**

| Key | Description | Value |
| -------- | -------- | -------- |
| kKWKBannerCustomParamsRefreshRate | Ad refresh rate in seconds | NSNumber |

* banner refresh rate : The defauld banner refresh rate(5 minutes) can be changed by adding to customParams a NSNumber representing the new value in seconds of the desired refresh time, using the key * *kKWKBannerCustomParamsRefreshRate* *. (Example: bannerRequest.customParams = @{kKWKBannerCustomParamsRefreshRate : [NSNumber numberWithInt:5]};)

### Overlay ads

Overlay Ads are ads that are showing inside an activity over the activity content, however the user can still operate with the content that is not behind the overlay ad. In order to integrate this type of ad you will have to follow these steps:
* instantiate overlayAdRequest(KWKOverlayAdRequest object) and fill necessarry params. Slot is mandatory.
* instantiate a KWKOverlay object and use it to load the request via loadRequest
* provide a presenting View Controller via rootViewController(See KWKOverlayDelegete)


Example:
```
#import "KWKOverlayAdRequest.h"
#import "KWKOverlay.h"
... 

@interface OverlayViewController () <KWKOverlayDelegate>
@end

@implementation OverlayViewController
...

KWKOverlayAdRequest *request = [[KWKOverlayAdRequest alloc] init];
request.slotID = @"slotID";
request.size = CGSizeMake(320, 480);

KWKOverlay *overlay = [[KWKOverlay alloc] init];
overlay.delegate = self;
[overlay loadRequest:request];

...

- (UIViewController*) rootViewController  {
return self;
}

...

@end

```

** KWKOverlayDelegete **

#pragma mark -
@required
- (UIViewController*) rootViewController;  * * Provides root view controller for presenting overlays * *

#pragma mark - Ad events
@optional

- (void) didLoadOverlay:(KWKOverlay*) overlay;   * *Called when overlay is loaded* *
- (void) didFailToLoadOverlay:(KWKOverlay*) overlay error:(NSError*) error;  * *Called when overlay cannot be loaded* *
- (void) didDisplayOverlay:(KWKOverlay*) overlay;  * *Called when overlay is displayed* *
- (void) didFailToDisplayOverlay:(KWKOverlay*) overlay;  * *Called when overlay cannot be displayed* *

- (void) didCloseKwankoOverlay;  * *Called when **KWANKO** overlay is closed (does not work for mediated ads* *
**NOTE:** you can simulate an ad refresh by reloading the request when this event is called

### Mediation
The Kwanko SDK can be used to display ads from Admob via mediation process.

Currently the sdk supports the following ads types:
* Banner;
* Interstitial;

In order to use mediation, you have to follow these steps:
* Install the basic kwanko ad static library(libKWKLib.a)
* Install the static library that mediates your targeted network in your project. (Example: libKWKAdMobMediator.a)
* Install the mediated framework/static library(example: GoogleMobileAds.framework)
* Configure your network on the server** <- //TODO insert link
* Load the banner/interstitial like you would with a normal ad.

### Tracking parameters
For every ad request, tracking parameters are reported to the server, allong side with the parameters set by the developer(eg.: slotID, customCategories, etc) the ads.
In the following table you can find a complete list of parameters (params for short) that a request can contain.


The list of all custom parameters which are filled by the developer or by the SDK is:

| Params | Description | Value |  Filled by
| -------- | -------- | -------- | -------- |
| nativeAd   | his param allow to specify to ad server that you want an native ad   | string   | Filled by developer   |
| categories   |   | string  | Filled by developer    |
| categories   |   | string  | Filled by developer    |
| lat | This param represent the latitude of the user | float | Filled by SDK  |
| long | This param represent the longitude of the user | float | Filled by SDK |
| devicetype | This param represent the type of the device. (Ex: 1 => Computer, 1 =>Tablet, 3 => Mobile, 4 => Television, 5 => Other) | int | Filled by SDK |
| make | This param represent the brand of device. Ex: Samsung | string | Filled by SDK |
| language   |  This param represent the language | string  |Filled by SDK  |
| ua   |  This param represent the user agent | string  |Filled by SDK  |
| domain   |  This represents the app name | string  |Filled by SDK  |
| adWidth   |  Represent the width of the ad. Can be dp or ratio. | int  |Filled by SDK |
| adHeight   |  Represent the height of the ad. Can be dp or ratio. | int  |Filled by SDK |
| screenWidth   |  Represent the width of the screen. Always in dp | int  |Filled by SDK  |
| screenHeight   | Represent the height of the screen. Always in dp | int  |Filled by SDK  |
| adSizeStrategy   |  Represent the strategy of the size. Ex: pixel / ratio | string  |Filled by SDK  |
| format   |  This param represent the type of ad. Could have one of this 4 values: inline, overlay, parallax, native. Ex: format: "overlay" | string  |Filled by SDK  |
| adPosition   |  Represent the position of the overlay ad. Can have only 2 values: top or bottom | string  |Filled by developer  |
| customParams   |  Represent a dictionary. (Ex: {@"foo" : @"bar",@"foo2" : @"bar2",@"foo3" : @"bar3",@"foo4" : @"bar4",@"foo5" : @"bar5"} | dict  |Filled by developer  |
| domain   |  This represents the app name | string  |Filled by SDK  |
| antenneID | Represent an ID of a Carrier Antenna from which the mobile phone get the signal | string | Filled by SDK |
| radioType | Represents the network radio type the user is connected to at the time the SDK makes the ad request. See Radio type sheet(Server column). | int |Filled by SDK |
| carriers | Ex: SFR / ORANGE / BOUYGUES | string | Filled by SDK |
| homeMobileCountryCode | The mobile country(MCC) code consists of 3 decimal digits and is used in combination with mobile network code(MNC) to uniquely identify the mobile network operator. The mobile country code consists of 3 decimal digits | int | Filled by SDK |
| homeMobileNetworkCode | Mobile network code consists of 2 or 3 decimal digits. See MCC above | int | Filled by SDK |
| connectivity | Represent the network of the device. (Ex: EDGE / 2G / 3G / 4G / Wifi) | int | Filled by SDK |
| model | Represent the model of the device. (Ex: Iphone) | string | Filled by SDK |
| os | Represent the operating system. (Ex: IOS/ Android/ etc..) | string |Filled by SDK |
| osv | Represent the operating system version(Ex: 8.1) | string | Filled by SDK |
| forceGeoloc | If this is set then the SDK will get the geolocation of the user, when the website where the SDK is used not asking for geolocation. (Ex: forceGeoloc: true) | bool | Filled by SDK|


### Tracking actions
#### Tracking simple actions
In order to track a simple action, mostly install of the application, you will need to call **reportConversionWithID:Label:AlternativeID:isRepeatable:** method from the KwankoConversion object that is returned via getInstance;



Reports conversion to traking server
*  @param trackingID - Mandatory -Is a unique ID to identify the "Tracking Object", it's like the slotUID which is the unique Id of the adSlot.
Every tracking ID will be given to the developer (as SlotUID, it will be created on our frontoffice).
*  @param action - Optional - Will be install / register / form. See consts(kKwankoConversionAction..).
*  @param email - Optional
*  @param isRepeatable if set to NO, the tracking Object will call 1 time the adserver and will never call again

```
(void) reportConversionWithID:(NSString*) trackingID
Label:(NSString*) action
AlternativeID:(NSString*) email
isRepeatable:(BOOL) repeatable;
```

Example:
```
[[KwankoConversion getInstance] reportConversionWithID:@"ACTION_ID"
Label:@"LABEL"
AlternativeID:@"ALTERNATIVE_ID"
isRepeatable:NO];
```

#### Tracking a sale action

In order to track sale action you will need to call **reportRemarketingWithID:Label:EventID:Amount:Currency:PaymentMethod:AlternativeID:CustomParameters:isRepeatable:** from the method from the KwankoRemarketing object
that is returned via getInstance;  


Reports remarketing to traking server

* @param trackingID - Mandatory -Is a unique ID to identify the "Tracking Object", it's like the slotUID
which is the unique Id of the adSlot.
Every tracking ID will be given to the developer (as SlotUID, it will be created on our frontoffice).

* @param action - Optional - Will be install / register / form. See consts(kKwankoConversionAction..).

*  @param email - Optional

*  @param isRepeatable if set to NO, the tracking Object will call 1 time the adserver and will never call again

*  @param eventID - As we are talking about a sale action, the developer must give something unique , can be a transaction ID, customer ID in BDD etc.....  through EventId

*  @param amount - Amount Without Tax of the transaction, without shipping through Amount

*  @param currency - Currency ISO 4217   through Currency

*  @param payname - will be filed by the dev through PaymentMethod

```
- (void) reportRemarketingWithID:(NSString*) trackingID
Label:(NSString*) action
EventID:(NSString*) eventID
Amount:(float) amount
Currency:(NSString*) currency
PaymentMethod:(NSString*) payname
AlternativeID:(NSString*) email
CustomParameters:(NSDictionary*) CustomParameters
isRepeatable:(BOOL) repeatable;
```
Example:
```
[[KwankoRemarketing getInstance] reportRemarketingWithID:@"ACTION_ID"
Label:@"LABEL"
EventID:@"EVENT_ID"
Amount:10.0f
Currency:@"USD"
PaymentMethod:@"PAYMENT_METHOD"
AlternativeID:@"ALTERNATIVE_ID"
CustomParameters:@{CUSTOM_PARAMS_DICTIONARY}
isRepeatable:NO];

```

