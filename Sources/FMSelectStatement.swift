import GRDB

@objc public class FMSelectStatement : NSObject {
    private let db: FMDatabase
    private let statement: SelectStatement
    
    @objc public var sqliteHandle: OpaquePointer {
        return statement.sqliteStatement
    }
    
    init(database: FMDatabase, statement: SelectStatement) {
        self.db = database
        self.statement = statement
    }
    
    // TODO: is it FMDB API? Shouldn't values be optional, then?
    @objc public func execute(values: [Any]) throws -> FMResultSet {
        do {
            let cursor = try Row.fetchCursor(statement, arguments: db.statementArguments(from: values))
            return FMResultSet(database: db, cursor: cursor)
        } catch {
            throw db.handleError(error)
        }
    }
}
