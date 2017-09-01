import XCTest
import GRDB
import GRDBObjc

class FMDatabaseQueueTests: GRDBObjcTestCase {

    func testDatabaseQueueIntializer() throws {
        let dbQueue = try DatabaseQueue(path: makeTemporaryDatabasePath())
        let fmdbQueue: FMDatabaseQueue = FMDatabaseQueue(dbQueue)
        fmdbQueue.inDatabase { db in
            db.executeUpdate("CREATE TABLE t(a)")
            db.executeUpdate("INSERT INTO t(a) VALUES (123)")
            guard let resultSet = db.executeQuery("SELECT a FROM T") else {
                XCTFail()
                return
            }
            XCTAssert(resultSet.next())
            XCTAssertEqual(resultSet.int(columnIndex: 0), 123)
        }
    }

    func testFMDatabaseQueueInitializer() throws {
        let fmdbQueue = try FMDatabaseQueue(path: makeTemporaryDatabasePath())
        let dbQueue: DatabaseQueue = fmdbQueue.dbQueue
        try dbQueue.inDatabase { db in
            try db.execute("CREATE TABLE t(a)")
            try db.execute("INSERT INTO t(a) VALUES (123)")
            let int = try Int.fetchOne(db, "SELECT a FROM T")
            XCTAssertEqual(int, 123)
        }
    }

}
