//
//  KWKCalendarUtils.h
//  TestKwanko
//
//  Created by Bogdan CHITU on 19/04/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

//@interface KWKCalendarUtils : NSObject
//
//@end

@interface EKRecurrenceRule (KWK)

+(EKRecurrenceRule*) ruleFromInfo:(NSDictionary*) info;

@end


@interface EKEvent (KWK)

-(void) updateWithInfo:(NSDictionary*) info;

@end

@interface NSDate (KWK)

+ (instancetype) dateFromISO8601FormattedString:(NSString*) string;

@end
