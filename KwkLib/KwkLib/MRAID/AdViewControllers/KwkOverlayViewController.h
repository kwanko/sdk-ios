//
//  KwkOverlayViewController.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 14/02/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KWKAdData.h"
#import "KWKAdBaseView.h"
#import "KWKOverlayAdRequest.h"

@protocol KWKOverlayViewControllerProtocol <NSObject>

- (UIViewController*) rootViewController;

- (void) didCloseOverlayViewController;

@end

@interface KwkOverlayViewController : UIViewController 

@property (nonatomic, retain) KWKOverlayAdRequest* adRequest;
@property (nonatomic, retain) KWKAdData* adData;
@property (nonatomic, retain) KWKAdBaseView* adView;

@property (nonatomic, weak) id<KWKOverlayViewControllerProtocol> delegate;

@end
