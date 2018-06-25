//
//  KwkLib.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 09/12/16.
//  Copyright © 2016 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface KwkLib : NSObject


/*
 * forceGeoloc - Setting this to YES will cause lib to ask for geolocation with requestWhenInUseAuthorization.
 * If it;s set to NO, lib will do this "silently"(if user already allowed getting the location, lib will get the location. If not, it wpn;t request it)
 * Default is NO
 */
@property (nonatomic, readwrite) BOOL forceGeoloc;

+ (instancetype) getInstance;

- (NSString*) version;


- (void) setLoggingEnabled:(BOOL)enabled;


@end
