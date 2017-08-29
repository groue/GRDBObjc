import GRDB

extension StatementArguments {
    init(lossless values: [Any]) {
        let values = values.map { value -> DatabaseValue in
            guard let dbValue = DatabaseValue(value: value) else {
                fatalError("\(String(reflecting: value)) is not a valid database value")
            }
            return dbValue
        }
        self.init(values)
    }

    init(lossless dictionary: [String: Any]) {
        let dictionary = dictionary.mapValues { value -> DatabaseValue in
            guard let dbValue = DatabaseValue(value: value) else {
                fatalError("\(String(reflecting: value)) is not a valid database value")
            }
            return dbValue
        }
        self.init(dictionary)
    }
}
