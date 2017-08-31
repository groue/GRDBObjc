#import "GRDBObjcTestCase.h"

static NSString *const sandboxPath = @"/tmp/GRDBObjcTestCase";

@implementation GRDBObjcTestCase

- (NSString *)makeTemporaryDatabasePath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *directoryPath = [sandboxPath stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
    NSError *error;
    if (![fm createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error]) {
        [NSException raise:NSInternalInconsistencyException format:@"Could not create database directory: %@", error];
        return nil;
    }
    return [directoryPath stringByAppendingPathComponent:@"db.sqlite"];
}

- (void)tearDown
{
    [super tearDown];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:sandboxPath]) {
        NSError *error;
        BOOL success = [fm removeItemAtPath:sandboxPath error:&error];
        XCTAssert(success, "%@", error);
    }
}

@end
