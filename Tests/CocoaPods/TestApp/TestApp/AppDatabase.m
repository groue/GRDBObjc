// AppDatabase creates and accesses the database using FMDB-compatible APIs.

#import "AppDatabase.h"

static FMDatabaseQueue *dbQueue;

@implementation AppDatabase

+ (void)setupDatabaseAtPath:(NSString * _Nonnull)path
{
    // Use regular FMDB API:
    dbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    [dbQueue inDatabase:^(FMDatabase *db) {
        if (![db tableExists:@"demo"]) {
            [db executeUpdate:@"CREATE TABLE demo(text TEXT)"];
            [db executeUpdate:@"INSERT INTO demo(text) VALUES (?)" withArgumentsInArray:@[@"OK"]];
        }
    }];
}

+ (FMDatabaseQueue *)dbQueue
{
    return dbQueue;
}

@end
