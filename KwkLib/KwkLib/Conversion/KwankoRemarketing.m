//
//  KwankoRemarketing.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 21/02/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KwankoRemarketing.h"
#import "KWKRestService.h"
#import "KWKUtils.h"
#import "KWKDBHelper.h"
#import "KwankoTrackingConstants.h"

#define KWK_REMARKETING_PARAM_MCLIC         @"mclic"
#define KWK_REMARKETING_PARAM_USERID        @"userId"
#define KWK_REMARKETING_PARAM_CIBLE         @"cible"
#define KWK_REMARKETING_PARAM_ARGANN        @"argann"
#define KWK_REMARKETING_PARAM_ARGMON        @"argmon"
#define KWK_REMARKETING_PARAM_NACUR         @"nacur"
#define KWK_REMARKETING_PARAM_ALT_ID        @"altid"
#define KWK_REMARKETING_PARAM_ARGMODP       @"argmodp"
#define KWK_REMARKETING_PARAM_ACTION        @"action"
#define KWK_REMARKETING_PARAM_MODE          @"mode"
#define KWK_REMARKETING_PARAM_CUSTOM_PARAMS @"customParams"
#define KWK_REMARKETING_PARAM_ISREP         @"isRepeatable"

#define KWK_REMARKETING_VALUE_MODE          @"inapp"

NSString* const kKwankoRemarketingActionInstall = @"install";
NSString* const kKwankoRemarketingActionRegister = @"register";
NSString* const kKwankoRemarketingActionForm = @"form";

@implementation KwankoRemarketing

+(instancetype) getInstance
{
    static dispatch_once_t once;
    
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}


#warning TODO - consts for params accepted in payname
- (void) reportRemarketingWithID:(NSString*) trackingID
                          Label:(NSString*) action
                        EventID:(NSString*) eventID
                         Amount:(float) amount
                       Currency:(NSString*) currency
                  PaymentMethod:(NSString*) payname
                  AlternativeID:(NSString*) email
               CustomParameters:(NSDictionary*) CustomParameters
                   isRepeatable:(BOOL) repeatable
{
    NSAssert(trackingID && eventID && amount > 0 && currency, @"Params cannot be nil/0");
    if (trackingID && eventID && amount > 0 && currency)
    {
        if (!repeatable)
        {
            NSString* dbPaht = [[KWKUtils getDocumentsDirPath] stringByAppendingPathComponent:KWK_TRACKING_DB_NAME];
            KWKDBHelper *dbHelper = [[KWKDBHelper alloc] init];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:dbPaht])
            {
                BOOL dbCreated = [KWKDBHelper createDBAtPath:dbPaht];
                if (dbCreated)
                {
                    BOOL dbOpen = [dbHelper openDBAtPath:dbPaht];
                    
                    if (dbOpen)
                    {
                        NSString* createTableStatement = [NSString stringWithFormat:@"CREATE TABLE %@(%@ varchar(255));", KWK_REMARKETING_TABLE_NAME, KWK_REMARKETING_TRACKING_ID_COL_NAME];
                        [dbHelper executeStatement:createTableStatement completion:^(NSArray *columnNames, NSArray *rows, NSError *error)
                         {
                             if (error)
                             {
                                 KWKLog(@"%s %@",__PRETTY_FUNCTION__, error);
                             }
                         }];
                        
                        [dbHelper close];
                    }
                }
            }
            
            BOOL dbOpen = [dbHelper openDBAtPath:dbPaht];
            if (dbOpen)
            {
                __block BOOL trackingIDReported = NO;
                NSString* selectStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'", KWK_REMARKETING_TABLE_NAME , KWK_REMARKETING_TRACKING_ID_COL_NAME, trackingID];
                [dbHelper executeStatement:selectStatement completion:^(NSArray *columnNames, NSArray *rows, NSError *error) {
                    if (error)
                    {
                        KWKLog(@"Error performing select: %@",error);
                    }
                    else
                    {
                        if (rows.count > 0)
                        {
                            trackingIDReported = YES;
                        }
                    }
                }];
                
                if (trackingIDReported)
                {
                    KWKLog(@"Remarketing for %@ already reported as nonrepeatable", trackingID);
                    return;
                }
                
                
                
                NSString* insertStatement = [NSString stringWithFormat:@"INSERT INTO %@ (%@) \
                                             VALUES ('%@');", KWK_REMARKETING_TABLE_NAME , KWK_REMARKETING_TRACKING_ID_COL_NAME, trackingID];
                [dbHelper executeStatement:insertStatement completion:^(NSArray *columnNames, NSArray *rows, NSError *error) {
                    if (error)
                    {
                        KWKLog(@"Error performing insert: %@",error);
                    }
                }];
                
                [dbHelper close];
            }
        }
        
        NSURL* url = [NSURL URLWithString:KWK_REMARKETING_SERVER_URL];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:trackingID forKey:KWK_REMARKETING_PARAM_MCLIC];
        if (action)
        {
            [params setValue:action forKey:KWK_REMARKETING_PARAM_ACTION];
        }
        if (email)
        {
            [params setValue:email forKey:KWK_REMARKETING_PARAM_ALT_ID];
        }
        if(eventID)
        {
            [params setValue:eventID forKey:KWK_REMARKETING_PARAM_ARGANN];
        }
        [params setValue:eventID forKey:KWK_REMARKETING_PARAM_ARGANN];
        [params setValue:currency forKey:KWK_REMARKETING_PARAM_NACUR];
        [params setValue:[NSString stringWithFormat:@"%.2f", amount] forKey:KWK_REMARKETING_PARAM_ARGMON];
        if (payname)
        {
            [params setValue:payname forKey:KWK_REMARKETING_PARAM_ARGMODP];
        }
        
        [params setValue:KWK_REMARKETING_VALUE_MODE forKey:KWK_REMARKETING_PARAM_MODE];
        
        NSString* idfa = [KWKUtils savedIDFA];
        if (!idfa && [KWKUtils isTrackingForAdvertisingEnabled])
        {
            idfa = [KWKUtils IDFA];
        }
        
        if (idfa)
        {
            [KWKUtils savedIDFA];
            [params setValue:idfa forKey:KWK_REMARKETING_PARAM_USERID];
        }
        
        [params setValue:repeatable? @"true" : @"false" forKey:KWK_REMARKETING_PARAM_ISREP];
        
        if (CustomParameters)
        {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:CustomParameters
                                                               options:0
                                                                 error:&error];
            
            if (jsonData)
            {
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                [params setObject:jsonString forKey:KWK_REMARKETING_PARAM_CUSTOM_PARAMS];
            }
        }
        
        NSData* postData = [NSData requestDataFromParamsDictionary:params];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:postData];
        [req setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postData length]] forHTTPHeaderField:@"Content-Length"];
        
        [KWKRestService queueTrackinRequest:req completion:^(NSError * _Nullable error) {
            if (error)
            {
                KWKLog(@"Remarketing report for %@ %@", trackingID, error == nil ? @"succeded" : [NSString stringWithFormat:@"failed. Reason: %@", error.description]);
                //TODO - save req and send later
            }
        }];
    }
    
}

@end
