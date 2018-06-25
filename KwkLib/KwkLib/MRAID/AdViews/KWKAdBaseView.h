//
//  KWKAdBaseView.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 27/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KWKAdData.h"
#import "KWKBannerAdRequest.h"

typedef enum
{
    KWK_AD_CONTAINER_TYPE_BANNER,
    KWK_AD_CONTAINER_TYPE_INTERSTITIAL
}KWKAdContainerType;

@protocol KWKAdBaseViewDelegate <NSObject>

@required
- (KWKAdContainerType) containerType;
- (void) containerDidClose;

@end

@interface KWKAdBaseView : UIView

@property (nonatomic, strong) KWKAdData* adData;
@property (nonatomic, weak) id<KWKAdBaseViewDelegate> adDelegate;

- (instancetype) initWithFrame:(CGRect)frame andData:(KWKAdData*) _kwkAdData;
- (void) destroyAd;


@end
