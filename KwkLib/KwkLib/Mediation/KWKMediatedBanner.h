//
//  KWKMediatedBanner.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 09/05/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KWKAdData.h"
#import "KWKOverlayAdRequest.h"

@class KWKMediatedBanner;

@protocol KWKMediatedBannerProtocol <NSObject>

#pragma mark - 
@required
- (UIViewController*) rootViewController;

#pragma mark Ad Events
@optional
- (void) didLoadMediatedBanner:(KWKMediatedBanner*) banner;
- (void) didFailToLoadMediatedBanner:(KWKMediatedBanner*) banner error:(NSError*) error;
- (void) didDisplayMediatedBanner:(KWKMediatedBanner*) banner;
- (void) didFailToDisplayMediatedBanner:(KWKMediatedBanner*) banner;

@end

@interface KWKMediatedBanner : NSObject

@property (nonatomic, weak) id<KWKMediatedBannerProtocol> bannerDelegate;

@property (nonatomic, strong) KWKOverlayAdRequest* originalRequest;
@property (nonatomic, strong) KWKAdData* adData;

- (instancetype) initWithAdData:(KWKAdData*) data;
- (void) loadAdInView:(UIView*) container; //most likely the container will be a KWKBannerView

+(id) mediatedBannerFromData:(KWKAdData*) data; //note: can return nil if data.adType is not recognized

@end
