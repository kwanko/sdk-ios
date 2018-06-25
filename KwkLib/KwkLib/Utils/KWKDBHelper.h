//
//  KWKDBHelper.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 15/03/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KWKDbHelperResult)(NSArray* columnNames, NSArray* rows, NSError* error);

@interface KWKDBHelper : NSObject

- (BOOL) openDBAtPath:(NSString*) path;
- (BOOL) close;
- (void) executeStatement:(NSString*) statement completion:(KWKDbHelperResult) block;

+ (BOOL) createDBAtPath:(NSString*) path;

@end
