//
//  KWKJSResizeProperty.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 25/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKJSResizeProperty.h"
#import <UIKit/UIKit.h>

@implementation KWKJSResizeProperty

- (instancetype) initWithRect:(CGRect) rect andClosePosition:(NSString*) closePosition;
{
    if (self = [super init])
    {
        self.offsetX = rect.origin.x;
        self.offsetY = rect.origin.y;
        self.width = rect.size.width;
        self.height = rect.size.height;
        self.customClosePosition = closePosition;
        
        return self;
    }
    return nil;
}

- (CGRect)toRect
{
    return CGRectMake(self.offsetX, self.offsetY, self.width, self.height);
}

- (NSString *)description
{
    return NSStringFromCGRect(CGRectMake(self.offsetX, self.offsetY, self.width, self.height));
}

@end

