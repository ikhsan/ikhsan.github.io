---
title: Harder, Better, Faster, Stronger Notification
date: 2017-03-26 11:55 UTC
tags: notification, objective-c, swift
---

At work, we are rethinking ways to communicate changes from our models. The changes should be propagated to all interested classes. This sounds like the perfect use case for introducing new reactive libraries, but this is not an article on how to use fantastic reactive libraries. Instead, let me reintroduce to our old friends, `Notification` and `NotificationCenter`. READMORE

## Requirements

In this article, I will share the requirements and my current design of the better version of `Notification`. Note that this is only for custom notifications. Supporting `UIKit`'s notifications is out of this article's scope.

![harder_better](blog/2017-03-26-harder-better-faster-stronger-notification/harder_better.jpg "Harder better faster stronger")

* __Harder__ to make mistakes. No use for stringly-typed notification names.
* __Better__ compatibility with Objective-C. Our app is almost 5 year-old, it is important to keep it compatible with our old Objective-C classes.
* __Faster__ creation of posts and observers. Posting and observing changes should be fast and easy.
* __Stronger__ types. `Notification` has poor type information, you can put any class (or not) as the `object` and put any dictionary as its `userInfo`. Let's make a safer version with more type information.

_I know, these requirements was a bit forced. I made it up just to make my Daft Punk reference relevant._

## 1st Design: Swift Talk's design

My starting point was heavily based on someone's work. Chris and Florian from [Swift Talk](https://talk.objc.io) fame have [great](https://talk.objc.io/episodes/S01E27-typed-notifications-part-1) [screencasts](https://talk.objc.io/episodes/S01E28-typed-notifications-part-2) (which you all should [subscribe](https://talk.objc.io/subscribe)!) that teach viewers how to wrap `Notification` using protocols. The basic idea is that the protocol will require notification name and the object itself will be assigned as `Notification` object property.

```swift

// MARK: Design I
protocol Notifiable {
    static var notificationName: Notification.Name { get }
}

extension NotificationCenter {
    func post<A: Notifiable>(notifiable: A) {
        post(name: A.notificationName, object: notifiable)
    }

    func observe<A: Notifiable>(using block: @escaping (A) -> Void) -> NSObjectProtocol {
        return addObserver(forName: A.notificationName, object: nil, queue: nil) {
            notification in
            if let notif = notification.object as? A {
                block(notif)
            }
        }
    }
}
```

Let's make a simple example to explain its design and why it is better than `Notification`'s API. Supposed that we have global counter in our app and we want to get the latest changes of our counter. We will make custom notification class called `CounterDidChangeNotification` that conforms to `Notifiable` protocol. We use class instead of struct because it will be used by Objective-C classes. Don't forget to [use good names for your notification](/blog/en/how-to-name-your-notification.html).

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

Our `Notification`s interface are more-typed and safer to `Foundation`'s. When posting in using `Foundation`'s interface (`post(name:object:)`), it needs its name to be manually put and its object can can be any type or even nil. Observing in `Foundation` is similarly tedious, it needs its name and then the block should process its `Notification` instance. The important info might be inside `object` or might be values inside `userInfo`.

In our current design, when posting we just need to make a `Notifiable` instance and then post it. We don't need to care about naming or how to wrap the object. Moreover, observing feels almost magical since we only need to give information of the instance inside the block. Swift can derive which `Notifiable` instance the method is listening by looking at the type (in our case, it's `{ (notification: CounterDidChangeNotification) in ... }`). The names and how to unwrap the object will be taken care by our method.

Very neat![^1] 👏👏

## 2nd Design: Auto-naming

We can take the 1st design up a notch by deriving the name from the class name using protocol extension.

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

Now our `CounterDidChangeNotification` is simpler, we can start posting it just by conforming to `Notifiable` protocol.

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

Now it's even easier to post notification class, great! 👍

![great](blog/2017-03-26-harder-better-faster-stronger-notification/dp.gif "great")

## 3rd Design: Needy old friend

Here comes the harder parts: Objective-C. Let's see our `NotificationCenter` extension inside our generated header file.

```objc
@interface NSNotificationCenter (SWIFT_EXTENSION(Notification))
@end
```

Can you see any of our extension methods? Exactly! Objective-C can't understand Swift's protocol extensions and generic methods. So how do we make our methods compatible to Objective-C classes?

Firstly, we can make our `Notifiable` protocol to be a base class so that it will share its dynamic notification naming.

Making your code compatible with Objective-C can sometimes feel like your going backwards. You might often heard that "Don't use subclass if you don't want magic behaviours, use protocol extension all the way, etc". Subclassing is fine, nothing bad about using it. Subclassing is a great tool especially in our case because we care about compatibility and only have one level of subclassing.

```swift
// MARK: Design III
class Notifiable: NSObject {
    static var notificationName: Notification.Name {
        return Notification.Name(String(describing: self))
    }
}
```

Next step, we make our `post` method compatible with Objective-C. Let's ditch the generics and use our new `Notifiable` base class. The other method `observe` is trickier. Because Objective-C's generic support is limited, we pass the class' type as a parameter and use that to check `Notification`'s object. This interface is not as typed as its Swift's counterparts, but at least it is safe because the block won't get called with incorrect object.

It works like an immigration officer, they compare visitor's visa and the current country, then allow them to pass the border if visitor has the correct visa. Similarly, we compare the name of `Notification`'s object and the passed class's name from the parameter, then allow the object by passing it through the block if both has the same name.


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

Last step, use our method extension by passing the class that we're interested in and force cast the `id` to that same class. Look closely on two appearances of `CounterDidChangeNotification`, one as parameter and one as the type inside the block.

```objc
// MARK: Design III's call site
[self.notificationCenter
    observeWithClassType:CounterDidChangeNotification.class
    using:^(CounterDidChangeNotification *notification) {
    NSLog(@"latest count %ld", (long)notification.count) // will print "latest count 10"
}];
```

Great! We have compatible interfaces to post and observe in both languages 🙌 I'm pretty happy on this current design. There are gotchas that I would like remove but I don't know how. Let me know if you have more techniques to make `Notification` better to create and use. Rock on!

To see it in action, I made a sample app that use this `Notification` design if needed: __Notification sample__ ([zip](2017-03-26-harder-better-faster-stronger-notification/Notification.zip), [github](https://github.com/ikhsan/ikhsan.github.io/tree/develop/source/blog/2017-03-26-harder-better-faster-stronger-notification/Notification/Notification)).

---

## Gotchas

There are still 2 gotchas that I can't solve.

### Compiler allows to pass all classes inside observe method

The compiler can't detect whether the class type is a subclass of `Notifiable` class or not. Although, the type of the class has been specified as `Notifiable.Type` but it is translated only as a `Class`. (Actually, it's `SWIFT_METATYPE(Notifiable)` which is a macro that translates into `Class`). So, that parameter can accept all classes like `NSString.class` or `NSData.class` without making the compiler complain.

Is there a way to make compiler stricter by only allowing `Notifiable` class types?

### Using string comparison is not really ideal, in objective-c it's easier

The way that I compare classes is by comparing via `String`'s `describing:` init method. In Objective-C, I know I can just check classes by using `isKindOfClass:`

```objc
- (id <NSObject>)observeWithClassType:(Class)classType using:(void (^)(id notification))block {
    // ...

    if ([notificationObject isKindOfClass:classType]) {
        // ...
    }
}
```

The same checks can't be done in Swift.

```swift
func observe(classType: Notifiable.Type, using block: @escaping (Any) -> ()) -> NSObjectProtocol {
    // ...

    // Got "use of undeclared type 'classType'" error
    if (notificationObject is classType) {
        // ...
    }
}
```

I'm fine using current comparison with `String`s, but I think it would be more ideal to check class types using Swift's `is`. Is this feasible in Swift?

[^1]: That is their synchronised clapping as emoji
