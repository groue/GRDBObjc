#import "GRDBObjcTestCase.h"
#import <sqlite3.h>

@interface GRResultSetTests : GRDBObjcTestCase
@end

@implementation GRResultSetTests

- (GRResultSet *)executeValuesQueryInDatabase:(GRDatabase *)db
{
    NSError *error;
    GRResultSet *rs = [db executeQuery:@"SELECT ? AS integer, ? AS double, ? AS text, ? AS blob, NULL AS \"null\""
                                values:@[@(123), @(1.5), @"20 little cigars", [@"654" dataUsingEncoding:NSUTF8StringEncoding]]
                                 error:&error];
    XCTAssertNotNil(rs, @"%@", error);
    return rs;
}

- (void)testColumnIsNull
{
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        GRResultSet *rs = [self executeValuesQueryInDatabase:db];
        XCTAssert([rs next]);
        XCTAssertFalse([rs columnIndexIsNull:0]);
        XCTAssertFalse([rs columnIsNull:@"integer"]);
        XCTAssertFalse([rs columnIndexIsNull:1]);
        XCTAssertFalse([rs columnIsNull:@"double"]);
        XCTAssertFalse([rs columnIndexIsNull:2]);
        XCTAssertFalse([rs columnIsNull:@"text"]);
        XCTAssertFalse([rs columnIndexIsNull:3]);
        XCTAssertFalse([rs columnIsNull:@"blob"]);
        XCTAssertTrue([rs columnIndexIsNull:4]);
        XCTAssertTrue([rs columnIsNull:@"null"]);
    }];
}

- (void)testIntValue
{
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        GRResultSet *rs = [self executeValuesQueryInDatabase:db];
        XCTAssert([rs next]);
        XCTAssertEqual([rs intForColumnIndex:0], 123);
        XCTAssertEqual([rs intForColumn:@"integer"], 123);
        XCTAssertEqual([rs intForColumnIndex:1], 1);
        XCTAssertEqual([rs intForColumn:@"double"], 1);
        XCTAssertEqual([rs intForColumnIndex:2], 20);
        XCTAssertEqual([rs intForColumn:@"text"], 20);
        XCTAssertEqual([rs intForColumnIndex:3], 654);
        XCTAssertEqual([rs intForColumn:@"blob"], 654);
        XCTAssertEqual([rs intForColumnIndex:4], 0);
        XCTAssertEqual([rs intForColumn:@"null"], 0);
    }];
}

- (void)testLongValue
{
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        GRResultSet *rs = [self executeValuesQueryInDatabase:db];
        XCTAssert([rs next]);
        XCTAssertEqual([rs longForColumnIndex:0], 123);
        XCTAssertEqual([rs longForColumn:@"integer"], 123);
        XCTAssertEqual([rs longForColumnIndex:1], 1);
        XCTAssertEqual([rs longForColumn:@"double"], 1);
        XCTAssertEqual([rs longForColumnIndex:2], 20);
        XCTAssertEqual([rs longForColumn:@"text"], 20);
        XCTAssertEqual([rs longForColumnIndex:3], 654);
        XCTAssertEqual([rs longForColumn:@"blob"], 654);
        XCTAssertEqual([rs longForColumnIndex:4], 0);
        XCTAssertEqual([rs longForColumn:@"null"], 0);
    }];
}

- (void)testLongLongIntValue
{
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        GRResultSet *rs = [self executeValuesQueryInDatabase:db];
        XCTAssert([rs next]);
        XCTAssertEqual([rs longLongIntForColumnIndex:0], 123);
        XCTAssertEqual([rs longLongIntForColumn:@"integer"], 123);
        XCTAssertEqual([rs longLongIntForColumnIndex:1], 1);
        XCTAssertEqual([rs longLongIntForColumn:@"double"], 1);
        XCTAssertEqual([rs longLongIntForColumnIndex:2], 20);
        XCTAssertEqual([rs longLongIntForColumn:@"text"], 20);
        XCTAssertEqual([rs longLongIntForColumnIndex:3], 654);
        XCTAssertEqual([rs longLongIntForColumn:@"blob"], 654);
        XCTAssertEqual([rs longLongIntForColumnIndex:4], 0);
        XCTAssertEqual([rs longLongIntForColumn:@"null"], 0);
    }];
}

- (void)testUnsignedLongLongIntValue
{
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        GRResultSet *rs = [self executeValuesQueryInDatabase:db];
        XCTAssert([rs next]);
        XCTAssertEqual([rs unsignedLongLongIntForColumnIndex:0], 123);
        XCTAssertEqual([rs unsignedLongLongIntForColumn:@"integer"], 123);
        XCTAssertEqual([rs unsignedLongLongIntForColumnIndex:1], 1);
        XCTAssertEqual([rs unsignedLongLongIntForColumn:@"double"], 1);
        XCTAssertEqual([rs unsignedLongLongIntForColumnIndex:2], 20);
        XCTAssertEqual([rs unsignedLongLongIntForColumn:@"text"], 20);
        XCTAssertEqual([rs unsignedLongLongIntForColumnIndex:3], 654);
        XCTAssertEqual([rs unsignedLongLongIntForColumn:@"blob"], 654);
        XCTAssertEqual([rs unsignedLongLongIntForColumnIndex:4], 0);
        XCTAssertEqual([rs unsignedLongLongIntForColumn:@"null"], 0);
    }];
}

- (void)testBoolValue
{
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        GRResultSet *rs = [self executeValuesQueryInDatabase:db];
        XCTAssert([rs next]);
        XCTAssertEqual([rs boolForColumnIndex:0], YES);
        XCTAssertEqual([rs boolForColumn:@"integer"], YES);
        XCTAssertEqual([rs boolForColumnIndex:1], YES);
        XCTAssertEqual([rs boolForColumn:@"double"], YES);
        XCTAssertEqual([rs boolForColumnIndex:2], YES);
        XCTAssertEqual([rs boolForColumn:@"text"], YES);
        XCTAssertEqual([rs boolForColumnIndex:3], YES);
        XCTAssertEqual([rs boolForColumn:@"blob"], YES);
        XCTAssertEqual([rs boolForColumnIndex:4], NO);
        XCTAssertEqual([rs boolForColumn:@"null"], NO);
    }];
}

- (void)testDoubleValue
{
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        GRResultSet *rs = [self executeValuesQueryInDatabase:db];
        XCTAssert([rs next]);
        XCTAssertEqual([rs doubleForColumnIndex:0], 123.0);
        XCTAssertEqual([rs doubleForColumn:@"integer"], 123.0);
        XCTAssertEqual([rs doubleForColumnIndex:1], 1.5);
        XCTAssertEqual([rs doubleForColumn:@"double"], 1.5);
        XCTAssertEqual([rs doubleForColumnIndex:2], 20.0);
        XCTAssertEqual([rs doubleForColumn:@"text"], 20.0);
        XCTAssertEqual([rs doubleForColumnIndex:3], 654.0);
        XCTAssertEqual([rs doubleForColumn:@"blob"], 654.0);
        XCTAssertEqual([rs doubleForColumnIndex:4], 0.0);
        XCTAssertEqual([rs doubleForColumn:@"null"], 0.0);
    }];
}

- (void)testStringValue
{
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        GRResultSet *rs = [self executeValuesQueryInDatabase:db];
        XCTAssert([rs next]);
        XCTAssertEqualObjects([rs stringForColumnIndex:0], @"123");
        XCTAssertEqualObjects([rs stringForColumn:@"integer"], @"123");
        XCTAssertEqualObjects([rs stringForColumnIndex:1], @"1.5");
        XCTAssertEqualObjects([rs stringForColumn:@"double"], @"1.5");
        XCTAssertEqualObjects([rs stringForColumnIndex:2], @"20 little cigars");
        XCTAssertEqualObjects([rs stringForColumn:@"text"], @"20 little cigars");
        XCTAssertEqualObjects([rs stringForColumnIndex:3], @"654");
        XCTAssertEqualObjects([rs stringForColumn:@"blob"], @"654");
        XCTAssertNil([rs stringForColumnIndex:4]);
        XCTAssertNil([rs stringForColumn:@"null"]);
    }];
}

- (void)testDataValue
{
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        GRResultSet *rs = [self executeValuesQueryInDatabase:db];
        XCTAssert([rs next]);
        XCTAssertEqualObjects([rs dataForColumnIndex:0], [@"123" dataUsingEncoding:NSUTF8StringEncoding]);
        XCTAssertEqualObjects([rs dataForColumn:@"integer"], [@"123" dataUsingEncoding:NSUTF8StringEncoding]);
        XCTAssertEqualObjects([rs dataForColumnIndex:1], [@"1.5" dataUsingEncoding:NSUTF8StringEncoding]);
        XCTAssertEqualObjects([rs dataForColumn:@"double"], [@"1.5" dataUsingEncoding:NSUTF8StringEncoding]);
        XCTAssertEqualObjects([rs dataForColumnIndex:2], [@"20 little cigars" dataUsingEncoding:NSUTF8StringEncoding]);
        XCTAssertEqualObjects([rs dataForColumn:@"text"], [@"20 little cigars" dataUsingEncoding:NSUTF8StringEncoding]);
        XCTAssertEqualObjects([rs dataForColumnIndex:3], [@"654" dataUsingEncoding:NSUTF8StringEncoding]);
        XCTAssertEqualObjects([rs dataForColumn:@"blob"], [@"654" dataUsingEncoding:NSUTF8StringEncoding]);
        XCTAssertNil([rs dataForColumnIndex:4]);
        XCTAssertNil([rs dataForColumn:@"null"]);
    }];
}

- (void)testDataNoCopyValue
{
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        GRResultSet *rs = [self executeValuesQueryInDatabase:db];
        XCTAssert([rs next]);
        XCTAssertEqualObjects([rs dataNoCopyForColumnIndex:0], [@"123" dataUsingEncoding:NSUTF8StringEncoding]);
        XCTAssertEqualObjects([rs dataNoCopyForColumn:@"integer"], [@"123" dataUsingEncoding:NSUTF8StringEncoding]);
        XCTAssertEqualObjects([rs dataNoCopyForColumnIndex:1], [@"1.5" dataUsingEncoding:NSUTF8StringEncoding]);
        XCTAssertEqualObjects([rs dataNoCopyForColumn:@"double"], [@"1.5" dataUsingEncoding:NSUTF8StringEncoding]);
        XCTAssertEqualObjects([rs dataNoCopyForColumnIndex:2], [@"20 little cigars" dataUsingEncoding:NSUTF8StringEncoding]);
        XCTAssertEqualObjects([rs dataNoCopyForColumn:@"text"], [@"20 little cigars" dataUsingEncoding:NSUTF8StringEncoding]);
        XCTAssertEqualObjects([rs dataNoCopyForColumnIndex:3], [@"654" dataUsingEncoding:NSUTF8StringEncoding]);
        XCTAssertEqualObjects([rs dataNoCopyForColumn:@"blob"], [@"654" dataUsingEncoding:NSUTF8StringEncoding]);
        XCTAssertNil([rs dataNoCopyForColumnIndex:4]);
        XCTAssertNil([rs dataNoCopyForColumn:@"null"]);
    }];
}

- (void)testObjectValue
{
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        GRResultSet *rs = [self executeValuesQueryInDatabase:db];
        XCTAssert([rs next]);
        {
            NSNumber *value = [rs objectForColumnIndex:0];
            XCTAssert([value isKindOfClass:[NSNumber class]]);
            XCTAssert(strcmp([value objCType], @encode(sqlite3_int64)) == 0);
            XCTAssertEqual([value integerValue], 123);
        }
        {
            NSNumber *value = [rs objectForColumn:@"integer"];
            XCTAssert([value isKindOfClass:[NSNumber class]]);
            XCTAssert(strcmp([value objCType], @encode(sqlite3_int64)) == 0);
            XCTAssertEqual([value integerValue], 123);
        }
        {
            NSNumber *value = [rs objectForColumnIndex:1];
            XCTAssert([value isKindOfClass:[NSNumber class]]);
            XCTAssert(strcmp([value objCType], @encode(double)) == 0);
            XCTAssertEqual([value doubleValue], 1.5);
        }
        {
            NSNumber *value = [rs objectForColumn:@"double"];
            XCTAssert([value isKindOfClass:[NSNumber class]]);
            XCTAssert(strcmp([value objCType], @encode(double)) == 0);
            XCTAssertEqual([value doubleValue], 1.5);
        }
        {
            NSString *value = [rs objectForColumnIndex:2];
            XCTAssert([value isKindOfClass:[NSString class]]);
            XCTAssertEqualObjects(value, @"20 little cigars");
        }
        {
            NSString *value = [rs objectForColumn:@"text"];
            XCTAssert([value isKindOfClass:[NSString class]]);
            XCTAssertEqualObjects(value, @"20 little cigars");
        }
        {
            NSData *value = [rs objectForColumnIndex:3];
            XCTAssert([value isKindOfClass:[NSData class]]);
            XCTAssertEqualObjects(value, [@"654" dataUsingEncoding:NSUTF8StringEncoding]);
        }
        {
            NSData *value = [rs objectForColumn:@"blob"];
            XCTAssert([value isKindOfClass:[NSData class]]);
            XCTAssertEqualObjects(value, [@"654" dataUsingEncoding:NSUTF8StringEncoding]);
        }
        XCTAssertNil([rs objectForColumnIndex:4]);
        XCTAssertNil([rs objectForColumn:@"null"]);
    }];
}

- (void)testIndexedSubscript
{
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        GRResultSet *rs = [self executeValuesQueryInDatabase:db];
        XCTAssert([rs next]);
        {
            NSNumber *value = rs[0];
            XCTAssert([value isKindOfClass:[NSNumber class]]);
            XCTAssert(strcmp([value objCType], @encode(sqlite3_int64)) == 0);
            XCTAssertEqual([value integerValue], 123);
        }
        {
            NSNumber *value = rs[1];
            XCTAssert([value isKindOfClass:[NSNumber class]]);
            XCTAssert(strcmp([value objCType], @encode(double)) == 0);
            XCTAssertEqual([value doubleValue], 1.5);
        }
        {
            NSString *value = rs[2];
            XCTAssert([value isKindOfClass:[NSString class]]);
            XCTAssertEqualObjects(value, @"20 little cigars");
        }
        {
            NSData *value = rs[3];
            XCTAssert([value isKindOfClass:[NSData class]]);
            XCTAssertEqualObjects(value, [@"654" dataUsingEncoding:NSUTF8StringEncoding]);
        }
        XCTAssertNil(rs[4]);
    }];
}

- (void)testKeyedSubscript
{
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        GRResultSet *rs = [self executeValuesQueryInDatabase:db];
        XCTAssert([rs next]);
        {
            NSNumber *value = rs[@"integer"];
            XCTAssert([value isKindOfClass:[NSNumber class]]);
            XCTAssert(strcmp([value objCType], @encode(sqlite3_int64)) == 0);
            XCTAssertEqual([value integerValue], 123);
        }
        {
            NSNumber *value = rs[@"double"];
            XCTAssert([value isKindOfClass:[NSNumber class]]);
            XCTAssert(strcmp([value objCType], @encode(double)) == 0);
            XCTAssertEqual([value doubleValue], 1.5);
        }
        {
            NSString *value = rs[@"text"];
            XCTAssert([value isKindOfClass:[NSString class]]);
            XCTAssertEqualObjects(value, @"20 little cigars");
        }
        {
            NSData *value = rs[@"blob"];
            XCTAssert([value isKindOfClass:[NSData class]]);
            XCTAssertEqualObjects(value, [@"654" dataUsingEncoding:NSUTF8StringEncoding]);
        }
        XCTAssertNil(rs[@"null"]);
    }];
}

- (void)testResultDictionary
{
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        GRResultSet *rs = [self executeValuesQueryInDatabase:db];
        XCTAssertNil(rs.resultDictionary);
        XCTAssert([rs next]);
        NSDictionary *dict = rs.resultDictionary;
        {
            NSNumber *value = dict[@"integer"];
            XCTAssert([value isKindOfClass:[NSNumber class]]);
            XCTAssert(strcmp([value objCType], @encode(sqlite3_int64)) == 0);
            XCTAssertEqual([value integerValue], 123);
        }
        {
            NSNumber *value = dict[@"double"];
            XCTAssert([value isKindOfClass:[NSNumber class]]);
            XCTAssert(strcmp([value objCType], @encode(double)) == 0);
            XCTAssertEqual([value doubleValue], 1.5);
        }
        {
            NSString *value = dict[@"text"];
            XCTAssert([value isKindOfClass:[NSString class]]);
            XCTAssertEqualObjects(value, @"20 little cigars");
        }
        {
            NSData *value = dict[@"blob"];
            XCTAssert([value isKindOfClass:[NSData class]]);
            XCTAssertEqualObjects(value, [@"654" dataUsingEncoding:NSUTF8StringEncoding]);
        }
        XCTAssertEqual(dict[@"null"], [NSNull null]);
        XCTAssertFalse([rs next]);
        XCTAssertNil(rs.resultDictionary);
    }];
}

- (void)testResultDictionaryCompatibilityWithFMDB
{
    // This is a FMDB compatibility test
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        GRResultSet *rs = [db executeQuery:@"SELECT 1 AS foo, 2 AS foo, 3 AS FOO"];
        XCTAssert([rs next]);
        NSDictionary *dict = rs.resultDictionary;
        XCTAssertEqualObjects(dict[@"foo"], @(1)); // Compatibility warning: leftmost value. FMDB would have returned 2 instead.
        XCTAssertEqualObjects(dict[@"FOO"], @(3));
    }];
}

- (void)testNext
{
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a, b)"];
        [db executeUpdate:@"INSERT INTO t(a, b) VALUES (1, 2)"];
        [db executeUpdate:@"INSERT INTO t(a, b) VALUES (3, 4)"];
        
        GRResultSet *rs = [db executeQuery:@"SELECT a, b FROM t"];
        XCTAssertNotNil(rs);
        
        XCTAssert([rs next]);
        XCTAssertEqual([rs intForColumnIndex:0], 1);
        XCTAssertEqual([rs intForColumnIndex:1], 2);
        
        XCTAssert([rs next]);
        XCTAssertEqual([rs intForColumnIndex:0], 3);
        XCTAssertEqual([rs intForColumnIndex:1], 4);
        
        XCTAssertFalse([rs next]);
        XCTAssertFalse([rs next]);
    }];
}

- (void)testClose
{
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(a)"];
        [db executeUpdate:@"INSERT INTO t(a) VALUES (1)"];
        [db executeUpdate:@"INSERT INTO t(a) VALUES (3)"];
        
        GRResultSet *rs = [db executeQuery:@"SELECT a FROM t"];
        XCTAssertNotNil(rs);
        
        XCTAssert([rs next]);
        [rs close];
        XCTAssertFalse([rs next]);
        XCTAssertFalse([rs next]);
    }];
}

- (void)testColumnIndexForName
{
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        GRResultSet *rs = [db executeQuery:@"SELECT 1 AS foo, 2 AS bar, 3 AS bar"];
        XCTAssertNotNil(rs);
        XCTAssertEqual([rs columnIndexForName:@"foo"], 0);
        XCTAssertEqual([rs columnIndexForName:@"FOO"], 0);
        XCTAssertEqual([rs columnIndexForName:@"Bar"], 1); // Compatibility warning: leftmost value. FMDB would have returned 2 instead.
        XCTAssertEqual([rs columnIndexForName:@"missing"], -1);
    }];
}

- (void)testColumnNameIsCaseInsensitive
{
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        [db executeUpdate:@"CREATE TABLE t(InTeGeR)"];
        [db executeUpdate:@"INSERT INTO t(InTeGeR) VALUES (123)"];
        
        GRResultSet *rs = [db executeQuery:@"SELECT integer FROM t"];
        XCTAssertNotNil(rs);
        XCTAssert([rs next]);
        XCTAssertEqual([rs intForColumn:@"integer"], 123);
        XCTAssertEqual([rs intForColumn:@"INTEGER"], 123);
        XCTAssertEqual([rs intForColumn:@"INTeger"], 123);
    }];
}

@end
