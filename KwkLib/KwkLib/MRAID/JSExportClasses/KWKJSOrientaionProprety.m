//
//  KWKJSOrientaionProprety.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 24/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKJSOrientaionProprety.h"
#import "KWKMraid.h"

@implementation KWKJSOrientaionProprety

- (instancetype) init
{
    if (self = [super init])
    {
        self.allowOrientationChange = YES;
        self.forceOrientationString = kMraidExpandInterfaceOrientatonNone;
        
        return self;
    }
    
    return nil;
}

- (BOOL) canRotateTo:(UIInterfaceOrientation) interFaceOrientation
{
    switch (interFaceOrientation)
    {
        case UIInterfaceOrientationPortrait:
            return [self.forceOrientationString containsString:@"portrait"];
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return [self.forceOrientationString containsString:@"landscape"];
            break;
            
        default:
            break;
    }
    
    return false;
}

- (UIInterfaceOrientationMask) forcedInterfaceOrientationMask
{
    if ([[self forceOrientationString] isEqualToString:kMraidExpandInterfaceOrientatonPortrait])
    {
        return UIInterfaceOrientationMaskPortrait;
    }
    else if ([[self forceOrientationString] isEqualToString:kMraidExpandInterfaceOrientatonLandscape])
    {
        return UIInterfaceOrientationMaskLandscape;
    }
    
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
