//
//  KwankoRemarketing.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 21/02/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const kKwankoRemarketingActionInstall;
extern NSString* const kKwankoRemarketingActionRegister;
extern NSString* const kKwankoRemarketingActionForm;

@interface KwankoRemarketing : NSObject

+(instancetype) getInstance;



/*
 *  Reports remarketing to traking server
 *  @param trackingID - Mandatory -Is a unique ID to identify the "Tracking Object", it's like the slotUID
 *                       which is the unique Id of the adSlot.
 *                       Every tracking ID will be given to the developer (as SlotUID, it will be created on
 *                       our frontoffice).
 *  @param action - Optional - Will be install / register / form. See consts(kKwankoConversionAction..).
 *  @param email - Optional
 *  @param isRepeatable if set to NO, the tracking Object will call 1 time the adserver and will never call again
 *  @param eventID - As we are talking about a sale action, the developer must give something unique , can be a transaction ID, customer ID in BDD etc.....  through EventId
 *  @param amount - Amount Without Tax of the transaction, without shipping through Amount
 *  @param currency - Currency ISO 4217   through Currency
 *  @param payname - will be filed by the dev through PaymentMethod
 */
 
- (void) reportRemarketingWithID:(NSString*) trackingID
                          Label:(NSString*) action
                        EventID:(NSString*) eventID
                         Amount:(float) amount
                       Currency:(NSString*) currency
                  PaymentMethod:(NSString*) payname
                  AlternativeID:(NSString*) email
               CustomParameters:(NSDictionary*) CustomParameters
                   isRepeatable:(BOOL) repeatable;

@end
