#import <sqlite3.h>
#import "FMResultSet+Objc.h"

@implementation FMResultSet (Objc)

- (id)objectForColumnName:(NSString*)columnName {
    return [self objectForColumn:columnName];
}

@end
