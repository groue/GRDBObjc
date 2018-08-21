#import <sqlite3.h>
#import "FMDatabase+Objc.h"

@implementation FMDatabase(Objc)

- (BOOL)executeUpdate:(NSString *)sql withErrorAndBindings:(NSError **)outErr, ...
{
    va_list args;
    va_start(args, outErr);
    BOOL success = [self executeUpdate:sql va_list:args error:outErr];
    va_end(args);
    return success;
}

- (BOOL)executeUpdate:(NSString * _Nonnull)sql, ...
{
    va_list args;
    va_start(args, sql);
    BOOL success = [self executeUpdate:sql va_list:args error:NULL];
    va_end(args);
    return success;
}

- (BOOL)executeUpdate:(NSString * _Nonnull)sql va_list:(va_list)args error:(NSError **)outErr;
{
    BOOL result = NO;
    NSError *error = nil;
    
    // @autoreleasepool asserts intermediate GRDB values are deinited on the
    // current (correct) thread.
    @autoreleasepool {
        _FMUpdateStatement *statement = [self _makeUpdateStatement:sql error:&error];
        if (statement) {
            NSMutableArray *arguments = [NSMutableArray array];
            for(int i = sqlite3_bind_parameter_count(statement.sqliteHandle); i > 0; i--) {
                id obj = va_arg(args, id);
                [arguments addObject:obj ?: [NSNull null]];
            }
            result = [statement executeWithValues:arguments error:&error];
        }
    }
    
    if (result) { return result; }
    NSParameterAssert(error);
    if (outErr != NULL) { *outErr = error; }
    return NO;
}

- (FMResultSet * _Nullable)executeQuery:(NSString * _Nonnull)sql, ...
{
    va_list args;
    va_start(args, sql);
    FMResultSet *resultSet = [self executeQuery:sql va_list:args error:NULL];
    va_end(args);
    return resultSet;
}

- (FMResultSet * _Nullable)executeQuery:(NSString * _Nonnull)sql va_list:(va_list)args error:(NSError **)outErr;
{
    FMResultSet *result = nil;
    NSError *error = nil;
    
    // @autoreleasepool asserts intermediate GRDB values are deinited on the
    // current (correct) thread.
    @autoreleasepool {
        _FMSelectStatement *statement = [self _makeSelectStatement:sql error:&error];
        if (statement) {
            NSMutableArray *arguments = [NSMutableArray array];
            for(int i = sqlite3_bind_parameter_count(statement.sqliteHandle); i > 0; i--) {
                id obj = va_arg(args, id);
                [arguments addObject:obj ?: [NSNull null]];
            }
            result = [statement executeWithValues:arguments error:&error];
        }
    }
    
    if (result) { return result; }
    NSParameterAssert(error);
    if (outErr != NULL) { *outErr = error; }
    return nil;
}

@end
