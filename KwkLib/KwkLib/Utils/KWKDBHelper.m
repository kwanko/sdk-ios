//
//  KWKDBHelper.m
//  TestKwanko
//
//  Created by Bogdan CHITU on 15/03/17.
//  Copyright © 2017 Bogdan CHITU. All rights reserved.
//

#import "KWKDBHelper.h"
#import <sqlite3.h>

NSString* const KWKDBHelperErrorDomain = @"KWKDBHelperErrorDomain";

@interface KWKDBHelper()
{
    sqlite3 *sqlite3Database;
    int openDBResult;
}

@end

@implementation KWKDBHelper

- (instancetype) init
{
    if (self = [super init])
    {
        sqlite3Database = NULL;
        openDBResult = INT_MAX;
    }
    
    return self;
}

- (BOOL) openDBAtPath:(NSString*) databasePath
{
    openDBResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    if(openDBResult == SQLITE_OK)
    {
        return YES;
    }
    
    return NO;
}

- (BOOL) close
{
    if (sqlite3Database)
    {
        sqlite3_close(sqlite3Database);
        sqlite3Database = NULL;
        openDBResult = INT_MAX;
        return YES;
    }
    
    return NO;
}

- (void) executeStatement:(NSString*) statement completion:(KWKDbHelperResult) block
{
    if (sqlite3Database)
    {
        sqlite3_stmt *compiledStatement;
        
        int prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, [statement UTF8String], -1, &compiledStatement, NULL);
        if(prepareStatementResult == SQLITE_OK)
        {
            int executeQueryResults = sqlite3_step(compiledStatement);
            if (executeQueryResults == SQLITE_DONE)  //querry was not executable and is done
            {
                if (block)
                {
                    block(nil, nil, nil);
                }
            }
            else if(executeQueryResults == SQLITE_ROW)
            {
                NSMutableArray* resultRowsArr = [[NSMutableArray alloc] init];
                NSMutableArray* columnNamesArr = [[NSMutableArray alloc] init];
                
                do
                {
                    NSMutableArray* rowDataArray = [[NSMutableArray alloc] init];
                    int columnCount = sqlite3_column_count(compiledStatement);
            
                    for (int i=0; i<columnCount; i++)
                    {
                        char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
                        
                        if (dbDataAsChars != NULL)
                        {
                            [rowDataArray addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                        
                        if (columnNamesArr.count != columnCount)
                        {
                            dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
                            [columnNamesArr addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                        }
                    }
                    
                    if (rowDataArray.count > 0)
                    {
                        [resultRowsArr addObject:rowDataArray];
                    }
                    
                    executeQueryResults = sqlite3_step(compiledStatement);
                }while (executeQueryResults == SQLITE_ROW);
                
                if (block)
                {
                    block(columnNamesArr, resultRowsArr, nil);
                }
            }
            else
            {
                NSString* errorMessage = [NSString stringWithFormat:@"%s",sqlite3_errmsg(sqlite3Database)];
                NSError* error = [NSError errorWithDomain:KWKDBHelperErrorDomain
                                                     code:0 //TODO define
                                                 userInfo:@{NSLocalizedDescriptionKey : errorMessage,
                                                            NSLocalizedFailureReasonErrorKey : @"statement could not be executed"}];
                
                if (block)
                {
                    block(nil, nil, error);
                }
            }
            
            
           
        }
        else
        {
            NSString* errorMessage = [NSString stringWithFormat:@"%s",sqlite3_errmsg(sqlite3Database)];
            NSError* error = [NSError errorWithDomain:KWKDBHelperErrorDomain
                                                 code:0 //TODO define
                                             userInfo:@{NSLocalizedDescriptionKey : errorMessage,
                                                        NSLocalizedFailureReasonErrorKey : @"database cannot be opened"}];
            if (block)
            {
                block(nil, nil, error);
            }
        }
        
        sqlite3_finalize(compiledStatement);
    }
    else
    {
        NSError* error = [NSError errorWithDomain:KWKDBHelperErrorDomain
                                             code:0 //TODO define
                                         userInfo:@{NSLocalizedDescriptionKey : @"Db not open",
                                                    NSLocalizedFailureReasonErrorKey : @"database cannot be opened"}];
        if (block)
        {
            block(nil, nil, error);
        }
    }
    
}

+ (BOOL)createDBAtPath:(NSString *)path
{
    BOOL ok = YES;
    sqlite3 *newDB = NULL;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: path] == NO)
    {
        const char *dbpath = [path UTF8String];
        if (sqlite3_open(dbpath, &newDB) == SQLITE_OK)
        {
            sqlite3_close(newDB);
        }
    }
    else
    {
        ok = NO;
    }
    
    return ok;
}

- (void)dealloc
{
    [self close];
}

@end
