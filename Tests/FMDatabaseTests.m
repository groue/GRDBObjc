#import "GRDBObjcTestCase.h"
#import <sqlite3.h>

@interface FMDatabaseTests : GRDBObjcTestCase
@end

@implementation FMDatabaseTests

- (void)testExecuteUpdate
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:@"CREATE TABLE t(a)"];
        XCTAssert(success);
        XCTAssert([db tableExists:@"t"]);
    }];
}

- (void)testExecuteUpdateWithoutErrorHandling
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeUpdate:@"CREATE TABLE t(a)"];
        XCTAssert(success);
    }];
}

- (void)testExecuteUpdateWithArgumentsInArray
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a, b)"];
        
        BOOL success = [db executeUpdate:@"INSERT INTO t(a, b) VALUES (?, ?)"
                    withArgumentsInArray:@[@(123), @(654)]];
        XCTAssert(success);
        
        FMResultSet *rs = [db executeQuery:@"SELECT a, b FROM t"];
        XCTAssertNotNil(rs);
        BOOL fetched = NO;
        while ([rs next]) {
            fetched = YES;
            XCTAssertEqual([rs intForColumnIndex:0], 123);
            XCTAssertEqual([rs intForColumnIndex:1], 654);
        }
        XCTAssert(fetched);
    }];
}

- (void)testExecuteUpdateWithParameterDictionary
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a, b)"];
        
        BOOL success = [db executeUpdate:@"INSERT INTO t(a, b) VALUES (:a, :b)"
                 withParameterDictionary:@{@"a": @(123), @"b": @(654)}];
        XCTAssert(success);
        
        FMResultSet *rs = [db executeQuery:@"SELECT a, b FROM t"];
        XCTAssertNotNil(rs);
        BOOL fetched = NO;
        while ([rs next]) {
            fetched = YES;
            XCTAssertEqual([rs intForColumnIndex:0], 123);
            XCTAssertEqual([rs intForColumnIndex:1], 654);
        }
        XCTAssert(fetched);
    }];
}

- (void)testExecuteUpdateWithValues
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a, b)"];
        
        NSError *error;
        BOOL success = [db executeUpdate:@"INSERT INTO t(a, b) VALUES (?, ?)"
                                  values:@[@(123), @(654)]
                                   error:&error];
        XCTAssert(success, @"%@", error);
        
        FMResultSet *rs = [db executeQuery:@"SELECT a, b FROM t"];
        XCTAssertNotNil(rs);
        BOOL fetched = NO;
        while ([rs next]) {
            fetched = YES;
            XCTAssertEqual([rs intForColumnIndex:0], 123);
            XCTAssertEqual([rs intForColumnIndex:1], 654);
        }
        XCTAssert(fetched);
    }];
}

- (void)testExecuteUpdateWithNilValues
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a, b)"];
        
        NSError *error;
        BOOL success = [db executeUpdate:@"INSERT INTO t(a, b) VALUES (123, 654)"
                                  values:nil
                                   error:&error];
        XCTAssert(success, @"%@", error);
        
        FMResultSet *rs = [db executeQuery:@"SELECT a, b FROM t"];
        XCTAssertNotNil(rs);
        BOOL fetched = NO;
        while ([rs next]) {
            fetched = YES;
            XCTAssertEqual([rs intForColumnIndex:0], 123);
            XCTAssertEqual([rs intForColumnIndex:1], 654);
        }
        XCTAssert(fetched);
    }];
}

- (void)testExecuteUpdateWithValuesError
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        db.logsErrors = YES;
        
        NSError *error;
        BOOL success = [db executeUpdate:@"When on board H.M.S. ‘Beable’ as naturalist," values: nil error:&error];
        XCTAssertFalse(success);
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.domain, @"GRDB.DatabaseError");
        XCTAssertEqual(error.code, SQLITE_ERROR);
        XCTAssertEqualObjects(error.localizedDescription, @"SQLite error 1 with statement `When on board H.M.S. ‘Beable’ as naturalist,`: near \"When\": syntax error");
    }];
}

- (void)testExecuteQuery
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a, b)"];
        [db executeUpdate:@"INSERT INTO t(a, b) VALUES (123, 654)"];
        
        FMResultSet *rs = [db executeQuery:@"SELECT a, b FROM t"];
        XCTAssertNotNil(rs);
        BOOL fetched = NO;
        while ([rs next]) {
            fetched = YES;
            XCTAssertEqual([rs intForColumnIndex:0], 123);
            XCTAssertEqual([rs intForColumnIndex:1], 654);
        }
        XCTAssert(fetched);
    }];
}

- (void)testExecuteQueryWithArgumentsInArray
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a, b)"];
        [db executeUpdate:@"INSERT INTO t(a, b) VALUES (123, 654)"];
        
        FMResultSet *rs = [db executeQuery:@"SELECT a, b FROM t WHERE a > ? AND a < ?"
                   withArgumentsInArray:@[@(122), @(124)]];
        XCTAssertNotNil(rs);
        BOOL fetched = NO;
        while ([rs next]) {
            fetched = YES;
            XCTAssertEqual([rs intForColumnIndex:0], 123);
            XCTAssertEqual([rs intForColumnIndex:1], 654);
        }
        XCTAssert(fetched);
    }];
}

- (void)testExecuteQueryWithParameterDictionary
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a, b)"];
        [db executeUpdate:@"INSERT INTO t(a, b) VALUES (123, 654)"];
        
        FMResultSet *rs = [db executeQuery:@"SELECT a, b FROM t WHERE a > :a AND a < :b"
                   withParameterDictionary:@{@"a": @(122), @"b": @(124)}];
        XCTAssertNotNil(rs);
        BOOL fetched = NO;
        while ([rs next]) {
            fetched = YES;
            XCTAssertEqual([rs intForColumnIndex:0], 123);
            XCTAssertEqual([rs intForColumnIndex:1], 654);
        }
        XCTAssert(fetched);
    }];
}

- (void)testExecuteQueryWithNilValues
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a, b)"];
        [db executeUpdate:@"INSERT INTO t(a, b) VALUES (123, 654)"];
        
        NSError *error;
        FMResultSet *rs = [db executeQuery:@"SELECT a, b FROM t WHERE a > 122 AND a < 124"
                                    values:nil
                                     error:&error];
        XCTAssertNotNil(rs, @"%@", error);
        BOOL fetched = NO;
        while ([rs next]) {
            fetched = YES;
            XCTAssertEqual([rs intForColumnIndex:0], 123);
            XCTAssertEqual([rs intForColumnIndex:1], 654);
        }
        XCTAssert(fetched);
    }];
}

- (void)testExecuteQueryWithValuesError
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        db.logsErrors = YES;
        
        NSError *error;
        FMResultSet *rs = [db executeQuery:@"Call me Ishmael." values:nil error:&error];
        XCTAssertNil(rs);
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.domain, @"GRDB.DatabaseError");
        XCTAssertEqual(error.code, SQLITE_ERROR);
        XCTAssertEqualObjects(error.localizedDescription, @"SQLite error 1 with statement `Call me Ishmael.`: near \"Call\": syntax error");
        
        NSError *lastError = db.lastError;
        XCTAssertNotNil(lastError);
        XCTAssertEqualObjects(lastError.domain, @"GRDB.DatabaseError");
        XCTAssertEqual(lastError.code, SQLITE_ERROR);
        XCTAssertEqualObjects(lastError.localizedDescription, @"SQLite error 1: near \"Call\": syntax error");
    }];
}

- (void)testLastInsertRowId
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        XCTAssertEqual(db.lastInsertRowId, 0);
        [db executeUpdate:@"CREATE TABLE t(id INTEGER PRIMARY KEY, a)"];
        [db executeUpdate:@"INSERT INTO t(a) VALUES (1)"];
        XCTAssertEqual(db.lastInsertRowId, 1);
        [db executeUpdate:@"INSERT INTO t(a) VALUES (1)"];
        XCTAssertEqual(db.lastInsertRowId, 2);
        [db executeUpdate:@"INSERT INTO t(id, a) VALUES (123, 1)"];
        XCTAssertEqual(db.lastInsertRowId, 123);
        [db executeUpdate:@"INSERT INTO t(id, a) VALUES (0, 1)"];
        XCTAssertEqual(db.lastInsertRowId, 0);
    }];
}

- (void)testChanges
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        XCTAssertEqual(db.changes, 0);
        [db executeUpdate:@"CREATE TABLE t(id INTEGER PRIMARY KEY, a)"];
        [db executeUpdate:@"INSERT INTO t(a) VALUES (1)"];
        XCTAssertEqual(db.changes, 1);
        [db executeUpdate:@"INSERT INTO t(a) VALUES (2)"];
        XCTAssertEqual(db.changes, 1);
        [db executeUpdate:@"DELETE FROM t"];
        XCTAssertEqual(db.changes, 2);
    }];
}

- (void)testTransaction
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        XCTAssertFalse(db.isInTransaction);
        [db executeUpdate:@"BEGIN TRANSACTION"];
        XCTAssertTrue(db.isInTransaction);
        [db executeUpdate:@"ROLLBACK"];
        XCTAssertFalse(db.isInTransaction);
        XCTAssertFalse([db rollback]);
        XCTAssertFalse([db commit]);

        XCTAssertTrue([db beginTransaction]);
        XCTAssertTrue(db.isInTransaction);
        XCTAssertTrue([db rollback]);
        XCTAssertFalse(db.isInTransaction);
        XCTAssertFalse([db rollback]);
        XCTAssertFalse([db commit]);

        XCTAssertTrue([db beginTransaction]);
        XCTAssertTrue(db.isInTransaction);
        XCTAssertTrue([db commit]);
        XCTAssertFalse(db.isInTransaction);
        XCTAssertFalse([db rollback]);
        XCTAssertFalse([db commit]);

        XCTAssertTrue([db beginDeferredTransaction]);
        XCTAssertTrue(db.isInTransaction);
        XCTAssertTrue([db rollback]);
        XCTAssertFalse(db.isInTransaction);
        XCTAssertFalse([db rollback]);
        XCTAssertFalse([db commit]);
        
        XCTAssertTrue([db beginDeferredTransaction]);
        XCTAssertTrue(db.isInTransaction);
        XCTAssertTrue([db commit]);
        XCTAssertFalse(db.isInTransaction);
        XCTAssertFalse([db rollback]);
        XCTAssertFalse([db commit]);
    }];
}

- (void)testSQLiteHandle
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        sqlite3_exec(db.sqliteHandle, "CREATE TABLE t(a)", NULL, NULL, NULL);
        BOOL success = [db executeUpdate:@"INSERT INTO t(a) VALUES (1)"];
        XCTAssert(success);
    }];
}

- (void)testTableExists
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE defined(a)"];
        XCTAssertTrue([db tableExists:@"defined"]);
        XCTAssertTrue([db tableExists:@"DEFINED"]);
        XCTAssertFalse([db tableExists:@"undefined"]);
    }];
}

- (void)testInSavePointCommit
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a)"];
        [db executeUpdate:@"INSERT INTO t(a) VALUES (123)"];
        NSError *error = [db inSavePoint:^(BOOL *rollback) {
            XCTAssertFalse(*rollback);
            [db executeUpdate:@"DELETE FROM t"];
        }];
        XCTAssertNil(error);
        FMResultSet *resultSet = [db executeQuery:@"SELECT a FROM t"];
        XCTAssertFalse([resultSet next]);
    }];
}

- (void)testInSavePointRollback
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a)"];
        [db executeUpdate:@"INSERT INTO t(a) VALUES (123)"];
        NSError *error = [db inSavePoint:^(BOOL *rollback) {
            XCTAssertFalse(*rollback);
            [db executeUpdate:@"DELETE FROM t"];
            *rollback = YES;
        }];
        XCTAssertNil(error);
        FMResultSet *resultSet = [db executeQuery:@"SELECT a FROM t"];
        XCTAssertTrue([resultSet next]);
    }];
}

- (void)testInSavePointNested
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a)"];
        [db executeUpdate:@"INSERT INTO t(a) VALUES (123)"];
        NSError *error = [db inSavePoint:^(BOOL *rollback) {
            XCTAssertFalse(*rollback);
            *rollback = YES;
            
            NSError *error = [db inSavePoint:^(BOOL *rollback) {
                XCTAssertFalse(*rollback);
                [db executeUpdate:@"DELETE FROM t"];
            }];
            XCTAssertNil(error);
            FMResultSet *resultSet = [db executeQuery:@"SELECT a FROM t"];
            XCTAssertFalse([resultSet next]);
            
            [db executeUpdate:@"INSERT INTO t(a) VALUES (123)"];
            *rollback = NO;
        }];
        XCTAssertNil(error);
        FMResultSet *resultSet = [db executeQuery:@"SELECT a FROM t"];
        XCTAssertTrue([resultSet next]);
    }];
}

- (void)testSavePoint
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        XCTAssertFalse(db.isInTransaction);
        
        NSError *error;
        BOOL success = [db startSavePointWithName:@"foo" error:&error];
        XCTAssert(success, @"%@", error);
        XCTAssertTrue(db.isInTransaction);
        success = [db rollbackSavePointWithName:@"bar" error:&error];
        XCTAssertFalse(success);
        success = [db rollbackSavePointWithName:@"foo" error:&error];
        XCTAssert(success, @"%@", error);
        XCTAssertTrue(db.isInTransaction);
        success = [db releaseSavePointWithName:@"bar" error:&error];
        XCTAssertFalse(success);
        success = [db releaseSavePointWithName:@"foo" error:&error];
        XCTAssert(success, @"%@", error);
        XCTAssertFalse(db.isInTransaction);
    }];
}

@end
