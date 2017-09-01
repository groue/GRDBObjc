#import "GRDBObjcTestCase.h"

@interface NSDateTests : GRDBObjcTestCase

@end

@implementation NSDateTests

- (void)testSaveDefaultDate
{
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        XCTAssertFalse([db hasDateFormatter]);
        
        [db executeUpdate:@"CREATE TABLE dates(date DATETIME)"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:2.5];
        
        NSError *error;
        BOOL success = [db executeUpdate:@"INSERT INTO dates(date) VALUES (?)" values: @[date] error:&error];
        XCTAssert(success, @"%@", error);
        
        GRResultSet *rs = [db executeQuery:@"SELECT date FROM dates"];
        XCTAssertNotNil(rs);
        XCTAssert([rs next]);
        
        NSTimeInterval timeInterval = [rs doubleForColumnIndex:0];
        XCTAssertEqual(timeInterval, 2.5);
        
        NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        calendar.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
        
        date = [rs dateForColumnIndex:0];
        XCTAssertNotNil(date);
        XCTAssertEqual([date timeIntervalSince1970], 2.5);
        
        date = [rs dateForColumn:@"date"];
        XCTAssertNotNil(date);
        XCTAssertEqual([date timeIntervalSince1970], 2.5);
    }];
}

- (void)testSaveDateWithFormat
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
    GRDatabaseQueue *dbQueue = [GRDatabaseQueue databaseQueueWithPath:[self makeTemporaryDatabasePath] error:NULL];
    [dbQueue inDatabase:^(GRDatabase *db) {
        [db setDateFormat:[GRDatabase storeableDateFormat:@"YYYY-MM-DD"]];
        XCTAssertTrue([db hasDateFormatter]);

        [db executeUpdate:@"CREATE TABLE dates(date DATETIME)"];
        NSError *error;
        BOOL success = [db executeUpdate:@"INSERT INTO dates(date) VALUES (?)" values: @[date] error:&error];
        XCTAssert(success, @"%@", error);
        
        GRResultSet *rs = [db executeQuery:@"SELECT date FROM dates"];
        XCTAssertNotNil(rs);
        XCTAssert([rs next]);
        
        NSString *string = [rs stringForColumnIndex:0];
        XCTAssertEqualObjects(string, @"1970-01-01");
        
        NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        calendar.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
        
        NSDate *fetchedDate = [rs dateForColumnIndex:0];
        XCTAssertNotNil(fetchedDate);
        XCTAssertEqual([fetchedDate timeIntervalSince1970], 0);

        fetchedDate = [rs dateForColumn:@"date"];
        XCTAssertNotNil(fetchedDate);
        XCTAssertEqual([fetchedDate timeIntervalSince1970], 0);
    }];
    
    // Check dateformat is still there
    [dbQueue inDatabase:^(GRDatabase *db) {
        XCTAssertTrue([db hasDateFormatter]);
        
        GRResultSet *rs = [db executeQuery:@"SELECT date FROM dates"];
        XCTAssertNotNil(rs);
        XCTAssert([rs next]);
        
        NSString *string = [rs stringForColumnIndex:0];
        XCTAssertEqualObjects(string, @"1970-01-01");
        
        NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        calendar.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
        
        NSDate *fetchedDate = [rs dateForColumnIndex:0];
        XCTAssertNotNil(fetchedDate);
        XCTAssertEqual([fetchedDate timeIntervalSince1970], 0);
        
        fetchedDate = [rs dateForColumn:@"date"];
        XCTAssertNotNil(fetchedDate);
        XCTAssertEqual([fetchedDate timeIntervalSince1970], 0);
    }];

}

@end
