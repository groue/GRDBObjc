import GRDB

@objc public class FMDatabaseQueue : NSObject {
    public let dbQueue: DatabaseQueue
    private var _db: FMDatabase?
    
    private func database(_ db: Database) -> FMDatabase {
        if let _db = _db {
            precondition(_db.db === db)
            return _db
        } else {
            let _db = FMDatabase(db)
            self._db = _db
            return _db
        }
    }
    
    public init(_ dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }
    
    @objc public var path: String {
        return dbQueue.path
    }
    
    @objc public override convenience init() {
        self.init(DatabaseQueue())
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
        dbQueue.inDatabase { db in
            block(database(db))
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
            try dbQueue.inTransaction(transactionKind) { db in
                var rollback: ObjCBool = false
                let transactionCompletion = withUnsafeMutablePointer(to: &rollback) { rollbackp -> Database.TransactionCompletion in
                    block(database(db), rollbackp)
                    return rollbackp.pointee.boolValue ? .rollback : .commit
                }
                crashOnErrors = database(db).crashOnErrors
                logsErrors = database(db).crashOnErrors
                return transactionCompletion
            }
        } catch {
            if logsErrors { NSLog("DB Error: %@", "\(error)") }
            if crashOnErrors { fatalError("\(error)") }
        }
    }
}
