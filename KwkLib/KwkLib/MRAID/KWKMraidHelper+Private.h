//
//  KWKMraidHelper+Private.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 27/04/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKMraidHelper.h"
#import <EventKitUI/EventKitUI.h>
#import "KWKJSExpandProperty.h"
#import "KWKJSOrientaionProprety.h"
#import "KWKJSResizeProperty.h"

@protocol KWKMraidHelperWebViewDelegate <NSObject>

- (void) helperDidLoadHtml:(KWKMraidHelper*) helper;

@end

@class KWKMraidExpandViewController;

@interface KWKMraidHelper() <KWKMRAIDBridgeDelegate, KWKClosableViewDelegate, UIWebViewDelegate, EKEventEditViewDelegate>
{
    UIInterfaceOrientation currentOrientation;
    KWKMraidExpandViewController *expandVC;
}

@property (nonatomic, readwrite) MraidState mraidState;
@property (nonatomic, strong) KWKMRAIDBridge* nativebridge;

@property (nonatomic, strong) UIView* overlayView;//used for blocking touches when resized; this will be the topmost view and webview will move to it
@property (nonatomic, strong) KWKJSOrientaionProprety* orientationProperties;
@property (nonatomic, strong) KWKJSExpandProperty* expandProperties;
@property (nonatomic, strong) KWKJSResizeProperty* resizeProperties;

@property (nonatomic, strong)   KWKClosableView* mraidWebViewContainer;
@property (nonatomic, strong)   UIWebView* mraidWebView;

@property (nonatomic, readwrite) KWKMraidOpenURLDestination openURLDestination;

@property (nonatomic, weak) id<KWKMraidHelperWebViewDelegate> webViewDelegate;


- (void)resizeWithRect:(CGRect)rect andCustomClosePosition:(NSString*) customClosePostion;
- (void) close:(BOOL) fromMraidCommand;

@end
