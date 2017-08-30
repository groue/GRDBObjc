import GRDB
import SQLite3

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
    
    @objc public var lastError: Error {
        return DatabaseError(
            resultCode: ResultCode(rawValue: sqlite3_errcode(db.sqliteConnection)),
            message: String(cString: sqlite3_errmsg(db.sqliteConnection)))
    }
    
    @objc public var isInTransaction: Bool {
        return db.isInsideTransaction
    }
    
    @objc public var sqliteHandle: OpaquePointer {
        return db.sqliteConnection
    }
    
    @objc public func executeUpdate(_ sql: String) -> Bool {
        do {
            try db.execute(sql)
            return true
        } catch {
            return false
        }
    }
    
    @objc public func executeUpdate(_ sql: String) throws {
        try db.execute(sql)
    }
    
    @objc(executeUpdate:withArgumentsInArray:) public func executeUpdate(_ sql: String, argumentsInArray values: [Any]?) -> Bool {
        let arguments = values.map { StatementArguments(lossless: $0) } ?? StatementArguments()
        do {
            try db.execute(sql, arguments: arguments)
            return true
        } catch {
            return false
        }
    }
    
    @objc public func executeUpdate(_ sql: String, values: [Any]?) throws {
        let arguments = values.map { StatementArguments(lossless: $0) } ?? StatementArguments()
        try db.execute(sql, arguments: arguments)
    }
    
    @objc(executeUpdate:withParameterDictionary:) public func executeUpdate(_ sql: String, parameterDictionary: [String: Any]?) -> Bool {
        let arguments = parameterDictionary.map { StatementArguments(lossless: $0) } ?? StatementArguments()
        do {
            try db.execute(sql, arguments: arguments)
            return true
        } catch {
            return false
        }
    }
    
    @objc public func executeQuery(_ sql: String) throws -> GRResultSet {
        let cursor = try Row.fetchCursor(db, sql)
        return GRResultSet(cursor: cursor)
    }

    @objc public func executeQuery(_ sql: String, values: [Any]?) throws -> GRResultSet {
        let arguments = values.map { StatementArguments(lossless: $0) } ?? StatementArguments()
        let cursor = try Row.fetchCursor(db, sql, arguments: arguments)
        return GRResultSet(cursor: cursor)
    }
    
    @objc public func executeQuery(_ sql: String, parameterDictionary: [String: Any]?) throws -> GRResultSet {
        let arguments = parameterDictionary.map { StatementArguments(lossless: $0) } ?? StatementArguments()
        let cursor = try Row.fetchCursor(db, sql, arguments: arguments)
        return GRResultSet(cursor: cursor)
    }
    
    @objc public func inSavePoint(_ block: (UnsafeMutablePointer<ObjCBool>) -> ()) -> Error? {
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
    
    @objc public func tableExists(_ tableName: String) -> Bool {
        return (try? db.tableExists(tableName)) ?? false  // return false on error, for compatibility with FMDB
    }
    
    @objc public func __makeUpdateStatement(_ sql: String) throws -> GRUpdateStatement {
        return try GRUpdateStatement(statement: db.makeUpdateStatement(sql))
    }
}
