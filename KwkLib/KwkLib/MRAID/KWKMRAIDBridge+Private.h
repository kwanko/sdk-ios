//
//  KWKMRAIDBridge+Private.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 24/04/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

@interface KWKMRAIDBridge()

- (JSValue*) getBridgeJSObject;
- (JSValue *) callJSBridgeFunction:(NSString*) funcName withArguments: (NSArray*) args;

@end
