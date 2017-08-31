import XCTest
import GRDB
import GRDBObjc

class GRDatabaseQueueTests: XCTestCase {

    func testDatabaseQueueIntializer() {
        let dbQueue = DatabaseQueue()
        let grQueue: GRDatabaseQueue = GRDatabaseQueue(dbQueue)
    }

    func testGRDatabaseQueueInitializer() {
        let grQueue = GRDatabaseQueue()
        let dbQueue: DatabaseQueue = grQueue.dbQueue
    }

}
