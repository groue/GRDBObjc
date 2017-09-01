import GRDB

@objc public class GRDatabaseQueue : NSObject {
    public let dbQueue: DatabaseQueue
    private var _db: GRDatabase?
    
    private func database(_ db: Database) -> GRDatabase {
        if let _db = _db {
            precondition(_db.db === db)
            return _db
        } else {
            let _db = GRDatabase(db)
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
    
    @objc public static func databaseQueue(path: String) -> GRDatabaseQueue? {
        return try? GRDatabaseQueue(path: path)
    }
    
    @objc public static func databaseQueue(path: String) throws -> GRDatabaseQueue {
        return try GRDatabaseQueue(path: path)
    }

    @objc public init(path: String) throws {
        dbQueue = try DatabaseQueue(path: path)
    }
    
    @objc public func inDatabase(_ block: (GRDatabase) -> ()) {
        dbQueue.inDatabase { db in
            block(database(db))
        }
    }
    
    @objc public func inTransaction(_ block: (GRDatabase, UnsafeMutablePointer<ObjCBool>) -> ()) {
        inTransaction(transactionKind: .exclusive, block)
    }
    
    @objc public func inDeferredTransaction(_ block: (GRDatabase, UnsafeMutablePointer<ObjCBool>) -> ()) {
        inTransaction(transactionKind: .deferred, block)
    }
    
    func inTransaction(transactionKind: Database.TransactionKind, _ block: (GRDatabase, UnsafeMutablePointer<ObjCBool>) -> ()) {
        // TODO: error handling
        try? dbQueue.inTransaction(transactionKind) { db in
            var rollback: ObjCBool = false
            return withUnsafeMutablePointer(to: &rollback) { rollbackp -> Database.TransactionCompletion in
                block(database(db), rollbackp)
                return rollbackp.pointee.boolValue ? .rollback : .commit
            }
        }
    }
}
