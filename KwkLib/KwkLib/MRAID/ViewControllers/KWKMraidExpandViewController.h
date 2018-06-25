//
//  KWKMraidExpandViewController.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 13/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KWKMraid.h"
#import "KWKJSOrientaionProprety.h"

@interface KWKMraidExpandViewController : UIViewController
@property (nonatomic, strong) KWKJSOrientaionProprety *orientationProperties;
@property (nonatomic, readwrite) BOOL useCustomClose; //if set to false, close button is hidden. Html provides own displayable content for close region. Close region remains implemented

@property (nonatomic, strong) void (^closeBlock)(void);

@end
