#import "GRDBObjcTestCase.h"

@interface GRDatabaseQueueTests : GRDBObjcTestCase
@end

@implementation GRDatabaseQueueTests

- (BOOL)databaseHasBasicFunctionnality:(GRDatabase *)db
{
    [db executeUpdate:@"CREATE TABLE t(a)"];
    [db executeUpdate:@"INSERT INTO t(a) VALUES (123)"];
    GRResultSet *resultSet = [db executeQuery:@"SELECT a FROM T"];
    int fetchedInt = 0;
    while ([resultSet next]) {
        fetchedInt = [resultSet intForColumnIndex:0];
    }
    return (fetchedInt == 123);
}

- (BOOL)databaseQueueHasBasicFunctionnality:(GRDatabaseQueue *)dbQueue
{
    NSParameterAssert(dbQueue);
    __block BOOL success = NO;
    [dbQueue inDatabase:^(GRDatabase *db) {
        success = [self databaseHasBasicFunctionnality:db];
    }];
    return success;
}

- (void)testMemoryInitializer {
    GRDatabaseQueue *dbQueue = [[GRDatabaseQueue alloc] init];
    XCTAssert([self databaseQueueHasBasicFunctionnality:dbQueue]);
}

- (void)testPathFactoryMethod {
    NSError *error;
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:&error];
    XCTAssertNotNil(dbQueue, "%@", error);
    XCTAssert([self databaseQueueHasBasicFunctionnality:dbQueue]);
}

- (void)testPathFactoryMethodWithoutErrorHandling {
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    XCTAssert([self databaseQueueHasBasicFunctionnality:dbQueue]);
}

- (void)testPathInitializer {
    NSError *error;
    GRDatabaseQueue *dbQueue = [[GRDatabaseQueue alloc] initWithPath:[self makeTemporaryDatabasePath] error:&error];
    XCTAssertNotNil(dbQueue, "%@", error);
    XCTAssert([self databaseQueueHasBasicFunctionnality:dbQueue]);
}

- (void)testPathOfDiskDatabase {
    NSString *initPath = [self makeTemporaryDatabasePath];
    GRDatabaseQueue *dbQueue = [[GRDatabaseQueue alloc] initWithPath:initPath error:NULL];
    NSString *path = dbQueue.path;
    XCTAssertEqualObjects(path, initPath);
}

- (void)testInDatabase {
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    __block BOOL success = NO;
    [dbQueue inDatabase:^(GRDatabase *db) {
        success = [self databaseHasBasicFunctionnality:db];
    }];
    XCTAssert(success);
}

- (void)testInTransactionCommit {
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a)"];
        [db executeUpdate:@"INSERT INTO t(a) VALUES (123)"];
    }];
    [dbQueue inTransaction:^(GRDatabase *db, BOOL *rollback) {
        XCTAssertFalse(*rollback);
        [db executeUpdate:@"DELETE FROM t"];
    }];
    [dbQueue inDatabase:^(GRDatabase *db) {
        GRResultSet *resultSet = [db executeQuery:@"SELECT a FROM t"];
        XCTAssertNotNil(resultSet);
        XCTAssertFalse([resultSet next]);
    }];
}

- (void)testInTransactionRollback {
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a)"];
        [db executeUpdate:@"INSERT INTO t(a) VALUES (123)"];
    }];
    [dbQueue inTransaction:^(GRDatabase *db, BOOL *rollback) {
        XCTAssertFalse(*rollback);
        [db executeUpdate:@"DELETE FROM t"];
        *rollback = YES;
    }];
    [dbQueue inDatabase:^(GRDatabase *db) {
        GRResultSet *resultSet = [db executeQuery:@"SELECT a FROM t"];
        XCTAssertNotNil(resultSet);
        XCTAssertTrue([resultSet next]);
    }];
}

- (void)testInDeferredTransaction {
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a)"];
        [db executeUpdate:@"INSERT INTO t(a) VALUES (123)"];
    }];
    [dbQueue inDeferredTransaction:^(GRDatabase *db, BOOL *rollback) {
        XCTAssertFalse(*rollback);
        [db executeUpdate:@"DELETE FROM t"];
    }];
    [dbQueue inDatabase:^(GRDatabase *db) {
        GRResultSet *resultSet = [db executeQuery:@"SELECT a FROM t"];
        XCTAssertNotNil(resultSet);
        XCTAssertFalse([resultSet next]);
    }];
}

@end
