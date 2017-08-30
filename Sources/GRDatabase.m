//#import <sqlite3.h>
//#import "GRDatabase.h"
//
//@implementation GRDatabase(Objc)
//
//- (BOOL)executeUpdate:(NSString *)sql withErrorAndBindings:(NSError **)outErr, ...
//{
//    GRUpdateStatement *statement = [self __makeUpdateStatement:sql error:outErr];
//    if (!statement) {
//        return NO;
//    }
//
//    va_list args;
//    va_start(args, outErr);
//    NSMutableArray *arguments = [NSMutableArray array];
//    for(int i = sqlite3_bind_parameter_count(statement.sqliteHandle); i >= 0; i--) {
//        id obj = va_arg(args, id);
//        [arguments addObject:obj];
//    }
//    va_end(args);
//
//    return [statement executeWithValues:arguments error:outErr];
//}
//
//@end

