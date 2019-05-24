import GRDB
import SQLite3
import Foundation

@objc public class FMDatabase : NSObject {
    let db: Database
    var dateFormatter: DateFormatter?
    var openResultSets: [WeakResultSet] = []

    /// The GRDB database connection that fuels this FMDatabase instance.
    public var grdbConnection: Database { return db }
    
    init(_ db: Database) {
        self.db = db
        self.dateFormatter = nil
        self.logsErrors = true
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
    public func executeStatements(_ sql: String) -> Bool {
        do {
            try db.execute(sql: sql)
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
            let statement = try db.makeUpdateStatement(sql: sql)
            try statement.execute(arguments: arguments)
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
            let statement = try db.makeUpdateStatement(sql: sql)
            try statement.execute(arguments: arguments)
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
            let statement = try db.makeUpdateStatement(sql: sql)
            try statement.execute(arguments: arguments)
        } catch {
            throw handleError(error)
        }
    }
    
    // MARK: - Queries
    
    @objc(executeQuery:withArgumentsInArray:)
    public func executeQuery(_ sql: String, argumentsInArray values: [Any]?) -> FMResultSet? {
        do {
            let arguments = values.map { statementArguments(from: $0) } ?? StatementArguments()
            let cursor = try Row.fetchCursor(db, sql: sql, arguments: arguments)
            return FMResultSet(database: self, cursor: cursor)
        } catch {
            handleError(error)
            return nil
        }
    }
    
    @objc(executeQuery:withParameterDictionary:)
    public func executeQuery(_ sql: String, parameterDictionary: [String: Any]?) -> FMResultSet? {
        do {
            let arguments = parameterDictionary.map { statementArguments(from: $0) } ?? StatementArguments()
            let cursor = try Row.fetchCursor(db, sql: sql, arguments: arguments)
            return FMResultSet(database: self, cursor: cursor)
        } catch {
            handleError(error)
            return nil
        }
    }
    
    @objc
    public func executeQuery(_ sql: String, values: [Any]?) throws -> FMResultSet {
        do {
            let arguments = values.map { statementArguments(from: $0) } ?? StatementArguments()
            let cursor = try Row.fetchCursor(db, sql: sql, arguments: arguments)
            return FMResultSet(database: self, cursor: cursor)
        } catch {
            throw handleError(error)
        }
    }
    
    // MARK: - Transactions
    
    @objc
    public func beginTransaction() -> Bool {
        do {
            try db.beginTransaction(.exclusive)
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    @objc
    public func beginDeferredTransaction() -> Bool {
        do {
            try db.beginTransaction(.deferred)
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    @objc
    public func commit() -> Bool {
        do {
            try db.commit()
            return true
        } catch {
            handleError(error)
            return false
        }
    }
    
    @objc
    public func rollback() -> Bool {
        do {
            try db.commit()
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
            try db.execute(sql: "SAVEPOINT '\(espaceSavePointName(name))'")
        } catch {
            throw handleError(error)
        }
    }
    
    @objc
    public func releaseSavePoint(name: String) throws {
        do {
            try db.execute(sql: "RELEASE SAVEPOINT '\(espaceSavePointName(name))'")
        } catch {
            throw handleError(error)
        }
    }
    
    @objc
    public func rollbackSavePoint(name: String) throws {
        do {
            try db.execute(sql: "ROLLBACK TRANSACTION TO SAVEPOINT '\(espaceSavePointName(name))'")
        } catch {
            throw handleError(error)
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
    
    // MARK: - Statements
    
    @objc
    public func _makeUpdateStatement(_ sql: String) throws -> _FMUpdateStatement {
        do {
            return try _FMUpdateStatement(database: self, statement: db.makeUpdateStatement(sql: sql))
        } catch {
            throw handleError(error)
        }
    }
    
    @objc
    public func _makeSelectStatement(_ sql: String) throws -> _FMSelectStatement {
        do {
            return try _FMSelectStatement(database: self, statement: db.makeSelectStatement(sql: sql))
        } catch {
            throw handleError(error)
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
            return data.databaseValue
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
    
    private static let errorDomain = "FMDatabase"
    
    @objc public var crashOnErrors: Bool
    @objc public var logsErrors: Bool
    @objc public var lastError: NSError {
        return NSError(
            domain: FMDatabase.errorDomain,
            code: Int(sqlite3_errcode(db.sqliteConnection)),
            userInfo: [NSLocalizedDescriptionKey: String(cString: sqlite3_errmsg(db.sqliteConnection))])
    }
    
    /// Return an FMDB-compatible error, and perform FMDB side effects on errors
    /// such as logging or crashing.
    @discardableResult
    func handleError(_ error: Error) -> NSError {
        var fmdbError: NSError
        if let error = error as? DatabaseError {
            // GRDB outputs extended result codes, when FMDB outputs primary
            // result codes:
            let primaryResultCode = Int(error.resultCode.primaryResultCode.rawValue)
            fmdbError = NSError(
                domain: FMDatabase.errorDomain,
                code: primaryResultCode,
                userInfo: [NSLocalizedDescriptionKey: error.description])
        } else {
            fmdbError = error as NSError
        }
        if logsErrors { NSLog("DB Error: %@", "\(fmdbError)") }
        if crashOnErrors { fatalError("\(error)") }
        return fmdbError
    }
    
    // Private
    
    func autoclosingResultSets<T>(_ block: () -> T) -> T {
        defer {
            for openResultSet in openResultSets {
                openResultSet.close()
            }
            openResultSets = []
        }
        return block()
    }

}

class WeakResultSet {
    weak var resultSet: FMResultSet?
    
    init(_ resultSet: FMResultSet) {
        self.resultSet = resultSet
    }
    
    func close() {
        resultSet?.close()
        resultSet = nil
    }
}
