//
//  KWKBannerView.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 13/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KWKBannerAdRequest.h"

@protocol KWKBannerViewDelegate <NSObject>

#pragma mark -
@required
- (UIViewController*) rootViewController;

#pragma mark - Ad events
//TODO
@end

@interface KWKBannerView : UIView
@property (nonatomic, weak) id<KWKBannerViewDelegate> delegate;

- (void) loadAdForRequest:(KWKBannerAdRequest*) adRequest;

@end
