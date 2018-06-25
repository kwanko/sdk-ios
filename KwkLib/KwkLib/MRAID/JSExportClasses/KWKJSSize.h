//
//  KWKJSSize.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 12/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol KWKSizeJSexport <JSExport>

@required

- (int) getWidth;
- (void) setWidth:(int) width;

- (int) getHeight;
- (void) setHeight: (int) height;

@end

@interface KWKJSSize: NSObject<KWKSizeJSexport>
{
    int _width;
    int _height;
}

- (int) getWidth;
- (void) setWidth:(int) width;

- (int) getHeight;
- (void) setHeight: (int) height;



- (instancetype) initWithSize: (CGSize) size;

@end
