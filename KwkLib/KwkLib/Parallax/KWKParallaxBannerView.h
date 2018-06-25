//
//  KWKParallaxBannerView.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 27/03/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KWKBannerView.h"
#import "KWKParallaxBannerAdRequest.h"

@interface KWKParallaxBannerView : UIView

/* please use this to set the parent before loading the ad. It will help server return a correct html for the scrollview's size.
 If the parent is not set, parallax will still work but content size might not be appropriate*/
- (void) setParentScrollView:(__weak UIScrollView*) parentScrollView;

- (void) loadAdForRequest:(KWKParallaxBannerAdRequest *)adRequest;

@end

