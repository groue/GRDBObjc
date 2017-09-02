// ViewController accesses the database using GRDB APIs.

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let text = try AppDatabase.dbQueue.inDatabase { db in
                try String.fetchOne(db, "SELECT text FROM demo")
            }
            statusLabel.text = text ?? "NOT OK"
        } catch {
            statusLabel.text = "NOT OK"
        }
    }
}
