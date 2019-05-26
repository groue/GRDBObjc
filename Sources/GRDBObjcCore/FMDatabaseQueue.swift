import GRDB

@objc public class FMDatabaseQueue : NSObject {
    public let dbQueue: DatabaseQueue
    private var _fmdb: FMDatabase?
    
    private func inFMDB<T>(_ db: Database, _ block: (FMDatabase) throws -> T) rethrows -> T {
        let fmdb: FMDatabase
        if let _fmdb = _fmdb {
            precondition(_fmdb.db === db)
            fmdb = _fmdb
        } else {
            fmdb = FMDatabase(db)
            self._fmdb = fmdb
        }
        
        return try withoutActuallyEscaping(block) { block in
            try fmdb.autoclosingResultSets { try block(fmdb) }
        }
    }
    
    public init(_ dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }
    
    @objc public var path: String {
        return dbQueue.path
    }
    
    @objc public static func databaseQueue(path: String) -> FMDatabaseQueue? {
        return try? FMDatabaseQueue(path: path)
    }
    
    @objc public static func databaseQueue(path: String) throws -> FMDatabaseQueue {
        return try FMDatabaseQueue(path: path)
    }

    @objc public init(path: String) throws {
        dbQueue = try DatabaseQueue(path: path)
    }
    
    @objc public func inDatabase(_ block: (FMDatabase) -> ()) {
        withoutActuallyEscaping(block) { block in
            dbQueue.inDatabase { db in
                inFMDB(db, block)
            }
        }
    }
    
    @objc public func inTransaction(_ block: (FMDatabase, UnsafeMutablePointer<ObjCBool>) -> ()) {
        inTransaction(transactionKind: .exclusive, block)
    }
    
    @objc public func inDeferredTransaction(_ block: (FMDatabase, UnsafeMutablePointer<ObjCBool>) -> ()) {
        inTransaction(transactionKind: .deferred, block)
    }
    
    func inTransaction(transactionKind: Database.TransactionKind, _ block: (FMDatabase, UnsafeMutablePointer<ObjCBool>) -> ()) {
        var crashOnErrors = false
        var logsErrors = false
        do {
            try withoutActuallyEscaping(block) { block in
                try dbQueue.inTransaction(transactionKind) { db in
                    inFMDB(db) { fmdb in
                        var rollback: ObjCBool = false
                        let transactionCompletion = withUnsafeMutablePointer(to: &rollback) { rollbackp -> Database.TransactionCompletion in
                            block(fmdb, rollbackp)
                            return rollbackp.pointee.boolValue ? .rollback : .commit
                        }
                        crashOnErrors = fmdb.crashOnErrors
                        logsErrors = fmdb.crashOnErrors
                        return transactionCompletion
                    }
                }
            }
        } catch {
            if logsErrors { NSLog("DB Error: %@", "\(error)") }
            if crashOnErrors { fatalError("\(error)") }
        }
    }
}
