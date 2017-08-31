import GRDB
import SQLite3
import Foundation

@objc public class GRDatabase : NSObject {
    let db: Database
    var dateFormatter: DateFormatter?
    
    init(_ db: Database) {
        self.db = db
        self.dateFormatter = nil
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
            let arguments = try values.map { try statementArguments(from: $0) }
            try db.execute(sql, arguments: arguments)
            return true
        } catch {
            return false
        }
    }
    
    @discardableResult @objc(executeUpdate:withParameterDictionary:)
    public func executeUpdate(_ sql: String, parameterDictionary: [String: Any]?) -> Bool {
        do {
            let arguments = try parameterDictionary.map { try statementArguments(from: $0) }
            try db.execute(sql, arguments: arguments)
            return true
        } catch {
            return false
        }
    }
    
    @objc
    public func executeUpdate(_ sql: String, values: [Any]?) throws {
        let arguments = try values.map { try statementArguments(from: $0) }
        try db.execute(sql, arguments: arguments)
    }
    
    // MARK: - Queries
    
    @objc
    public func executeQuery(_ sql: String) -> GRResultSet? {
        do {
            let cursor = try Row.fetchCursor(db, sql)
            return GRResultSet(database: self, cursor: cursor)
        } catch {
            return nil
        }
    }

    @objc(executeQuery:withArgumentsInArray:)
    public func executeQuery(_ sql: String, argumentsInArray values: [Any]?) -> GRResultSet? {
        do {
            let arguments = try values.map { try statementArguments(from: $0) }
            let cursor = try Row.fetchCursor(db, sql, arguments: arguments)
            return GRResultSet(database: self, cursor: cursor)
        } catch {
            return nil
        }
    }
    
    @objc(executeQuery:withParameterDictionary:)
    public func executeQuery(_ sql: String, parameterDictionary: [String: Any]?) -> GRResultSet? {
        do {
            let arguments = try parameterDictionary.map { try statementArguments(from: $0) }
            let cursor = try Row.fetchCursor(db, sql, arguments: arguments)
            return GRResultSet(database: self, cursor: cursor)
        } catch {
            return nil
        }
    }
    
    @objc
    public func executeQuery(_ sql: String, values: [Any]?) throws -> GRResultSet {
        let arguments = try values.map { try statementArguments(from: $0) }
        let cursor = try Row.fetchCursor(db, sql, arguments: arguments)
        return GRResultSet(database: self, cursor: cursor)
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
    
    // MARK: - Dates
    
    @objc
    public static func storeableDateFormat(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(secondsFromGMT: 0)!
        formatter.locale = Locale(identifier: "en_US") // Compatibility warning: GRDB uses en_US_POSIX
        return formatter
    }
    
    @objc
    public var hasDateFormatter: Bool {
        return dateFormatter != nil
    }
    
    @objc
    public func setDateFormat(_ formatter: DateFormatter) {
        dateFormatter = formatter
    }
    
    @objc
    public func date(from string: String?) -> Date? {
        guard let dateFormatter = dateFormatter else { return nil }
        guard let string = string else { return nil }
        return dateFormatter.date(from: string)
    }
    
    @objc
    public func string(from date: Date?) -> String? {
        guard let dateFormatter = dateFormatter else { return nil }
        guard let date = date else { return nil }
        return dateFormatter.string(from: date)
    }
    
    // MARK: - Schema
    
    @objc
    public func tableExists(_ tableName: String) -> Bool {
        return (try? db.tableExists(tableName)) ?? false  // return false on error, for compatibility with FMDB
    }
    
    @objc
    public func __makeUpdateStatement(_ sql: String) throws -> GRUpdateStatement {
        return try GRUpdateStatement(database: self, statement: db.makeUpdateStatement(sql))
    }
    
    // MARK: - Arguments
    
    func statementArguments(from values: [Any]) throws -> StatementArguments {
        let values = try values.map { try databaseValue(for: $0) }
        return StatementArguments(values)
    }
    
    func statementArguments(from dictionary: [String: Any]) throws -> StatementArguments {
        let dictionary = try dictionary.mapValues { try databaseValue(for: $0) }
        return StatementArguments(dictionary)
    }
    
    func databaseValue(for value: Any) throws -> DatabaseValue {
        switch value {
        case let date as Date:
            if let dateFormatter = dateFormatter {
                return dateFormatter.string(from: date).databaseValue
            } else {
                return date.timeIntervalSince1970.databaseValue
            }
        case let date as NSDate:
            if let dateFormatter = dateFormatter {
                return dateFormatter.string(from: date as Date).databaseValue
            } else {
                return date.timeIntervalSince1970.databaseValue
            }
        default:
            guard let dbValue = DatabaseValue(value: value) else {
                throw DatabaseError(resultCode: .SQLITE_MISUSE, message: "\(String(reflecting: value)) is not a valid database value")
            }
            return dbValue
        }
    }
}
