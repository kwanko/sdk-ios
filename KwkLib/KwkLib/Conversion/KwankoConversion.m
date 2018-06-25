//
//  KwankoConversion.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 20/02/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KwankoConversion.h"
#import "KwankoTrackingConstants.h"
#import "KWKRestService.h"
#include "KWKUtils.h"
#include "KWKDBHelper.h"

#define KWK_CONVERSION_PARAM_MCLIC    @"mclic"
#define KWK_CONVERSION_PARAM_USERID   @"userId"
#define KWK_CONVERSION_PARAM_CIBLE    @"cible"
#define KWK_CONVERSION_PARAM_ALT_ID   @"altid"
#define KWK_CONVERSION_PARAM_ACTION   @"action"
#define KWK_CONVERSION_PARAM_MODE     @"mode"
#define KWK_CONVERSION_PARAM_ISREP    @"isRepeatable"
#define KWK_CONVERSION_PARAM_ARGANN   @"argann"

#define KWK_CONVERSION_VALUE_MODE     @"inapp"

NSString* const kKwankoConversionActionInstall = @"install";
NSString* const kKwankoConversionActionRegister = @"register";
NSString* const kKwankoConversionActionForm = @"form";


@implementation KwankoConversion

+(instancetype) getInstance
{
    static dispatch_once_t once;
    
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (void) reportConversionWithID:(NSString *)trackingID
                          Label:(NSString *)action
                  AlternativeID:(NSString *)email
                   isRepeatable:(BOOL)repeatable
{
    NSAssert(trackingID, @"Traking id cannot be nil");
    if (trackingID)
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
                        NSString* createTableStatement = [NSString stringWithFormat:@"CREATE TABLE %@(%@ varchar(255));", KWK_CONVERSION_TABLE_NAME, KWK_CONVERSION_TRACKING_ID_COL_NAME];
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
                NSString* selectStatement = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'", KWK_CONVERSION_TABLE_NAME , KWK_CONVERSION_TRACKING_ID_COL_NAME, trackingID];
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
                    KWKLog(@"Conversion for %@ already reported as nonrepeatable", trackingID);
                    return;
                }
                
                
                
                NSString* insertStatement = [NSString stringWithFormat:@"INSERT INTO %@ (%@) \
                                            VALUES ('%@');", KWK_CONVERSION_TABLE_NAME , KWK_CONVERSION_TRACKING_ID_COL_NAME, trackingID];
                [dbHelper executeStatement:insertStatement completion:^(NSArray *columnNames, NSArray *rows, NSError *error) {
                    if (error)
                    {
                        KWKLog(@"Error performing insert: %@",error);
                    }
                }];
                
                [dbHelper close];
            }
        }
        
        NSURL* url = [NSURL URLWithString:KWK_CONVERSION_SERVER_URL];
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setValue:trackingID forKey:KWK_CONVERSION_PARAM_MCLIC];
        if (action)
        {
            [params setValue:action forKey:KWK_CONVERSION_PARAM_ACTION];
        }
        if (email)
        {
            [params setValue:email forKey:KWK_CONVERSION_PARAM_ALT_ID];
        }
        
        [params setValue:KWK_CONVERSION_VALUE_MODE forKey:KWK_CONVERSION_PARAM_MODE];
        if ([KWKUtils isTrackingForAdvertisingEnabled])
        {
            [params setValue:[KWKUtils IDFA] forKey:KWK_CONVERSION_PARAM_USERID];
            [params setValue:[KWKUtils IDFA] forKey:KWK_CONVERSION_PARAM_ARGANN];
        }
        [params setValue:repeatable? @"true" : @"false" forKey:KWK_CONVERSION_PARAM_ISREP];

        NSData* postData = [NSData requestDataFromParamsDictionary:params];
        [req setHTTPMethod:@"POST"];
        [req setHTTPBody:postData];
        [req setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postData length]] forHTTPHeaderField:@"Content-Length"];
        
        [KWKRestService queueTrackinRequest:req completion:^(NSError * _Nullable error) {
            if (error)
            {
                KWKLog(@"Conversion report for %@ %@", trackingID, error == nil ? @"succeded" : [NSString stringWithFormat:@"failed. Reason: %@", error.description]);
                //TODO - save req and send later
            }
        }];
    }
    
}



@end
