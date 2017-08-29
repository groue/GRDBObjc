import GRDB

@objc public class GRResultSet : NSObject {
    let cursor: RowCursor
    var row: Row?
    
    init(cursor: RowCursor) {
        self.cursor = cursor
        self.row = nil
    }
    
    @objc public func next() -> Bool {
        do {
            if let fetchedRow = try cursor.next() {
                row = fetchedRow
                return true
            } else {
                row = nil
                return false
            }
        } catch {
            // TODO: handle error
            return false
        }
    }
    
    @objc(intForColumnIndex:) public func int(columnIndex: Int) -> CInt {
        guard let row = row else {
            fatalError("-[GRResultSet next] has to be called before accessing fetched results")
        }
        return row[columnIndex]
    }
}
