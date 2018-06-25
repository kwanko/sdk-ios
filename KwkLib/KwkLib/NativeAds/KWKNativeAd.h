//
//  KWKNativeAd.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 31/03/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KWKNativeAdRequest.h"

@class KWKNativeAd;

@protocol KWKNativeAdsProtocol <NSObject>

@required
- (UIView*) adContainerView;

@optional

- (UILabel*) titleLabel;
- (UILabel*) mainTextLabel;
- (UIImageView*) mainImageView;
- (UIImageView*) privacyInfoImageView;

- (UIViewController*) rootViewController;//used to present uiwebviewcontroller;

@end

@protocol NativeAdRequestProtocol <NSObject>

- (void) nativeAdDidFail:(KWKNativeAd*) ad error:(NSError*) error;
- (void) nativeAdDidLoad:(KWKNativeAd*) ad;

@end

@interface KWKNativeAd : NSObject

@property (nonatomic, weak) id<KWKNativeAdsProtocol> adDelegate;
@property (nonatomic, weak) id<NativeAdRequestProtocol> adRequestDelegate;

- (void) loadAdForRequest:(KWKNativeAdRequest*) adRequest;

@end
