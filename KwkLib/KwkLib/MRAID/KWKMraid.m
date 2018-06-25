//
//  KWKMraid.mm
//
//  Created by Bogdan CHITU on 09/12/16.
//  Copyright © 2016 Bogdan CHITU. All rights reserved.
//
#import "KWKMraid.h"

NSString* const kMraidStateDefault = @"default";
NSString* const kMraidStateLoading = @"loading";
NSString* const kMraidStateExpanded = @"expanded";
NSString* const kMraidStateResized = @"resized";
NSString* const kMraidStateHidden = @"hidden";

NSString* GetMraidStateAsString(MraidState state)
{
    static dispatch_once_t once;
    static NSArray* sMraidStateIDs = nil;
    dispatch_once(&once, ^{
        sMraidStateIDs = @[kMraidStateLoading,
                           kMraidStateDefault,
                           kMraidStateExpanded,
                           kMraidStateResized,
                           kMraidStateHidden];
    });
    
    return [sMraidStateIDs objectAtIndex: (int)state];
}

NSString* const kMraidFeatureSMS = @"sms";
NSString* const kMraidFeatureTEL = @"tel";
NSString* const kMraidFeatureCalendar = @"calendar";
NSString* const kMraidFeatureStorePicture = @"storePicture";
NSString* const kMraidFeatureInlineVideo = @"inlineVideo";

NSString* const kMRaidPlacementNameInline = @"inline";
NSString* const kMRaidPlacementNameInterstitial = @"interstitial";
NSString* const kMraidPlacementNameOverlay = @"overlay";
static NSArray* MRaidPlacementStringIDs;

NSString* GetIdentifierForPlacementType(MraidPlacementType placementType)
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        MRaidPlacementStringIDs = @[kMRaidPlacementNameInline, kMRaidPlacementNameInterstitial];
    });
    
    if ((int) placementType >= 0 && (int) placementType < [MRaidPlacementStringIDs count])
    {
        return MRaidPlacementStringIDs[(int) placementType];
    }
    
    return @"";
}


NSString* const kMraidExpandInterfaceOrientatonNone = @"none";
NSString* const kMraidExpandInterfaceOrientatonPortrait = @"portrait";
NSString* const kMraidExpandInterfaceOrientatonLandscape = @"landscape";
