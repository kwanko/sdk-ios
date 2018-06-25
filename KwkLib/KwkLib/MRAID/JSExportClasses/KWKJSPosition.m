//
//  Position.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 12/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKJSPosition.h"

@implementation KWKJSPosition

- (instancetype) initWithRect:(CGRect) rect
{
    if (self = [super init])
    {
        _x = rect.origin.x;
        _y = rect.origin.y;
        _width = rect.size.width;
        _height = rect.size.height;
        
        return self;
    }
    return nil;
}

- (int) getX
{
    return _x;
}

- (void) setX: (int) x
{
    _x = x;
}

- (int) getY
{
    return _y;
}

- (void) setY: (int) Y
{
    _y = Y;
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
