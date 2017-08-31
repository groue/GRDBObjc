import GRDB
import SQLite3

@objc public class GRResultSet : NSObject {
    private enum State {
        case initialized(RowCursor)
        case row(RowCursor, Row)
        case ended
        case error(Error)
    }
    private var state: State
    private var cursor: RowCursor {
        switch state {
        case .initialized(let cursor): return cursor
        case .row(let cursor, _): return cursor
        case .ended: fatalError("GRResultSet has been fully consumed, or closed")
        case .error(let error): fatalError("GRResultSet had an error: \(error)")
        }
    }
    private var row: Row {
        switch state {
        case .initialized: fatalError("-[GRResultSet next] has to be called before accessing fetched results")
        case .row(_, let row): return row
        case .ended: fatalError("GRResultSet has been fully consumed, or closed")
        case .error(let error): fatalError("GRResultSet had an error: \(error)")
        }
    }

    init(cursor: RowCursor) {
        self.state = .initialized(cursor)
    }
    
    @objc public func next() -> Bool {
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
                return false
            }
        case .ended: return false
        case .error: return false
        }
    }
    
    @objc public func close() {
        state = .ended
    }
    
    @objc(columnIndexForName:) public func columnIndex(columnName: String) -> Int {
        let statement = cursor.statement
        if let index = statement.index(ofColumn: columnName) {
            return index
        }
        return -1 // Compatibility with FMDB
    }
    
    @objc public func columnIndexIsNull(_ columnIndex: Int) -> Bool {
        return sqlite3_column_type(cursor.statement.sqliteStatement, Int32(columnIndex)) == SQLITE_NULL
    }
    
    @objc public func columnIsNull(_ columnName: String) -> Bool {
        return columnIndexIsNull(columnIndex(columnName: columnName))
    }
    
    @objc(intForColumnIndex:) public func int(columnIndex: Int) -> CInt { return row[columnIndex] ?? 0 }
    @objc(intForColumn:) public func int(columnName: String) -> CInt { return row[columnName] ?? 0 }
    @objc(longForColumnIndex:) public func long(columnIndex: Int) -> CLong { return row[columnIndex] ?? 0 }
    @objc(longForColumn:) public func long(columnName: String) -> CLong { return row[columnName] ?? 0 }
    @objc(longLongIntForColumnIndex:) public func long(columnIndex: Int) -> CLongLong { return row[columnIndex] ?? 0 }
    @objc(longLongIntForColumn:) public func long(columnName: String) -> CLongLong { return row[columnName] ?? 0 }
    @objc(unsignedLongLongIntForColumnIndex:) public func long(columnIndex: Int) -> CUnsignedLongLong { return row[columnIndex] ?? 0 }
    @objc(unsignedLongLongIntForColumn:) public func long(columnName: String) -> CUnsignedLongLong { return row[columnName] ?? 0 }
    @objc(boolForColumnIndex:) public func bool(columnIndex: Int) -> Bool { return row[columnIndex] ?? false }
    @objc(boolForColumn:) public func bool(columnName: String) -> Bool { return row[columnName] ?? false }
    @objc(doubleForColumnIndex:) public func double(columnIndex: Int) -> Double { return row[columnIndex] ?? 0.0 }
    @objc(doubleForColumn:) public func double(columnName: String) -> Double { return row[columnName] ?? 0.0 }
    @objc(stringForColumnIndex:) public func string(columnIndex: Int) -> String? { return row[columnIndex] }
    @objc(stringForColumn:) public func string(columnName: String) -> String? { return row[columnName] }
    @objc(dataForColumnIndex:) public func data(columnIndex: Int) -> Data? { return row[columnIndex] }
    @objc(dataForColumn:) public func data(columnName: String) -> Data? { return row[columnName] }
    @objc(dataNoCopyForColumnIndex:) public func dataNoCopy(columnIndex: Int) -> Data? { return row.dataNoCopy(atIndex: columnIndex) }
    @objc(dataNoCopyForColumn:) public func dataNoCopy(columnName: String) -> Data? { return row.dataNoCopy(named: columnName) }
    @objc(objectForColumnIndex:) public func object(columnIndex: Int) -> Any? { return row[columnIndex] }
    @objc(objectForColumn:) public func object(columnName: String) -> Any? { return row[columnName] }
    
    @objc public subscript(_ columnIndex: Int) -> Any? { return row[columnIndex] }
    @objc public subscript(_ columnName: String) -> Any? { return row[columnName] }
    
    @objc public var resultDictionary: [String: AnyObject]? {
        switch state {
        case .row(_, let row):
            return Dictionary(
                row.map { ($0, $1.storage.value as AnyObject) },
                uniquingKeysWith: { (left, _) in left }) // keep leftmost value, despite FMDB returns rightmost value: we favor consistency over compatibility here.
        default:
            return nil
        }
    }
}
