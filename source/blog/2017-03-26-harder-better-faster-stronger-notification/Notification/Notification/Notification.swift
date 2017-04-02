//
//  Created by Ikhsan Assaat on 26/03/2017.
//  Copyright © 2017 ikhsan. All rights reserved.
//

import Foundation

class Notifiable: NSObject {
    static var notificationName: Notification.Name {
        let className = String(describing: self)
        return Notification.Name(className)
    }
}

extension NotificationCenter {
    func post(notifiable: Notifiable) {
        post(name: type(of: notifiable).notificationName, object: notifiable)
    }

    func observe<A: Notifiable>(using block: @escaping (A) -> ()) -> NSObjectProtocol {
        return addObserver(forName: A.notificationName, object: nil, queue: nil) { notification in
            if let notif = notification.object as? A {
                block(notif)
            }
        }
    }

    func observe(classType: Notifiable.Type, using block: @escaping (Any) -> ()) -> NSObjectProtocol {
        return addObserver(forName: classType.notificationName, object: nil, queue: nil) { notification in
            guard let notificationObject = notification.object else { return }
            let expectedType = String(describing: classType)
            let type = String(describing: type(of: notificationObject))
            if expectedType == type  {
                block(notificationObject)
            }
        }
    }
}


final class CounterDidChangeNotification: Notifiable {
    let count: Int

    init(_ count: Int) {
        self.count = count
        super.init()
    }
}
