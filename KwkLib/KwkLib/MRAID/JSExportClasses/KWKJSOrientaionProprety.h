//
//  KWKJSOrientaionProprety.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 24/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <UIKit/UIKit.h>

//orientationProperties object = {
//    "allowOrientationChange" : boolean,
//    "forceOrientation" : "portrait|landscape|none"
//}

@protocol KWKJSOrientaionPropretyJSExport <JSExport>

@required

@property (nonatomic, readwrite) BOOL allowOrientationChange;
@property (nonatomic, strong) NSString* forceOrientationString;

@end

@interface KWKJSOrientaionProprety : NSObject <KWKJSOrientaionPropretyJSExport>

@property (nonatomic, readwrite) BOOL allowOrientationChange;
@property (nonatomic, strong) NSString* forceOrientationString;

- (UIInterfaceOrientationMask) forcedInterfaceOrientationMask;

@end
