//
//  KWKJSExpandProperty.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 17/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol KWKJSExpandPropertyJSExport <JSExport>

@required
@property (nonatomic, readwrite) int width;
@property (nonatomic, readwrite) int height;
@property (nonatomic, readwrite) BOOL useCustomClose;
@property (nonatomic, readwrite) BOOL isModal;

@end

@interface KWKJSExpandProperty : NSObject <KWKJSExpandPropertyJSExport>

@property (nonatomic, readwrite) int width;
@property (nonatomic, readwrite) int height;
@property (nonatomic, readwrite) BOOL useCustomClose;
@property (nonatomic, readwrite) BOOL isModal; //For mraid 2.0 it will always be YES. however, i think mraid 1.0 ad will set this to NO. TODO: tald to the client about this

- (instancetype) initWithSize:(CGSize) size andUseCustomClose:(BOOL) useCustomClose;


@end
