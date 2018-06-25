//
//  KWKJSSize.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 12/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKJSSize.h"

@implementation KWKJSSize

- (instancetype) initWithSize: (CGSize) size
{
    if (self = [super init])
    {
        _width = size.width;
        _height = size.height;
        
        return self;
    }
    return nil;
}

- (void) setWidth: (int) width
{
    _width = width;
}

- (int) getWidth
{
    return _width;
}

- (void) setHeight: (int) height
{
    _height = height;
}

- (int) getHeight
{
    return _height;
}



@end
