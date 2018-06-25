//
//  KWKCalendarUtils.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 19/04/2017.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKCalendarUtils.h"
#import "KWKUtils.h"
#import <EventKit/EventKit.h>

NSString* const kCalendarRepeatRuleFrequencyDaily = @"daily";
NSString* const kCalendarRepeatRuleFrequencyWeekly = @"weekly";
NSString* const kCalendarRepeatRuleFrequencyMonthly = @"monthly";
NSString* const kCalendarRepeatRuleFrequencyYearly = @"yearly";

#define KWK_RECURRENCE_KEY_FREQUENCY        @"frequency"
#define KWK_RECURRENCE_KEY_INTERVAL         @"interval"
#define KWK_RECURRENCE_KEY_DAYS_IN_WEEK     @"daysInWeek"
#define KWK_RECURRENCE_KEY_DAYS_IN_MONTH    @"daysInMonth"
#define KWK_RECURRENCE_KEY_DAYS_IN_YEAR     @"daysInYear"
#define KWK_RECURRENCE_KEY_MONTHS_IN_YEAR   @"monthsInYear"
#define KWK_RECURRENCE_KEY_WEEKS_IN_MONTH   @"weeksInMonth" //NOT USED
#define KWK_RECURRENCE_KEY_EXPIRES          @"expires"
#define KWK_RECURRENCE_KEY_EXCEPTION_DATES @"exceptionDates" //NOT USED




@implementation EKRecurrenceRule (KWK)

/*
 * Returns a reccurence rule if infos are valid.
 * Documentation used: https://dev.w3.org/2009/dap/calendar/#idl-def-CalendarRepeatRule
 * NOTE: weeksInMonth and exception dates not supported
 */
+ (EKRecurrenceRule*) ruleFromInfo:(NSDictionary *)info
{
    EKRecurrenceRule* recRule = nil;
    
    EKRecurrenceFrequency frequency;
    NSInteger interval = 1;
    NSArray<EKRecurrenceDayOfWeek *>* days;
    NSArray<NSNumber *>* monthDays;
    NSArray<NSNumber *>* monthsOfTheYear;
    NSArray<NSNumber *>* weeksOfTheYear;
    NSArray<NSNumber *>* daysOfTheYear;
    EKRecurrenceEnd* recurrenceEnd;
    
    //determine frequency. continue only if valid
    static dispatch_once_t once;
    static NSArray* frequencyArray;
    dispatch_once(&once, ^{
        frequencyArray = @[kCalendarRepeatRuleFrequencyDaily, kCalendarRepeatRuleFrequencyWeekly, kCalendarRepeatRuleFrequencyMonthly, kCalendarRepeatRuleFrequencyYearly];
    });
    
    NSString* frequencyAsString = [info objectForKey:KWK_RECURRENCE_KEY_FREQUENCY];
    NSUInteger locationOfString = [frequencyArray indexOfObject:frequencyAsString];
    if (locationOfString != NSNotFound)
    {
        //set freq
        frequency = (EKRecurrenceFrequency) locationOfString;
        
        //interval
        NSNumber *intervalNSNumber = [info objectForKey:KWK_RECURRENCE_KEY_INTERVAL];
        if (IsValidJSONObject(intervalNSNumber) && [intervalNSNumber integerValue] > 1) //Interval must be greater than 0 or recurrence rule init will fail
        {
            interval = [intervalNSNumber integerValue];
        }
        
        //try and get daysinweek
        if (IsValidJSONObject([info objectForKey:KWK_RECURRENCE_KEY_DAYS_IN_WEEK]))
        {
            NSArray* daysInWeekArray = [info objectForKey:KWK_RECURRENCE_KEY_DAYS_IN_WEEK];
            NSMutableArray<EKRecurrenceDayOfWeek*> * daysInWeekForDate = [[NSMutableArray alloc] init];
            for (NSNumber* dayNumber in daysInWeekArray)
            {
                int dayAsInt = [dayNumber intValue];
                dayAsInt = dayAsInt % 7; //W3 CalendarRepeatRule interface states it will be a nb from 0 to 6. does not hurt to enforce.
                ++dayAsInt;
                
                EKRecurrenceDayOfWeek* weekDay = [EKRecurrenceDayOfWeek dayOfWeek:(EKWeekday)dayAsInt];
                [daysInWeekForDate addObject:weekDay];
            }
            days = daysInWeekForDate;
        }
        
        //month days
        if (IsValidJSONObject([info objectForKey:KWK_RECURRENCE_KEY_DAYS_IN_MONTH]))
        {
            monthDays = [info objectForKey:KWK_RECURRENCE_KEY_DAYS_IN_MONTH];
        }
        
        
        //months of year
        if (IsValidJSONObject([info objectForKey:KWK_RECURRENCE_KEY_MONTHS_IN_YEAR]))
        {
            monthsOfTheYear = [info objectForKey:KWK_RECURRENCE_KEY_MONTHS_IN_YEAR];
        }
        
        //weeks of year
        KWK_RECURRENCE_KEY_WEEKS_IN_MONTH; //??
        
        //days of year
        if (IsValidJSONObject([info objectForKey:KWK_RECURRENCE_KEY_DAYS_IN_YEAR]))
        {
            daysOfTheYear = [info objectForKey:KWK_RECURRENCE_KEY_DAYS_IN_YEAR];
        }
        
        //expire date
        NSString* expireDateString = ObjectOrNilFromJSONObject([info objectForKey:KWK_RECURRENCE_KEY_EXPIRES]);
        if(expireDateString)
        {
            NSDate* expires = [NSDate dateFromISO8601FormattedString:expireDateString];
            if (expires)
            {
                recurrenceEnd = [EKRecurrenceEnd recurrenceEndWithEndDate:expires];
            }
        }
        
        recRule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:frequency
                                                               interval:interval
                                                          daysOfTheWeek:days
                                                         daysOfTheMonth:monthDays
                                                        monthsOfTheYear:monthsOfTheYear
                                                         weeksOfTheYear:weeksOfTheYear
                                                          daysOfTheYear:daysOfTheYear
                                                           setPositions:nil
                                                                    end:recurrenceEnd];
    }
    
    return recRule;
}

@end

#define KWK_CALENDAR_EVENT_KEY_DESCRIPTION      @"description"
#define KWK_CALENDAR_EVENT_KEY_LOCATION         @"location"
#define KWK_CALENDAR_EVENT_KEY_SUMMARY          @"summary"
#define KWK_CALENDAR_EVENT_KEY_START            @"start"
#define KWK_CALENDAR_EVENT_KEY_END              @"end"
#define KWK_CALENDAR_EVENT_KEY_REMINDER         @"reminder"
#define KWK_CALENDAR_EVENT_KEY_TRANSPARENCY     @"transparency"
#define KWK_CALENDAR_EVENT_KEY_RECURRENCE       @"recurrence"


NSString* const kKWKEventTransparencyTransparent = @"transparent";
NSString* const kKWKEventTransparencyOpaque = @"opaque";

@implementation EKEvent (KWK)

- (void)updateWithInfo:(NSDictionary *)info
{
    self.title = ObjectOrNilFromJSONObject([info objectForKey:KWK_CALENDAR_EVENT_KEY_DESCRIPTION]);
    self.location = ObjectOrNilFromJSONObject([info objectForKey:KWK_CALENDAR_EVENT_KEY_LOCATION]);
    self.notes = ObjectOrNilFromJSONObject([info objectForKey:KWK_CALENDAR_EVENT_KEY_SUMMARY]);
    
    NSString* startDateString = [info objectForKey:KWK_CALENDAR_EVENT_KEY_START];
    if (IsValidJSONObject(startDateString))
    {
        NSDate* startDate = [NSDate dateFromISO8601FormattedString:startDateString];
        self.startDate = startDate;
    }
    
    NSString* endDateString = [info objectForKey:KWK_CALENDAR_EVENT_KEY_END];
    if (IsValidJSONObject(endDateString))
    {
        NSDate* endDate = [NSDate dateFromISO8601FormattedString:endDateString];
        self.endDate = endDate;
    }
    
    NSString* reminderString = [info objectForKey:KWK_CALENDAR_EVENT_KEY_REMINDER];
    if (IsValidJSONObject(reminderString))
    {
        NSDate* alarmDate = [NSDate dateFromISO8601FormattedString:reminderString];
        if (alarmDate)
        {
            EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:alarmDate];
            [self addAlarm:alarm];
        }
        else //it;s an offset
        {
            NSTimeInterval offsetInterfal = [reminderString doubleValue];
            EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:offsetInterfal];
            [self addAlarm:alarm];
        }
    }
    
    //transparency - DK if this is ok!
    NSString* transparencyString = [info objectForKey:KWK_CALENDAR_EVENT_KEY_TRANSPARENCY];
    if (IsValidJSONObject(transparencyString))
    {
        //may be set to one of the following constants: 'transparent', 'opaque'.
        if ([transparencyString isEqualToString:kKWKEventTransparencyTransparent])
        {
            self.availability = EKEventAvailabilityFree;
        }
        else if ([transparencyString isEqualToString:kKWKEventTransparencyOpaque])
        {
            self.availability = EKEventAvailabilityBusy;
        }
    }
    
    //recurrence (see EKRecurrenceRule ruleWithInfo:
    NSDictionary* recurrenceDict = info;//[info objectForKey:KWK_CALENDAR_EVENT_KEY_RECURRENCE]; //all args are added into a big array in JS and sent like that.
    if (IsValidJSONObject(recurrenceDict))
    {
        EKRecurrenceRule* recRule = [EKRecurrenceRule ruleFromInfo:recurrenceDict];
        if (recRule)
        {
            [self addRecurrenceRule:recRule];
        }
    }
}

@end

@implementation NSDate (KWK)

+ (instancetype) dateFromISO8601FormattedString:(NSString*) string
{
    NSDate* returnDate = nil;
    NSArray* formats = @[@"yyyy-MM-dd'T'HH:mmssZZZZZ",
                         @"yyyy-MM-dd'T'HH:mmZZZZZ"];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    for (int i=0;i<[formats count] && !returnDate;++i)
    {
        [dateFormatter setDateFormat:formats[i]];
        returnDate = [dateFormatter dateFromString:string];
    }
    
    return returnDate;
}

@end
