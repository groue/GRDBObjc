import GRDB
import SQLite3

@objc public class FMResultSet : NSObject {
    private enum State {
        case initialized(RowCursor)
        case row(RowCursor, Row)
        case ended
        case error(Error)
    }
    
    private var db: FMDatabase
    private var state: State
    
    private var cursor: RowCursor {
        switch state {
        case .initialized(let cursor): return cursor
        case .row(let cursor, _): return cursor
        case .ended: fatalError("FMResultSet has been fully consumed, or closed")
        case .error(let error): fatalError("FMResultSet had an error: \(error)")
        }
    }
    
    private var row: Row {
        switch state {
        case .initialized: fatalError("-[FMResultSet next] has to be called before accessing fetched results")
        case .row(_, let row): return row
        case .ended: fatalError("FMResultSet has been fully consumed, or closed")
        case .error(let error): fatalError("FMResultSet had an error: \(error)")
        }
    }
    
    private lazy var columIndexForLowercaseColumnName: [String: Int] = Dictionary(
        self.cursor.statement.columnNames.enumerated().map { ($1.lowercased(), $0) },
        uniquingKeysWith: { $1 }) // keep rightmost index like FMDB

    init(database: FMDatabase, cursor: RowCursor) {
        self.db = database
        self.state = .initialized(cursor)
    }
    
    @objc
    public func next() -> Bool {
        return nextWithError(nil)
    }
    
    @objc(nextWithError:)
    public func nextWithError(_ outErr: NSErrorPointer) -> Bool {
        // This FMDB method breaks error handling conventions very badly. The
        // GRDBObjc version does the same. The problem is that the return value
        // NO does not mean there is an error.
        switch state {
        case .initialized(let cursor), .row(let cursor, _):
            do {
                if let row = try cursor.next() {
                    state = .row(cursor, row)
                    return true
                } else {
                    state = .ended
                    return false
                }
            } catch {
                state = .error(error)
                outErr?.pointee = db.handleError(error)
                return false
            }
        case .ended:
            return false
        case .error(let error):
            outErr?.pointee = db.handleError(error)
            return false
        }
    }

    @objc public func close() {
        state = .ended
    }
    
    @objc(columnIndexForName:) public func columnIndex(_ columnName: String) -> Int {
        return columIndexForLowercaseColumnName[columnName.lowercased()] ?? -1
    }
    
    @objc public func columnIndexIsNull(_ columnIndex: Int) -> Bool {
        return sqlite3_column_type(cursor.statement.sqliteStatement, Int32(columnIndex)) == SQLITE_NULL
    }
    
    @objc public func columnIsNull(_ columnName: String) -> Bool {
        return columnIndexIsNull(columnIndex(columnName))
    }
    
    @objc public subscript(_ columnIndex: Int) -> Any? { return row[columnIndex] }
    @objc(objectForColumnIndex:) public func object(columnIndex: Int) -> Any? { return row[columnIndex] }
    @objc(intForColumnIndex:) public func int(columnIndex: Int) -> CInt { return row[columnIndex] ?? 0 }
    @objc(longForColumnIndex:) public func long(columnIndex: Int) -> CLong { return row[columnIndex] ?? 0 }
    @objc(longLongIntForColumnIndex:) public func longlong(columnIndex: Int) -> CLongLong { return row[columnIndex] ?? 0 }
    @objc(unsignedLongLongIntForColumnIndex:) public func unsignedLongLong(columnIndex: Int) -> CUnsignedLongLong { return row[columnIndex] ?? 0 }
    @objc(boolForColumnIndex:) public func bool(columnIndex: Int) -> Bool { return row[columnIndex] ?? false }
    @objc(doubleForColumnIndex:) public func double(columnIndex: Int) -> Double { return row[columnIndex] ?? 0.0 }
    @objc(stringForColumnIndex:) public func string(columnIndex: Int) -> String? { return row[columnIndex] }
    @objc(dataForColumnIndex:) public func data(columnIndex: Int) -> Data? { return row[columnIndex] }
    @objc(dataNoCopyForColumnIndex:) public func dataNoCopy(columnIndex: Int) -> Data? { return row.dataNoCopy(atIndex: columnIndex) }
    @objc(dateForColumnIndex:) public func date(columnIndex: Int) -> Date? {
        if let dateFormatter = db.dateFormatter {
            guard let string = string(columnIndex: columnIndex) else { return nil }
            return dateFormatter.date(from: string)
        } else {
            return Date(timeIntervalSince1970: double(columnIndex: columnIndex))
        }
    }

    @objc public subscript(_ columnName: String) -> Any? { return self[columnIndex(columnName)] }
    @objc(objectForColumn:) public func object(columnName: String) -> Any? { return object(columnIndex: columnIndex(columnName)) }
    @objc(intForColumn:) public func int(columnName: String) -> CInt { return int(columnIndex: columnIndex(columnName)) }
    @objc(longForColumn:) public func long(columnName: String) -> CLong { return long(columnIndex: columnIndex(columnName)) }
    @objc(longLongIntForColumn:) public func longlong(columnName: String) -> CLongLong { return longlong(columnIndex: columnIndex(columnName)) }
    @objc(unsignedLongLongIntForColumn:) public func unsignedLongLong(columnName: String) -> CUnsignedLongLong { return unsignedLongLong(columnIndex: columnIndex(columnName)) }
    @objc(boolForColumn:) public func bool(columnName: String) -> Bool { return bool(columnIndex: columnIndex(columnName)) }
    @objc(doubleForColumn:) public func double(columnName: String) -> Double { return double(columnIndex: columnIndex(columnName)) }
    @objc(stringForColumn:) public func string(columnName: String) -> String? { return string(columnIndex: columnIndex(columnName)) }
    @objc(dataForColumn:) public func data(columnName: String) -> Data? { return data(columnIndex: columnIndex(columnName)) }
    @objc(dataNoCopyForColumn:) public func dataNoCopy(columnName: String) -> Data? { return dataNoCopy(columnIndex: columnIndex(columnName)) }
    @objc(dateForColumn:) public func date(columnName: String) -> Date? { return date(columnIndex: columnIndex(columnName)) }
    
    @objc public var resultDictionary: [String: AnyObject]? {
        switch state {
        case .row(_, let row):
            return Dictionary(
                row.map { ($0, $1.storage.value as AnyObject) },
                uniquingKeysWith: { $1 }) // keep rightmost value like FMDB
        default:
            return nil
        }
    }
}