---
title: Harder, Better, Faster, Stronger Notification
date: 2017-03-26 11:55 UTC
tags: notification, objective-c, swift
---

At work, we are rethinking the way to communicate our models' changes. The changes in our model should be propagated to all interested classes. This sounds like the perfect use case for introducing new reactive libraries, but.. this is not another articles about how to use any of the fantastic reactive libraries. Instead, let me introduce our old friends, `Notification` and `NotificationCenter`. READMORE

## Requirements

In this article, I will share the requirements and my current design of the better version of `Notification`. Note that this is only for custom notifications. Supporting `UIKit`'s and other Apple SDK's notifications is out of this article's scope.

![harder_better](blog/2017-03-26-harder-better-faster-stronger-notification/harder_better.jpg "Harder better faster stronger")

* __'Harder' to make mistakes__. No use for stringly-typed notification names. Typo free!
* __'Better' compatibility with Objective-C__. Our app is almost 5 year-old, it is important to keep it compatible with Objective-C.
* __'Faster' creation of posts and observers__. Posting and observing changes should be fast and easy.
* __'Stronger' types__. `Notification` has poor type information, you can put any class (or not) as the `object` and put any dictionary as its `userInfo`. Let's make a safer version with more type information.

I know, these requirements was a bit forced. I made it up just to make Daft Punk reference relevant.

## 1st Design: Swift Talk 👏👏

My starting point was heavily based on someone's work. Chris and Florian from Swift Talk fame have great screencasts (which you all should subscribe!) that teach me how to wrap `Notification` using protocols. The basic idea is that the protocol will give us the notification name, and the object itself will be assigned as `Notification` object property.

```swift

// MARK: Design I
protocol Notifiable {
    static var notificationName: Notification.Name { get }
}

extension NotificationCenter {
    func post<A: Notifiable>(notifiable: A) {
        post(name: A.notificationName, object: notifiable)
    }

    func observe<A: Notifiable>(using block: @escaping (A) -> ()) -> NSObjectProtocol {
        return addObserver(forName: A.notificationName, object: nil, queue: nil) {
            notification in
            if let notif = notification.object as? A { block(notif) }
        }
    }
}
```

Let's make a simple example to explain the design and its improvement better. Supposed that we have global counter in our app and we want to get the latest changes of our counter. We will make custom notification class called `CounterDidChangeNotification` that conforms to `Notifiable` protocol. We use class from the get go because we know that in the end it will be used by an Objective-C class. Don't forget to [use good names for your notification](/blog/en/how-to-name-your-notification.html).

```swift

// MARK: Design I's call site
final class CounterDidChangeNotification: NSObject {
    let count: Int
    init(_ count: Int) {
        self.count = count
        super.init()
    }
}

extension CounterDidChangeNotification: Notifiable {
    static var notificationName: Notification.Name {
        return Notification.Name(rawValue: "CounterDidChangeNotification")
    }
}

// MARK: Post and observe 'CounterDidChangeNotification'
notificationCenter.post(CounterDidChangeNotification(10))

notificationCenter.observe { (notification: CounterDidChangeNotification) in
    print("latest count \(notification.count)") // will print "latest count 10"
}
```

## 2nd Design: Auto-naming

This is all good but we can take it up a notch by deriving the name from the class name using protocol extension.

```swift
// MARK: Design II
protocol Notifiable {
    static var notificationName: Notification.Name { get }
}

extension Notifiable {
    static var notificationName: Notification.Name {
        return Notification.Name(String(describing: self))
    }
}
```

Our notification class won't need to give an explicit name anymore because it will use default implementation by using the class name as its notification name. Note that you can still override the implementation and give explicit name if needed.

Now our `CounterDidChangeNotification` is simpler:

```swift
// MARK: Design II's call site
final class CounterDidChangeNotification: NSObject, Notifiable {
    let count: Int

    init(_ count: Int) {
        self.count = count
        super.init()
    }
}
```

## 3rd Design: Needy old friend

Here comes the harder parts: Objective-C. Let's see our `NotificationCenter` extension inside our generated header file.

```objc
@interface NSNotificationCenter (SWIFT_EXTENSION(Notification))
@end
```

Can you see any of our methods? Exactly! Objective-C can't understand swift protocol and generic methods.

First step, we can make our `Notifiable` protocol to be a base class so that it will share its dynamic notification naming.

Making your code compatible with Objective-C can sometimes feel like your going backwards. You might heard that "Don't use subclass if you don't want magic behaviours, use new hotness protocol all the way, etc". Subclassing is totally fine, don't feel bad about using it. Subclassing is still a great tool especially in our case because we won't need complicated subclass hierarchy.

```swift
// MARK: Design III
class Notifiable: NSObject {
    static var notificationName: Notification.Name {
        return Notification.Name(String(describing: self))
    }
}
```

Next, we make our `post` method compatible with Objective-C. Let's ditch the generics and use our new `Notifiable` base class. The other method `observe` is trickier. Because Objective-C's generic support is limited, we pass the class as parameter and use that to check `Notification`'s object.
It works like an immigration officer, they compare visitor's visa and current country, then allow them to pass the border gate if visitor has the correct visa. Similarly, we compare the name of `Notification`'s object and the passed class's name from the parameter, then allow the object by passing it the block if both has the same name. The limitation makes the interface not as safe as its Swift's counterparts, but at least it is safe because block won't get called when having incorrect object.

```swift
// MARK: Design III continued
func post(notifiable: Notifiable) {
    post(name: type(of: notifiable).notificationName, object: notifiable)
}

func observe(classType: Notifiable.Type, using block: @escaping (Any) -> ()) -> NSObjectProtocol {
    return addObserver(forName: classType.notificationName, object: nil, queue: nil) {
        notification in

        guard let notificationObject = notification.object else { return }
        let expectedType = String(describing: classType)
        let type = String(describing: type(of: notificationObject))
        if expectedType == type  {
            block(notificationObject)
        }
    }
}
```

Now let's look back to our generated headers again, now we should see our methods in `NotificationCenter` extension!

```objc
@interface NSNotificationCenter (SWIFT_EXTENSION(Notification))
- (void)postWithNotifiable:(Notifiable * )notifiable;
- (id <NSObject>)observeWithClassType:(SWIFT_METATYPE(Notifiable))classType using:(void (^)(id))block;
@end
```

To use it, pass the class that we're interested in and force cast the `id` to the same class.

```objc
// MARK: Design III's call site
[self.notificationCenter
    observeWithClassType:CounterDidChangeNotification.class
    using:^(CounterDidChangeNotification *notification) {
    NSLog(@"latest count %ld", (long)notification.count); // will print "latest count 10"
}];
```

Great! We have compatible interfaces to post and observe in both languages 🙌

I made a sample app that use this design if needed: Notification sample.

## Gotchas

* Compiler allows to pass all classes inside observe method
* Using string comparison is not really ideal, in objective-c it's easier

```objc
if ([note.object isKindOfClass:PayloadClass]) {
    block(note.object);
}
```
