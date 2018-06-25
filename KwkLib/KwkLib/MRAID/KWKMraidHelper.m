//
//  KWKMraidHelper.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 27/12/16.
//  Copyright © 2016 Bogdan CHITU. All rights reserved.
//

#import "KWKMraidHelper.h"
#import "KWKMraidHelper+Private.h"
#import "KwkLib.h"
#import "KWKLib+Private.h"
#import "KwkLibDefines.h"
#import "KwkLibConsts.h"
#import "KWKGlobals.h"
#import "KWKUtils.h"
#import "KWKMraidExpandViewController.h"
#import "KWKWebViewController.h"
#import "KWKJSExpandProperty.h"
#import "KWKJSResizeProperty.h"
#import "KWKRestService.h"
#import <AVKit/AVPlayerViewController.h>
#import <AVFoundation/AVFoundation.h>
#import "KWKCalendarUtils.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>


#define KWK_MRAID_COMMAND_NAME_RESIZE                       @"resize"
#define KWK_MRAID_COMMAND_NAME_EXPAND                       @"expand"
#define KWK_MRAID_COMMAND_NAME_SET_ORIENT_PROPS             @"setOrientationProperties"
#define KWK_MRAID_COMMAND_NAME_CLOSE                        @"close"
#define KWK_MRAID_COMMAND_NAME_OPEN                         @"open"
#define KWK_MRAID_COMMAND_STORE_PICTURE                     @"storePicture"
#define KWK_MRAID_COMMAND_PLAY_VIDEO                        @"playVideo"
#define KWK_MRAID_COMMAND_CREATE_CALENDAR_EVENT             @"createCalendarEvent"


@implementation KWKMraidHelper

- (instancetype) init
{
    if (self = [super init])
    {
        self.mraidState = MRAID_STATE_LOADING;
        [self registerForDeviceOrientationChangeNotiffications];
        [self registerForApplicationPauseResumeEvents];
        
        self.orientationProperties = [[KWKJSOrientaionProprety alloc] init];
        
        CGSize maxSize = [self getMaxSize];
        self.expandProperties = [[KWKJSExpandProperty alloc] initWithSize:maxSize andUseCustomClose:NO];
        
        self.resizeProperties = [[KWKJSResizeProperty alloc] initWithRect:CGRectMake(0, 0, maxSize.width, maxSize.height) andClosePosition:nil];
        
        _openURLDestination = KWK_URL_OPEN_DESTINATION_SAFARI;
        return self;
    }
    
    return nil;
}

- (void) dealloc
{
    [self unregisterFromDeviceOrientationChangeNotiffications];
    [self unregisterFromApplicationPauseResumeEvents];
    
    [self.mraidWebViewContainer removeFromSuperview];
    [self.overlayView removeFromSuperview];
    
    self.mraidWebViewContainer = nil;
    self.mraidWebView = nil;
    self.nativebridge = nil;
}

- (void) setupUI
{
    if (self.mraidWebViewContainer)
    {
        //Already set up
        return;
    }
    
    //setup webview that will load ad
    CGRect containerFrame = self.initialParentView.frame;
    self.mraidWebViewContainer = [[KWKClosableView alloc] initWithFrame:CGRectMake(0, 0, containerFrame.size.width, containerFrame.size.height)];
    self.mraidWebViewContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.mraidWebViewContainer setDelegate:self];
    
    [self.mraidWebViewContainer setCloseImgURLString:[self.mraidDelegate getCloseBtnURL]];
    [self.mraidWebViewContainer setCloseImgPadding:[self.mraidDelegate getCloseBtnPadding]];
    [self.mraidWebViewContainer setCloseImgSize:[self.mraidDelegate getCloseBtnSize]];
    
    self.mraidWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.mraidWebViewContainer.frame.size.width, self.mraidWebViewContainer.frame.size.height)];
    self.mraidWebView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.mraidWebView.scrollView.scrollEnabled = NO;
    self.mraidWebView.scalesPageToFit = NO;
    
    //see pag 43.49 of http://www.iab.com/wp-content/uploads/2015/08/IAB_MRAID_v2_FINAL.pdf
    self.mraidWebView.mediaPlaybackRequiresUserAction = NO;
    self.mraidWebView.allowsInlineMediaPlayback = YES;
    
    self.mraidWebView.delegate = self;

    [self.mraidWebViewContainer addSubview:self.mraidWebView];
    [self.initialParentView addSubview:self.mraidWebViewContainer];
}

- (void) setupOverlayView
{
    //setup overlay that webview will move to when resizing
    UIView* mainView = [[UIApplication sharedApplication] topMostViewController].view;
    self.overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainView.frame.size.width, mainView.frame.size.height)];
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.overlayView setBackgroundColor:[UIColor clearColor]];
    [mainView addSubview:self.self.overlayView];
    [mainView bringSubviewToFront:self.overlayView];
    [self.overlayView setHidden:YES];
}

- (void) deleteOverlayView
{
    [self.overlayView removeFromSuperview];
    self.overlayView = nil;
}

- (void) loadAdHtml:(NSString*) htmlString
{
    if (nil == self.mraidWebView)
    {
        [self setupUI];
    }

    //inject js
    //TODO -> use bundle and bundle path
    NSError* err = nil;
    NSString* fileName = @"mraid";
    NSString* fileType = @"js";
    NSString *mraidString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:fileType] encoding:NSUTF8StringEncoding error:&err];
    if(err)
    {
        KWKLog(@"Error loading %@.%@", fileName, fileType);
    }
    else
    {
        [self.mraidWebView stringByEvaluatingJavaScriptFromString:mraidString];
    }
    
    
    //load actual content
    [self.mraidWebView loadHTMLString:htmlString baseURL:nil];
}

#pragma mark -
- (void) setMraidState:(MraidState)mraidState
{
    if (_mraidState != mraidState)
    {
        _mraidState = mraidState;
        
        //notify js
        [self.nativebridge sendState:GetMraidStateAsString(mraidState)];
    }
}

- (void) setCurrentContext:(JSContext *)currentContext
{
    //Rebuild native bridge
    self.nativebridge = [[KWKMRAIDBridge alloc] init];
    [self.nativebridge setDelegate:self];
    [self.nativebridge setCurrentContext:currentContext];
}

- (void) setOrientationProperties:(KWKJSOrientaionProprety *)orientationProperties
{
    _orientationProperties = orientationProperties;
    if (expandVC && self.mraidState == MRAID_STATE_EXPANDED) //check state not really needed
    {
        __weak __typeof__(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^
        {
            expandVC.orientationProperties = orientationProperties;
            UIViewController* presentingVC = expandVC.presentingViewController;
            [expandVC dismissViewControllerAnimated:NO completion:^{
                [presentingVC presentViewController:expandVC animated:NO completion:^{
                    [weakSelf updateMRAIDProperties];
                    [weakSelf.nativebridge sendNativaCallComplete:KWK_MRAID_COMMAND_NAME_SET_ORIENT_PROPS];
                }];
            }];
        });
    }
    else
    {
        [self.nativebridge sendNativaCallComplete:KWK_MRAID_COMMAND_NAME_SET_ORIENT_PROPS];
    }
    
    [self reportAction:KWK_MRAID_COMMAND_NAME_SET_ORIENT_PROPS];
}

- (void) checkAndReportViewable
{
    BOOL isViewable = [[self mraidWebView] isViewableToUser];
    [self.nativebridge fireViewableEvent:isViewable];
}


- (void)updateMRAIDProperties
{
    [self.nativebridge sendDefaultPosition:[self getDefaultPosition]];
    [self.nativebridge sendCurrentPosition:[self getCurrentPosition]];
    [self.nativebridge sendMaxSize:[self getMaxSize]];
    [self.nativebridge sendScreenSize:[self getScreenSize]];
    [self.nativebridge fireSizeChangeEvent:self.mraidWebView.frame.size];
    [self.nativebridge fireViewableEvent:[self isViewable]];
}

- (MraidSupportFeatures) supportsFeatures
{
    MraidSupportFeatures s;
    s.tel = [[KwkLib getInstance] supportsTel];
    s.sms = [[KwkLib getInstance] supportsSMS];
    s.calendar = [[KwkLib getInstance] supportsCalendar];
    s.storePicture = [[KwkLib getInstance] supportsPhotos];
    s.inlineVideo = YES;
    
    return s;
}


#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        if ([_mraidDelegate getOpenUrlDestination] == KWK_URL_OPEN_DESTINATION_UIWEBVIEV)
        {
            UIViewController* topMostViewController = [[UIApplication sharedApplication] topMostViewController];
            KWKWebViewController* openVC = [[KWKWebViewController alloc] init];
            openVC.urlToLoad = request.URL.absoluteString;
            
            [topMostViewController presentViewController:openVC animated:YES completion:nil];
            
            return NO;
        }
        else //assume safari for now
        {
            NSURL* url = request.URL;
            if ([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:request.URL options:@{} completionHandler:nil];
                return NO;
            }
        }
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //disable copy Note: this can be done by subclassing uiwebview and overriding - (BOOL)canPerformAction:(SEL)action withSender:(id)sender and might be safer.
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    
    //set viewport for responsive ads
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.querySelector('meta[name=viewport]').setAttribute('content', 'width=%d;', false);",
                                                                                (int)webView.frame.size.width]];
    
    
    JSContext* context =  [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    [self setCurrentContext:context];
    
    [self.nativebridge fireReadyEvent];
    [self setMraidState:MRAID_STATE_DEFAULT];
    [self.nativebridge sendPlacementType:[self getPlacementType]];
    [self.nativebridge sendSupports:[self supportsFeatures]];
    
    [self updateMRAIDProperties];
    
    MraidPlacementType placementType = [self placementType];
    if (placementType == MRAID_PLACEMENT_TYPE_INTERSTITIAL || placementType == MRAID_PLACEMENT_TYPE_OVERLAY)
    {
        [self.mraidWebViewContainer setShouldDisplayCloseBtn:YES];
    }
    
    if (_webViewDelegate)
    {
        [_webViewDelegate helperDidLoadHtml:self];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([error code] != NSURLErrorCancelled)
    {
        //skip async res loading errors
        return;
    }
}

#pragma mark KWKClosableViewDelegate -

- (void)closeButtonPressedFromView:(UIView *)closableView
{
    [self close:NO];
}

#pragma mark EKEventEditViewDelegate
- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action;
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    //[self close:NO];
}

#pragma mark - Orientation
- (void) registerForDeviceOrientationChangeNotiffications
{
    [self unregisterFromDeviceOrientationChangeNotiffications];
    
    currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void) unregisterFromDeviceOrientationChangeNotiffications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void) deviceOrientationDidChange: (NSNotification *)notification
{
    UIInterfaceOrientation newOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (currentOrientation != newOrientation)
    {
        NSLog(@"New interfaceorientaion %@", StringFromOrientatoin(newOrientation));

        currentOrientation = newOrientation;
        [self updateMRAIDProperties];
    }
}

#pragma mark - App Active
- (void) registerForApplicationPauseResumeEvents
{
    [self unregisterFromApplicationPauseResumeEvents];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void) unregisterFromApplicationPauseResumeEvents
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void) appWillResignActive
{
    [[self nativebridge] fireViewableEvent:NO]; //programatically checking if mraid container is viewable will return YES. Sending no on App Pause Events
}

- (void) appDidBecomeActive
{
    [self checkAndReportViewable];
}

#pragma mark - calls from JS
- (MraidPlacementType) placementType
{
    MraidPlacementType plType = MRAID_PLACEMENT_TYPE_UNKNOWN;
    if ([self mraidDelegate] && [[self mraidDelegate] respondsToSelector:@selector(getPlacementType)])
    {
        plType = [[self mraidDelegate] getPlacementType];
    }
    
    return plType;
}

#pragma mark -

#pragma mark KWKMRAIDBridgeDelegate

- (NSString*) getPlacementType
{
    return GetIdentifierForPlacementType([self placementType]);
}

- (CGRect) getDefaultPosition
{
    if (self.mraidWebView == nil)
    {
        KWKNativeLog(@"Error: Mraid Web View not initialized");
        return CGRectZero;
    }
    
    UIWindow* keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect defaultRect = [self.initialParentView.superview convertRect:self.initialParentView.frame toView:keyWindow];
    
    return defaultRect;
}

- (CGRect) getCurrentPosition
{
    if (self.mraidWebView == nil)
    {
        KWKNativeLog(@"Error: Mraid Web View not initialized");
        return CGRectZero;
    }
    
    UIWindow* keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    CGRect currentPos = [self.mraidWebView.superview convertRect:self.mraidWebView.frame toView:keyWindow];
    return currentPos;
}

- (CGSize) getScreenSize
{
    return [KWKUtils getScreenSize];
}

- (CGSize) getMaxSize
{
    return [KWKUtils getMaxSize];
}

- (BOOL) isViewable
{
    return [[self mraidWebView] isViewableToUser];
}

- (void)resizeWithRect:(CGRect)rect andCustomClosePosition:(NSString*) customClosePostion
{
    MraidPlacementType placementType = [self placementType];
    if (placementType == MRAID_PLACEMENT_TYPE_UNKNOWN || placementType == MRAID_PLACEMENT_TYPE_INTERSTITIAL)
    {
        [self.nativebridge fireErrorEventForAction:KWK_MRAID_COMMAND_NAME_RESIZE withMessage:@"Resize can only be done for inline ads"];
        [self reportAction:KWK_MRAID_COMMAND_NAME_RESIZE];
        return;
    }
    
    if ([self mraidState] == MRAID_STATE_EXPANDED)
    {
        [self.nativebridge fireErrorEventForAction:KWK_MRAID_COMMAND_NAME_RESIZE withMessage:@"Ad is already expanded"];
        [self reportAction:KWK_MRAID_COMMAND_NAME_RESIZE];
        return;
    }
    
    self.resizeProperties.customClosePosition = customClosePostion;
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [weakSelf setupOverlayView];
        
        [weakSelf.mraidWebViewContainer setFrame:rect]; //animate??
        [weakSelf.mraidWebViewContainer setShouldDisplayCloseBtn:NO];
        [weakSelf.mraidWebViewContainer setCustomClosePosition:weakSelf.resizeProperties.customClosePosition];
        
        [self.overlayView addSubview:weakSelf.mraidWebViewContainer];
        [self.overlayView setHidden:NO];
        
        [weakSelf.nativebridge sendNativaCallComplete:KWK_MRAID_COMMAND_NAME_RESIZE];
        weakSelf.mraidState = MRAID_STATE_RESIZED;
        [weakSelf updateMRAIDProperties];
        
    });
    
    [self reportAction:KWK_MRAID_COMMAND_NAME_RESIZE];
}

- (void) expandWithUrl:(NSString*) url andCustomClose:(BOOL)useCustomClose;
{
    self.expandProperties.useCustomClose = useCustomClose;
    __weak __typeof__(self) weakSelf = self;

    dispatch_async(dispatch_get_main_queue(), ^
    {
        if ([weakSelf placementType] == MRAID_PLACEMENT_TYPE_INTERSTITIAL)
        {
            [weakSelf.nativebridge fireErrorEventForAction:KWK_MRAID_COMMAND_NAME_EXPAND withMessage:@"Cannot expand an interstitial"];
            [self reportAction:KWK_MRAID_COMMAND_NAME_EXPAND];
            return;
        }
        
        if (weakSelf.mraidState == MRAID_STATE_EXPANDED)
        {
            [weakSelf.nativebridge fireErrorEventForAction:KWK_MRAID_COMMAND_NAME_EXPAND withMessage:@"Ad already expanded"];
            [self reportAction:KWK_MRAID_COMMAND_NAME_EXPAND];
            return;
        }
        
        if (weakSelf.mraidState == MRAID_STATE_RESIZED)
        {
            CGSize initialSize = weakSelf.initialParentView.frame.size;
            [weakSelf.mraidWebViewContainer setFrame:CGRectMake(0, 0, initialSize.width, initialSize.height)]; //animate??
            [weakSelf.initialParentView addSubview:weakSelf.mraidWebViewContainer];
            
            [self.overlayView setHidden:YES];
        }
        
        UIViewController* topMostViewController = [[UIApplication sharedApplication] topMostViewController];
        expandVC = [[KWKMraidExpandViewController alloc] init];
        expandVC.useCustomClose = weakSelf.expandProperties.useCustomClose;
        [expandVC setCloseBlock:^{
            [weakSelf resetFromExpand:false];
        }];
        expandVC.orientationProperties = _orientationProperties;
        
        [topMostViewController presentViewController:expandVC animated:YES completion:^{
            [weakSelf updateMRAIDProperties]; //need to update viewable again!
        }];
        
        KWKClosableView* expandedVCView = self.mraidWebViewContainer;
    
        if ([url length] > 0) //todo check valid??
        {
            expandedVCView = [[KWKClosableView alloc] init];
            expandedVCView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            
            
            UIWebView *newWebView = [[UIWebView alloc] init];
            newWebView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
            NSURLRequest* loadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [newWebView loadRequest:loadRequest];
            [expandedVCView addSubview:newWebView];
        }
        
        [expandVC.view addSubview:expandedVCView];
        [expandedVCView setFrame:CGRectMake(0,0,expandVC.view.frame.size.width,expandVC.view.frame.size.height)];
        [expandedVCView setShouldDisplayCloseBtn:YES];
        
        [[weakSelf nativebridge] sendNativaCallComplete:KWK_MRAID_COMMAND_NAME_EXPAND];
        weakSelf.mraidState = MRAID_STATE_EXPANDED;
        [weakSelf updateMRAIDProperties];
    });
    
    [self reportAction:KWK_MRAID_COMMAND_NAME_EXPAND];
}

- (void) mraidClose
{
    [self close:YES];
}

- (void) mraidOpen:(NSString*) urlString
{
    if ([_mraidDelegate getOpenUrlDestination] == KWK_URL_OPEN_DESTINATION_UIWEBVIEV)
    {
        __weak __typeof__(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^
        {
            UIViewController* topMostViewController = [[UIApplication sharedApplication] topMostViewController];
           KWKWebViewController* openVC = [[KWKWebViewController alloc] init];
           openVC.urlToLoad = urlString;
           
           [topMostViewController presentViewController:openVC animated:YES completion:^{
               [weakSelf.nativebridge sendNativaCallComplete:KWK_MRAID_COMMAND_NAME_OPEN];
           }];
        });
    }
    else //assume safari for now
    {
        NSURL* url = [NSURL URLWithString:urlString];
        if ([[UIApplication sharedApplication] canOpenURL:url])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }
        else
        {
            //fire error
            [self.nativebridge fireErrorEventForAction:KWK_MRAID_COMMAND_NAME_OPEN withMessage:[NSString stringWithFormat:@"Application cannot open url: %@", urlString]];
        }
        
        //send call complete(even if error is sent, call complete must be marked so next one can execute
        [self.nativebridge sendNativaCallComplete:KWK_MRAID_COMMAND_NAME_OPEN];
    }
    
    //[self reportAction:KWK_MRAID_COMMAND_NAME_OPEN];
}

- (void) storePicture:(NSString*) urlString;
{
    NSURL *imgUrl = [NSURL URLWithString:urlString];
    if (![[UIApplication sharedApplication] canOpenURL:imgUrl])
    {
        [self.nativebridge fireErrorEventForAction:KWK_MRAID_COMMAND_STORE_PICTURE withMessage:@"invalid url"];
        [self.nativebridge sendNativaCallComplete:KWK_MRAID_COMMAND_STORE_PICTURE];
        [self reportAction:KWK_MRAID_COMMAND_STORE_PICTURE];
        return;
    }
    
    __weak __typeof__(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:imgUrl]
                                             returningResponse:&response
                                                         error:&error];
        
        if (!error)
        {
            UIImage* img = [UIImage imageWithData:data];
            if (data && img)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                     UIImageWriteToSavedPhotosAlbum(img, weakSelf, @selector(image:didFinishSavingWithError:contextInfo:), nil); //fireerror/nativecallcomplete will be called in didfinishsaving
                });
            }
            else
            {
                [self.nativebridge fireErrorEventForAction:KWK_MRAID_COMMAND_STORE_PICTURE withMessage:[NSString stringWithFormat:@"Error downloading image from %@  Invalid data.",imgUrl.absoluteString]];
                [self.nativebridge sendNativaCallComplete:KWK_MRAID_COMMAND_STORE_PICTURE];
            }
        }
        else
        {
            [self.nativebridge fireErrorEventForAction:KWK_MRAID_COMMAND_STORE_PICTURE withMessage:[NSString stringWithFormat:@"Error downloading image from %@ Message: %@",imgUrl.absoluteString, [error description]]];
            [self.nativebridge sendNativaCallComplete:KWK_MRAID_COMMAND_STORE_PICTURE];
        }
    });
    
    [self reportAction:KWK_MRAID_COMMAND_STORE_PICTURE];
}

- (void) playVideo:(NSString*) urlString
{
    NSURL *videoURL = [NSURL URLWithString:urlString];
    if (![[UIApplication sharedApplication] canOpenURL:videoURL])
    {
        [self.nativebridge fireErrorEventForAction:KWK_MRAID_COMMAND_PLAY_VIDEO withMessage:@"invalid url"];
        [self.nativebridge sendNativaCallComplete:KWK_MRAID_COMMAND_PLAY_VIDEO];
        [self reportAction:KWK_MRAID_COMMAND_PLAY_VIDEO];
        return;
    }
    
    AVPlayerViewController *avpVC = [[AVPlayerViewController alloc] init];
    AVPlayer *avPlayer = [AVPlayer playerWithURL: videoURL];
    avpVC.player = avPlayer;
    
   
    __weak __typeof__(self) weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^
    {
         UIViewController* topMostViewController = [[UIApplication sharedApplication] topMostViewController];
        [topMostViewController presentViewController:avpVC animated:YES completion:^
        {
            [weakself.nativebridge sendNativaCallComplete:KWK_MRAID_COMMAND_PLAY_VIDEO];
            [avPlayer play];
        }];
    });
    
    [self reportAction:KWK_MRAID_COMMAND_PLAY_VIDEO];
}

- (void) createCalendarEvent:(NSDictionary*) eventInfo
{
    __weak __typeof__(self) weakSelf = self;
    
    //create event
    EKEventStore *store = [EKEventStore new];
    if ([store respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            
            if (granted)
            {
                EKEvent *event = [EKEvent eventWithEventStore:store];
                event.calendar = [store defaultCalendarForNewEvents];
                [event updateWithInfo:eventInfo];
                
                
                dispatch_async(dispatch_get_main_queue(), ^
                   {
                       if (weakSelf)
                       {
                           //create controller
                           EKEventEditViewController *eventViewController = [[EKEventEditViewController alloc] init];
                           eventViewController.event = event;
                           eventViewController.editViewDelegate = weakSelf;
                           eventViewController.eventStore = store;
                           
                           //present controller
                           UIViewController* topMostViewController = [[UIApplication sharedApplication] topMostViewController];
                           [topMostViewController presentViewController:eventViewController animated:YES completion:^{
                               [weakSelf.nativebridge sendNativaCallComplete:KWK_MRAID_COMMAND_CREATE_CALENDAR_EVENT];
                           }];
                       }
                   });
            }
            else
            {
                KWKLog(@"Calendar access not granted");
            }
        }];
    }
    else
    {
        [self.nativebridge fireErrorEventForAction:KWK_MRAID_COMMAND_CREATE_CALENDAR_EVENT withMessage:@"Cannot create calendar event"];
        [self.nativebridge sendNativaCallComplete:KWK_MRAID_COMMAND_CREATE_CALENDAR_EVENT];
    }
    
}

#pragma mark -

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error)
    {
        [self.nativebridge fireErrorEventForAction:KWK_MRAID_COMMAND_STORE_PICTURE withMessage:[error description]];
    }
    [self.nativebridge sendNativaCallComplete:KWK_MRAID_COMMAND_STORE_PICTURE];
}

- (void) close:(BOOL) fromMraidCommand
{
    BOOL closeDone = YES;
    switch (self.mraidState)
    {
        case MRAID_STATE_RESIZED:
            [self resetFromResize:fromMraidCommand];
            break;
        case MRAID_STATE_EXPANDED:
            [self resetFromExpand:fromMraidCommand];
            break;
        case MRAID_STATE_DEFAULT:
            [self closeFromDefaultState:fromMraidCommand];
            break;
            
        default:
            closeDone = NO;
            break;
    }
    
    if (closeDone && fromMraidCommand)
    {
        [self reportAction:KWK_MRAID_COMMAND_NAME_CLOSE];
    }
}

- (void) resetFromExpand: (BOOL) fromMraidCommand
{
    if (self.mraidState != MRAID_STATE_EXPANDED)
    {
        KWKNativeLog(@"%s cannot execute. mraid state is %@", __FUNCTION__ , GetMraidStateAsString(self.mraidState));
        [self.nativebridge fireErrorEventForAction:KWK_MRAID_COMMAND_NAME_CLOSE withMessage:@"Ad is not expanded"];
        return;
    }
    
    if (expandVC)
    {
        __weak __typeof__(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [expandVC dismissViewControllerAnimated:YES completion:^
            {
                [weakSelf.initialParentView addSubview: weakSelf.mraidWebViewContainer];
                [weakSelf.mraidWebViewContainer setFrame:CGRectMake(0, 0, weakSelf.initialParentView.frame.size.width, weakSelf.initialParentView.frame.size.height)];
                
                if ([weakSelf placementType] == MRAID_PLACEMENT_TYPE_INLINE)
                {
                    [weakSelf.mraidWebViewContainer setShouldDisplayCloseBtn:NO];
                }
                else
                {
                    [weakSelf.mraidWebViewContainer setShouldDisplayCloseBtn:YES];
                }
                
                
                if (fromMraidCommand)
                {
                    [weakSelf.nativebridge sendNativaCallComplete:KWK_MRAID_COMMAND_NAME_CLOSE];
                }
                weakSelf.mraidState = MRAID_STATE_DEFAULT;
                [weakSelf updateMRAIDProperties];
            }];
            expandVC = nil;
        });
    }
}

- (void) destroyAd //thsi is called when destroying ad(for now, only when overlaycountdown reaches 0
{
    self.mraidState = MRAID_STATE_HIDDEN;
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self.mraidDelegate adDidClose];
                   });
}

- (void) resetFromResize:(BOOL) fromMraidCommand
{
    if (self.mraidState != MRAID_STATE_RESIZED)
    {
        KWKNativeLog(@"%s cannot execute. mraid state is %@", __FUNCTION__ , GetMraidStateAsString(self.mraidState));
        [self.nativebridge fireErrorEventForAction:KWK_MRAID_COMMAND_NAME_CLOSE withMessage:@"Ad is not resized"];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        CGSize initialSize = self.initialParentView.frame.size;
        BOOL shouldDisplayCloseBtn = [self placementType] == MRAID_PLACEMENT_TYPE_OVERLAY;
        
        [self.mraidWebViewContainer setFrame:CGRectMake(0, 0, initialSize.width, initialSize.height)]; //animate??
        [self.initialParentView addSubview:self.mraidWebViewContainer];
        [self.mraidWebViewContainer setShouldDisplayCloseBtn:shouldDisplayCloseBtn];
        
        self.mraidState = MRAID_STATE_DEFAULT;
        [self updateMRAIDProperties];
        
        [self.overlayView setHidden:YES];
        if (fromMraidCommand)
        {
            [self.nativebridge sendNativaCallComplete:KWK_MRAID_COMMAND_NAME_CLOSE];
        }
    });
}

- (void) closeFromDefaultState: (BOOL) fromMraidCommand
{
    if (self.mraidState != MRAID_STATE_DEFAULT)
    {
        return;
    }
    
    //send native call complete now. sending it from main thread might be too late
    if (fromMraidCommand)
    {
        [self.nativebridge sendNativaCallComplete:KWK_MRAID_COMMAND_NAME_CLOSE];
    }
    self.mraidState = MRAID_STATE_HIDDEN;
    
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self.mraidDelegate adDidClose];
                   });
}


- (void) reportAction: (NSString*) action
{
    NSDictionary *trackingDict = [self.mraidDelegate getTrackingParams];
    if (IsValidJSONObject(trackingDict))
    {
        NSString *trackingURLString = [trackingDict objectForKey:action];
        if (IsValidJSONObject(trackingURLString))
        {
            NSURL *trackingURL = [NSURL URLWithString:trackingURLString];
            NSURLRequest *trackingURLRequest = [NSURLRequest requestWithURL:trackingURL];
            
            [KWKRestService queueGETRequest:trackingURLRequest completion:nil];
        }
    }
}


@end
