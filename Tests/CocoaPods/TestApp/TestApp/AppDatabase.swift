// This Swift extension to AppDatabase exposes a GRDB dbQueue to Swift.

import GRDBObjc
import GRDB

extension AppDatabase {
    static var dbQueue: DatabaseQueue {
        // AppDatabase.__dbQueue() in Swift is the same as +[AppDatabase dbQueue]
        // in Objective-C.
        //
        // The double underscore comes from the NS_REFINED_FOR_SWIFT macro which
        // decorates the declaration of +[AppDatabase dbQueue] in AppDatabase.h.
        //
        // This macro allows us to free the dbQueue method name so that Swift
        // can refine it as a GRDB database queue.
        return __dbQueue().dbQueue
    }
}
