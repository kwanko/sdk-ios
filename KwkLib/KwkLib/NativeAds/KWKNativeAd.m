//
//  KWKNativeAd.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 31/03/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKNativeAd.h"
#import <UIKit/UIKit.h>

#import "KWKUtils.h"
#import "KWKAdProvider.h"
#import "KWKNativeAdData.h"
#import "KWKRestService.h"
#import "KWKWebViewController.h"
#import "KWKNativeAdRequest+Private.h"


#define JSON_KEY_TITLE_TEXT @"titleText"
#define JSON_KEY_MAIN_TEXT @"mainText"
#define JSON_KEY_MAIN_IMAGE @"mainImage"
#define JSON_KEY_PRIVACY_INFO @"privacyInfo"

@interface KWKNativeAd()
@property (nonatomic, readwrite) BOOL isLoadingAd;
@property (nonatomic, strong)    KWKNativeAdData* adData;
@property (nonatomic, strong)    UITapGestureRecognizer* tapGR;


@end

@implementation KWKNativeAd

- (void) setupTapGR
{
    if (self.tapGR == nil)
    {
        self.tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openURL)];
    }
    if (self.adDelegate)
    {
        UIView* container = [self.adDelegate adContainerView];
        if (![container.gestureRecognizers containsObject:self.tapGR])
        {
            [container addGestureRecognizer:self.tapGR];
        }
    }
}

- (void) populateAdFields
{
    __weak __typeof__(self) weakSelf = self;
    if (self.adData.titleText && [self.adDelegate respondsToSelector:@selector(titleLabel)])
    {
    
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf)
            {
                UILabel* titleLabel = [weakSelf.adDelegate titleLabel];
                titleLabel.text = weakSelf.adData.titleText;
            }
        });
    }
    
    if (self.adData.mainText && [self.adDelegate respondsToSelector:@selector(mainTextLabel)])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf)
            {
                UILabel* mainTextLabel = [weakSelf.adDelegate mainTextLabel];
                mainTextLabel.text = weakSelf.adData.mainText
                ;
            }
        });
    }
    
    if (self.adData.mainImageURL && [self.adDelegate respondsToSelector:@selector(mainImageView)])
    {
        __weak UIImageView* imageView = [self.adDelegate mainImageView];
        [self loadImageForUrl:self.adData.mainImageURL inView:imageView];
    }
    
    if (self.adData.privacyInfoIconURL && [self.adDelegate respondsToSelector:@selector(privacyInfoImageView)])
    {
        __weak UIImageView* imageView = [self.adDelegate privacyInfoImageView];
        [self loadImageForUrl:self.adData.privacyInfoIconURL inView:imageView];
    }
}

-(void) openURL
{
    if ([self.adDelegate respondsToSelector:@selector(rootViewController)])
    {
        UIViewController* vc = [self.adDelegate rootViewController];
        
        KWKWebViewController *webViewController = [[KWKWebViewController alloc] init];
        webViewController.urlToLoad = [self.adData.clickURL absoluteString];
        
        [vc presentViewController:webViewController animated:YES completion:nil];
    }
    else //open safari
    {
        if ([[UIApplication sharedApplication] canOpenURL:self.adData.clickURL])
        {
            [[UIApplication sharedApplication] openURL:self.adData.clickURL];
        }
        else
        {
            KWKLog(@"%s url cannot be open. URL: %@",__PRETTY_FUNCTION__ , self.adData.clickURL);
        }
    }
        
}

- (void) loadAdForRequest:(KWKNativeAdRequest*) adRequest;
{
    if (self.isLoadingAd)
    {
        KWKLog(@"%s. Already loading ad", __PRETTY_FUNCTION__);
        return;
    }

    
    self.isLoadingAd = YES;
    
    KWKAdProvider* provider = [[KWKAdProvider alloc] init];
    __weak __typeof__(self) weakSelf = self;
    
    adRequest.nativeAdComponents = [self buildNativeCompsFroRequest];
    
    [provider loadNativeAdForRequestWithRequest:adRequest completion:^(KWKNativeAdData *adData, NSError *error)
    {
        if (error)
        {
            if ([weakSelf.adRequestDelegate respondsToSelector:@selector(nativeAdDidFail:error:)])
            {
                [weakSelf.adRequestDelegate nativeAdDidFail:weakSelf error:error];
            }
        }
        else
        {
            [weakSelf setupTapGR];
            weakSelf.isLoadingAd = NO;
            weakSelf.adData = adData;
            [weakSelf populateAdFields];
            
            if ([weakSelf.adRequestDelegate respondsToSelector:@selector(nativeAdDidLoad:)])
            {
                [weakSelf.adRequestDelegate nativeAdDidLoad:weakSelf];
            }
        }
        
    }];
}

- (NSArray*) buildNativeCompsFroRequest
{
    NSDictionary* selectorsDict = [NSDictionary dictionaryWithObjectsAndKeys:   JSON_KEY_TITLE_TEXT, NSStringFromSelector(@selector(titleLabel)),
                                   JSON_KEY_MAIN_TEXT, NSStringFromSelector(@selector(mainTextLabel)),
                                   JSON_KEY_MAIN_IMAGE, NSStringFromSelector(@selector(mainImageView)),
                                   JSON_KEY_PRIVACY_INFO, NSStringFromSelector(@selector(privacyInfoIconURL)),
                                   nil];
    
    NSMutableArray* requestComps = [[NSMutableArray alloc] init];
    for (NSString* key in [selectorsDict allKeys])
    {
        if ([self.adDelegate respondsToSelector:NSSelectorFromString(key)])
        {
            [requestComps addObject:[selectorsDict objectForKey:key]];
        }
    }
    
    return requestComps;
}

- (void) loadImageForUrl:(__weak NSURL*) url inView:(__weak UIImageView*) view
{
    //start loading image
    [KWKRestService queueImageLoadRequest:url completion:^(NSData * _Nullable data, NSError * _Nullable error)
     {
         if (!error && data)
         {
             if (error)
             {
                 KWKLog(@"Error loading image for URL: %@. Error: %@", url.absoluteString, error);
             }
             
             if (data)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     view.image = [UIImage imageWithData:data];
                 });
             }
         }
     }];
}

@end
