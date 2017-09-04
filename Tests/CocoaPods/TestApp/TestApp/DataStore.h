// DataStore exposes a FMDB-compatible dbQueue to both Objective-C and Swift.

#import <Foundation/Foundation.h>
#import <GRDBObjc/GRDBObjc.h>

@interface DataStore : NSObject
+ (void)setupDatabaseAtPath:(NSString * _Nonnull)path;
+ (FMDatabaseQueue * _Nonnull)dbQueue NS_REFINED_FOR_SWIFT;
@end
