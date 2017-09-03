@import XCTest;
#import <GRDBObjc/GRDBObjc.h>
#import <GRDBObjc/GRDBObjc-Swift.h>
#import <GRDBObjc/GRDBObjc-Objc.h>

@interface GRDBObjcTestCase : XCTestCase
- (NSString * _Nonnull)makeTemporaryDatabasePath;
@end
