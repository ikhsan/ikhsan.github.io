//
//  Created by Ikhsan Assaat on 26/03/2017.
//  Copyright © 2017 ikhsan. All rights reserved.
//

import Foundation

class Counter: NSObject {
    var count: Int = 0
    var timer: Timer? = nil
    let notificationCenter = NotificationCenter.default

    static let `default` = Counter()

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: updateCounter)
    }

    func stop() {
        timer?.invalidate()
    }

    func updateCounter(_ timer: Timer) {
        count += 1
        print("counter : \(count)")

        // post
        let notif = CounterDidChangeNotification(count)
        notificationCenter.post(notifiable: notif)
    }
}
