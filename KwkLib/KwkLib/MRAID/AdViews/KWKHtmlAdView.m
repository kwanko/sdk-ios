//
//  KWKHtmlAdView.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 24/02/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKHtmlAdView.h"
#import "KWKGlobals.h"
#import "KWKWebViewController.h"

@interface KWKHtmlAdView () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView* webView;

@end


@implementation KWKHtmlAdView

- (instancetype) initWithFrame:(CGRect)frame andData:(KWKAdData *)_kwkAdData
{
    if (self = [super initWithFrame:frame andData:_kwkAdData])
    {
        #pragma warning TODO remove scroll, set zoom, etc
        self.webView = [[UIWebView alloc] initWithFrame:frame];
        self.webView.autoresizingMask =  UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.webView];

        
        NSURL* testURL = [NSURL URLWithString:_kwkAdData.html];
        if ([[UIApplication sharedApplication] canOpenURL:testURL])
        {
            [self.webView loadRequest:[NSURLRequest requestWithURL:testURL]];
        }
        else
        {
            [self.webView loadHTMLString:_kwkAdData.html baseURL:nil];
        }
        
        return self;
    }
    
    return nil;
}

#pragma mark UIWebViewDelegate - 
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        if (self.adData.urlOpenDestination == KWK_URL_OPEN_DESTINATION_UIWEBVIEV)
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

@end
