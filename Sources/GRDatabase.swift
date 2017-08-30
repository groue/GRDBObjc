import GRDB
import SQLite3

@objc public class GRDatabase : NSObject {
    let db: Database
    
    init(_ db: Database) {
        self.db = db
    }
    
    @objc
    public var lastInsertRowId: Int64 {
        return db.lastInsertedRowID
    }
    
    @objc
    public var changes: CInt {
        return CInt(db.changesCount)
    }
    
    @objc
    public var lastError: Error {
        return DatabaseError(
            resultCode: ResultCode(rawValue: sqlite3_errcode(db.sqliteConnection)),
            message: String(cString: sqlite3_errmsg(db.sqliteConnection)))
    }
    
    @objc
    public var isInTransaction: Bool {
        return db.isInsideTransaction
    }
    
    @objc
    public var sqliteHandle: OpaquePointer {
        return db.sqliteConnection
    }
    
    // MARK: - Updates

    @discardableResult @objc
    public func executeUpdate(_ sql: String) -> Bool {
        do {
            try db.execute(sql)
            return true
        } catch {
            return false
        }
    }
    
    @discardableResult @objc(executeUpdate:withArgumentsInArray:)
    public func executeUpdate(_ sql: String, argumentsInArray values: [Any]?) -> Bool {
        do {
            let arguments = try values.map { try StatementArguments(lossless: $0) } ?? StatementArguments()
            try db.execute(sql, arguments: arguments)
            return true
        } catch {
            return false
        }
    }
    
    @discardableResult @objc(executeUpdate:withParameterDictionary:)
    public func executeUpdate(_ sql: String, parameterDictionary: [String: Any]?) -> Bool {
        do {
            let arguments = try parameterDictionary.map { try StatementArguments(lossless: $0) } ?? StatementArguments()
            try db.execute(sql, arguments: arguments)
            return true
        } catch {
            return false
        }
    }
    
    @objc
    public func executeUpdate(_ sql: String, values: [Any]?) throws {
        let arguments = try values.map { try StatementArguments(lossless: $0) } ?? StatementArguments()
        try db.execute(sql, arguments: arguments)
    }
    
    // MARK: - Queries
    
    @objc
    public func executeQuery(_ sql: String) -> GRResultSet? {
        do {
            let cursor = try Row.fetchCursor(db, sql)
            return GRResultSet(cursor: cursor)
        } catch {
            return nil
        }
    }

    @objc(executeQuery:withArgumentsInArray:)
    public func executeQuery(_ sql: String, argumentsInArray values: [Any]?) -> GRResultSet? {
        do {
            let arguments = try values.map { try StatementArguments(lossless: $0) } ?? StatementArguments()
            let cursor = try Row.fetchCursor(db, sql, arguments: arguments)
            return GRResultSet(cursor: cursor)
        } catch {
            return nil
        }
    }
    
    @objc(executeQuery:withParameterDictionary:)
    public func executeQuery(_ sql: String, parameterDictionary: [String: Any]?) -> GRResultSet? {
        do {
            let arguments = try parameterDictionary.map { try StatementArguments(lossless: $0) } ?? StatementArguments()
            let cursor = try Row.fetchCursor(db, sql, arguments: arguments)
            return GRResultSet(cursor: cursor)
        } catch {
            return nil
        }
    }
    
    @objc
    public func executeQuery(_ sql: String, values: [Any]?) throws -> GRResultSet {
        let arguments = try values.map { try StatementArguments(lossless: $0) } ?? StatementArguments()
        let cursor = try Row.fetchCursor(db, sql, arguments: arguments)
        return GRResultSet(cursor: cursor)
    }
    
    // MARK: - Savepoints
    
    @objc
    public func inSavePoint(_ block: (UnsafeMutablePointer<ObjCBool>) -> ()) -> Error? {
        do {
            try db.inSavepoint {
                var rollback: ObjCBool = false
                return withUnsafeMutablePointer(to: &rollback) { rollbackp -> Database.TransactionCompletion in
                    block(rollbackp)
                    return rollbackp.pointee.boolValue ? .rollback : .commit
                }
            }
            return nil
        } catch {
            return error
        }
    }
    
    // MARK: - Schema
    
    @objc
    public func tableExists(_ tableName: String) -> Bool {
        return (try? db.tableExists(tableName)) ?? false  // return false on error, for compatibility with FMDB
    }
    
    @objc
    public func __makeUpdateStatement(_ sql: String) throws -> GRUpdateStatement {
        return try GRUpdateStatement(statement: db.makeUpdateStatement(sql))
    }
}
