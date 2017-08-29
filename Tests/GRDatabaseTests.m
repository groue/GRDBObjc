#import "GRDBObjcTestCase.h"
#import <sqlite3.h>

@interface GRDatabaseTests : GRDBObjcTestCase
@end

@implementation GRDatabaseTests

- (void)testExecuteUpdate
{
    GRDatabaseQueue *dbQueue = [[GRDatabaseQueue alloc] initWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        NSError *error;
        BOOL success = [db executeUpdate:@"CREATE TABLE t(a)" error:&error];
        XCTAssert(success, @"%@", error);
    }];
}

- (void)testExecuteUpdateWithValues
{
    GRDatabaseQueue *dbQueue = [[GRDatabaseQueue alloc] initWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a, b)" error:NULL];
        
        NSError *error;
        BOOL success = [db executeUpdate:@"INSERT INTO t(a, b) VALUES (?, ?)"
                                  values:@[@(123), @(654)]
                                   error:&error];
        XCTAssert(success, @"%@", error);
        
        GRResultSet *rs = [db executeQuery:@"SELECT a, b FROM t" error:&error];
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

- (void)testExecuteUpdateWithParameterDictionary
{
    GRDatabaseQueue *dbQueue = [[GRDatabaseQueue alloc] initWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a, b)" error:NULL];
        
        NSError *error;
        BOOL success = [db executeUpdate:@"INSERT INTO t(a, b) VALUES (:a, :b)"
                     parameterDictionary:@{@"a": @(123), @"b": @(654)}
                                   error:&error];
        XCTAssert(success, @"%@", error);
        
        GRResultSet *rs = [db executeQuery:@"SELECT a, b FROM t" error:&error];
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

- (void)testExecuteUpdateError
{
    GRDatabaseQueue *dbQueue = [[GRDatabaseQueue alloc] initWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        NSError *error;
        BOOL success = [db executeUpdate:@"When on board H.M.S. ‘Beable’ as naturalist," error:&error];
        XCTAssertFalse(success);
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.domain, @"GRDB.DatabaseError");
        XCTAssertEqual(error.code, SQLITE_ERROR);
        XCTAssertEqualObjects(error.localizedDescription, @"SQLite error 1 with statement `When on board H.M.S. ‘Beable’ as naturalist,`: near \"When\": syntax error");
    }];
}

- (void)testExecuteQuery
{
    GRDatabaseQueue *dbQueue = [[GRDatabaseQueue alloc] initWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a, b)" error:NULL];
        [db executeUpdate:@"INSERT INTO t(a, b) VALUES (123, 654)" error:NULL];
        
        NSError *error;
        GRResultSet *rs = [db executeQuery:@"SELECT a, b FROM t" error:&error];
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

- (void)testExecuteQueryWithValues
{
    GRDatabaseQueue *dbQueue = [[GRDatabaseQueue alloc] initWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a, b)" error:NULL];
        [db executeUpdate:@"INSERT INTO t(a, b) VALUES (123, 654)" error:NULL];
        
        NSError *error;
        GRResultSet *rs = [db executeQuery:@"SELECT a, b FROM t WHERE a > ? AND a < ?"
                                    values:@[@(122), @(124)]
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

- (void)testExecuteQueryWithParameterDictionary
{
    GRDatabaseQueue *dbQueue = [[GRDatabaseQueue alloc] initWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a, b)" error:NULL];
        [db executeUpdate:@"INSERT INTO t(a, b) VALUES (123, 654)" error:NULL];
        
        NSError *error;
        GRResultSet *rs = [db executeQuery:@"SELECT a, b FROM t WHERE a > :a AND a < :b"
                       parameterDictionary:@{@"a": @(122), @"b": @(124)}
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

- (void)testExecuteQueryError
{
    GRDatabaseQueue *dbQueue = [[GRDatabaseQueue alloc] initWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        NSError *error;
        GRResultSet *rs = [db executeQuery:@"Call me Ishmael." error:&error];
        XCTAssertNil(rs);
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(error.domain, @"GRDB.DatabaseError");
        XCTAssertEqual(error.code, SQLITE_ERROR);
        XCTAssertEqualObjects(error.localizedDescription, @"SQLite error 1 with statement `Call me Ishmael.`: near \"Call\": syntax error");
    }];
}

- (void)testLastInsertRowId
{
    GRDatabaseQueue *dbQueue = [[GRDatabaseQueue alloc] initWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        XCTAssertEqual(db.lastInsertRowId, 0);
        [db executeUpdate:@"CREATE TABLE t(id INTEGER PRIMARY KEY, a)" error:NULL];
        [db executeUpdate:@"INSERT INTO t(a) VALUES (1)" error:NULL];
        XCTAssertEqual(db.lastInsertRowId, 1);
        [db executeUpdate:@"INSERT INTO t(a) VALUES (1)" error:NULL];
        XCTAssertEqual(db.lastInsertRowId, 2);
        [db executeUpdate:@"INSERT INTO t(id, a) VALUES (123, 1)" error:NULL];
        XCTAssertEqual(db.lastInsertRowId, 123);
        [db executeUpdate:@"INSERT INTO t(id, a) VALUES (0, 1)" error:NULL];
        XCTAssertEqual(db.lastInsertRowId, 0);
    }];
}

- (void)testChanges
{
    GRDatabaseQueue *dbQueue = [[GRDatabaseQueue alloc] initWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        XCTAssertEqual(db.changes, 0);
        [db executeUpdate:@"CREATE TABLE t(id INTEGER PRIMARY KEY, a)" error:NULL];
        [db executeUpdate:@"INSERT INTO t(a) VALUES (1)" error:NULL];
        XCTAssertEqual(db.changes, 1);
        [db executeUpdate:@"INSERT INTO t(a) VALUES (2)" error:NULL];
        XCTAssertEqual(db.changes, 1);
        [db executeUpdate:@"DELETE FROM t" error:NULL];
        XCTAssertEqual(db.changes, 2);
    }];
}

@end
