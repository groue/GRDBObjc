import GRDB

@objc public class GRDatabase : NSObject {
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    @objc public var lastInsertRowId: Int64 {
        return db.lastInsertedRowID
    }
    
    @objc public var changes: CInt {
        return CInt(db.changesCount)
    }
    
    @objc public var isInTransaction: Bool {
        return db.isInsideTransaction
    }
    
    @objc public func executeUpdate(_ sql: String) throws {
        try db.execute(sql)
    }
    
    @objc public func executeUpdate(_ sql: String, values: [Any]?) throws {
        let arguments = values.map { StatementArguments(lossless: $0) }
        try db.execute(sql, arguments: arguments)
    }
    
    @objc public func executeUpdate(_ sql: String, parameterDictionary: [String: Any]?) throws {
        let arguments = parameterDictionary.map { StatementArguments(lossless: $0) }
        try db.execute(sql, arguments: arguments)
    }
    
    @objc public func executeQuery(_ sql: String) throws -> GRResultSet {
        let cursor = try Row.fetchCursor(db, sql)
        return GRResultSet(cursor: cursor)
    }

    @objc public func executeQuery(_ sql: String, values: [Any]?) throws -> GRResultSet {
        let arguments = values.map { StatementArguments(lossless: $0) }
        let cursor = try Row.fetchCursor(db, sql, arguments: arguments)
        return GRResultSet(cursor: cursor)
    }
    
    @objc public func executeQuery(_ sql: String, parameterDictionary: [String: Any]?) throws -> GRResultSet {
        let arguments = parameterDictionary.map { StatementArguments(lossless: $0) }
        let cursor = try Row.fetchCursor(db, sql, arguments: arguments)
        return GRResultSet(cursor: cursor)
    }
}
