//
//  KWKOverlayAdRequest.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 13/04/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKAdRequest.h"

#pragma mark KWKAdPosition -
typedef enum
{
    KWK_AD_POSITION_CENTERED = 0,
    KWK_AD_POSITION_TOP,
    KWK_AD_POSITION_BOTTOM
}KWKAdPosition;

extern NSString* const kKWKAdPositionUnknown;
extern NSString* const kKWKAdPositionTop;
extern NSString* const kKWKAdPositionBottom;

NSString* StringFromAdPosition(KWKAdPosition pos);


#pragma mark KWKOverlayAdRequest -
@interface KWKOverlayAdRequest : KWKAdRequest

@property (nonatomic, readwrite) KWKADSizeStrategy sizeStrategy; //defaults to pixels
@property (nonatomic, readwrite) CGSize size;
@property (nonatomic, readwrite) KWKAdPosition adPosition; //defaults to center

@end
