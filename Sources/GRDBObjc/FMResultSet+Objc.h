#import <Foundation/Foundation.h>
#import <GRDBObjcCore/GRDBObjcCore-Swift.h>

@interface FMResultSet(Objc)
- (id _Nullable)objectForColumnName:(NSString * _Nonnull)columnName __deprecated_msg("Use objectForColumn instead");
@end
