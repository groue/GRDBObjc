import XCTest
import GRDB
import GRDBObjc

class GRDatabaseQueueTests: XCTestCase {

    func testDatabaseQueueIntializer() {
        let dbQueue = DatabaseQueue()
        let grQueue: GRDatabaseQueue = GRDatabaseQueue(dbQueue)
        grQueue.inDatabase { db in
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

    func testGRDatabaseQueueInitializer() throws {
        let grQueue = GRDatabaseQueue()
        let dbQueue: DatabaseQueue = grQueue.dbQueue
        try dbQueue.inDatabase { db in
            try db.execute("CREATE TABLE t(a)")
            try db.execute("INSERT INTO t(a) VALUES (123)")
            let int = try Int.fetchOne(db, "SELECT a FROM T")
            XCTAssertEqual(int, 123)
        }
    }

}
