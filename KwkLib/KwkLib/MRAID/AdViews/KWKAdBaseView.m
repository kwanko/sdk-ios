//
//  KWKAdBaseView
//  TestKwanko
//
//  Created by Bogdan CHITU on 27/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKAdBaseView.h"


@implementation KWKAdBaseView


- (instancetype) initWithFrame:(CGRect)frame andData:(KWKAdData*) _kwkAdData
{
    if (self = [self initWithFrame:frame])
    {
        self.adData = _kwkAdData;
        return self;
    }
    
    return nil;
}

- (void) destroyAd
{
    //[self removeFromSuperview];
}

@end
