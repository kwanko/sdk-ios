//
//  KwkLib.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 09/12/16.
//  Copyright © 2016 Bogdan CHITU. All rights reserved.
//

#import "KwkLib.h"
#import "KWKLib+Private.h"
#import "KwkLibDefines.h"
#import "KWKGlobals.h"
#import "KWKUtils.h"
#import "KwkLibConsts.h"

#import "KWKAdProvider.h"

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AdSupport/AdSupport.h>

#import "KWKConnectivityManager.h"


#define KWK_NSU_DEF_KEY_GEOLOC @"KWK_NSU_DEF_KEY_GEOLOC"

@interface KwkLib ()<CLLocationManagerDelegate>
{
    CLLocationManager* locationManager;
    NSMutableArray<locationRecievedBlock>* locationBlocks;
}

@property (nonatomic, strong) CLLocation* lastRecievedLocation;
    
@end

@implementation KwkLib

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
    
#pragma mark -
    
- (instancetype) init
{
    if (self = [super init])
    {
        self.lastRecievedLocation = [self geoLocFromPrefs];
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        [KWKConnectivityManager getInstance]; //starts listening for network
        
        [self registerForApplicationLifeCycleEvents];
        
        locationBlocks = [[NSMutableArray alloc] init];
        
        return self;
    }
    
    return nil;
}

- (void)setForceGeoloc:(BOOL)forceGeoloc
{
    _forceGeoloc = forceGeoloc;
    if (forceGeoloc)
    {
        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse)
        {
             [locationManager requestWhenInUseAuthorization];
        }
    }
}

- (void) forceGeolocWithBlock:(locationRecievedBlock) block
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        block();
        return;
    }
    
    [locationBlocks addObject:block];
    [self setForceGeoloc:YES];
}

- (void) registerForApplicationLifeCycleEvents
{
    [self unregisterFromApplicationLifeCycleEvents];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminate)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}

- (void) unregisterFromApplicationLifeCycleEvents
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

- (void) appWillResignActive
{
    [self saveLocation];
}

- (void) appWillTerminate
{
    [self saveLocation];
}

- (void)dealloc
{
    [self unregisterFromApplicationLifeCycleEvents];
    [locationManager stopUpdatingLocation];
}


#pragma mark CLLocationManagerDelegate 

- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status)
    {
        case kCLAuthorizationStatusNotDetermined:
        {
            KWKLog(@"kCLAuthorizationStatusNotDetermined");
        }
        break;
        case kCLAuthorizationStatusDenied:
        {
            KWKLog(@"kCLAuthorizationStatusDenied");
            if ([locationBlocks count] > 0)
            {
                for (locationRecievedBlock block in locationBlocks)
                {
                    block();
                    [locationBlocks removeObject:block];
                }
            }
        }
        break;
        
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            [locationManager startUpdatingLocation]; 
        }
        break;
        
        default:
        break;
    }
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    BOOL shouldSaveImediately = self.lastRecievedLocation == nil;
    self.lastRecievedLocation = [locations lastObject];
    _isGeoLocFromPrefs = NO;
    
    if (shouldSaveImediately)
    {
        [self saveLocation];
    }
    
    if ([locationBlocks count] > 0)
    {
        for (locationRecievedBlock block in locationBlocks)
        {
            block();
            [locationBlocks removeObject:block];
        }
    }
}

#pragma mark -

- (void) saveLocation
{
    if (self.lastRecievedLocation)
    {
        CLLocationCoordinate2D lastRecievedLocCoords = self.lastRecievedLocation.coordinate;
        NSData* geolocData = [NSData dataWithBytes:&lastRecievedLocCoords length:sizeof(CLLocationCoordinate2D)];
        
        [[NSUserDefaults standardUserDefaults] setObject:geolocData forKey:KWK_NSU_DEF_KEY_GEOLOC];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (CLLocation*) geoLocFromPrefs
{
    CLLocation* location = nil;
    NSData *geolocData = [[NSUserDefaults standardUserDefaults] objectForKey:KWK_NSU_DEF_KEY_GEOLOC];
    if (geolocData)
    {
        CLLocationCoordinate2D coordinate;
        [geolocData getBytes:&coordinate length:sizeof(CLLocationCoordinate2D)];
        location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        _isGeoLocFromPrefs = YES;
    }
   
    return location;
}

#pragma mark Helpers -

- (CLLocation *)getCurrentLocation
{
    return self.lastRecievedLocation;
}


/*
 Returns true if device can make phone calls
 */
- (BOOL) supportsTel
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:"]];
}

/*
 Returns true if device can send sms
 */
- (BOOL) supportsSMS
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sms:"]];
}

- (NSString*) version
{
    return KWK_LIB_VERSION;
}

- (void) setLoggingEnabled:(BOOL)enabled
{
    KWKEnableLogging(enabled);
}

- (BOOL) supportsPhotos
{
    if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"])
    {
        return YES;
    }
    
    return NO;
}

- (BOOL) supportsCalendar
{
    if ([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSCalendarsUsageDescription"])
    {
        return YES;
    }
    
    return NO;
}

@end


