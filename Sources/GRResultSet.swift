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
    
    @objc(intForColumnIndex:) public func int(columnIndex: Int) -> CInt {
        return row[columnIndex] ?? 0
    }
}
