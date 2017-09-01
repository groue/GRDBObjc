import GRDB

@objc public class GRUpdateStatement : NSObject {
    private let db: GRDatabase
    private let statement: UpdateStatement
    
    @objc public var sqliteHandle: OpaquePointer {
        return statement.sqliteStatement
    }
    
    init(database: GRDatabase, statement: UpdateStatement) {
        self.db = database
        self.statement = statement
    }
    
    // TODO: is it FMDB API? Shouldn't values be optional, then?
    @objc public func execute(values: [Any]) throws {
        do {
            try statement.execute(arguments: db.statementArguments(from: values))
        } catch {
            db.handleError(error)
            throw error
        }
    }
}
