#import <sqlite3.h>
#import "FMDatabase+Objc.h"

@implementation FMDatabase(Objc)

- (BOOL)executeUpdate:(NSString *)sql withErrorAndBindings:(NSError **)outErr, ...
{
    va_list args;
    va_start(args, outErr);
    BOOL result = [self executeUpdate:sql va_list:args error:outErr];
    va_end(args);
    return result;
}

- (BOOL)executeUpdate:(NSString * _Nonnull)sql, ...
{
    va_list args;
    va_start(args, sql);
    BOOL result = [self executeUpdate:sql va_list:args error:NULL];
    va_end(args);
    return result;
}

- (BOOL)executeUpdate:(NSString * _Nonnull)sql va_list:(va_list)args error:(NSError **)outErr;
{
    FMUpdateStatement *statement = [self __makeUpdateStatement:sql error:outErr];
    if (!statement) {
        return NO;
    }
    
    NSMutableArray *arguments = [NSMutableArray array];
    for(int i = sqlite3_bind_parameter_count(statement.sqliteHandle); i > 0; i--) {
        id obj = va_arg(args, id);
        [arguments addObject:obj ?: [NSNull null]];
    }
    return [statement executeWithValues:arguments error:outErr];
}

@end
