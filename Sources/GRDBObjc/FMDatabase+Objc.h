#import <Foundation/Foundation.h>
#import <GRDBObjcCore/GRDBObjcCore-Swift.h>

// Here we define variadics methods that Swift can't handle
@interface FMDatabase(Objc)
- (BOOL)executeUpdate:(NSString * _Nonnull)sql, ...;
- (BOOL)executeUpdate:(NSString * _Nonnull)sql withErrorAndBindings:(NSError * _Nullable * _Nullable)outErr, ...;
- (FMResultSet * _Nullable)executeQuery:(NSString * _Nonnull)sql, ...;
@end
