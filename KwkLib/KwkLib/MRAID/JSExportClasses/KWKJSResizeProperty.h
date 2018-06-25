//
//  KWKJSResizeProperty.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 25/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol KWKJSResizePropertyJSExport <JSExport>

@required
@property (nonatomic, readwrite) int offsetX;
@property (nonatomic, readwrite) int offsetY;
@property (nonatomic, readwrite) int width;
@property (nonatomic, readwrite) int height;
@property (nonatomic, strong)    NSString* customClosePosition;

@end

@interface KWKJSResizeProperty : NSObject <KWKJSResizePropertyJSExport>

@property (nonatomic, readwrite) int offsetX;
@property (nonatomic, readwrite) int offsetY;
@property (nonatomic, readwrite) int width;
@property (nonatomic, readwrite) int height;
@property (nonatomic, strong)    NSString* customClosePosition;

- (CGRect) toRect;

- (instancetype) initWithRect:(CGRect) rect andClosePosition:(NSString*) closePosition;


@end
