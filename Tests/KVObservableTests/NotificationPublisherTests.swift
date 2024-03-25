import Combine
@testable import KVObservable
import XCTest

private class MockObject: Equatable {
  let name: String
  init(name: String) {
    self.name = name
  }

  static func == (lhs: MockObject, rhs: MockObject) -> Bool {
    return lhs.name == rhs.name
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(name)
  }
}

final class NotificationPublisherTests: XCTestCase {
  var cancellables: Set<AnyCancellable>!

  override func setUp() {
    super.setUp()
    cancellables = Set<AnyCancellable>()
  }

  override func tearDown() {
    cancellables?.forEach { $0.cancel() }
    cancellables = nil
    super.tearDown()
  }

  func testNotificationPublisherEmitsNotifications() {
    let expectation = self.expectation(description: "NotificationPublisher should emit notification")
    let notificationName = Notification.Name("TestNotificationPublisher")
    var didReceiveNotification = false

    let publisher = NotificationPublisher(notificationName: notificationName)
    publisher.notification.sink { _ in
      didReceiveNotification = true
      expectation.fulfill()
    }.store(in: &cancellables)

    NotificationCenter.default.post(name: notificationName, object: nil)

    waitForExpectations(timeout: 1) { error in
      XCTAssertNil(error, "Notification was not emitted")
      XCTAssertTrue(didReceiveNotification, "NotificationPublisher did not emit the notification")
    }
  }

  func testNotificationPublisherResume() {
    let resumeExpectation = expectation(description: "Notification should be received after resume")
    let notificationName = Notification.Name("TestResumeNotification")
    var notificationCount = 0

    let publisher = NotificationPublisher(notificationName: notificationName)
    publisher.notification.sink { _ in
      notificationCount += 1
      if notificationCount == 2 {
        resumeExpectation.fulfill()
      }
    }.store(in: &cancellables)

    // Pause publisher
    publisher.pause()

    // Post notification once, should not be received because publisher is paused
    NotificationCenter.default.post(name: notificationName, object: nil)
    XCTAssertEqual(notificationCount, 0, "Notification should not be received when paused")

    // Resume and post notification, should be received
    publisher.resume()
    NotificationCenter.default.post(name: notificationName, object: nil)
    XCTAssertEqual(notificationCount, 1, "Notification should be received after resume")

    // Post another notification to fulfill expectation
    NotificationCenter.default.post(name: notificationName, object: nil)

    waitForExpectations(timeout: 1) { error in
      XCTAssertNil(error, "Notification was not received after resume")
    }
  }

  func testNotificationPublisherPause() {
    let pauseExpectation = expectation(description: "Notification should not be received after pause")
    pauseExpectation.isInverted = true // We expect this not to fulfill
    let notificationName = Notification.Name("TestPauseNotification")
    var didReceiveNotification = false

    let publisher = NotificationPublisher(notificationName: notificationName)
    publisher.notification.sink { _ in
      didReceiveNotification = true
      pauseExpectation.fulfill()
    }.store(in: &cancellables)

    // Pause publisher
    publisher.pause()

    // Post notification, should not be received because publisher is paused
    NotificationCenter.default.post(name: notificationName, object: nil)

    waitForExpectations(timeout: 1) { error in
      XCTAssertFalse(didReceiveNotification, "NotificationPublisher did emit the notification despite being paused")
      XCTAssertNil(error, "Notification was emitted when it should not have been")
    }
  }

  func testNotificationPublisherPauseResume() {
    let notificationName = Notification.Name("TestPauseResume")
    var notificationCount = 0

    let publisher = NotificationPublisher(notificationName: notificationName)
    publisher.notification.sink { _ in
      notificationCount += 1
    }.store(in: &cancellables)

    NotificationCenter.default.post(name: notificationName, object: nil)
    XCTAssertEqual(notificationCount, 1, "Should receive notification")

    publisher.pause()
    NotificationCenter.default.post(name: notificationName, object: nil)
    XCTAssertEqual(notificationCount, 1, "Should not receive notification after pause")

    publisher.resume()
    NotificationCenter.default.post(name: notificationName, object: nil)
    XCTAssertEqual(notificationCount, 2, "Should resume receiving notifications")
  }

  func testNotificationPublisherDeinit() {
    let expectation = self.expectation(description: "NotificationPublisher should stop emitting notifications on deinit")
    expectation.isInverted = true
    let notificationName = Notification.Name("TestDeinit")

    var publisher: NotificationPublisher? = NotificationPublisher(notificationName: notificationName)
    publisher?.notification.sink { _ in
      expectation.fulfill()
    }.store(in: &cancellables)

    publisher = nil

    NotificationCenter.default.post(name: notificationName, object: nil)

    waitForExpectations(timeout: 1) { error in
      XCTAssertNil(error, "NotificationPublisher did not deinitialize correctly")
    }
  }

  func testNotificationPublisherReceivesNotificationWithObject() {
    let expectation = self.expectation(description: "NotificationPublisher should receive notification with specific object")
    let notificationName = Notification.Name("TestNotificationWithObject")
    let notificationObject = MockObject(name: "TestObject")
    var didReceiveNotificationForObject = false

    let publisher = NotificationPublisher(notificationName: notificationName)
    publisher.notification.sink { notification in
      if let object = notification.object as? MockObject, object == notificationObject {
        didReceiveNotificationForObject = true
      }
      expectation.fulfill()
    }.store(in: &cancellables)

    NotificationCenter.default.post(name: notificationName, object: notificationObject)

    waitForExpectations(timeout: 1) { error in
      XCTAssertNil(error, "Notification with object was not received")
      XCTAssertTrue(didReceiveNotificationForObject, "NotificationPublisher did not receive the notification with the expected object")
    }
  }

  func testNotificationPublisherReceivesNotificationFromCorrectObject() {
    let expectation = self.expectation(description: "NotificationPublisher should receive notification from correct object")
    let notificationName = Notification.Name("TestNotificationForObject")
    let correctObject = MockObject(name: "CorrectObject")
    var didReceiveNotificationFromCorrectObject = false

    let publisher = NotificationPublisher(notificationName: notificationName, object: correctObject)
    publisher.notification.sink { notification in
      if let object = notification.object as? MockObject, object == correctObject {
        didReceiveNotificationFromCorrectObject = true
      } else {
        didReceiveNotificationFromCorrectObject = false
      }
      expectation.fulfill()
    }.store(in: &cancellables)

    NotificationCenter.default.post(name: notificationName, object: correctObject)

    waitForExpectations(timeout: 3) { error in
      XCTAssertNil(error, "Notification from correct object was not received correctly")
      XCTAssertTrue(didReceiveNotificationFromCorrectObject, "NotificationPublisher did not receive the notification from the correct object")
    }
  }

  func testNotificationPublisherDoesNotReceiveNotificationFromIncorrectObject() {
    let expectation = self.expectation(description: "NotificationPublisher should not receive notification from incorrect object")
    expectation.isInverted = true // Expectation is inverted to ensure that the publisher does not receive the notification
    let notificationName = Notification.Name("TestNotificationForObject")
    let correctObject = MockObject(name: "CorrectObject")
    let incorrectObject = MockObject(name: "IncorrectObject")
    var didReceiveNotificationFromIncorrectObject = false

    let publisher = NotificationPublisher(notificationName: notificationName, object: correctObject)
    publisher.notification.sink { _ in
      didReceiveNotificationFromIncorrectObject = true
      expectation.fulfill()
    }.store(in: &cancellables)

    NotificationCenter.default.post(name: notificationName, object: incorrectObject)

    waitForExpectations(timeout: 1) { error in
      XCTAssertNil(error, "Notification from incorrect object was incorrectly received")
      XCTAssertFalse(didReceiveNotificationFromIncorrectObject, "NotificationPublisher received the notification from the incorrect object")
    }
  }

  func testNotificationPublisherReceivesNotificationWithUserInfo() {
    let expectation = self.expectation(description: "NotificationPublisher should receive notification with userInfo")
    let notificationName = Notification.Name("TestNotificationWithUserInfo")
    let userInfoKey = "TestUserInfoKey"
    let userInfoValue = "TestUserInfoValue"
    var didReceiveNotificationWithUserInfo = false

    let publisher = NotificationPublisher(notificationName: notificationName)
    publisher.notification.sink { notification in
      if let userInfo = notification.userInfo as? [String: String], userInfo[userInfoKey] == userInfoValue {
        didReceiveNotificationWithUserInfo = true
      }
      expectation.fulfill()
    }.store(in: &cancellables)

    NotificationCenter.default.post(name: notificationName, object: nil, userInfo: [userInfoKey: userInfoValue])

    waitForExpectations(timeout: 1) { error in
      XCTAssertNil(error, "Notification with userInfo was not received correctly")
      XCTAssertTrue(didReceiveNotificationWithUserInfo, "NotificationPublisher did not receive the notification with the expected userInfo")
    }
  }
}
