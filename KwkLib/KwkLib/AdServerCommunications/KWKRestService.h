//
//  KWKRestService.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 26/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>


#define HTTP_REQ_TIMEOUT 30

@interface KWKRestService : NSObject


+ (void) queueRequest:(NSURLRequest* _Nonnull) request
           completion:(void(^_Nullable)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))block;
+ (void) queuePOSTRequest:(NSURLRequest * _Nonnull)request completion:(void(^_Nullable)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))block;
+ (void) queueGETRequest:(NSURLRequest * _Nonnull)request completion:(void(^_Nullable)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))block;

+ (void)queueImageLoadRequest:(NSURL * _Nonnull)imageURL completion:(void (^_Nullable)(NSData * _Nullable data, NSError * _Nullable error))block;


+ (void) queueTrackinRequest:(NSURLRequest* _Nonnull) request
                  completion:(void(^_Nullable)(NSError * _Nullable error))block;
#ifndef KWK_TRACKING_ONLY
+ (void) queueAdRequest:(NSURLRequest * _Nonnull)request
             completion:(void(^_Nullable)(NSData * _Nullable data, NSError * _Nullable error))block;
#endif //!KWK_TRACKING_ONLY
@end
