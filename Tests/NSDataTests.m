#import "GRDBObjcTestCase.h"

@interface NSDataTests : GRDBObjcTestCase

@end

@implementation NSDataTests

- (void)testNonEmptyData
{
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        NSData *data = [@"foo" dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        GRResultSet *resultSet = [db executeQuery:@"SELECT ?" values:@[data] error:&error];
        XCTAssertNotNil(resultSet, @"%@", error);
        XCTAssert([resultSet next]);
        NSData *fetchedData = [resultSet dataForColumnIndex:0];
        XCTAssertEqualObjects(data, fetchedData);
    }];
}

- (void)testEmptyData
{
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        NSData *data = [NSData data];
        NSError *error;
        GRResultSet *resultSet = [db executeQuery:@"SELECT ?" values:@[data] error:&error];
        XCTAssertNotNil(resultSet, @"%@", error);
        XCTAssert([resultSet next]);
        NSData *fetchedData = [resultSet dataForColumnIndex:0];
        XCTAssertEqualObjects(data, fetchedData);
    }];
}

@end
