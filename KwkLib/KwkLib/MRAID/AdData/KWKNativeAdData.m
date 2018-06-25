//
//  KWKNativeAdData.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 31/03/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

//#error  TODO remove ad data files from mraid folder on disc when merging to develop!

#import "KWKNativeAdData.h"
#import "KWKUtils.h"


#define KWK_NATIVE_AD_DATA_JSON_KEY_RET                         @"ret"
#define KWK_NATIVE_AD_DATA_JSON_KEY_SLOT_ID                     @"slotID"
#define KWK_NATIVE_AD_DATA_JSON_KEY_TITLE_TEXT                  @"titleText"
#define KWK_NATIVE_AD_DATA_JSON_KEY_MAIN_TEXT                   @"mainText"
#define KWK_NATIVE_AD_DATA_JSON_KEY_MAIN_IMG_URL                @"mainImage"
#define KWK_NATIVE_AD_DATA_JSON_KEY_PRIVACY_IMG_URL             @"privacyInfoIcon"
#define KWK_NATIVE_AD_DATA_JSON_KEY_CLICK_URL                   @"clickURL"




@implementation KWKNativeAdData

- (instancetype)initWithData:(NSData *)data
{
    if (self = [self init])
    {
        NSError *e = nil;
        NSDictionary* jsonContents = [NSJSONSerialization JSONObjectWithData:data options:0 error:&e];
        
        if (e)
        {
            KWKLog(@"%s Error parsing jsoncontents: %@", __FUNCTION__, [e description]);
            return nil;
        }
        
        id ret = [jsonContents objectForKey:KWK_NATIVE_AD_DATA_JSON_KEY_RET];
        if (IsValidJSONObject(ret))
        {
            self.slotID = [ret objectForKey:KWK_NATIVE_AD_DATA_JSON_KEY_SLOT_ID];
            self.titleText = [ret objectForKey:KWK_NATIVE_AD_DATA_JSON_KEY_TITLE_TEXT];
            self.mainText = [ret objectForKey:KWK_NATIVE_AD_DATA_JSON_KEY_MAIN_TEXT];
            self.mainImageURL = [NSURL URLWithString:[ret objectForKey:KWK_NATIVE_AD_DATA_JSON_KEY_MAIN_IMG_URL]];
            self.privacyInfoIconURL = [NSURL URLWithString:[ret objectForKey:KWK_NATIVE_AD_DATA_JSON_KEY_PRIVACY_IMG_URL]];
            self.clickURL = [NSURL URLWithString:[ret objectForKey:KWK_NATIVE_AD_DATA_JSON_KEY_CLICK_URL]];
        }
    }
    
    return self;
}

@end
