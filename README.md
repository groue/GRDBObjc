GRDBObjc
========

### A library that provides FMDB-compatible Objective-C bindings to the SQLite library GRDB.swift.

The goal is dead simple: help Objective-C applications replacing [FMDB](http://github.com/ccgus/fmdb) with [GRDB](http://github.com/groue/GRDB.swift), at minimal cost.


### Indulge yourself with a little Swift

It happens that we developers have to maintain Objective-C applications, and wish you could inject more and more Swift into them.

This happens when rewriting a whole application from scratch is not a reasonable option, and yet the expressivity and safety of Swift has an intense appeal. We preserve the legacy Objective-C code that represents years of development, experience, bug hunting and tests, and use Swift in new and isolated features that can easily be plugged on the Objective-C body.

Such a mixed application has an Objective-C trunk, and a few Swift leaves. Those Swift add-ons are sometimes hampered by their foreign foundations: maybe they don't look very Swifty, or maybe we dream of Swift alternatives that offer superior solutions.


### FMDB in a Swift World

We at [Pierlis](http://pierlis.com) feel this quite badly with FMDB. FMDB does a perfect job, but GRDB has a lot of advantages over it. When GRDB speaks SQL just as well as its venerable precursor, and offers the same robust concurrency guarantees, the Swift toolkit adds features such as database observation and support for record types that are nowhere to be seen with FMDB.

For example, compare two equivalent code snippets that load an array of application models:

```swift
// GRDB
struct Player: RowConvertible {
    init(row: Row) { ... }
}

func fetchPlayers(dbQueue: FMDatabaseQueue) throws -> [Player] {
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

You may think: "I never use FMDB like that!". Indeed error handling makes FMDB such a pain to read that barely nobody does it. And yet robustness is what eventually allows your application to run in the background on a locked device, when necessary. GRDB is concise, won't miss any error, and yet runs the code above [much faster](https://github.com/groue/GRDB.swift/wiki/Performance) than FMDB.


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

TODO

### KVO, FCModel

TODO: write something about GRDB support for Codable protocol

---

Contact: [@groue](http://twitter.com/groue) on Twitter, or [Github issues](http://github.com/groue/GRDBObjc/issues).
