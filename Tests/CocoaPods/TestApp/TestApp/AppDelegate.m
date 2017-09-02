// AppDelegate sets up the database at application startup, using the
// +[DataStore setupDatabaseAtPath:] method.

#import "AppDelegate.h"
#import "DataStore.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dbPath = [documentsPath stringByAppendingPathComponent:@"db.sqlite"];
    [DataStore setupDatabaseAtPath:dbPath];
    return YES;
}

@end
