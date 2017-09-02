GRDBObjc [![Swift](https://img.shields.io/badge/swift-4-orange.svg?style=flat)](https://developer.apple.com/swift/) [![License](https://img.shields.io/github/license/RxSwiftCommunity/RxGRDB.svg?maxAge=2592000)](/LICENSE)
========

### FMDB-compatible bindings to GRDB.swift.

GRDBObjc helps Objective-C applications that use SQLite replace [FMDB](http://github.com/ccgus/fmdb) with [GRDB](http://github.com/groue/GRDB.swift), at minimal cost.

**Latest release**: September 2, 2017 &bull; version 0.1 &bull; [Release Notes](CHANGELOG.md)

**Requirements**: iOS 8.0+ / OSX 10.10+ / watchOS 2.0+ • Xcode 9+ • Swift 4

Follow [@groue](http://twitter.com/groue) on Twitter for release announcements and usage tips.


---

<p align="center">
    <a href="#installation">Installation</a> &bull;
    <a href="#demo">Demo</a> &bull;
    <a href="#fmdb-compatibility-chart">FMDB Compatibility Chart</a>
</p>

---


### Indulge yourself with a little Swift

It happens that we developers maintain and develop Objective-C applications, and wish we could inject more and more Swift into them.

Rewriting a whole application from scratch is often not a reasonable option, despite the intense appeal of Swift. We preserve the legacy Objective-C code that represents years of development, and isolate Swift in the few features that can easily be plugged on to the Objective-C body.

In such a mixed application that has an Objective-C trunk, the few Swift leaves are sometimes hampered by their foreign foundations. Maybe the imported Objective-C does not look very Swifty. Maybe we dream of Swift alternatives that offer superior solutions.


### FMDB in a Swift World

We at [Pierlis](http://pierlis.com) feel this itch quite acutely with FMDB. FMDB does a tremendous job, but GRDB does even better.

In 2015, GRDB was an internal project heavily inspired by FMDB. Two years and four versions of Swift later, this library has reached API stability, and offers a strong toolkit focused on application development. Fundamentals are the same: GRDB speaks SQL just as well as its venerable precursor. It offers the same robust concurrency guarantees. Yet GRBD adds that inimitable Swift taste, and features such as database observation and record types that are nowhere to be seen with FMDB.

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

The `FMDatabaseQueue`, `FMResultSet`, etc. classes are now backed by GRDB. A database queue initialized from Objective-C is usable from Swift, and vice versa. See the [Installation](#installation) procedure below for detailed instructions.


# Installation

**Before considering using GRDBObjc**, please consider it is still very young software. It is tested, but does not fuel many real-life apps yet.

Get familiar with the ["Swift and Objective-C in the Same Project"](https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html) chapter of Swift documentation.

Check the [FMDB compatibility chart](#fmdb-compatibility-chart).

Be ready to open a [pull request](https://github.com/groue/GRDBObjc/pulls) if some API you need is missing, or if you discover a bug or a surprising behavior.

**GRDObjc can be installed with Cocoapods:**

1. Specify in your target's Build Settings: `SWIFT_VERSION = 4.0`.

2. Replace FMDB with GRDBObjc and GRDB in your Podfile:

    ```diff
    -pod 'FMDB'
    +pod 'GRDBObjc', :git => 'https://github.com/groue/GRDBObjc.git', branch: 'master'
    +pod 'GRDB.swift', :git => 'https://github.com/groue/GRDB.swift.git', branch: 'Swift4'
    ```

3. Run `pod install`.

4. Replace Objective-C import directives:

    ```diff
    -#import <fmdb/FMDB.h>
    +#import <GRDBObjc/GRDBObjc.h>
    +#import <GRDBObjc/GRDBObjc-Swift.h>
    ```
5. Run and test your application: make sure your Objective-C code handles GRDBObjc well.

6. Expose your Objective-C `FMDatabaseQueue` to Swift via the bridging header, so that you can use a genuine GRDB `DatabaseQueue` from Swift.

    **Don't use the FMDB APIs from Swift**: that's not the goal of this library! Instead, convert a `FMDatabaseQueue` to GRDB's `DatabaseQueue`, and make sure Swift code only uses GRDB:
    
    ```swift
    // Some FMDatabaseQueue exposed to Swift via the bridging header:
    let fmdbQueue: FMDatabaseQueue = ...
    
    // The genuine GRDB's DatabaseQueue:
    let dbQueue: DatabaseQueue = fmdbQueue.dbQueue
    ```
    
    See the [demo app](#demo) for a sample setup.


# Demo

The demo application sets up a database in Objective-C using FMDB-compatible APIs, and uses the database from Swift using GRDB.

To run this demo app:

- Download a copy of this repository. 
- Run `pod install` from the `Tests/CocoaPods/TestApp` directory.
- Open `Tests/CocoaPods/TestApp/TestApp.xcworkspace` in Xcode 9.
- Run the app.
- The bridging between Objective-C and Swift happens in the DataStore class, and the bridging header.

<p align="center">
    <a href= "https://cdn.rawgit.com/groue/GRDBObjc/master/Documentation/Pictures/Demo.png"><img src="https://cdn.rawgit.com/groue/GRDBObjc/master/Documentation/Pictures/Demo.png" height="320"></a>
</p>


# FMDB Compatibility Chart

GRDB and FMDB usually behave exactly in the same manner. When there are differences, GRDBObjc favors FMDB compatibility over native GRDB behavior.

**Some FMDB features are missing, and out of scope for GRDBObjc.** For example, GRDBObjc requires that databases are accessed through the thread-safe FMDatabaseQueue.

**Some other FMDB features have not been ported to GRDBObjc yet.** If some API you need is missing, please open a [pull request](https://github.com/groue/GRDBObjc/pulls).

**Beware of NSDate.** By default, FMDB stores and reads dates as numerical timestamps. GRDB stores [dates](https://github.com/groue/GRDB.swift/blob/master/README.md#date-and-datecomponents) as strings, and interprets numerical values as Julian day numbers. So double check your code that deals with dates.

Now jump to the class you're interested into:

- [FMDatabaseQueue](#fmdatabasequeue)
- [FMDatabase](#fmdatabase)
- [FMResultSet](#fmresultset)


#### FMDatabaseQueue

- Available with full compatibility:
    
    ```objc
    @property (atomic, retain, nullable) NSString *path;
    + (instancetype)databaseQueueWithPath:(NSString * _Nullable)aPath;
    - (instancetype)initWithPath:(NSString * _Nullable)aPath;
    ```

- Available with compatibility warning:
    
    ```objc
    // FMDB lets you escape a FMDatabase connection from its database
    // queue's protected blocks. You shouldn't do that, but it's
    // possible. With GRDBObjc, it is a programmer error, with undefined
    // consequences, to do so. Don't use an FMDatabase connection
    // outside of a protected block.
    - (void)inDatabase:(__attribute__((noescape)) void (^)(FMDatabase *db))block;
    - (void)inTransaction:(__attribute__((noescape)) void (^)(FMDatabase *db, BOOL *rollback))block;
    - (void)inDeferredTransaction:(__attribute__((noescape)) void (^)(FMDatabase *db, BOOL *rollback))block;
    ```


#### FMDatabase

- Available with full compatibility:
    
    ```objc
    // Properties
    @property (nonatomic, readonly) void *sqliteHandle;
    @property (nonatomic, readonly) int64_t lastInsertRowId;
    @property (nonatomic, readonly) int changes;
    
    /// Retrieving error codes
    @property (atomic, assign) BOOL logsErrors;
    @property (atomic, assign) BOOL crashOnErrors;
    - (NSError *)lastError;
    
    // Perform updates
    - (BOOL)executeUpdate:(NSString*)sql;
    
    // Retrieving results
    - (FMResultSet * _Nullable)executeQuery:(NSString*)sql;
    
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
    
- Available with compatibility warning:
    
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
    
    // When an NSDecimalNumber parameter contains a value that can be
    // exactly represented as int64_t, GRDBObjc presents it to SQLite as
    // an integer. FMDB presents all decimal numbers as doubles.
    //
    // When an NSNumber parameter contains an unsigned 64-bit integer
    // higher than the maximum signed 64-bit integer, GRDBObjc crashes
    // with a fatal error, when FMDB stores a negative value.
    - (BOOL)executeUpdate:(NSString*)sql withArgumentsInArray:(NSArray *)arguments;
    - (BOOL)executeUpdate:(NSString*)sql values:(NSArray * _Nullable)values error:(NSError * _Nullable __autoreleasing *)error;
    - (BOOL)executeUpdate:(NSString*)sql withParameterDictionary:(NSDictionary *)arguments;
    - (FMResultSet * _Nullable)executeQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments;
    - (FMResultSet * _Nullable)executeQuery:(NSString *)sql values:(NSArray * _Nullable)values error:(NSError * _Nullable __autoreleasing *)error;
    - (FMResultSet * _Nullable)executeQuery:(NSString *)sql withParameterDictionary:(NSDictionary * _Nullable)arguments;
    ```


#### FMResultSet

- Available with full compatibility:
    
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
    
- Available with compatibility warning:
    
    ```objc
    // Those methods crash with a fatal error when database contains 64-bit
    // values that are not representable with `int`. FMDB would instead return
    // a truncated value.
    - (int)intForColumnIndex:(int)columnIdx;
    - (int)intForColumn:(NSString*)columnName;
    ```

---

:bowtie: Happy GRDB!
