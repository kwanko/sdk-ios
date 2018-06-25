//
//  KWKJSExpandProperty.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 17/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKJSExpandProperty.h"

#define KWK_JS_EXPAND_PROPRETY_IS_MODAL_DEFAULT_VALUE YES

@implementation KWKJSExpandProperty

- (instancetype) init
{
    if (self = [super init])
    {
        self.width = 0;
        self.height = 0;
        self.isModal = YES;
        self.useCustomClose = KWK_JS_EXPAND_PROPRETY_IS_MODAL_DEFAULT_VALUE;
        
        return self;
    }

    
    return nil;
}

- (instancetype) initWithSize:(CGSize) size andUseCustomClose:(BOOL) useCustomClose
{
    if (self = [super init])
    {
        self.width = size.width;
        self.height = size.height;
        self.useCustomClose = useCustomClose;
        self.isModal = KWK_JS_EXPAND_PROPRETY_IS_MODAL_DEFAULT_VALUE;
        
        return self;
    }
    
    return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"w:%i h:%i useCustomClose:%s isModal:%s", self.width, self.height, self.useCustomClose ? "YES" : "NO", self.isModal ? "YES" : "NO"];
}

@end
