import GRDB

extension StatementArguments {
    init(lossless values: [Any]) {
        var convertedValues = [DatabaseValueConvertible?]()
        for value in values {
            guard let dbValue = DatabaseValue(value: value) else {
                fatalError("\(String(reflecting: value)) is not a valid database value")
            }
            convertedValues.append(dbValue)
        }
        self.init(convertedValues)
    }
}
