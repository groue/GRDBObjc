#import "GRDBObjcTestCase.h"

@interface NSDataTests : GRDBObjcTestCase

@end

@implementation NSDataTests

- (void)testNonEmptyData
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSData *data = [@"foo" dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        FMResultSet *resultSet = [db executeQuery:@"SELECT ?" values:@[data] error:&error];
        XCTAssertNotNil(resultSet, @"%@", error);
        XCTAssert([resultSet next]);
        NSData *fetchedData = [resultSet dataForColumnIndex:0];
        XCTAssertEqualObjects(data, fetchedData);
    }];
}

- (void)testEmptyData
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        NSData *data = [NSData data];
        NSError *error;
        FMResultSet *resultSet = [db executeQuery:@"SELECT ?" values:@[data] error:&error];
        XCTAssertNotNil(resultSet, @"%@", error);
        XCTAssert([resultSet next]);
        NSData *fetchedData = [resultSet dataForColumnIndex:0];
        XCTAssertEqualObjects(data, fetchedData);
    }];
}

@end
