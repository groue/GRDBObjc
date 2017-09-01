import GRDB
import SQLite3
import Foundation

@objc public class GRDatabase : NSObject {
    let db: Database
    var dateFormatter: DateFormatter?

    init(_ db: Database) {
        self.db = db
        self.dateFormatter = nil
        self.logsErrors = false
        self.crashOnErrors = false
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
            handleError(error)
            return false
        }
    }
    
    @discardableResult @objc(executeUpdate:withArgumentsInArray:)
    public func executeUpdate(_ sql: String, argumentsInArray values: [Any]?) -> Bool {
        do {
            let arguments = values.map { statementArguments(from: $0) }
            try db.execute(sql, arguments: arguments)
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    @discardableResult @objc(executeUpdate:withParameterDictionary:)
    public func executeUpdate(_ sql: String, parameterDictionary: [String: Any]?) -> Bool {
        do {
            let arguments = parameterDictionary.map { statementArguments(from: $0) }
            try db.execute(sql, arguments: arguments)
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    @objc
    public func executeUpdate(_ sql: String, values: [Any]?) throws {
        do {
            let arguments = values.map { statementArguments(from: $0) }
            try db.execute(sql, arguments: arguments)
        } catch {
            handleError(error)
            throw error
        }
    }
    
    // MARK: - Queries
    
    @objc
    public func executeQuery(_ sql: String) -> GRResultSet? {
        do {
            let cursor = try Row.fetchCursor(db, sql)
            return GRResultSet(database: self, cursor: cursor)
        } catch {
            handleError(error)
            return nil
        }
    }

    @objc(executeQuery:withArgumentsInArray:)
    public func executeQuery(_ sql: String, argumentsInArray values: [Any]?) -> GRResultSet? {
        do {
            let arguments = values.map { statementArguments(from: $0) }
            let cursor = try Row.fetchCursor(db, sql, arguments: arguments)
            return GRResultSet(database: self, cursor: cursor)
        } catch {
            handleError(error)
            return nil
        }
    }
    
    @objc(executeQuery:withParameterDictionary:)
    public func executeQuery(_ sql: String, parameterDictionary: [String: Any]?) -> GRResultSet? {
        do {
            let arguments = parameterDictionary.map { statementArguments(from: $0) }
            let cursor = try Row.fetchCursor(db, sql, arguments: arguments)
            return GRResultSet(database: self, cursor: cursor)
        } catch {
            handleError(error)
            return nil
        }
    }
    
    @objc
    public func executeQuery(_ sql: String, values: [Any]?) throws -> GRResultSet {
        do {
            let arguments = values.map { statementArguments(from: $0) }
            let cursor = try Row.fetchCursor(db, sql, arguments: arguments)
            return GRResultSet(database: self, cursor: cursor)
        } catch {
            handleError(error)
            throw error
        }
    }
    
    // MARK: - Transactions
    
    @objc
    public func beginTransaction() -> Bool {
        do {
            try db.execute("BEGIN EXCLUSIVE TRANSACTION")
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    @objc
    public func beginDeferredTransaction() -> Bool {
        do {
            try db.execute("BEGIN DEFERRED TRANSACTION")
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    @objc
    public func commit() -> Bool {
        do {
            try db.execute("COMMIT")
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    @objc
    public func rollback() -> Bool {
        do {
            try db.execute("ROLLBACK")
            return true
        } catch {
            handleError(error)
            return false
        }
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
            handleError(error)
            return error
        }
    }
    
    @objc
    public func startSavePoint(name: String) throws {
        do {
            try db.execute("SAVEPOINT '\(espaceSavePointName(name))'")
        } catch {
            handleError(error)
            throw error
        }
    }
    
    @objc
    public func releaseSavePoint(name: String) throws {
        do {
            try db.execute("RELEASE SAVEPOINT '\(espaceSavePointName(name))'")
        } catch {
            handleError(error)
            throw error
        }
    }
    
    @objc
    public func rollbackSavePoint(name: String) throws {
        do {
            try db.execute("ROLLBACK TRANSACTION TO SAVEPOINT '\(espaceSavePointName(name))'")
        } catch {
            handleError(error)
            throw error
        }
    }
    
    private func espaceSavePointName(_ name: String) -> String {
        return name.replacingOccurrences(of: "'", with: "''")
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
        do {
            return try GRUpdateStatement(database: self, statement: db.makeUpdateStatement(sql))
        } catch {
            handleError(error)
            throw error
        }
    }
    
    // MARK: - Arguments
    
    func statementArguments(from values: [Any]) -> StatementArguments {
        let values = values.map { databaseValue(for: $0) }
        return StatementArguments(values)
    }
    
    func statementArguments(from dictionary: [String: Any]) -> StatementArguments {
        let dictionary = dictionary.mapValues { databaseValue(for: $0) }
        return StatementArguments(dictionary)
    }
    
    func databaseValue(for value: Any) -> DatabaseValue {
        switch value {
        case is NSNull:
            return .null
        case let data as Data:
            if data.isEmpty {
                // Compatibility warning: GRDB turns empty data into NULL, because SQLite can't store zero-length NSData
                return "".databaseValue
            } else {
                return data.databaseValue
            }
        case let date as Date:
            // Compatibility warning: GRDB turns dates into strings
            if let dateFormatter = dateFormatter {
                return dateFormatter.string(from: date as Date).databaseValue
            } else {
                return date.timeIntervalSince1970.databaseValue
            }
        case let number as NSNumber:
            return number.databaseValue
        default:
            return (value as AnyObject).description.databaseValue
        }
    }
    
    // MARK: - Errors
    
    @objc public var crashOnErrors: Bool
    @objc public var logsErrors: Bool
    @objc public var lastError: Error {
        return DatabaseError(
            resultCode: ResultCode(rawValue: sqlite3_errcode(db.sqliteConnection)),
            message: String(cString: sqlite3_errmsg(db.sqliteConnection)))
    }
    
    func handleError(_ error: Error) {
        if logsErrors { NSLog("DB Error: %@", "\(error)") }
        if crashOnErrors { fatalError("\(error)") }
    }
}
