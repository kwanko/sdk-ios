//
//  KWKNativeAdData.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 31/03/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KWKNativeAdData : NSObject

@property (nonatomic, strong) NSString* slotID;
@property (nonatomic, strong) NSString* titleText;
@property (nonatomic, strong) NSString* mainText;
@property (nonatomic, strong) NSURL* mainImageURL;
@property (nonatomic, strong) NSURL* privacyInfoIconURL;

@property (nonatomic, strong) NSURL* clickURL;

- (instancetype) initWithData:(NSData*) data;

@end
