import Combine
import Foundation

/// I know there is a NotificationCenter.default.publisher(for:object:) but I make this for some reason.
///
///
/// A publisher that observes notifications for a specific `NSNotification.Name`.
///
/// This class encapsulates the logic for observing notifications and publishing those through a Combine `PassthroughSubject`.
/// It manages the observation lifecycle, ensuring that observations start when the publisher is initialized and stop when it is deallocated.
public final class NotificationPublisher {
  /// The name of the notification to observe.
  private let notificationName: Notification.Name

  /// The object whose notifications to observe. If `nil`, all notifications with the specified name are observed.
  private let object: Any?

  /// The operation queue on which notification handling is executed.
  private let queue: OperationQueue

  /// The observation token returned by `NotificationCenter`, used to unregister as an observer.
  private var observation: NSObjectProtocol?

  /// A `PassthroughSubject` that emits observed notifications.
  public let notification = PassthroughSubject<Notification, Never>()

  /// Initializes a new publisher for observing notifications.
  ///
  /// - Parameters:
  ///   - notificationName: The name of the notification to observe.
  ///   - object: The object whose notifications to observe; that is, only notifications sent by this sender are delivered to the observer.
  ///   - queue: The operation queue on which notification handling should be executed.
  public init(notificationName: Notification.Name, object: Any? = nil, queue: OperationQueue = .main) {
    self.notificationName = notificationName
    self.object = object
    self.queue = queue
    resume()
  }

  /// Starts or resumes observation of the notification.
  public func resume() {
    guard observation == nil else { return }
    observation = NotificationCenter.default.addObserver(forName: notificationName, object: object, queue: queue) { [weak self] noti in
      self?.notification.send(noti)
    }
  }

  /// Pauses observation of the notification.
  public func pause() {
    if let observation = observation {
      NotificationCenter.default.removeObserver(observation)
    }
    observation = nil
  }

  /// Ensures the observation is stopped when the instance is deallocated.
  deinit {
    pause()
  }
}
