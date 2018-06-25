//
//  KWKGlobals.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 03/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define KWK_MAKE    @"Apple"

@interface UIView (KWKUIView)

- (UIWindow*) getWindow;
- (BOOL) isViewableToUser;
- (void) removeSubvies;

@end

@interface UIApplication (KWKUiApplication)

- (NSString*) appDisplayName;
- (UIViewController*) topMostViewController;

@end

@interface NSData (KWKNSData)

+(NSData*) requestDataFromParamsDictionary:(NSDictionary*) paramsDictionary;

@end

@interface UIWebView(KWKUIwebView)

+(NSString *) userAgent;

@end


NSString* StringFromOrientatoin(UIInterfaceOrientation orient);

void KWKEnableLogging(BOOL bVal);
void KWKLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2) NS_NO_TAIL_CALL;
void KWKJSLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2) NS_NO_TAIL_CALL;
void KWKNativeLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2) NS_NO_TAIL_CALL;

