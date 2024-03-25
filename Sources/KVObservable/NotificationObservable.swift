import Foundation

/// A class that observes notifications for a specific `NSNotification.Name`.
///
/// This class simplifies the process of observing notifications by encapsulating the setup and teardown logic required to observe notifications with `NotificationCenter`.
/// It allows for pausing and resuming observation as needed.
public final class NotificationObservable {
  /// The name of the notification to observe.
  private let name: NSNotification.Name
  
  /// The object to observe. If `nil`, the notification center doesn’t use the notification’s sender to decide whether to deliver it to the observer.
  private let object: Any?
  
  /// The queue on which to execute the `onNotify` closure. If `nil`, the block is run synchronously on the posting thread.
  private let queue: OperationQueue
  
  /// The closure to execute when the notification is observed.
  private let onNotify: (Notification) -> Void
  
  /// The observation token returned by `NotificationCenter`, used to unregister as an observer.
  private var observation: NSObjectProtocol?

  /// Initializes a new `NotificationObservable`.
  ///
  /// - Parameters:
  ///   - name: The name of the notification to observe.
  ///   - object: The object whose notifications the observer wants to receive; that is, only notifications sent by this sender are delivered to the observer.
  ///   - queue: The operation queue to which `onNotify` should be added.
  ///   - onNotify: The closure to execute when the notification is observed.
  public init(name: NSNotification.Name, object: Any? = nil, queue: OperationQueue = .main, onNotify: @escaping (Notification) -> Void) {
    self.name = name
    self.object = object
    self.queue = queue
    self.onNotify = onNotify
    resume()
  }

  /// Starts or resumes observation of the notification.
  public func resume() {
    guard observation == nil else { return }
    observation = NotificationCenter.default.addObserver(forName: name, object: object, queue: queue) { [weak self] notification in 
      self?.onNotify(notification)
    }
  }

  /// Pauses observation of the notification.
  public func pause() {
    if let observation = observation {
      NotificationCenter.default.removeObserver(observation)
    }
    observation = nil
  }

  /// Stops observation upon deinitialization.
  deinit {
    pause()
  }
}

