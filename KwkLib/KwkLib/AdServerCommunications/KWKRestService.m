//
//  KWKRestService.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 26/01/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKRestService.h"
#import "KWKGlobals.h"

#ifndef KWK_TRACKING_ONLY
#import "KwkLib.h"
#endif //!KWK_TRACKING_ONLY

#define KWK_RS_POST_METHOD_NAME         @"POST"
#define KWK_RS_PUT_METHOD_NAME          @"PUT"
#define KWK_RS_GET_METHOD_NAME          @"GET"
#define KWK_RS_DELETE_METHOD_NAME       @"DELETE"


@implementation KWKRestService

#ifndef KWK_TRACKING_ONLY
+ (void)queueAdRequest:(NSURLRequest *)request completion:(void(^)(NSData * _Nullable data, NSError * _Nullable error))block
{
    NSMutableURLRequest *URLRequest = [request mutableCopy];
    [URLRequest setValue:@"application/json" forHTTPHeaderField:@"x-kwanko-content-type"];
    [URLRequest setValue:[NSString stringWithFormat:@"ios-%@", [[KwkLib getInstance] version]] forHTTPHeaderField:@"x-kwanko-sdk-version"];
    
   
    [self queuePOSTRequest:URLRequest completion:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
     {
         if (error)
         {
             KWKLog(@"error loading url %@. \n%@", response.URL.absoluteString, [error description]);
             if (block)
             {
                 block(nil, error);
             }
         }
         else
         {
             NSString* responseDataAsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             KWKLog(@"Response data: %@", responseDataAsString);
             if (block)
             {
                 block([responseDataAsString dataUsingEncoding:NSUTF8StringEncoding], error);
             }
         }
    }];
}
#endif//!KWK_TRACKING_ONLY

+ (void) queueTrackinRequest:(NSURLRequest* _Nonnull) request
                  completion:(void(^_Nullable)(NSError * _Nullable error))block
{
    [self queueRequest:request completion:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        if(block)
        {
            block(error);
        }
    }];
}

+ (void) queueRequest:(NSURLRequest* _Nonnull) request
           completion:(void(^_Nullable)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))block
{
    NSMutableURLRequest *URLRequest = [request mutableCopy];
    [URLRequest setTimeoutInterval:HTTP_REQ_TIMEOUT];
    
    KWKLog(@"Requesting: %@ %@", URLRequest.URL, URLRequest.HTTPMethod);
    KWKLog(@"Headers: %@", [URLRequest allHTTPHeaderFields]);
    
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    NSURLSessionDataTask* task = [sharedSession dataTaskWithRequest:URLRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        KWKLog(@"Response for %@", [response.URL absoluteString]);
        KWKLog(@"%@", response);
        if (block)
        {
            block(data, response, error);
        }
    }];
    [task resume];
}

+ (void) queuePOSTRequest:(NSURLRequest *)request completion:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))block
{
    NSMutableURLRequest *mutableReq = [request mutableCopy];
    [mutableReq setHTTPMethod:KWK_RS_POST_METHOD_NAME];
    
    [self queueRequest:mutableReq completion:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (block)
        {
            block(data, response, error);
        }
    }];
}

+ (void) queueGETRequest:(NSURLRequest *)request completion:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))block
{
    NSMutableURLRequest *mutableReq = [request mutableCopy];
    [mutableReq setHTTPMethod:KWK_RS_GET_METHOD_NAME];
    
    [self queueRequest:mutableReq completion:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (block)
        {
            block(data, response, error);
        }
    }];
}

+ (void)queueImageLoadRequest:(NSURL * _Nonnull)imageURL completion:(void (^_Nullable)(NSData * _Nullable data, NSError * _Nullable error))block;
{
    NSURLRequest* imageRequest = [NSURLRequest requestWithURL:imageURL];
    
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    NSURLSessionDataTask* task = [sharedSession dataTaskWithRequest:imageRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                                  {
                                      if (block)
                                      {
                                          block(data,error);
                                      }
                                  }];
    [task resume];
}


@end
