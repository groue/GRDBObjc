GRDBObjc [![Swift](https://img.shields.io/badge/swift-4-orange.svg?style=flat)](https://developer.apple.com/swift/) [![License](https://img.shields.io/github/license/RxSwiftCommunity/RxGRDB.svg?maxAge=2592000)](/LICENSE)
========

### FMDB-compatible bindings to GRDB.swift.

GRDBObjc helps Objective-C applications that use SQLite replace [FMDB](http://github.com/ccgus/fmdb) with [GRDB](http://github.com/groue/GRDB.swift), at minimal cost.

**Requirements**: iOS 8.0+ / OSX 10.10+ / watchOS 2.0+ • Xcode 9+ • Swift 4

---

<p align="center">
    <a href="#installation">Installation</a> &bull;
    <a href="#fmdb-compatibility-chart">FMDB Compatibility Chart</a>
</p>

---


### Indulge yourself with a little Swift

It happens that we developers maintain and develop Objective-C applications, and wish you could inject more and more Swift into them.

This happens when rewriting a whole application from scratch is not a reasonable option, and yet the expressivity and safety of Swift has an intense appeal. We preserve the legacy Objective-C code that represents years of development, experience, bug hunting and tests, and use Swift in new and isolated features that can easily be plugged on to the Objective-C body.

Such a mixed application has an Objective-C trunk, and a few Swift leaves. Those Swift add-ons are sometimes hampered by their foreign foundations, which may not look very Swifty. Maybe we dream of Swift alternatives that offer superior solutions.


### FMDB in a Swift World

We at [Pierlis](http://pierlis.com) feel this quite badly with FMDB. FMDB does a perfect job, but GRDB has a lot of advantages over it. When GRDB speaks SQL just as well as its venerable precursor, and offers the same robust concurrency guarantees, the Swift toolkit adds features such as database observation and support for record types that are nowhere to be seen with FMDB.

For example, compare two equivalent code snippets that load an array of application models:

```swift
// GRDB
struct Player: RowConvertible {
    init(row: Row) { ... }
}

func fetchPlayers(dbQueue: DatabaseQueue) throws -> [Player] {
    return try dbQueue.inDatabase { db in
        try Player.fetchAll(db, "SELECT * FROM players")
    }
}

// FMDB
struct Player {
    init(dictionary: [AnyHashable: Any]) { ... }
}

func fetchPlayers(dbQueue: FMDatabaseQueue) throws -> [Player] {
    var fetchError: Error? = nil
    var players = [Player]()
    dbQueue.inDatabase { db in
        do {
            let rs = try db.executeQuery("SELECT * FROM players", values: nil)
            while rs.next() {
                let player = Player(dictionary: rs.resultDictionary!)
                players.append(player)
            }
        } catch {
            fetchError = error
        }
    }
    if let fetchError = fetchError {
        throw fetchError
    }
    return players
}
```

You may think: "I never use FMDB like that!". Indeed error handling makes FMDB such a pain to read that barely nobody does it. And yet robustness is what eventually allows your application to run safely in the background on a locked device, when necessary. GRDB is concise, won't miss any error, and yet runs the code above [much faster](https://github.com/groue/GRDB.swift/wiki/Performance) than FMDB.


### Going Further with GRDB

[Database observation](https://github.com/groue/GRDB.swift#database-changes-observation) is another feature that will save you the hours developing it on top of FMDB. GRDB comes with high-level tools such as [FetchedRecordsController](https://github.com/groue/GRDB.swift#fetchedrecordscontroller), and the companion library [RxGRDB](http://github.com/RxSwiftCommunity/RxGRDB) which lets you observe database changes in the reactive way. Observation happens at the SQLite level, which means that it won't be fooled by raw SQL updates, foreign key cascades, and SQL triggers. Don't miss a single commit:

```swift
let request = SQLRequest(
    "SELECT * FROM players ORDER BY score DESC LIMIT 10")
    .asRequest(of: Player.self)

request.rx.fetchAll(in: dbQueue)
    .subscribe(onNext: { players: [Player] in
        print("Players have changed")
    })
```


### GRDBObjc is the glue between GRDB and your Objective-C code that targets FMDB

One can not simply install FMDB along with GRDB in the same application, and have Objective-C code target FMDB while new Swift code uses GRDB. This won't work well because SQLite won't let two distinct connections write in the database at the same time. Instead, it will fail with an SQLITE_BUSY error as soon as an Objective-C thread and a Swift thread happen to modify the database concurrently. Think of a download operation that completes as the user is editing some value.

Enter GRDBObjc. Very often, all you will have to do is remove FMDB, install GRDB and GRDBObjc, and replace `#import` directives:

```diff
-#import <fmdb/FMDB.h>
+#import <GRDBObjc/GRDBObjc.h>
+#import <GRDBObjc/GRDBObjc-Swift.h>
```

This is enough for most of your Objective-C code that targets FMDB to compile on top of GRDB and GRDBObjc. Of course, the devil is in the detail, and we'll list below a detailed [compatibility chart](#fmdb-compatibility-chart).

The `FMDatabaseQueue`, `FMResultSet`, etc. identifiers are now aliases to GRDBObjc's `GRDatabaseQueue`, `GRResultSet` that are backed by GRDB. The databases initialized from Objective-C are usable from Swift, with the full GRDB toolkit. For example:

```objc
#import <GRDBObjc/GRDBObjc.h>
#import <GRDBObjc/GRDBObjc-Swift.h>

@interface DataStore
@property (nonatomic, nonnull) FMDatabaseQueue* dbQueue NS_REFINED_FOR_SWIFT;
@end

@implementation DataStore
- (void)setupDatabase {
    self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:...];
}
@end
```

```swift
import GRDB
import GRDBObjc

extension DataStore {
    var dbQueue: DatabaseQueue {
        return __dbQueue.dbQueue
    }
}
```


### Installation

TODO

### FMDB Compatibility Chart

GRDB and FMDB usually behave exactly in the same manner. When there are slight differences, GRDBObjc generally favors FMDB compatibility over native GRDB behavior.

Yet some FMDB features have not yet been ported to GRDBObjc. This includes support for custom SQL functions, for example.

Finally, some FMDB features are simply unavailable. For example, GRDBObjc won't let you create a naked FMDatabase. To access the database, you must use a FMDatabaseQueue.

We'll list all FMDB methods below. Each of them will be either:

- Available with full compatibility
- Available with compatiblity warning
- Not available yet (pull requests are welcome)
- Not available and replaced with another method
- Not available and requiring GRDB modifications
- Not available without any hope for eventual support

#### FMDatabase

- Available with full compatibility
    
    ```objc
    // Properties
    @property (nonatomic, readonly) void *sqliteHandle;
    
    // Perform updates
    @property (nonatomic, readonly) int64_t lastInsertRowId;
    @property (nonatomic, readonly) int changes;
    - (BOOL)executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments;
    - (BOOL)executeUpdate:(NSString*)sql values:(NSArray * _Nullable)values error:(NSError * _Nullable __autoreleasing *)error;
    - (BOOL)executeUpdate:(NSString*)sql withParameterDictionary:(NSDictionary *)arguments;
    
    // Retrieving results
    - (FMResultSet * _Nullable)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments;
    - (FMResultSet * _Nullable)executeQuery:(NSString *)sql values:(NSArray * _Nullable)values error:(NSError * _Nullable __autoreleasing *)error;
    - (FMResultSet * _Nullable)executeQuery:(NSString *)sql withParameterDictionary:(NSDictionary * _Nullable)arguments;
    
    /// Retrieving error codes
    - (NSError *)lastError;
    
    // Save points
    - (NSError * _Nullable)inSavePoint:(__attribute__((noescape)) void (^)(BOOL *rollback))block;
    ```
    
- Available with compatiblity warning
    
    ```objc
    // The isInTransaction property reflects actual SQLite state instead
    // of relying on the balance of beginTransaction/commit/rollback
    // methods. Some transaction errors will thus have FMDB return
    // true when GRDBObjc returns false.
    @property (nonatomic, readonly) BOOL isInTransaction;
    ```
    
- Not available yet (pull requests are welcome)
    
    ```objc
    + (NSString*)sqliteLibVersion;
    + (BOOL)isSQLiteThreadSafe;
    
    // Properties
    @property (atomic, assign) BOOL traceExecution;
    @property (atomic, assign) BOOL logsErrors;
    @property (nonatomic, readonly) BOOL goodConnection;
    @property (nonatomic, readonly, nullable) NSString *databasePath;
    @property (nonatomic, readonly, nullable) NSURL *databaseURL;
    @property (nonatomic) NSTimeInterval maxBusyRetryTimeInterval;
    
    // Perform updates
    - (BOOL)executeUpdate:(NSString*)sql withErrorAndBindings:(NSError * _Nullable *)outErr, ...;
    - (BOOL)executeUpdate:(NSString*)sql, ...;
    - (BOOL)executeUpdateWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
    - (BOOL)executeUpdate:(NSString*)sql withVAList: (va_list)args;
    - (BOOL)executeStatements:(NSString *)sql;
    - (BOOL)executeStatements:(NSString *)sql withResultBlock:(__attribute__((noescape)) FMDBExecuteStatementsCallbackBlock _Nullable)block;
    
    // Retrieving results
    - (FMResultSet * _Nullable)executeQuery:(NSString*)sql, ...;
    - (FMResultSet * _Nullable)executeQueryWithFormat:(NSString*)format, ... NS_FORMAT_FUNCTION(1,2);
    - (FMResultSet * _Nullable)executeQuery:(NSString *)sql withVAList:(va_list)args;
    
    // Transactions
    - (BOOL)beginTransaction;
    - (BOOL)beginDeferredTransaction;
    - (BOOL)commit;
    - (BOOL)rollback;
    
    // Cached statements and result sets
    @property (nonatomic) BOOL shouldCacheStatements;
    @property (atomic, retain, nullable) NSMutableDictionary *cachedStatements;
    - (void)clearCachedStatements;    
    - (BOOL)interrupt;
    
    // Encryption methods
    - (BOOL)setKey:(NSString*)key;
    - (BOOL)rekey:(NSString*)key;
    - (BOOL)setKeyWithData:(NSData *)keyData;
    - (BOOL)rekeyWithData:(NSData *)keyData;
    
    // Retrieving error codes
    @property (atomic, assign) BOOL crashOnErrors;
    - (NSString*)lastErrorMessage;
    - (int)lastErrorCode;
    - (int)lastExtendedErrorCode;
    - (BOOL)hadError;
    
    // Save points
    - (BOOL)startSavePointWithName:(NSString*)name error:(NSError * _Nullable *)outErr;
    - (BOOL)releaseSavePointWithName:(NSString*)name error:(NSError * _Nullable *)outErr;
    - (BOOL)rollbackToSavePointWithName:(NSString*)name error:(NSError * _Nullable *)outErr;
    
    // Make SQL function
    - (void)makeFunctionNamed:(NSString *)name arguments:(int)arguments block:(void (^)(void *context, int argc, void * _Nonnull * _Nonnull argv))block;
    - (void)makeFunctionNamed:(NSString *)name maximumArguments:(int)count withBlock:(void (^)(void *context, int argc, void * _Nonnull * _Nonnull argv))block __deprecated_msg("Use makeFunctionNamed:arguments:block:");
    - (SqliteValueType)valueType:(void *)argv;
    - (int)valueInt:(void *)value;
    - (long long)valueLong:(void *)value;
    - (double)valueDouble:(void *)value;
    - (NSData * _Nullable)valueData:(void *)value;
    - (NSString * _Nullable)valueString:(void *)value;
    - (void)resultNullInContext:(void *)context NS_SWIFT_NAME(resultNull(context:));
    - (void)resultInt:(int) value context:(void *)context;
    - (void)resultLong:(long long)value context:(void *)context;
    - (void)resultDouble:(double)value context:(void *)context;
    - (void)resultData:(NSData *)data context:(void *)context;
    - (void)resultString:(NSString *)value context:(void *)context;
    - (void)resultError:(NSString *)error context:(void *)context;
    - (void)resultErrorCode:(int)errorCode context:(void *)context;
    - (void)resultErrorNoMemoryInContext:(void *)context NS_SWIFT_NAME(resultErrorNoMemory(context:));
    - (void)resultErrorTooBigInContext:(void *)context NS_SWIFT_NAME(resultErrorTooBig(context:));
    ```
    
- Not available and requiring GRDB modifications
    
    ```objc
    /// Initialization
    + (instancetype)databaseWithPath:(NSString * _Nullable)inPath;
    + (instancetype)databaseWithURL:(NSURL * _Nullable)url;
    - (instancetype)initWithPath:(NSString * _Nullable)path;
    - (instancetype)initWithURL:(NSURL * _Nullable)url;
    
    // Opening and closing database
    - (BOOL)open;
    - (BOOL)openWithFlags:(int)flags;
    - (BOOL)openWithFlags:(int)flags vfs:(NSString * _Nullable)vfsName;
    - (BOOL)close;
    
    // Date formatter
    + (NSDateFormatter *)storeableDateFormat:(NSString *)format;
    - (BOOL)hasDateFormatter;
    - (void)setDateFormat:(NSDateFormatter *)format;
    - (NSDate * _Nullable)dateFromString:(NSString *)s;
    - (NSString *)stringFromDate:(NSDate *)date;
    ```
    
- Not available without any hope for eventual support
    
    ```objc
    @property (atomic, assign) BOOL checkedOut;
    @property (nonatomic, readonly) BOOL hasOpenResultSets;
    + (NSString*)FMDBUserVersion;
    + (NSString*)FMDBUserVersion;
    + (SInt32)FMDBVersion;
    - (BOOL)update:(NSString*)sql withErrorAndBindings:(NSError * _Nullable*)outErr, ...  __deprecated_msg("Use executeUpdate:withErrorAndBindings: instead");
    - (BOOL)inTransaction __deprecated_msg("Use isInTransaction property instead");
    - (void)closeOpenResultSets;
    ```

---

Contact: [@groue](http://twitter.com/groue) on Twitter, or [Github issues](http://github.com/groue/GRDBObjc/issues).
