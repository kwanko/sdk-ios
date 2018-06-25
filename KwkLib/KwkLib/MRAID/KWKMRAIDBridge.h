//
//  KWKMRAIDBridge.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 05/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "KWKMraid.h"
#import "KWKJSPosition.h"
#import "KWKJSSize.h"
#import "KWKJSOrientaionProprety.h"


@protocol KWKMRAIDBridgeDelegate <NSObject>

@required
- (void) setOrientationProperties:(KWKJSOrientaionProprety*) orientationProperties;
- (void) resizeWithRect:(CGRect) rect andCustomClosePosition:(NSString*) customClosePosition;
- (void) expandWithUrl:(NSString*) url andCustomClose:(BOOL)useCustomClose;
- (void) mraidClose;
- (void) mraidOpen:(NSString*) urlString;
- (void) storePicture:(NSString*) urlString;
- (void) playVideo:(NSString*) urlString;
- (void) createCalendarEvent:(NSDictionary*) eventInfo;


@end

/*
 * Bridge between JS and Native. Needs valid JSContext.
 */
@interface KWKMRAIDBridge : NSObject 
{
}

@property (nonatomic, weak) id<KWKMRAIDBridgeDelegate> delegate;
@property (nonatomic, strong) JSContext* currentContext;

- (void) sendState:(NSString *)state;

- (void) fireReadyEvent;
- (void) fireSizeChangeEvent:(CGSize) newSize;
- (void) fireViewableEvent:(BOOL) isViewable;
- (void) fireErrorEventForAction:(NSString *)action withMessage:(NSString *)message;

- (void) sendPlacementType:(NSString*) placementType;
- (void) sendDefaultPosition:(CGRect) defaultPosition;
- (void) sendCurrentPosition:(CGRect) currentPosition;
- (void) sendMaxSize:(CGSize) maxSize;
- (void) sendScreenSize:(CGSize) screenSize;
- (void) sendSupports:(MraidSupportFeatures) features;

- (void) sendNativaCallComplete:(NSString*) command;

@end

