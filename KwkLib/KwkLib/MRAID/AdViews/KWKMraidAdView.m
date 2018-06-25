//
//  KWKMraidAdView.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 27/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKMraidAdView.h"
#import "KWKMraidAdView+Private.h"
#import "KWKMraidHelper.h"
#import "KWKMraidHelper+Private.h"
#import "KwkLibDefines.h"


@implementation KWKMraidAdView

- (instancetype) initWithFrame:(CGRect)frame andData:(KWKAdData *)_kwkAdData
{
    if (self = [super initWithFrame:frame andData:_kwkAdData])
    {

        NSString* htmlString = _kwkAdData.html;
        [[self mraidHelper] loadAdHtml:htmlString];
        
        
        return self;
    }
    
    return nil;
}

- (KWKMraidHelper*) mraidHelper
{
    if (_mraidHelper == nil)
    {
        _mraidHelper = [[KWKMraidHelper alloc] init];
        _mraidHelper.initialParentView = self;
        [_mraidHelper setMraidDelegate:self];
    }
    return _mraidHelper;
}

- (void) dealloc
{
    _mraidHelper = nil;
}

#pragma mark KWKMraidHelperDelegate -

- (MraidPlacementType) getPlacementType
{
    KWKAdContainerType containerType = [[self adDelegate] containerType];
    switch (containerType)
    {
        case KWK_AD_CONTAINER_TYPE_INTERSTITIAL:
            return MRAID_PLACEMENT_TYPE_OVERLAY;//MRAID_PLACEMENT_TYPE_INTERSTITIAL;
            break;
        case KWK_AD_CONTAINER_TYPE_BANNER:
            return MRAID_PLACEMENT_TYPE_INLINE;
            break;
            
        default:
            break;
    }
    return MRAID_PLACEMENT_TYPE_INLINE;
}

- (KWKMraidOpenURLDestination) getOpenUrlDestination
{
    return self.adData.urlOpenDestination;
}

- (NSDictionary *) getTrackingParams
{
    return self.adData.mraidTrackingParams;
}

- (NSString*) getCloseBtnURL
{
    return [self.adData closeButtonSRC];
}

- (float) getCloseBtnPadding
{
    return [self.adData closeButtonPadding];
}

- (CGSize) getCloseBtnSize
{
    return  [self.adData closeButtonSize];
}

- (void) destroyAd
{
    [self.mraidHelper destroyAd];
}

- (void)adDidClose
{
    if (self.adDelegate && [self.adDelegate respondsToSelector:@selector(containerDidClose)])
    {
        [self.adDelegate containerDidClose];
    }
}

#pragma mark -


@end
