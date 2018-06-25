//
//  KWKMraidHelper.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 27/12/16.
//  Copyright © 2016 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>
#import "KWKMraid.h"
#import "KWKMRAIDBridge.h"
#import "KWKClosableView.h"
#import "KWKAdData.h"

@protocol KWKMraidHelperDelegate <NSObject>

- (MraidPlacementType) getPlacementType;
- (KWKMraidOpenURLDestination) getOpenUrlDestination;
- (NSDictionary*) getTrackingParams;
- (NSString*) getCloseBtnURL;
- (float) getCloseBtnPadding;
- (CGSize) getCloseBtnSize;

- (void) adDidClose; //called when the ad itself closes( state is default -> state moves to hidden)


@end

@interface KWKMraidHelper : NSObject
{
}

@property (nonatomic, weak) id<KWKMraidHelperDelegate> mraidDelegate;
@property (nonatomic, weak) UIView* initialParentView;

@property (nonatomic, readonly) MraidState mraidState;



- (void) loadAdHtml:(NSString*) htmlString;
- (void) destroyAd;

@end
