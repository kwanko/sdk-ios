//
//  KWKMraidAdView+Private.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 18/04/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKMraidAdView.h"
#import "KWKMraidHelper.h"

@interface KWKMraidAdView() <KWKMraidHelperDelegate>
{
    KWKMraidHelper * _mraidHelper;
}

- (KWKMraidHelper*) mraidHelper;

@end
