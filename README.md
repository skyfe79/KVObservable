# KVObservable

KVObservable is a Swift package that provides observable and publisher classes leveraging Key-Value Observing (KVO) and NotificationCenter for monitoring changes to properties on `NSObject` subclasses and system-wide notifications. It simplifies observing property changes and notifications by managing the observation lifecycle automatically.

## Features

- **KVObservable**: An observable class for monitoring changes to a specific property.
- **KVOPublisher**: A publisher class that emits changes of a specific property through Combine's `PassthroughSubject`.
- **NotificationObservable**: A class for observing notifications for a specific `NSNotification.Name`.
- **NotificationPublisher**: A publisher class that observes notifications and publishes those through a Combine `PassthroughSubject`.

## Requirements

- iOS 13.0+ / macOS 10.15+ / watchOS 8.0+ / tvOS 13.0+ / macCatalyst 13.0+ / visionOS 1.0+

## Installation

Add the package to your project by adding the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/skyfe79/KVObservable.git", .upToNextMajor(from: "0.0.3"))
]
```

## Usage

### KVObservable

Monitor changes to a property:

```swift
let observable = KVObservable(object: yourNSObject, keyPath: \.yourProperty) { newValue in
    print("New value: \(newValue)")
}
```

Pause and resume observation:

```swift
observable.pause()
observable.resume()
```

### KVOPublisher

Use `KVOPublisher` to integrate with Combine:

```swift
let publisher = KVOPublisher(object: yourNSObject, keyPath: \.yourProperty)
publisher.value.sink { newValue in
    print("New value: \(newValue)")
}.store(in: &cancellables)
```

Pause and resume observation:

```swift
publisher.pause()
publisher.resume()
```

### NotificationObservable

Observe notifications for a specific `NSNotification.Name`:

```swift
let notificationObservable = NotificationObservable(name: .yourNotificationName, object: nil, queue: .main) { notification in
    print("Notification received: \(notification)")
}

// To pause and resume observation
notificationObservable.pause()
notificationObservable.resume()
```

### NotificationPublisher

Use `NotificationPublisher` to observe notifications and publish those through Combine:

```swift
let notificationPublisher = NotificationPublisher(notificationName: .yourNotificationName, object: nil, queue: .main)

notificationPublisher.notification.sink { notification in
    print("Notification received: \(notification)")
}.store(in: &cancellables)

// To pause and resume observation
notificationPublisher.pause()
notificationPublisher.resume()
```

## License

KVObservable is released under the MIT license. See LICENSE for details.