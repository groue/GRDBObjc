import GRDB

@objc public class GRUpdateStatement : NSObject {
    let statement: UpdateStatement
    
    @objc public var sqliteHandle: OpaquePointer {
        return statement.sqliteStatement
    }
    
    init(statement: UpdateStatement) {
        self.statement = statement
    }
    
    @objc public func execute(values: [Any]) throws {
        try statement.execute(arguments: StatementArguments(lossless: values))
    }
}
