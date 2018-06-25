//
//  KWKMraid.h
//
//  Created by Bogdan CHITU on 09/12/16.
//  Copyright © 2016 Bogdan CHITU. All rights reserved.
//
#import <Foundation/Foundation.h>

#ifndef KWKMRAID_H
#define KWKMRAID_H

typedef enum
{
    MRAID_STATE_LOADING = 0,
    MRAID_STATE_DEFAULT,
    MRAID_STATE_EXPANDED,
    MRAID_STATE_RESIZED,
    MRAID_STATE_HIDDEN
}MraidState;

typedef struct
{
    BOOL tel;
    BOOL sms;
    BOOL calendar;
    BOOL storePicture;
    BOOL inlineVideo;
}MraidSupportFeatures;


extern NSString* const kMraidStateDefault;
extern NSString* const kMraidStateLoading;
extern NSString* const kMraidStateExpanded;
extern NSString* const kMraidStateResized;
extern NSString* const kMraidStateHidden;

NSString* GetMraidStateAsString(MraidState state);

typedef enum
{
    MRAID_PLACEMENT_TYPE_UNKNOWN = -1,
    MRAID_PLACEMENT_TYPE_INLINE,
    MRAID_PLACEMENT_TYPE_INTERSTITIAL,
    MRAID_PLACEMENT_TYPE_OVERLAY
}
MraidPlacementType;

extern NSString* const kMRaidPlacementNameInline;
extern NSString* const kMRaidPlacementNameInterstitial;

NSString* GetIdentifierForPlacementType(MraidPlacementType placementType);

extern NSString* const kMraidFeatureSMS;
extern NSString* const kMraidFeatureTEL;
extern NSString* const kMraidFeatureCalendar;
extern NSString* const kMraidFeatureStorePicture;
extern NSString* const kMraidFeatureInlineVideo;

extern NSString* const kMraidExpandInterfaceOrientatonNone;
extern NSString* const kMraidExpandInterfaceOrientatonPortrait;
extern NSString* const kMraidExpandInterfaceOrientatonLandscape;

#endif //KWKMRAID_H
