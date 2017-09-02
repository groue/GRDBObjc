// AppDelegate sets up the database at application startup, using the
// +[AppDatabase setupDatabaseAtPath:] method.

#import "AppDelegate.h"
#import "AppDatabase.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dbPath = [documentsPath stringByAppendingPathComponent:@"db.sqlite"];
    [AppDatabase setupDatabaseAtPath:dbPath];
    return YES;
}

@end
