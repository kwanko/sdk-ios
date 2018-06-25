//
//  KWKJSPosition.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 12/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol KWKPositionJSexport <JSExport>

@required

- (int) getX;
- (void) setX: (int) x;

- (int) getY;
- (void) setY: (int) y;

- (int) getWidth;
- (void) setWidth:(int) width;

- (int) getHeight;
- (void) setHeight: (int) height;




@end

@interface KWKJSPosition : NSObject<KWKPositionJSexport>
{
    int _x;
    int _y;
    int _width;
    int _height;
}

- (int) getX;
- (void) setX: (int) x;

- (int) getY;
- (void) setY: (int) y;

- (int) getWidth;
- (void) setWidth:(int) width;

- (int) getHeight;
- (void) setHeight: (int) height;

- (instancetype) initWithRect:(CGRect) rect;

@end
