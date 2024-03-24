# KVObservable

KVObservable is a Swift package that provides observable and publisher classes leveraging Key-Value Observing (KVO) for monitoring changes to properties on `NSObject` subclasses. It simplifies observing property changes by managing the observation lifecycle automatically.

## Features

- **KVObservable**: An observable class for monitoring changes to a specific property.
- **KVOPublisher**: A publisher class that emits changes of a specific property through Combine's `PassthroughSubject`.

## Requirements

- iOS 13.0+ / macOS 10.15+ / watchOS 8.0+ / tvOS 13.0+ / macCatalyst 13.0+ / visionOS 1.0+

## Installation

Add the package to your project by adding the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/skyfe79/KVObservable.git", .upToNextMajor(from: "0.0.1"))
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

## License

KVObservable is released under the MIT license. See LICENSE for details.
