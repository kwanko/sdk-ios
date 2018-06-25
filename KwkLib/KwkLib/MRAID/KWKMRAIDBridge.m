//
//  KWKMRAIDBridge.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 05/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKMRAIDBridge.h"
#import "KWKMRAIDBridge+Private.h"

#import "KwkLibDefines.h"
#import "KWKGlobals.h"
#import "KWKMraid.h"
#import "KwkLib.h"

#define KWK_NATIVE_OBJECT_NAME      @"mobileNative"
#define KWK_JS_OBJECT_NAME          @"mraidbridge"

//New method names

#define KWK_MRAID_BRIDGE_FUNC_NAME_SET_VIEWABLE             @"setIsViewable"
#define KWK_MRAID_BRIDGE_FUNC_NAME_SEND_SET_STATE           @"setState"
#define KWK_MRAID_BRIDGE_FUNC_NAME_SEND_PLACEMENT_TYPE      @"setPlacementType"
#define KWK_MRAID_BRIDGE_FUNC_NAME_SEND_DEFAULT_POS         @"setDefaultPosition"
#define KWK_MRAID_BRIDGE_FUNC_NAME_SEND_CURRENT_POS         @"setCurrentPosition"
#define KWK_MRAID_BRIDGE_FUNC_NAME_SEND_MAX_SIZE            @"setMaxSize"
#define KWK_MRAID_BRIDGE_FUNC_NAME_SEND_SCREEN_SIZE         @"setScreenSize"
#define KWK_MRAID_BRIDGE_FUNC_NAME_SEND_SUPPORTS            @"setSupports"
#define KWK_MRAID_BRIDGE_FUNC_NAME_SEND_CALL_COMPLETED      @"nativeCallComplete"
#define KWK_MRAID_BRIDGE_FUNC_NAME_FIRE_READY_EVENT         @"notifyReadyEvent"
#define KWK_MRAID_BRIDGE_FUNC_NAME_FIRE_EVENT_SIZE_CHANGE   @"notifySizeChangeEvent"
#define KWK_MRAID_BRIDGE_FUNC_NAME_FIRE_ERROR_EVENT         @"notifyErrorEvent"

@protocol KWKJStoNativeInterfaceExport <JSExport>

JSExportAs(         setOrientationProperties,
- (void)            setOrientationProperties:(BOOL) allowOrientationChange
                         andForceOrientation:(NSString*) forceOrientatoin
);

JSExportAs(resize,
- (void) resizeWithOffsetX:(int) offsetX
                   offsetY:(int) offsetY
                     width:(int) width
                    height:(int) height
       customClosePosition:(JSValue *) customClosePositionJSVal
            allowOffscreen:(Boolean) allowOffscreen
);

JSExportAs(expand,
- (void) expandWithUrl:(JSValue*) urlJSValue andUseCustomClose:(BOOL) useCustomClose
);

- (void) open:  (NSString*) urlString;
- (void) close;

- (void) storePicture:(NSString*) urlString;
- (void) playVideo:(NSString*) urlString;
- (void) createCalendarEvent:(NSArray* ) eventInfo;

@end

@interface KWKMRAIDBridge()<KWKJStoNativeInterfaceExport>

@end


@implementation KWKMRAIDBridge

- (instancetype) init
{
    self = [super init];
    return self;
}

- (void)setCurrentContext:(JSContext *)currentContext
{
    _currentContext = currentContext;
    _currentContext[KWK_NATIVE_OBJECT_NAME] = self;

    [_currentContext setExceptionHandler:^(JSContext * context, JSValue * val) {
        KWKJSLog(@"MRAID_BRIDGE ERROR: %@", val); //TODO - do something with err. Maybe report to mraid bridge?
    }];
    
    _currentContext[@"console"][@"log"] = ^(NSString* log)
    {
        KWKJSLog(@"%@",log);
    };
}

#pragma mark - KWKJStoNativeInterfaceExport


- (void)resizeWithOffsetX:(int)offsetX offsetY:(int)offsetY width:(int)width height:(int)height customClosePosition:(JSValue *)customClosePositionJSVal allowOffscreen:(Boolean)allowOffscreen
{
    NSString* customClosePosition = nil;
    if(![customClosePositionJSVal isUndefined] && ![customClosePositionJSVal isNull])
    {
        customClosePosition = [customClosePositionJSVal toString];
    }
    [_delegate resizeWithRect:CGRectMake(offsetX, offsetY, width, height) andCustomClosePosition:customClosePosition];
}

- (void) open:(NSString*) urlString
{
    [_delegate mraidOpen:urlString];
}

- (void) setOrientationProperties:(BOOL)allowOrientationChange andForceOrientation:(NSString *)forceOrientation
{
    KWKJSOrientaionProprety* orientatoinProperties = [[KWKJSOrientaionProprety alloc] init];
    orientatoinProperties.allowOrientationChange = allowOrientationChange;
    orientatoinProperties.forceOrientationString = forceOrientation;
    
    [_delegate setOrientationProperties:orientatoinProperties];
}

- (void) expandWithUrl:(JSValue*) urlJSValue andUseCustomClose:(BOOL) useCustomClose
{
    NSString* urlStringValue = nil;
    
    if (![urlJSValue isUndefined] && ![urlJSValue isNull])
    {
        urlStringValue = [urlJSValue toString];
    }
    
    [_delegate expandWithUrl:urlStringValue andCustomClose:useCustomClose];
}

- (void) close
{
    [_delegate mraidClose];
}

- (void) storePicture:(NSString *)urlString
{
    [_delegate storePicture:urlString];
}

- (void) playVideo:(NSString *)urlString
{
    [_delegate playVideo:urlString];
}

- (void) createCalendarEvent:(NSArray* ) eventInfoArray
{
    NSMutableDictionary* argumentsDictionary = [[NSMutableDictionary alloc] init];
    for (int i=0;i<[eventInfoArray count]/2;++i)
    {
        [argumentsDictionary setObject:eventInfoArray[2*i+1]  forKey:eventInfoArray[2*i]];
    }
 
    [_delegate createCalendarEvent:argumentsDictionary];
}

#pragma mark - native to JS -

- (JSValue*) getBridgeJSObject
{
    JSValue* bridge = [self currentContext][@"window"][KWK_JS_OBJECT_NAME];
    NSAssert(!([bridge isNull] || [bridge isUndefined]), @"No mraid js bridge present");
    return bridge;
}

- (JSValue *) callJSBridgeFunction:(NSString*) funcName withArguments: (NSArray*) args
{
    JSValue* bridge = [self getBridgeJSObject];
    return [bridge invokeMethod:funcName withArguments:args];
}

- (void) fireReadyEvent
{
    [self callJSBridgeFunction:KWK_MRAID_BRIDGE_FUNC_NAME_FIRE_READY_EVENT withArguments:nil];
}


- (void) fireSizeChangeEvent:(CGSize) newSize
{
    [self callJSBridgeFunction:KWK_MRAID_BRIDGE_FUNC_NAME_FIRE_EVENT_SIZE_CHANGE withArguments:@[
                                                                                  [NSNumber numberWithFloat:newSize.width],
                                                                                  [NSNumber numberWithFloat:newSize.height]
                                                                                  ]];
}

- (void) fireViewableEvent:(BOOL)isViewable
{
    [self callJSBridgeFunction:KWK_MRAID_BRIDGE_FUNC_NAME_SET_VIEWABLE withArguments:@[[JSValue valueWithBool:isViewable inContext:[self currentContext]]]];
}

- (void) fireErrorEventForAction:(NSString *)action withMessage:(NSString *)message
{
    [self callJSBridgeFunction:KWK_MRAID_BRIDGE_FUNC_NAME_FIRE_ERROR_EVENT
                 withArguments:@[action, message]];
}

- (void) sendPlacementType:(NSString*) placementType
{
    [self callJSBridgeFunction:KWK_MRAID_BRIDGE_FUNC_NAME_SEND_PLACEMENT_TYPE
                 withArguments:@[placementType]];
}

- (void)sendState:(NSString *)state
{
    [self callJSBridgeFunction:KWK_MRAID_BRIDGE_FUNC_NAME_SEND_SET_STATE withArguments:@[state]];
}

- (void) sendDefaultPosition:(CGRect) defaultPosition
{
    [self callJSBridgeFunction:KWK_MRAID_BRIDGE_FUNC_NAME_SEND_DEFAULT_POS
                 withArguments:@[[JSValue valueWithDouble:defaultPosition.origin.x inContext:[self currentContext]],
                                 [JSValue valueWithDouble:defaultPosition.origin.y inContext:[self currentContext]],
                                 [JSValue valueWithDouble:defaultPosition.size.width inContext:[self currentContext]],
                                 [JSValue valueWithDouble:defaultPosition.size.height inContext:[self currentContext]]]];
}

- (void) sendCurrentPosition:(CGRect) currentPosition
{
    [self callJSBridgeFunction:KWK_MRAID_BRIDGE_FUNC_NAME_SEND_CURRENT_POS
                 withArguments:@[[JSValue valueWithDouble:currentPosition.origin.x inContext:[self currentContext]],
                                 [JSValue valueWithDouble:currentPosition.origin.y inContext:[self currentContext]],
                                 [JSValue valueWithDouble:currentPosition.size.width inContext:[self currentContext]],
                                 [JSValue valueWithDouble:currentPosition.size.height inContext:[self currentContext]]]];
}

- (void) sendMaxSize:(CGSize) maxSize
{
    [self callJSBridgeFunction:KWK_MRAID_BRIDGE_FUNC_NAME_SEND_MAX_SIZE
                 withArguments:@[[JSValue valueWithDouble:maxSize.width inContext:[self currentContext]],
                                 [JSValue valueWithDouble:maxSize.height inContext:[self currentContext]]]];
}

- (void) sendScreenSize:(CGSize) screenSize
{
    [self callJSBridgeFunction:KWK_MRAID_BRIDGE_FUNC_NAME_SEND_SCREEN_SIZE
                 withArguments:@[[JSValue valueWithDouble:screenSize.width inContext:[self currentContext]],
                                 [JSValue valueWithDouble:screenSize.height inContext:[self currentContext]]]];
}

- (void) sendSupports:(MraidSupportFeatures) features
{
    //function(sms, tel, calendar, storePicture, inlineVideo)
    [self callJSBridgeFunction:KWK_MRAID_BRIDGE_FUNC_NAME_SEND_SUPPORTS
                 withArguments:@[[JSValue valueWithBool:features.sms inContext:[self currentContext]],
                                 [JSValue valueWithBool:features.tel inContext:[self currentContext]],
                                 [JSValue valueWithBool:features.calendar inContext:[self currentContext]],
                                 [JSValue valueWithBool:features.storePicture inContext:[self currentContext]],
                                 [JSValue valueWithBool:features.inlineVideo inContext:[self currentContext]]
                                 ]];
}

- (void) sendNativaCallComplete:(NSString *)command
{
    [self callJSBridgeFunction:KWK_MRAID_BRIDGE_FUNC_NAME_SEND_CALL_COMPLETED
                 withArguments:@[command]];
}

@end
