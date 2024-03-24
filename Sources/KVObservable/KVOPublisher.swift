import Foundation
import Combine

/// A publisher that leverages Key-Value Observing to emit changes of a specific property on an `NSObject`.
///
/// This class encapsulates the logic for observing property changes on `NSObject` subclasses and publishing those changes through a Combine `PassthroughSubject`.
/// It manages the observation lifecycle, ensuring that observations start when the publisher is initialized and stop when it is deallocated.
///
/// - Parameters:
///   - Object: The `NSObject` subclass whose property is being observed.
///   - Value: The type of the property's value.
public final class KVOPublisher<Object: NSObject, Value>: NSObject {
    /// The object whose property is being observed.
    private let object: Object
    
    /// The key path to the property being observed.
    private let keyPath: KeyPath<Object, Value>
    
    /// The observation object for managing the lifecycle of the observation.
    private var observation: NSKeyValueObservation?
    
    /// A `PassthroughSubject` that emits the property's new values.
    public let value = PassthroughSubject<Value, Never>()

    /// Initializes a new publisher for observing changes to a property.
    ///
    /// - Parameters:
    ///   - object: The object whose property is to be observed.
    ///   - keyPath: The key path to the property to observe.
    public init(object: Object, keyPath: KeyPath<Object, Value>) {
        self.object = object
        self.keyPath = keyPath
        super.init()
        resume()
    }

    /// Starts observing the property if not already observing and emits new values through the `value` subject.
    public func resume() {
      guard observation == nil else { return }
      observation = object.observe(keyPath, options: [.new]) { [weak self] _, change in 
        guard let newValue = change.newValue else { return }
        self?.value.send(newValue)
      }
    }

    /// Stops observing the property and cleans up the observation.
    public func pause() {
      observation?.invalidate()
      observation = nil
    }

    /// Ensures the observation is stopped when the instance is deallocated.
    deinit {
        pause()
    }
}

