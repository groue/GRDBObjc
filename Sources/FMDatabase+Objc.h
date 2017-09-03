#import <GRDBObjc/GRDBObjc-Swift.h>

// Here we define variadics methods that Swift can't handle
@interface FMDatabase(Objc)
- (BOOL)executeUpdate:(NSString * _Nonnull)sql, ...;
- (BOOL)executeUpdate:(NSString * _Nonnull)sql withErrorAndBindings:(NSError * _Nullable * _Nullable)outErr, ...;
- (FMResultSet * _Nullable)executeQuery:(NSString*)sql, ...;
@end
