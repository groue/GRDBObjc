#import "GRDBObjcTestCase.h"

@interface GRDatabaseQueueTests : GRDBObjcTestCase
@end

@implementation GRDatabaseQueueTests

- (void)assertBasicFunctionnalityInDatabaseQueue:(GRDatabaseQueue *)dbQueue
{
    NSParameterAssert(dbQueue);
    [dbQueue inDatabase:^(GRDatabase *db) {
        NSError *error;
        BOOL success = [db executeUpdate:@"CREATE TABLE t(a)" values:nil error:&error];
        XCTAssert(success, "%@", error);
        success = [db executeUpdate:@"INSERT INTO t(a) VALUES (123)" values:nil error:&error];
        XCTAssert(success, "%@", error);
        GRResultSet *resultSet = [db executeQuery:@"SELECT a FROM T" values:nil error:&error];
        XCTAssertNotNil(resultSet, "%@", error);
        int fetchedInt = 0;
        while ([resultSet next]) {
            fetchedInt = [resultSet intForColumnIndex:0];
        }
        XCTAssertEqual(fetchedInt, 123);
    }];
}

- (void)testMemoryInitializer {
    GRDatabaseQueue *dbQueue = [[GRDatabaseQueue alloc] init];
    [self assertBasicFunctionnalityInDatabaseQueue:dbQueue];
}

- (void)testPathInitializer {
    NSString *initPath = [self makeTemporaryDatabasePath];
    NSError *error;
    GRDatabaseQueue *dbQueue = [[GRDatabaseQueue alloc] initWithPath:initPath error:&error];
    XCTAssertNotNil(dbQueue, "%@", error);
    [self assertBasicFunctionnalityInDatabaseQueue:dbQueue];
}

- (void)testPathOfDiskDatabase {
    NSString *initPath = [self makeTemporaryDatabasePath];
    GRDatabaseQueue *dbQueue = [[GRDatabaseQueue alloc] initWithPath:initPath error:NULL];
    NSString *path = dbQueue.path;
    XCTAssertEqualObjects(path, initPath);
}

@end
