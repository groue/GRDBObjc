import GRDB

@objc public class GRDatabaseQueue : NSObject {
    let dbQueue: DatabaseQueue
    
    @objc public var path: String {
        return dbQueue.path
    }
    
    @objc public override init() {
        dbQueue = DatabaseQueue()
    }

    @objc public init(path: String) throws {
        dbQueue = try DatabaseQueue(path: path)
    }
    
    @objc public func inDatabase(_ block: (GRDatabase) -> ()) {
        dbQueue.inDatabase { db in
            block(GRDatabase(db))
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
                block(GRDatabase(db), rollbackp)
                return rollbackp.pointee.boolValue ? .rollback : .commit
            }
        }
    }
}
