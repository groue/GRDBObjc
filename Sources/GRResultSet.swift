import GRDB

@objc public class GRResultSet : NSObject {
    private let cursor: RowCursor
    private enum State {
        case initialized
        case row(Row)
        case ended
        case error(Error)
    }
    private var state = State.initialized
    private var row: Row {
        switch state {
        case .initialized: fatalError("-[GRResultSet next] has to be called before accessing fetched results")
        case .row(let row): return row
        case .ended: fatalError("GRResultSet has been fully consumed")
        case .error(let error): fatalError("GRResultSet had an error: \(error)")
        }
    }

    init(cursor: RowCursor) {
        self.cursor = cursor
    }
    
    @objc public func next() -> Bool {
        switch state {
        case .initialized, .row:
            do {
                if let row = try cursor.next() {
                    state = .row(row)
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
    
    @objc(intForColumnIndex:) public func int(columnIndex: Int) -> CInt { return row[columnIndex] ?? 0 }
    @objc(intForColumn:) public func int(column: String) -> CInt { return row[column] ?? 0 }
    @objc(longForColumnIndex:) public func long(columnIndex: Int) -> CLong { return row[columnIndex] ?? 0 }
    @objc(longForColumn:) public func long(column: String) -> CLong { return row[column] ?? 0 }
    @objc(longLongIntForColumnIndex:) public func long(columnIndex: Int) -> CLongLong { return row[columnIndex] ?? 0 }
    @objc(longLongIntForColumn:) public func long(column: String) -> CLongLong { return row[column] ?? 0 }
    @objc(unsignedLongLongIntForColumnIndex:) public func long(columnIndex: Int) -> CUnsignedLongLong { return row[columnIndex] ?? 0 }
    @objc(unsignedLongLongIntForColumn:) public func long(column: String) -> CUnsignedLongLong { return row[column] ?? 0 }
    @objc(boolForColumnIndex:) public func bool(columnIndex: Int) -> Bool { return row[columnIndex] ?? false }
    @objc(boolForColumn:) public func bool(column: String) -> Bool { return row[column] ?? false }
    @objc(doubleForColumnIndex:) public func double(columnIndex: Int) -> Double { return row[columnIndex] ?? 0.0 }
    @objc(doubleForColumn:) public func double(column: String) -> Double { return row[column] ?? 0.0 }
    @objc(stringForColumnIndex:) public func string(columnIndex: Int) -> String? { return row[columnIndex] }
    @objc(stringForColumn:) public func string(column: String) -> String? { return row[column] }
    @objc(dataForColumnIndex:) public func data(columnIndex: Int) -> Data? { return row[columnIndex] }
    @objc(dataForColumn:) public func data(column: String) -> Data? { return row[column] }
    @objc(objectForColumnIndex:) public func object(columnIndex: Int) -> Any? { return row[columnIndex] }
    @objc(objectForColumn:) public func object(column: String) -> Any? { return row[column] }
}
