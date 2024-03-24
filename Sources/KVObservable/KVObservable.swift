import Foundation

/// An observable class that leverages Key-Value Observing to monitor changes.
///
/// This class provides a way to observe property changes of `NSObject` subclasses.
/// It automatically manages the observation lifecycle to start and stop observing based on the object's lifecycle.
///
/// - Parameters:
///   - Object: The `NSObject` subclass being observed.
///   - Value: The type of the value being observed.
public final class KVObservable<Object: NSObject, Value>: NSObject {
    /// The object being observed.
    private let object: Object
    
    /// The key path of the property being observed.
    private let keyPath: KeyPath<Object, Value>
    
    /// The closure to call when a change is observed.
    private let onChange: (Value) -> Void
    
    /// The observation object for managing the lifecycle of the observation.
    private var observation: NSKeyValueObservation?

    /// Initializes a new observable object.
    ///
    /// - Parameters:
    ///   - object: The object to observe.
    ///   - keyPath: The key path of the property to observe.
    ///   - onChange: A closure to call when the property value changes.
    public init(object: Object, keyPath: KeyPath<Object, Value>, onChange: @escaping (Value) -> Void) {
        self.object = object
        self.keyPath = keyPath
        self.onChange = onChange
        super.init()
        resume()
    }

    /// Starts observing the property if not already observing.
    public func resume() {
      guard observation == nil else { return }
      observation = object.observe(keyPath, options: [.new]) { [weak self] _, change in 
        guard let newValue = change.newValue else { return }
        self?.onChange(newValue)
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
