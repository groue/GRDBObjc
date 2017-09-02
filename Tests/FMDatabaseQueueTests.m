#import "GRDBObjcTestCase.h"

@interface FMDatabaseQueueTests : GRDBObjcTestCase
@end

@implementation FMDatabaseQueueTests

- (BOOL)databaseHasBasicFunctionnality:(FMDatabase *)db
{
    [db executeUpdate:@"CREATE TABLE t(a)"];
    [db executeUpdate:@"INSERT INTO t(a) VALUES (123)"];
    FMResultSet *resultSet = [db executeQuery:@"SELECT a FROM T"];
    int fetchedInt = 0;
    while ([resultSet next]) {
        fetchedInt = [resultSet intForColumnIndex:0];
    }
    return (fetchedInt == 123);
}

- (BOOL)databaseQueueHasBasicFunctionnality:(FMDatabaseQueue *)dbQueue
{
    NSParameterAssert(dbQueue);
    __block BOOL success = NO;
    [dbQueue inDatabase:^(FMDatabase *db) {
        success = [self databaseHasBasicFunctionnality:db];
    }];
    return success;
}

- (void)testPathFactoryMethod
{
    NSError *error;
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:&error];
    XCTAssertNotNil(dbQueue, "%@", error);
    XCTAssert([self databaseQueueHasBasicFunctionnality:dbQueue]);
}

- (void)testPathFactoryMethodWithoutErrorHandling
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    XCTAssert([self databaseQueueHasBasicFunctionnality:dbQueue]);
}

- (void)testPathInitializer
{
    NSError *error;
    FMDatabaseQueue *dbQueue = [[FMDatabaseQueue alloc] initWithPath:[self makeTemporaryDatabasePath] error:&error];
    XCTAssertNotNil(dbQueue, "%@", error);
    XCTAssert([self databaseQueueHasBasicFunctionnality:dbQueue]);
}

- (void)testPathOfDiskDatabase
{
    NSString *initPath = [self makeTemporaryDatabasePath];
    FMDatabaseQueue *dbQueue = [[FMDatabaseQueue alloc] initWithPath:initPath error:NULL];
    NSString *path = dbQueue.path;
    XCTAssertEqualObjects(path, initPath);
}

- (void)testInDatabase
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    __block BOOL success = NO;
    [dbQueue inDatabase:^(FMDatabase *db) {
        success = [self databaseHasBasicFunctionnality:db];
    }];
    XCTAssert(success);
}

- (void)testInTransactionCommit
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        XCTAssertFalse([db isInTransaction]);
        [db executeUpdate:@"CREATE TABLE t(a)"];
        [db executeUpdate:@"INSERT INTO t(a) VALUES (123)"];
    }];
    [dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        XCTAssertTrue([db isInTransaction]);
        XCTAssertFalse(*rollback);
        [db executeUpdate:@"DELETE FROM t"];
    }];
    [dbQueue inDatabase:^(FMDatabase *db) {
        XCTAssertFalse([db isInTransaction]);
        FMResultSet *resultSet = [db executeQuery:@"SELECT a FROM t"];
        XCTAssertNotNil(resultSet);
        XCTAssertFalse([resultSet next]);
    }];
}

- (void)testInTransactionRollback
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a)"];
        [db executeUpdate:@"INSERT INTO t(a) VALUES (123)"];
    }];
    [dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        XCTAssertFalse(*rollback);
        [db executeUpdate:@"DELETE FROM t"];
        *rollback = YES;
    }];
    [dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:@"SELECT a FROM t"];
        XCTAssertNotNil(resultSet);
        XCTAssertTrue([resultSet next]);
    }];
}

- (void)testInDeferredTransaction
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a)"];
        [db executeUpdate:@"INSERT INTO t(a) VALUES (123)"];
    }];
    [dbQueue inDeferredTransaction:^(FMDatabase *db, BOOL *rollback) {
        XCTAssertTrue([db isInTransaction]);
        XCTAssertFalse(*rollback);
        [db executeUpdate:@"DELETE FROM t"];
    }];
    [dbQueue inDatabase:^(FMDatabase *db) {
        XCTAssertFalse([db isInTransaction]);
        FMResultSet *resultSet = [db executeQuery:@"SELECT a FROM t"];
        XCTAssertNotNil(resultSet);
        XCTAssertFalse([resultSet next]);
    }];
}

@end
