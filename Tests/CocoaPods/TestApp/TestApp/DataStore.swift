// This Swift extension to DataStore exposes a GRDB dbQueue to Swift.

import GRDBObjc
import GRDB

extension DataStore {
    static var dbQueue: DatabaseQueue {
        // DataStore.__dbQueue() in Swift is the same as +[DataStore dbQueue]
        // in Objective-C.
        //
        // The double underscore comes from the NS_REFINED_FOR_SWIFT macro which
        // decorates the declaration of +[DataStore dbQueue] in DataStore.h.
        //
        // This macro allows us to free the dbQueue method name so that Swift
        // can refine it as a GRDB database queue.
        return __dbQueue().dbQueue
    }
}
