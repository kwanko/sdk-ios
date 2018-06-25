//
//  KWKGlobals.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 03/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKGlobals.h"


@implementation UIView (KWKUIView)

- (UIWindow *)getWindow
{
    UIView* container = self;
    do
    {
        container = container.superview;
        if ([container isKindOfClass:[UIWindow class]])
        {
            return (UIWindow*)container;
        }
    }
    while (container != nil);
    
    return nil;
}

- (BOOL)isViewableToUser
{
    BOOL isViewable = !self.isHidden;
    if (isViewable)
    {
        UIWindow* win = [self getWindow];
        if (win == nil)
        {
            isViewable = NO;
        }
        else
        {
            CGRect frameInWindow = [self.superview convertRect:self.frame toView:win];
            if (!CGRectIntersectsRect(frameInWindow,win.frame))
            {
                isViewable = NO;
            }
        }
    }
    
    //TODO check if other views overlap the ad view
    return isViewable;
}

- (void)removeSubvies
{
    for (UIView* v in self.subviews)
    {
        [v removeFromSuperview];
    }
}

@end

@implementation UIApplication (KWKUiApplication)

- (NSString*) appDisplayName
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [infoDictionary objectForKey:(__bridge NSString *)kCFBundleNameKey];
    
    return appName;
}

- (UIViewController *)topMostViewController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

@end

@implementation NSData(KWKNSData)

+(NSData*) requestDataFromParamsDictionary:(NSDictionary*) paramsDictionary
{
    
    NSMutableString* paramsString = [[NSMutableString alloc] init];
    for (NSString* key in [paramsDictionary allKeys])
    {
        [paramsString appendFormat:@"%@=%@&",key, [paramsDictionary objectForKey:key]];
    }
    if ([paramsString length] > 0)//remove last & char
        paramsString = [[paramsString substringToIndex:[paramsString length] - 1] mutableCopy];

    NSData* data = [paramsString dataUsingEncoding:NSASCIIStringEncoding];
    return data;

//TODO uncomment this after server is done with processing sdkinfos and userinfos    
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:paramsDictionary
//                                                       options:0
//                                                         error:&error];
//    
//    if (error)
//    {
//        KWKLog(@"%s: Could not convert request params to json.", __PRETTY_FUNCTION__);
//        return nil;
//    }
//    
//    return jsonData;
}

@end

@implementation UIWebView(KWKUIwebView)

+ (NSString *)userAgent
{
    static dispatch_once_t once;
    static NSString* ua = nil;
    
    dispatch_once(&once, ^{
        UIWebView* wbView = [[UIWebView alloc] init];
        ua = [wbView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    });
    
    return ua;
}

@end


NSString* StringFromOrientatoin(UIInterfaceOrientation orient)
{
    switch (orient)
    {
        case UIInterfaceOrientationPortrait:
            return @"Portrait";
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            return @"Protrait Upside Donw";
            break;
        case UIInterfaceOrientationLandscapeLeft:
            return @"Landscape Left";
            break;
        case UIInterfaceOrientationLandscapeRight:
            return @"Landscape Right";
            break;
            
        default:
            break;
    }
    
    return @"Unknown";
}


