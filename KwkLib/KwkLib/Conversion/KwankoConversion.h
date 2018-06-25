//
//  KwankoConversion.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 20/02/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kKwankoConversionActionInstall;
extern NSString* const kKwankoConversionActionRegister;
extern NSString* const kKwankoConversionActionForm;

@interface KwankoConversion : NSObject

+(instancetype) getInstance;

/*
 *  Reports conversion to traking server
 *  @param trackingID - Mandatory -Is a unique ID to identify the "Tracking Object", it's like the slotUID
 *                       which is the unique Id of the adSlot.
 *                       Every tracking ID will be given to the developer (as SlotUID, it will be created on
 *                       our frontoffice).
 *  @param action - Optional - Will be install / register / form. See consts(kKwankoConversionAction..).
 *  @param email - Optional
 *  @param isRepeatable if set to NO, the tracking Object will call 1 time the adserver and will never call again
 */
- (void) reportConversionWithID:(NSString*) trackingID
                          Label:(NSString*) action
                  AlternativeID:(NSString*) email
                   isRepeatable:(BOOL) repeatable;


@end
