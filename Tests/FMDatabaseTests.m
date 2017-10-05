#import "GRDBObjcTestCase.h"
#import <sqlite3.h>

@interface FMDatabaseTests : GRDBObjcTestCase
@end

@implementation FMDatabaseTests

- (void)testExecuteStatements
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        BOOL success = [db executeStatements:@"CREATE TABLE t(a); DROP TABLE t; CREATE TABLE u(b);"];
        XCTAssert(success);
        XCTAssert([db tableExists:@"u"]);
    }];
}

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

- (void)testExecuteUpdateWithArguments
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a, b)"];

        BOOL success = [db executeUpdate:@"INSERT INTO t(a, b) VALUES (?, ?)", nil, @(654)];
        XCTAssert(success);
        
        FMResultSet *rs = [db executeQuery:@"SELECT a, b FROM t"];
        XCTAssertNotNil(rs);
        BOOL fetched = NO;
        while ([rs next]) {
            fetched = YES;
            XCTAssertTrue([rs columnIndexIsNull:0]);
            XCTAssertEqual([rs intForColumnIndex:1], 654);
        }
        XCTAssert(fetched);
    }];
}

- (void)testExecuteUpdateWithArgumentsInArray
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a, b)"];
        
        BOOL success = [db executeUpdate:@"INSERT INTO t(a, b) VALUES (?, ?)"
                    withArgumentsInArray:@[[NSNull null], @(654)]];
        XCTAssert(success);
        
        FMResultSet *rs = [db executeQuery:@"SELECT a, b FROM t"];
        XCTAssertNotNil(rs);
        BOOL fetched = NO;
        while ([rs next]) {
            fetched = YES;
            XCTAssertTrue([rs columnIndexIsNull:0]);
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
                 withParameterDictionary:@{@"a": [NSNull null], @"b": @(654)}];
        XCTAssert(success);
        
        FMResultSet *rs = [db executeQuery:@"SELECT a, b FROM t"];
        XCTAssertNotNil(rs);
        BOOL fetched = NO;
        while ([rs next]) {
            fetched = YES;
            XCTAssertTrue([rs columnIndexIsNull:0]);
            XCTAssertEqual([rs intForColumnIndex:1], 654);
        }
        XCTAssert(fetched);
    }];
}

- (void)testExecuteUpdateWithErrorAndBindings
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a, b)"];
        
        NSError *error;
        BOOL success = [db executeUpdate:@"INSERT INTO t(a, b) VALUES (?, ?)"
                                  withErrorAndBindings:&error, nil, @(654)];
        XCTAssert(success, @"%@", error);
        
        FMResultSet *rs = [db executeQuery:@"SELECT a, b FROM t"];
        XCTAssertNotNil(rs);
        BOOL fetched = NO;
        while ([rs next]) {
            fetched = YES;
            XCTAssertTrue([rs columnIndexIsNull:0]);
            XCTAssertEqual([rs intForColumnIndex:1], 654);
        }
        XCTAssert(fetched);
    }];
}

- (void)testExecuteUpdateWithErrorAndBindingsError
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        db.logsErrors = YES;
        
        NSError *error;
        BOOL success = [db executeUpdate:@"When on board H.M.S. ‘Beable’ as naturalist," withErrorAndBindings:&error];
        XCTAssertFalse(success);
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.domain, @"FMDatabase");
        XCTAssertEqual(error.code, SQLITE_ERROR);
        XCTAssertEqualObjects(error.localizedDescription, @"SQLite error 1 with statement `When on board H.M.S. ‘Beable’ as naturalist,`: near \"When\": syntax error");
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
                                  values:@[[NSNull null], @(654)]
                                   error:&error];
        XCTAssert(success, @"%@", error);
        
        FMResultSet *rs = [db executeQuery:@"SELECT a, b FROM t"];
        XCTAssertNotNil(rs);
        BOOL fetched = NO;
        while ([rs next]) {
            fetched = YES;
            XCTAssertTrue([rs columnIndexIsNull:0]);
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
        BOOL success = [db executeUpdate:@"INSERT INTO t(a, b) VALUES (NULL, 654)"
                                  values:nil
                                   error:&error];
        XCTAssert(success, @"%@", error);
        
        FMResultSet *rs = [db executeQuery:@"SELECT a, b FROM t"];
        XCTAssertNotNil(rs);
        BOOL fetched = NO;
        while ([rs next]) {
            fetched = YES;
            XCTAssertTrue([rs columnIndexIsNull:0]);
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
        XCTAssertEqualObjects(error.domain, @"FMDatabase");
        XCTAssertEqual(error.code, SQLITE_ERROR);
        XCTAssertEqualObjects(error.localizedDescription, @"SQLite error 1 with statement `When on board H.M.S. ‘Beable’ as naturalist,`: near \"When\": syntax error");
    }];
}

- (void)testExecuteQuery
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT NULL, 654"];
        XCTAssertNotNil(rs);
        BOOL fetched = NO;
        while ([rs next]) {
            fetched = YES;
            XCTAssertTrue([rs columnIndexIsNull:0]);
            XCTAssertEqual([rs intForColumnIndex:1], 654);
        }
        XCTAssert(fetched);
    }];
}

- (void)testExecuteQueryWithArguments
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT ?, ?", nil, @(654)];
        XCTAssertNotNil(rs);
        BOOL fetched = NO;
        while ([rs next]) {
            fetched = YES;
            XCTAssertTrue([rs columnIndexIsNull:0]);
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
        FMResultSet *rs = [db executeQuery:@"SELECT ?, ?"
                   withArgumentsInArray:@[[NSNull null], @(654)]];
        XCTAssertNotNil(rs);
        BOOL fetched = NO;
        while ([rs next]) {
            fetched = YES;
            XCTAssertTrue([rs columnIndexIsNull:0]);
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
        FMResultSet *rs = [db executeQuery:@"SELECT :a, :b"
                   withParameterDictionary:@{@"a": [NSNull null], @"b": @(654)}];
        XCTAssertNotNil(rs);
        BOOL fetched = NO;
        while ([rs next]) {
            fetched = YES;
            XCTAssertTrue([rs columnIndexIsNull:0]);
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
        NSError *error;
        FMResultSet *rs = [db executeQuery:@"SELECT NULL, 654"
                                    values:nil
                                     error:&error];
        XCTAssertNotNil(rs, @"%@", error);
        BOOL fetched = NO;
        while ([rs next]) {
            fetched = YES;
            XCTAssertTrue([rs columnIndexIsNull:0]);
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
        XCTAssertEqualObjects(error.domain, @"FMDatabase");
        XCTAssertEqual(error.code, SQLITE_ERROR);
        XCTAssertEqualObjects(error.localizedDescription, @"SQLite error 1 with statement `Call me Ishmael.`: near \"Call\": syntax error");
        
        NSError *lastError = db.lastError;
        XCTAssertNotNil(lastError);
        XCTAssertEqualObjects(lastError.domain, @"FMDatabase");
        XCTAssertEqual(lastError.code, SQLITE_ERROR);
        XCTAssertEqualObjects(lastError.localizedDescription, @"near \"Call\": syntax error");
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

// Regression test
- (void)testDropTable
{
    FMDatabaseQueue *dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath]];
    XCTAssertNotNil(dbQueue);
    [dbQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a)"];
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM sqlite_master WHERE name = 't'"];
        XCTAssertTrue([rs next]);
        [db executeUpdate:@"DROP TABLE t"];
        rs = [db executeQuery:@"SELECT * FROM sqlite_master WHERE name = 't'"];
        XCTAssertFalse([rs next]);
    }];
}

@end
