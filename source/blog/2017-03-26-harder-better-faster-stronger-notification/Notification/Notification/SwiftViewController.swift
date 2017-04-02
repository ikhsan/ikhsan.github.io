//
//  Created by Ikhsan Assaat on 26/03/2017.
//  Copyright © 2017 ikhsan. All rights reserved.
//

import UIKit

class SwiftViewController: UIViewController {

    var token: NSObjectProtocol? = nil
    let center = NotificationCenter.default
    var count = 0

    @IBOutlet weak var counterLabel: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        count = Counter.default.count
        render()

        token = center.observe { [weak self] (notif: CounterDidChangeNotification) in
            self?.count = notif.count
            self?.render()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let token = token {
            center.removeObserver(token)
        }
    }

    func render() {
        counterLabel.text = "\(count)"
    }

}
