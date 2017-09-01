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

It happens that we developers maintain and develop Objective-C applications, and wish we could inject more and more Swift into them.

This happens when rewriting a whole application from scratch is not a reasonable option, and yet the expressivity and safety of Swift has an intense appeal. We preserve the legacy Objective-C code that represents years of development, experience, bug hunting and tests, and use Swift in new and isolated features that can easily be plugged on to the Objective-C body.

Such a mixed application has an Objective-C trunk, and a few Swift leaves. Those Swift add-ons are sometimes hampered by their foreign foundations, which may not look very Swifty. Maybe we dream of Swift alternatives that offer superior solutions.


### FMDB in a Swift World

We at [Pierlis](http://pierlis.com) feel this itch quite acutely with FMDB. FMDB does a tremendous job, but GRDB does even better.

In 2015, GRDB was an internal project heavily inspired by FMDB. Two years and four versions of Swift later, this library has reached API stability and a focused toolkit that targets application development. Fundamentals are the same: GRDB speaks SQL just as well as its venerable precursor. It offers the same robust concurrency guarantees. Yet it adds that inimitable Swift taste, and features such as database observation and record types that are nowhere to be seen with FMDB.

For example, let's compare two equivalent code snippets that load an array of application models. With GRDB, it gives:

```swift
struct Player: RowConvertible {
    init(row: Row) { ... }
}

func fetchPlayers(dbQueue: DatabaseQueue) throws -> [Player] {
    return try dbQueue.inDatabase { db in
        try Player.fetchAll(db, "SELECT * FROM players")
    }
}
```

FMDB composes another kind of poetry:

```swift
struct Player {
    init(dictionary: [AnyHashable: Any]) { ... }
}

func fetchPlayers(dbQueue: FMDatabaseQueue) throws -> [Player] {
    var queryError: Error? = nil
    var players: [Player] = []
    dbQueue.inDatabase { db in
        do {
            let resultSet = try db.executeQuery("SELECT * FROM players", values: nil)
            while resultSet.next() {
                let player = Player(dictionary: resultSet.resultDictionary!)
                players.append(player)
            }
        } catch {
            queryError = error
        }
    }
    if let queryError = queryError {
        throw queryError
    }
    return players
}
```

You may think: "I never use FMDB like that!". Indeed error handling with FMDB is a pain to read and write, and barely nobody does it. And yet this kind of robustness is what allows your application to run safely in the background on a [locked device](https://developer.apple.com/library/content/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/StrategiesforImplementingYourApp/StrategiesforImplementingYourApp.html#//apple_ref/doc/uid/TP40007072-CH5-SW21), for example. GRDB is concise, won't miss any error, and yet runs the code above [much faster](https://github.com/groue/GRDB.swift/wiki/Performance) than FMDB.


### Going Further with GRDB

[Database observation](https://github.com/groue/GRDB.swift#database-changes-observation) is a ready-made GRDB feature that will save you the hours developing it on top of FMDB.

For example, GRDB comes with high-level tools such as [FetchedRecordsController](https://github.com/groue/GRDB.swift#fetchedrecordscontroller), and the companion library [RxGRDB](http://github.com/RxSwiftCommunity/RxGRDB) which lets you observe database changes in the reactive way. Since observation happens at the SQLite level, it won't be fooled by raw SQL updates, foreign key cascades, or even SQL triggers. Don't miss a single commit:

```swift
let request = SQLRequest(
    "SELECT * FROM players ORDER BY score DESC LIMIT 10")
    .asRequest(of: Player.self)

// Observe request changes with FetchedRecordsController:
let controller = FetchedRecordsController(dbQueue, request: request)
controller.trackChanges {
    let players = $0.fetchedRecords // [Player]
    print("Players have changed")
}
try controller.performFetch()

// Observe request changes in the reactive way:
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
// Objective-C
#import <GRDBObjc/GRDBObjc.h>
#import <GRDBObjc/GRDBObjc-Swift.h>

@interface DataStore
// Use FMDB in Objective-C
@property (nonatomic, nonnull) FMDatabaseQueue* dbQueue NS_REFINED_FOR_SWIFT;
@end

@implementation DataStore
- (void)setupDatabase {
    self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:...];
}
@end
```

```swift
// Swift
import GRDB
import GRDBObjc

extension DataStore {
    // Use GRDB in Swift
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
- Available with compatiblity warning ([pull requests](https://github.com/groue/GRDBObjc/pulls) are welcome)
- Not available yet  ([pull requests](https://github.com/groue/GRDBObjc/pulls) are welcome)
- Not available and replaced with another method
- Not available and requiring GRDB modifications ([discussion](https://github.com/groue/GRDBObjc/issues) is welcome)
- Not available without any hope for eventual support

Jump to the class you're interested into:

- [FMDatabase](#fmdatabase)
- [FMResultSet](#fmresultset)

#### FMDatabase

- Available with full compatibility
    
    ```objc
    // Properties
    @property (nonatomic, readonly) void *sqliteHandle;
    @property (nonatomic, readonly) int64_t lastInsertRowId;
    @property (nonatomic, readonly) int changes;
    
    /// Retrieving error codes
    - (NSError *)lastError;
    
    // Transactions
    - (BOOL)beginTransaction;
    - (BOOL)beginDeferredTransaction;
    - (BOOL)commit;
    - (BOOL)rollback;
    
    // Save points
    - (BOOL)startSavePointWithName:(NSString*)name error:(NSError * _Nullable *)outErr;
    - (BOOL)releaseSavePointWithName:(NSString*)name error:(NSError * _Nullable *)outErr;
    - (BOOL)rollbackToSavePointWithName:(NSString*)name error:(NSError * _Nullable *)outErr;
    - (NSError * _Nullable)inSavePoint:(__attribute__((noescape)) void (^)(BOOL *rollback))block;
    
    // Date formatter
    + (NSDateFormatter *)storeableDateFormat:(NSString *)format;
    - (BOOL)hasDateFormatter;
    - (void)setDateFormat:(NSDateFormatter *)format;
    - (NSDate * _Nullable)dateFromString:(NSString *)s;
    - (NSString *)stringFromDate:(NSDate *)date;
    ```
    
- Available with compatiblity warning
    
    ```objc
    // This property reflects actual SQLite state instead of relying on
    // the balance of beginTransaction/commit/rollback methods:
    //
    // - Some transaction errors have FMDB return true when GRDBObjc
    //   returns false.
    //
    // - Opening a transaction with a savepoint method has FMDB return
    //   false when GRDBObjc returns true.
    @property (nonatomic, readonly) BOOL isInTransaction;
    
    // When an NSDecimalNumber contains a value that can be exactly
    // represented as int64_t, GRDBObjc presents it to SQLite as an integer.
    // FMDB presents all decimal numbers as doubles.
    - (BOOL)executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments;
    - (BOOL)executeUpdate:(NSString*)sql values:(NSArray * _Nullable)values error:(NSError * _Nullable __autoreleasing *)error;
    - (BOOL)executeUpdate:(NSString*)sql withParameterDictionary:(NSDictionary *)arguments;
    - (FMResultSet * _Nullable)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments;
    - (FMResultSet * _Nullable)executeQuery:(NSString *)sql values:(NSArray * _Nullable)values error:(NSError * _Nullable __autoreleasing *)error;
    - (FMResultSet * _Nullable)executeQuery:(NSString *)sql withParameterDictionary:(NSDictionary * _Nullable)arguments;
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
    
    // Perform updates (¹)
    - (BOOL)executeUpdate:(NSString*)sql withErrorAndBindings:(NSError * _Nullable *)outErr, ...;
    - (BOOL)executeUpdate:(NSString*)sql, ...;
    - (BOOL)executeUpdateWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
    - (BOOL)executeUpdate:(NSString*)sql withVAList: (va_list)args;
    - (BOOL)executeStatements:(NSString *)sql;
    - (BOOL)executeStatements:(NSString *)sql withResultBlock:(__attribute__((noescape)) FMDBExecuteStatementsCallbackBlock _Nullable)block;
    
    // Retrieving results (¹)
    - (FMResultSet * _Nullable)executeQuery:(NSString*)sql, ...;
    - (FMResultSet * _Nullable)executeQueryWithFormat:(NSString*)format, ... NS_FORMAT_FUNCTION(1,2);
    - (FMResultSet * _Nullable)executeQuery:(NSString *)sql withVAList:(va_list)args;
    
    // Cached statements and result sets
    @property (nonatomic) BOOL shouldCacheStatements;
    @property (atomic, retain, nullable) NSMutableDictionary *cachedStatements;
    - (void)clearCachedStatements;    
    - (void)closeOpenResultSets;
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
    ```

(¹) I don't know how to expose the variadic methods
    

#### FMResultSet

- Available with full compatibility
    
    ```objc
    @property (nonatomic, readonly, nullable) NSDictionary *resultDictionary;
    
    - (void)close;
    - (BOOL)next;
    
    - (int)columnIndexForName:(NSString*)columnName;
    
    - (long)longForColumnIndex:(int)columnIdx;
    - (long)longForColumn:(NSString*)columnName;
    - (long long int)longLongIntForColumnIndex:(int)columnIdx;
    - (long long int)longLongIntForColumn:(NSString*)columnName;
    - (unsigned long long int)unsignedLongLongIntForColumnIndex:(int)columnIdx;
    - (unsigned long long int)unsignedLongLongIntForColumn:(NSString*)columnName;
    - (BOOL)boolForColumnIndex:(int)columnIdx;
    - (BOOL)boolForColumn:(NSString*)columnName;
    - (double)doubleForColumnIndex:(int)columnIdx;
    - (double)doubleForColumn:(NSString*)columnName;
    - (NSString * _Nullable)stringForColumnIndex:(int)columnIdx;
    - (NSString * _Nullable)stringForColumn:(NSString*)columnName;
    - (NSData * _Nullable)dataForColumnIndex:(int)columnIdx;
    - (NSData * _Nullable)dataForColumn:(NSString*)columnName;
    - (NSDate * _Nullable)dateForColumn:(NSString*)columnName;
    - (NSDate * _Nullable)dateForColumnIndex:(int)columnIdx;
    - (id _Nullable)objectForColumnIndex:(int)columnIdx;
    - (id _Nullable)objectForColumn:(NSString*)columnName;
    - (id _Nullable)objectAtIndexedSubscript:(int)columnIdx;
    - (id _Nullable)objectForKeyedSubscript:(NSString *)columnName;
    - (NSData * _Nullable)dataNoCopyForColumnIndex:(int)columnIdx NS_RETURNS_NOT_RETAINED;
    - (NSData * _Nullable)dataNoCopyForColumn:(NSString *)columnName NS_RETURNS_NOT_RETAINED;
    - (BOOL)columnIndexIsNull:(int)columnIdx;
    - (BOOL)columnIsNull:(NSString*)columnName;
    ```
    
- Available with compatiblity warning
    
    ```objc
    // Those methods crash with a fatal error when database contains 64-bit
    // values that are not representable with `int`. FMDB would instead return
    // a truncated value.
    - (int)intForColumnIndex:(int)columnIdx;
    - (int)intForColumn:(NSString*)columnName;
    ```
    
- Not available yet (pull requests are welcome)
    
    ```objc
    @property (nonatomic, retain, nullable) FMDatabase *parentDB;
    @property (atomic, retain, nullable) NSString *query;
    @property (readonly) NSMutableDictionary *columnNameToIndexMap;
    @property (atomic, retain, nullable) FMStatement *statement;
    + (instancetype)resultSetWithStatement:(FMStatement *)statement usingParentDatabase:(FMDatabase*)aDB;
    - (BOOL)hasAnotherRow;
    @property (nonatomic, readonly) int columnCount;
    - (NSString * _Nullable)columnNameForIndex:(int)columnIdx;
    - (const unsigned char * _Nullable)UTF8StringForColumn:(NSString*)columnName;
    - (const unsigned char * _Nullable)UTF8StringForColumnIndex:(int)columnIdx;
    - (void)kvcMagic:(id)object;
    - (BOOL)nextWithError:(NSError * _Nullable *)outErr;
    ```
    
- Not available and replaced with another method
- Not available and requiring GRDB modifications
- Not available without any hope for eventual support
    
    ```objc
    - (const unsigned char * _Nullable)UTF8StringForColumnName:(NSString*)columnName __deprecated_msg("Use UTF8StringForColumn instead");
    - (id _Nullable)objectForColumnName:(NSString*)columnName __deprecated_msg("Use objectForColumn instead");
    - (NSDictionary * _Nullable)resultDict __deprecated_msg("Use resultDictionary instead");
    ```

---

Contact: [@groue](http://twitter.com/groue) on Twitter, or [Github issues](http://github.com/groue/GRDBObjc/issues).
