Release Notes
=============

## 0.7

Released August 21, 2018

- [#2](https://github.com/groue/GRDB.swift/pull/2): Improve support for Swift and Objective-C interlacing
- [#3](https://github.com/groue/GRDB.swift/pull/3): Don't let statements outlive their execution


## 0.6

Released July 8, 2018

### New

- GRDB.swift dependency bumped to `~> 3.1`


## 0.5

Released Septembre 8, 2017

### Fixed

- FMResultSet returns NULL values (nil, 0, 0.0, NO) when asked for a column name that isn't in the row.

### New

- Implemented `-[FMResultSet columnCount]`
- Implemented `-[FMResultSet objectForColumnName:]`


## 0.4

Released September 4, 2017

### New

- Implemented `-[FMDatabase executeQuery:]` (variadic version)
- Implemented `-[FMDatabase executeUpdate:]` (variadic version)
- Implemented `-[FMDatabase executeUpdate:withErrorAndBindings:]`


## 0.3

Released September 3, 2017

### New

- Implemented `-[FMResultSet nextWithError:]`
- Implemented `-[FMDatabase executeStatements:]`

### Fixed

- Errors outputed by GRDBObjc have the some domain and codes as errors outputed by FMDB.


## 0.2

Released September 3, 2017

### Fixed

- Compatibility with FMDB handling of NSData values

## 0.1

Released September 2, 2017

**Initial release**
