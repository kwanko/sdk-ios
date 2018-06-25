//
//  KWKParallaxBannerView+Private.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 27/03/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKParallaxBannerView.h"
@interface KWKParallaxBannerView()

@property (nonatomic, weak)   UIScrollView* parentScrollView;

- (void) parentDidScrol;


@end
