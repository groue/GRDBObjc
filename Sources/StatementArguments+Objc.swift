import GRDB

extension StatementArguments {
    init(lossless values: [Any]) throws {
        let values = try values.map { value -> DatabaseValue in
            guard let dbValue = DatabaseValue(value: value) else {
                throw DatabaseError(resultCode: .SQLITE_MISUSE, message: "\(String(reflecting: value)) is not a valid database value")
            }
            return dbValue
        }
        self.init(values)
    }

    init(lossless dictionary: [String: Any]) throws {
        let dictionary = try dictionary.mapValues { value -> DatabaseValue in
            guard let dbValue = DatabaseValue(value: value) else {
                throw DatabaseError(resultCode: .SQLITE_MISUSE, message: "\(String(reflecting: value)) is not a valid database value")
            }
            return dbValue
        }
        self.init(dictionary)
    }
}
