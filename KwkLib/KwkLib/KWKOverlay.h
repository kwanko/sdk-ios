//
//  KWKOverlay.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 09/05/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KWKOverlayAdRequest.h"

@class KWKOverlay;

@protocol KWKOverlayDelegate <NSObject>

#pragma mark -
@required
- (UIViewController*) rootViewController;

#pragma mark - Ad events
@optional

- (void) didLoadOverlay:(KWKOverlay*) overlay;
- (void) didFailToLoadOverlay:(KWKOverlay*) overlay error:(NSError*) error;
- (void) didDisplayOverlay:(KWKOverlay*) overlay;
- (void) didFailToDisplayOverlay:(KWKOverlay*) overlay;

- (void) didCloseKwankoOverlay;



@end

@interface KWKOverlay : NSObject
@property (nonatomic, weak) id<KWKOverlayDelegate> delegate;

- (void) loadRequest:(KWKOverlayAdRequest*) request;


@end
